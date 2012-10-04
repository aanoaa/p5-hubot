package Hubot::Adapter::Irc;
use Moose;
use namespace::autoclean;

extends 'Hubot::Adapter';

use AnyEvent;
use AnyEvent::IRC::Client;
use Time::HiRes 'time';
use Encode 'encode_utf8';

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
sub part       { }
sub createUser { }
sub kick       { }
sub command    { }

sub parse_msg {
    my ( $self, $irc_msg ) = @_;

    my ($nickname) = $irc_msg->{prefix} =~ m/^([^!]+)/;
    my $message = $irc_msg->{params}[1];
    return ( $nickname, $message );
}

sub send {
    my ( $self, $user, @strings ) = @_;
    $self->irc->send_srv( 'PRIVMSG', $user->get('room'), encode_utf8($_) )
      for @strings;
}

sub reply {
    my ( $self, $user, @strings ) = @_;
    @strings = map { $user->name . ": $_" } @strings;
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
            $self->receive( new Hubot::EnterMessage );
        },
        publicmsg => sub {
            my ( $cl, $channel, $ircmsg ) = @_;
            my ( $nick, $msg ) = $self->parse_msg($ircmsg);
            my $user = $self->userForName($nick);
            unless ($user) {
                my $id = time;
                $id =~ s/\.//;
                $user = $self->userForId(
                    $id,
                    {
                        name => $nick,
                        room => $channel,
                    }
                );
            }

            $self->receive(
                new Hubot::TextMessage(
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

    $self->connect;
    $self->cv->begin;
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
          "HUBOT_IRC_ROOM is not defined, try: export HUBOT_IRC_ROOM='#myroom'\n";
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
