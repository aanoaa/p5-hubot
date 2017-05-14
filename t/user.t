use utf8;
use strict;
use warnings;
use Test::More;
use JSON;

use Hubot::User;

my $user = Hubot::User->new( { id => time, {} } );
ok( $user, 'new' );
my $json = JSON->new->convert_blessed;
my $text = $json->encode($user);
ok( $text, 'TO_JSON(convert_blessed)' );

done_testing();
