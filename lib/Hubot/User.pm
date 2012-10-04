package Hubot::User;
use Moose;
use namespace::autoclean;

has 'id' => ( is => 'ro', isa => 'Int' );
has 'options' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

sub set {
    my ( $self, $key, $value ) = @_;
    $self->options->{$key} = $value;
}

sub get {
    my ( $self, $key ) = @_;
    return $self->options->{$key};
}

sub name {
    my $self = shift;
    return $self->get('name') || $self->id;
}

__PACKAGE__->meta->make_immutable;

1;