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

=pod

=encoding utf-8

=head1 NAME

Hubot::Scripts::ascii

=head1 SYNOPSIS

    ascii me <text> - Show text in ascii art

=head1 AUTHOR

Hyungsuk Hong <hshong@perl.kr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Hyungsuk Hong.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
