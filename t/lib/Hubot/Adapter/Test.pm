package Hubot::Adapter::Test;
use Moo;

extends 'Hubot::Adapter';

use AnyEvent;

has robot => ( is => 'ro' );
has cv => ( is => 'ro', default => sub { AnyEvent->condvar } );

sub send {
    my ( $self, $user, @strings ) = @_;
    print "$_\n" for @strings;
}

sub reply {
    my ( $self, $user, @strings ) = @_;
    @strings = map { $user->{name} . ": $_" } @strings;
    $self->send( $user, @strings );
}

sub run   { shift->cv->recv }
sub close { shift->cv->send }

1;
