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

$robot->loadHubotScripts( [ "help", "roles" ] );

push @{ $robot->{receive} }, 'hubot help';
push @{ $robot->{receive} }, 'hubot help roles';

$robot->run;

my $got;
$got = shift @{ $robot->{sent} };
like( "@$got", qr/help <query>/, 'generall help' );
$got = shift @{ $robot->{sent} };
like( "@$got", qr/see what roles a user has/, 'specific help' );
