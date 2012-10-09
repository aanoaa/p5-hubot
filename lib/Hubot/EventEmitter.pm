package Hubot::EventEmitter;
use Moose;
use namespace::autoclean;

has 'events' => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { {} },
);

sub emit {
    my ($self, $name) = (shift, shift);
    if (my $s = $self->events->{$name}) {
        for my $cb (@$s) { $self->$cb(@_) }
    }
    return $self;
}

sub on {
    my ($self, $name, $cb) = @_;
    push @{$self->{events}{$name} ||= []}, $cb;
    return $cb;
}

__PACKAGE__->meta->make_immutable;

1;
