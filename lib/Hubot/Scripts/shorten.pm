package Hubot::Scripts::shorten;
use strict;
use warnings;
use WWW::Shorten::Bitly;
use Encode 'decode';

sub load {
    my ( $class, $robot ) = @_;
    $robot->hear(
        qr/(https?:\/\/\S+)/i,
        sub {
            my $msg   = shift;
            my $bitly = $msg->match->[0];
            if ( length $bitly > 50 ) {
                $bitly = makeashorterlink(
                    $bitly,
                    $ENV{HUBOT_BITLY_USERNAME},
                    $ENV{HUBOT_BITLY_API_KEY}
                );
            }

            $msg->http( $msg->match->[0] )->header( "User-Agent",
                "Mozilla/5.0 (X11; Linux x86_64; rv:10.0.7) Gecko/20100101 Firefox/10.0.7 Iceweasel/10.0.7"
              )->get(
                sub {
                    my ( $body, $hdr ) = @_;
                    return if ( !$body || !$hdr->{Status} =~ /^2/ );

                    # content-type
                    my @ct = split( /\s*,\s*/, $hdr->{'content-type'} );
                    if ( grep { /^image\/.+$/i } @ct || grep { !/text/i } @ct )
                    {
                        return $msg->send("[$ct[0]] - $bitly");
                    }

                    # charset
                    my $charset;
                    if ( $body =~
                        /charset=(?:'([^']+?)'|"([^"]+?)"|([a-zA-Z0-9_-]+)\b)/ )
                    {
                        $charset = lc( $1 || $2 || $3 );
                    }

                    unless ($charset) {
                        for my $ct (@ct) {
                            if ( $ct =~ m/charset\s*=\s*(.*)$/i ) {
                                $charset = $1;
                            }
                            else {
                                $charset = 'utf-8';
                            }
                        }
                    }

                    eval { $body = decode( $charset, $body ) };
                    if ($@) {
                        return $msg->send("[$@] - $bitly");
                    }

                    my ($title) = $body =~ m/<title>(.*)<\/title>/s;
                    $title = 'no title' unless $title;
                    $msg->send("[$title] - $bitly");
                }
              );
        }
    );
}

1;

=head1 SYNOPSIS

<url> - Shorten the URL using bit.ly

=head1 CONFIGURATION

=over

=item HUBOT_BITLY_USERNAME

=item HUBOT_BITLY_API_KEY

=back

=cut