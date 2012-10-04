package Hubot::Response;
use Moose;
use namespace::autoclean;

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot',
);

has 'message' => (
    is  => 'ro',
    isa => 'Hubot::Message',
);

has 'match' => (
    is  => 'rw',
    isa => 'ArrayRef'
);

sub send {
    my ( $self, @strings ) = @_;
    $self->robot->adapter->send( $self->message->user, @strings );
}

sub topic {
    my ( $self, @strings ) = @_;
    $self->robot->adapter->topic( $self->message->user, @strings );
}

sub reply {
    my ( $self, @strings ) = @_;
    $self->robot->adapter->reply( $self->message->user, @strings );
}

sub random {
    my ( $self, @items ) = @_;
    return $items[ srand( scalar(@items) ) ];
}

sub finish {
    my $self = shift;
    $self->message->finish();
}

sub http {
    my ( $self, $url ) = @_;
    return $self->robot->http($url);
}

__PACKAGE__->meta->make_immutable;

1;
