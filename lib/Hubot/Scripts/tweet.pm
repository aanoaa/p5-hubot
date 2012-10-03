package Hubot::Scripts::tweet;
use strict;
use warnings;
use JSON::XS;

sub load {
    my ( $class, $robot ) = @_;
    $robot->hear(
        qr/https?:\/\/(mobile\.)?twitter\.com\/.*?\/status\/([0-9]+)/i,
        sub {
            my $msg = shift;    # Hubot::Response
            $msg->http( 'https://api.twitter.com/1/statuses/show/'
                  . $msg->match->[1]
                  . '.json' )->get(
                sub {
                    my ( $body, $hdr ) = @_;
                    return if ( !$body || !$hdr->{Status} =~ /^2/ );
                    my $tweet = decode_json($body);
                    $msg->send("$tweet->{user}{screen_name}: $tweet->{text}");
                }
                  );
        }
    );
}

1;

=head1 SYNOPSIS

http://twitter.com/pdrucker_bot/status/250419748339331072

=cut
