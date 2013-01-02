package Hubot::Adapter::Irc;
use Moose;
use namespace::autoclean;

extends 'Hubot::Adapter';

use AnyEvent;
use AnyEvent::IRC::Client;
use Time::HiRes 'time';
use Encode qw/encode_utf8 decode_utf8/;

use Hubot::Message;

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot',
);

has 'cv' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'irc' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_cv  { AnyEvent->condvar }
sub _build_irc { AnyEvent::IRC::Client->new }

sub notice { }

sub join {
    my ( $self, $channel ) = @_;
    $self->irc->send_srv( JOIN => $channel );
}
sub part    { }
sub kick    { }
sub command { }

sub whois {
    my ( $self, $nick ) = @_;
    return $self->irc->nick_ident($nick);
}

sub parse_msg {
    my ( $self, $irc_msg ) = @_;

    my ($nickname) = $irc_msg->{prefix} =~ m/^([^!]+)/;
    my $message = decode_utf8( $irc_msg->{params}[1] );
    return ( $nickname, $message );
}

sub send {
    my ( $self, $user, @strings ) = @_;
    for my $str (@strings) {
        $self->irc->send_srv( 'PRIVMSG', $user->{room}, encode_utf8($str) );
        Time::HiRes::sleep(0.1);
    }
}

sub whisper {
    my ( $self, $user, $to, @strings ) = @_;
    $self->irc->send_srv( 'PRIVMSG', $to->{name}, encode_utf8($_) )
      for @strings;
}

sub reply {
    my ( $self, $user, @strings ) = @_;
    @strings = map { $user->{name} . ": $_" } @strings;
    $self->send( $user, @strings );
}

sub run {
    my $self = shift;

    $self->checkCanStart;

    my %options = (
        nick => $ENV{HUBOT_IRC_NICK} || $self->robot->name,
        port => $ENV{HUBOT_IRC_PORT} || 6667,
        rooms  => [ split( /,/, $ENV{HUBOT_IRC_ROOMS} ) ],
        server => $ENV{HUBOT_IRC_SERVER},
        password => $ENV{HUBOT_IRC_PASSWORD} || '',
        nickpass => $ENV{HUBOT_IRC_NICKSERV_PASSWORD},
        userName => $ENV{HUBOT_IRC_NICKSERV_USERNAME},
        ## TODO: fakessl, unflood, debug, usessl
    );

    my %clientOptions = (
        userName => $options{userName},
        password => $options{password},
        port     => $options{port},
        ## TODO: debug, stripColors, secure, selfSigned, floodProtection
    );

    $clientOptions{channels} = $options{rooms} unless $options{nickpass};

    $self->robot->name( $options{nick} );

    ## TODO: research node irc.Client
    $self->irc->reg_cb(
        connect => sub {
            my ( $con, $err ) = @_;

            # join rooms
            $self->join($_) for @{ $options{rooms} };
        },
        registered => sub {
        },
        join => sub {
            my ( $cl, $nick, $channel, $is_myself ) = @_;
            print "joined $channel\n";
            my $user = $self->createUser( $channel, $nick );
            $self->receive( new Hubot::EnterMessage( user => $user ) );
        },
        publicmsg => sub {
            my ( $cl, $channel, $ircmsg ) = @_;
            my ( $nick, $msg ) = $self->parse_msg($ircmsg);
            my $user = $self->createUser( $channel, $nick );
            $user->{room} = $channel if $channel =~ m/^#/;
            $self->receive(
                new Hubot::TextMessage(
                    user => $user,
                    text => $msg,
                )
            );
        },
        privatemsg => sub {
            my ( $cl, $nick, $ircmsg ) = @_;
            my $msg = ( $self->parse_msg($ircmsg) )[1];
            my ($channel) = $msg =~ m/^\#/ ? split / /, $msg : split /,/,
              $ENV{HUBOT_IRC_ROOMS};
            $msg =~ s/^$channel\s*//;
            my $user = $self->createUser( $channel, $nick );
            $self->receive(
                new Hubot::WhisperMessage(
                    user => $user,
                    text => $msg,
                )
            );
        },
        part => sub {
            my ( $nick, $channel, $is_myself, $msg ) = @_;
        },
        quit => sub {
            my ( $nick, $msg ) = @_;
        }
    );

    $self->emit('connected');
    $self->cv->begin;
    $self->irc->enable_ssl if $ENV{HUBOT_IRC_ENABLE_SSL};
    $self->irc->connect(
        $options{server},
        $options{port},
        {
            nick     => $options{nick},
            password => $options{password},
        }
    );

    $self->cv->recv;
}

sub close {
    my $self = shift;
    $self->irc->disconnect;
    $self->cv->send;
}

sub exist {
    my ( $self, $user, $nick ) = @_;
    return $self->findUser( $user->{room}, $nick );
}

sub createUser {
    my ( $self, $channel, $from ) = @_;
    my $user = $self->userForName($from);
    unless ($user) {
        my $id = time;
        $id =~ s/\.//;
        $user = $self->userForId(
            $id,
            {
                name => $from,
                room => $channel,
            }
        );
    }

    return $user;
}

sub findUser {
    my ( $self, $channel, $nick ) = @_;
    return $self->irc->nick_modes( $channel, $nick );
}

sub checkCanStart {
    my $self = shift;

    if ( !$ENV{HUBOT_IRC_NICK} && !$self->robot->name ) {
        ## use die?
        print STDERR
          "HUBOT_IRC_NICK is not defined, try: export HUBOT_IRC_NICK='mybot'\n";
        exit(2);    # TODO: research standard exit value
    }
    elsif ( !$ENV{HUBOT_IRC_ROOMS} ) {
        print STDERR
          "HUBOT_IRC_ROOMS is not defined, try: export HUBOT_IRC_ROOMS='#myroom'\n";
        exit(2);
    }
    elsif ( !$ENV{HUBOT_IRC_SERVER} ) {
        print STDERR
          "HUBOT_IRC_SERVER is not defined, try: export HUBOT_IRC_SERVER='irc.myserver.com'\n";
        exit(2);
    }
}

__PACKAGE__->meta->make_immutable;

1;

=pod

=encoding utf-8

=head1 NAME

Hubot::Adapter::Irc - IRC adapter for L<Hubot>

=head1 SYNOPSIS

    $ export HUBOT_IRC_SERVER='irc.myserver.com'
    $ export HUBOT_IRC_ROOMS='#mychannel'
    $ hubot -a irc

=head1 DESCRIPTION

IRC is a fairly old protocol for Internet chat.

=head1 CONFIGURATION

=head2 REQUIRED

=over

=item HUBOT_IRC_SERVER

This is the full hostname or IP address of the IRC server you want your hubot to connect to. Make a note of it.

=item HUBOT_IRC_ROOMS

This is a comma separated list of the IRC channels you want your hubot to join. They must include the C<#>. Make a note of them.

=back

=head2 OPTIONAL

=over

=item HUBOT_IRC_NICK

This is the optional nick you want your hubot to join with. If omitted it will default to the name of your hubot.

=item HUBOT_IRC_PORT

This is the optional port of the IRC server you want your hubot to connect to. If omitted the default is C<6667>. Make a note of it if required.

=item HUBOT_IRC_PASSWORD

This is the optional password of the IRC server you want your hubot to connect to. If the IRC server doesn't require a password, this can be omitted. Make a note of it if required.

=item HUBOT_IRC_NICKSERV_PASSWORD

This is the optional Nickserv password if your hubot is using a nick registered with Nickserv on the IRC server. Make a note of it if required.

=item HUBOT_IRC_NICKSERV_USERNAME

This is the optional Nickserv username if your hubot is using a nick registered with Nickserv on the IRC server, e.g. C</msg NickServ identify E<lt>usernameE<gt> E<lt>passwordE<gt>>.

=back

=head1 SEE ALSO

L<https://github.com/github/hubot/wiki/Adapter:-IRC>

=head1 AUTHOR

Hyungsuk Hong <hshong@perl.kr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Hyungsuk Hong.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
