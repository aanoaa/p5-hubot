package Hubot::Brain;
use Moose;
use namespace::autoclean;

extends 'Hubot::EventEmitter';

has 'data' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { { users => {} } },
);

sub save {
    my $self = shift;
    $self->emit( 'save', $self->data );
}

sub close {
    my $self = shift;
    $self->save;
    $self->emit('close');
}

sub mergeData {
    my ( $self, $data ) = @_;
    for my $key ( keys %$data ) {
        if ( $key eq 'users' ) {
            for my $k ( keys %{ $data->{$key} } ) {
                bless $data->{$key}{$k}, 'Hubot::User';
            }
        }

        $self->data->{$key} = $data->{$key};
    }

    $self->emit( 'loaded', $self->data );
}

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 SYNOPSIS

    $robot->brain->data->{key} = ''; # scalar
    $robot->brain->data->{key} = {}; # HashRef
    $robot->brain->data->{key} = []; # ArrayRef

=head1 DESCRIPTION

Brain with external storage like a L<Hubot::Scrips::redisBrain>, C<value> must be a B<Scalar> or B<HashRef> or B<ArrayRef>.

C<$robot-E<gt>brain-E<gt>data> will convert to json string and stored to external storage.
so, if you trying to store perl object, it will fail.

without external storage, everything is fine to store to memory.

=cut
