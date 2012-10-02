package Hubot::Listener;
use Moose;
use namespace::autoclean;

use Hubot::Robot;
use Hubot::Response;

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot',
);
has 'matcher' => (
    traits  => ['Code'],
    is      => 'rw',
    isa     => 'CodeRef',
    handles => { matching => 'execute', },
);
has 'callback' => (
    traits  => ['Code'],
    is      => 'rw',
    isa     => 'CodeRef',
    handles => { cb => 'execute', },
);

sub call {
    my ( $self, $message ) = @_;
    if ( my @match = $self->matching($message) ) {
        $self->cb(
            new Hubot::Response(
                robot   => $self->robot,
                message => $message,
                match   => \@match,
            )
        );

        return 1;
    }
    else {
        return 0;
    }
}

__PACKAGE__->meta->make_immutable;

1;
