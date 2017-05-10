package Hubot::Message;
use Moo;

has 'user' => ( is => 'ro' );
has 'done' => ( is => 'rw', default => 0 );

sub finish { shift->done(1) }

sub TO_JSON {
    my $self = shift;
    return {
        ## prvent recursive call
        ## Hubot::UserTO_JSON -> Hubot::Message::TO_JSON -> Hubot::User::TO_JSON
        user => { name => $self->user->{name}, id => $self->user->{id}, },
        done => $self->done,
    };
}

1;

package Hubot::TextMessage;
use Moo;

extends 'Hubot::Message';

has 'text' => ( is => 'ro' );

sub match {
    my ( $self, $regex ) = @_;
    return $self->text =~ m/$regex/;
}

around 'TO_JSON' => sub {
    my ( $orig, $self ) = ( shift, shift );
    my $hashref = $self->$orig(@_);
    $hashref->{text} = $self->text;
    return $hashref;
};

1;

package Hubot::EnterMessage;
use Moo;
extends 'Hubot::Message';

1;

package Hubot::LeaveMessage;
use Moo;
extends 'Hubot::Message';

1;

package Hubot::WhisperMessage;
use Moo;
extends 'Hubot::TextMessage';

1;

package Hubot::NoticeMessage;
use Moo;
extends 'Hubot::TextMessage';

1;

package Hubot::CatchAllMessage;
use Moo;
extends 'Hubot::Message';

has 'message' => ( is => 'ro' );

1;

=pod

=encoding utf-8

=head1 NAME

Hubot::Message

=head1 SYNOPSIS

    my $msg = Hubot::Message->new(
        user => $user    # $user is Hubot::User
    );

    $msg = Hubot::TextMessage->new(
        user => $user    # $user is Hubot::User
        text => 'hi'
    );

    $msg->finish;    # this message is processed.
                     # Hubot::Script::* will ignore this message.

=head1 DESCRIPTION

Hubot::Adapter::* will make L<Hubot::Message> stand on input.

=head1 AUTHOR

Hyungsuk Hong <hshong@perl.kr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Hyungsuk Hong.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
