package Hubot::TextListener;
use Moose;
use namespace::autoclean;

extends 'Hubot::Listener';

has 'regex' => (
    is  => 'ro',
    isa => 'RegexpRef',
);

sub BUILD {
    my $self = shift;
    $self->matcher(
        sub {
            my $message = shift;
            if ( 'Hubot::TextMessage' eq ( ref $message ) ) {
                my $regex = $self->regex;
                return $message->text =~ m/$regex/;
            }
            return;
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;
