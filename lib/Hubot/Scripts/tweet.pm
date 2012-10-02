package Hubot::Scripts::tweet;

use Moose;
use namespace::autoclean;

use utf8;
use URI::Escape;
use JSON::XS;

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot',
);

sub BUILD {
    my $self = shift;

    $self->robot->hear(
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

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 SYNOPSIS

http://twitter.com/pdrucker_bot/status/250419748339331072

=cut
