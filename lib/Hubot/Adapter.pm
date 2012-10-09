package Hubot::Adapter;
use Moose;
use namespace::autoclean;

extends 'Hubot::EventEmitter';

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot'
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

=pod

=head1 SYNOPSIS

    my $adapter = Hubot::Adapter->new( robot => $robot );
    $adapter->on('connected', sub {
        # so something
    });

    # Hubot::Adapter::XXX
    sub run {
        my $self = shift;
        $self->emit('connected');
    }

=cut
