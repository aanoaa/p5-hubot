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
                    print "$body\n" if $ENV{DEBUG};
                    my $tweet = decode_json($body);
                    $msg->send("$tweet->{user}{screen_name}: $tweet->{text}");
                }
                  );
            $msg->message->finish;
        }
    );
}

1;

=pod

=encoding utf-8

=head1 NAME

Hubot::Scripts::tweet

=head1 SYNOPSIS

    <tweeturl> - Display tweet content

=head1 DESCRIPTION

Detect tweet URL and send tweet content

=head1 AUTHOR

Hyungsuk Hong <hshong@perl.kr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Hyungsuk Hong.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
