package Hubot::Scripts::help;

sub load {
    my ($class, $robot) = @_;
    $robot->hear(
        qr/help\s*(.*)?$/i,
        sub {
            my $msg  = shift;    # Hubot::Response
            my $emit = '';
            my @cmds;
            if ( @{ $msg->match } ) {
                my $regex = $msg->match->[0];
                @cmds = grep { $_ =~ /$regex/i } $robot->commands;
            }
            else {
                @cmds = $robot->commands;
            }

            $emit = join( "\n", @cmds );
            $msg->send($emit);
        }
    );
}

1;

=head1 SYNOPSIS

    hubot> help

=cut
