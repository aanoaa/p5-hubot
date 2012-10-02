package Hubot::Adapter::Shell;
use Term::ReadLine;
use Moose;
use namespace::autoclean;

use AnyEvent;

use Hubot::Message;

extends 'Hubot::Adapter';

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot',
);

has '_prompt' => (
    is     => 'rw',
    isa    => 'Str',
    writer => 'setPrompt',
);

has 'cb_connected' => (
    traits  => ['Code'],
    is      => 'rw',
    isa     => 'CodeRef',
    handles => { connect => 'execute', },
);

has 'cv' => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_cv { AnyEvent->condvar }

sub close { exit }

sub send {
    my ( $self, $user, @strings ) = @_;
    print "$_\n" for @strings;
}

sub reply {
    my ( $self, $user, @strings ) = @_;
    @strings = map { $user->name . ": $_" } @strings;
    $self->send( $user, @strings );
}

sub run {
    my $self = shift;

    local $| = 1;
    binmode STDOUT, ':encoding(UTF-8)';

    $self->connect;
    $self->setPrompt( $self->robot->name . "> " );
    print $self->_prompt;
    my $w;
    $w = AnyEvent->io(
        fh   => \*STDIN,
        poll => 'r',
        cb   => sub {
            local $| = 1;
            chomp( my $input = <STDIN> );
            if ( lc($input) eq 'exit' ) {
                $self->robot->shutdown;
                exit;
            }

            my $user = $self->userForId(
                1,
                {
                    name => 'Shell',
                    room => 'Shell',
                }
            );

            $self->receive(
                new Hubot::TextMessage(
                    {
                        user => $user,
                        text => $input,
                    }
                )
            );

            print $self->_prompt;
        }
    );

    $self->cv->recv;
}

__PACKAGE__->meta->make_immutable;

1;
