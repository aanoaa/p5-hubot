use strict;
use warnings;
use Test::More;
use AnyEvent;

use ScopedClient;

my $cv = AE::cv;
my $http =
  ScopedClient->new('http://example.com/');    # TODO: specific example uri

$cv->begin;
$http->get(
    sub {
        my ( $body, $hdr ) = @_;
        diag("$hdr->{Status}: $hdr->{Reason}") if $hdr->{Status} !~ /^2/;
        is( $hdr->{Status}, 200, 'GET request' );
        $cv->end;
    }
);

$cv->begin;
$http->post(
    { foo => 'bar', bar => 'baz' },    # also available: "foo=bar&bar=baz",
    sub {
        my ( $body, $hdr ) = @_;
        diag("$hdr->{Status}: $hdr->{Reason}") if $hdr->{Status} !~ /^2/;
        is( $hdr->{Status}, 200, 'POST request' );
        $cv->end;
    }
);

$cv->recv;

# get
# post
# patch
# put
# delete
# head

done_testing();
