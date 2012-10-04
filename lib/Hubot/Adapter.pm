package Hubot::Adapter;
use Moose;
use namespace::autoclean;

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot'
);

has 'cb_connected' => (
    traits  => ['Code'],
    is      => 'rw',
    isa     => 'CodeRef',
    handles => { connect => 'execute' },
);

sub send  { }
sub reply { }
sub run   { }
sub close { }

sub receive              { shift->robot->receive(@_) }
sub users                { shift->robot->users }
sub userForId            { shift->robot->userForId(@_) }
sub userForName          { shift->robot->userForName(@_) }
sub usersForFuzzyRawName { shift->robot->usersForFuzzyRawName(@_) }
sub usersForFuzzyName    { shift->robot->usersForFuzzyName(@_) }
sub http                 { shift->robot->http(@_) }

__PACKAGE__->meta->make_immutable;

1;
