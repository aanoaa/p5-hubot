package Hubot::Scripts::help;
use strict;
use warnings;

sub load {
    my ( $class, $robot ) = @_;
    $robot->respond(
        qr/help\s*(.*)?$/i,
        sub {
            my $msg  = shift;              # Hubot::Response
            my @cmds = $robot->commands;
            if ( scalar @{ $msg->match } && $msg->match->[0] ) {
                my $regex = $msg->match->[0];
                @cmds = grep { $_ =~ /$regex/i } @cmds;
            }

            $msg->send(@cmds);
        }
    );
}

1;

=head1 SYNOPSIS

    $ hubot: help <command>

=cut
