package Hubot::Message;
use Moose;
use namespace::autoclean;

has 'user' => (
    is  => 'ro',
    isa => 'Hubot::User',
);
has 'done' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

sub finish { shift->done(1) }

package Hubot::TextMessage;
use Moose;
use namespace::autoclean;

extends 'Hubot::Message';

has 'text' => (
    is  => 'ro',
    isa => 'Str',
);

sub match {
    my ( $self, $regex ) = @_;
    return $self->text =~ m/$regex/;
}

__PACKAGE__->meta->make_immutable;

package Hubot::EnterMessage;
use Moose;
use namespace::autoclean;
extends 'Hubot::Message';
__PACKAGE__->meta->make_immutable;

package Hubot::LeaveMessage;
use Moose;
use namespace::autoclean;
extends 'Hubot::Message';
__PACKAGE__->meta->make_immutable;

package Hubot::CatchAllMessage;
use Moose;
use namespace::autoclean;
extends 'Hubot::Message';

has 'message' => ( is => 'ro', isa => 'Str' );

__PACKAGE__->meta->make_immutable;

1;
