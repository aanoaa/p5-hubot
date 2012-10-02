package Hubot::Brain;
use Moose;
use namespace::autoclean;

has 'data' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { { users => {} } },
);

has 'resetSaveInterval' => (
    is      => 'ro',
    isa     => 'Int',
    default => 5,
);

sub close { }

__PACKAGE__->meta->make_immutable;

1;
