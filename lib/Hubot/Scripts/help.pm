package Hubot::Scripts::help;

use Moose;
use namespace::autoclean;

has 'robot' => ( is => 'ro' );

sub BUILD {
    my $self = shift;
    $self->robot->hear(
        qr/help\s*(.*)?$/i,
        sub {
            my $msg  = shift;    # Hubot::Response
            my $emit = '';
            my @cmds;
            if ( @{ $msg->match } ) {
                my $regex = $msg->match->[0];
                @cmds = grep { $_ =~ /$regex/i } $self->robot->commands;
            }
            else {
                @cmds = $self->robot->commands;
            }

            $emit = join( "\n", @cmds );
            $msg->send($emit);
        }
    );
}

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 SYNOPSIS

    hubot> help

=cut
