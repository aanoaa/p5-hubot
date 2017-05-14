use utf8;
use strict;
use warnings;
use Test::More;
use Data::Dump;

use AnyEvent;
use AnyEvent::HTTP::ScopedClient;

use Hubot::Robot;
use lib 't/lib';

# loadAdapter
# setupHerokuPing
# useForId
# userForName

# usersForFuzzyRawName
# usersForFuzzyName
# shutdown
# loadHubotScripts
# loadFile
# parseHelp
# hear
# respond
# enter
# leave
# whisper
# notice
# catchAll
# receive
# http

$ENV{HUBOT_HEROKU_URL} = 'http://localhost:8080';

my $robot = Hubot::Robot->new(
    {
        adapter => 'test',
        name    => 'hubot'
    }
);

my $adapter = $robot->adapter;
my $cv      = $adapter->cv;

$robot->loadHubotScripts( ['help'] );
ok( $robot, 'new' );
is( ref $adapter, 'Hubot::Adapter::Test', 'loadAdapter' );

$cv->begin;
my $timer = AnyEvent->timer(
    after => 1,   # 1sec
    cb    => sub {
        my $url = $ENV{HUBOT_HEROKU_URL} . '/hubot/ping';
        AnyEvent::HTTP::ScopedClient->new($url)->get(
            sub {
                my ( $body, $hdr ) = @_;
                is( $hdr->{Status}, 200,    'heroku ping status' );
                is( $body,          'pong', 'heroku ping content' );
                $cv->end;
            }
        );
    }
);

$robot->run;

my $name = $ENV{LOGNAME} || $ENV{USER} || 'tester';
my $id   = time;
my $user = $robot->userForId( $id, { name => $name } );
is( ref $user, 'Hubot::User', 'userForId - create' );

$user = $robot->userForId($id);
is( $user->{name}, $name, 'userForId - exists' );

$user = $robot->userForName('Unknown');
is( $user, undef, 'userForName - Not found' );

$user = $robot->userForName($name);
is( $user->{id}, $id, 'userForName - exists' );

# usersForFuzzyRawName
# usersForFuzzyName

$robot->shutdown;
done_testing();
