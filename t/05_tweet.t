use strict;
use warnings;
use Hubot::Robot;
use lib 't/lib';
use Test::More tests => 2;

my $robot = Hubot::Robot->new(
    {
        adapter => 'helper',
        name    => 'hubot'
    }
);

$robot->loadHubotScripts( [ "help", "tweet" ] );
$robot->adapter->interval(3);

push @{ $robot->{receive} },
  (
    'hubot help tweet',
    'https://twitter.com/saltfactory/status/263821902001369088',
  );

$robot->run;

my $got;
$got = shift @{ $robot->{sent} };
ok( "@$got", 'containing help messages' );

$got = shift @{ $robot->{sent} };
like( "@$got", qr/Ruby/, 'has tweet content' );
