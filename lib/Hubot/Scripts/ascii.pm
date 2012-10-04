package Hubot::Scripts::ascii;
use strict;
use warnings;

sub load {
    my ( $class, $robot ) = @_;
    $robot->hear(
        qr/^ascii:?( me)? (.+)/i,
        sub {
            my $msg = shift;
            $msg->http('http://asciime.heroku.com/generate_ascii')
              ->query( 's', $msg->match->[1] )->get(
                sub {
                    my ( $body, $hdr ) = @_;
                    return if ( !$body || !$hdr->{Status} =~ /^2/ );
                    $msg->send( split( /\n/, $body ) );
                }
              );
        }
    );
}

1;

=head1 SYNOPSIS

  ascii (me) <string>

=cut
