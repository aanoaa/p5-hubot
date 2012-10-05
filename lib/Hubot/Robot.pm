package Hubot::Robot;
use Moose;
use namespace::autoclean;

use Pod::Usage;

use Hubot::User;
use Hubot::Brain;
use Hubot::Listener;
use Hubot::TextListener;
use ScopedClient;

our $VERSION = 'v0.0.1';

has 'name' => ( is => 'rw', isa => 'Str' );
has 'alias' => ( is => 'rw', isa => 'Str' );
has 'adapter' => ( is => 'rw' );
has 'brain' => (
    is => 'ro',
    isa => 'Hubot::Brain',
    default => sub { Hubot::Brain->new }
);
has '_commands' => (
    traits  => ['Array'],
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
    handles => {
        commands   => 'elements',
        addCommand => 'push',
    }
);
has '_listeners' => (
    traits  => ['Array'],
    is => 'rw',
    isa => 'ArrayRef[Hubot::Listener]',
    default => sub { [] },
    handles => {
        listeners   => 'elements',
        addListener => 'push',
    }
);

sub BUILD {
    my $self = shift;
    $self->loadAdapter($self->adapter)
}

sub receive {
    my ($self, $message) = @_;
    my $results = [];
    for my $listener ($self->listeners) {
        eval $listener->call($message);
        last if $message->done;
        if ($@) {
            print STDERR "Unable to call the listener: $@\n";
            return 0;
        }
    }

    # if message not instanceof CatchAllMessage and results.indexOf(true) is -1
    #   @receive new CatchAllMessage(message)
}

sub loadAdapter {
    my ($self, $adapter) = @_;
    ## TODO: HUBOT_DEFAULT_ADAPTERS
    $adapter = "Hubot::Adapter::" . ucfirst($adapter);
    eval "require $adapter; 1";
    if ($@) {
        print STDERR "Cannot load adapter $adapter - $@\n";
    } else {
        $self->adapter($adapter->new({ robot => $self }));
    }
}

sub run { shift->adapter->run }

sub userForId {
    my ($self, $id, $options) = @_;
    my $user = $self->brain->data->{users}{$id};
    unless ($user) {
        $user = Hubot::User->new({ id => $id, %$options });
        $self->brain->data->{users}{$id} = $user;
    }

    my $options_room = $options->{room} || '';
    if ($options_room ne $user->{room}) {
        $self->brain->data->{users}{$id} = $user;
    }

    return $user;
}

sub userForName {
    my ($self, $name) = @_;
    my $result;
    for my $k (keys %{ $self->brain->data->{users} }) {
        my $userName = $self->brain->data->{users}{$k}{name};
        if (lc $userName eq lc $name) {
            $result = $self->brain->data->{users}{$k};
        }
    }

    return $result;
}

sub shutdown {
    my $self = shift;
    $self->brain->close;
    $self->adapter->close;
}

sub loadHubotScripts {
    my ($self, $scripts) = @_;
    ## TODO: Debug Message
    # print "Loading hubot-scripts\n" if $ENV{DEBUG};
    for my $script (@$scripts) {
        $self->loadFile($script);
    }
}

sub loadFile {
    my ($self, $script) = @_;
    my $full = "Hubot::Scripts::$script";
    eval "require $full; 1";
    $full->load($self);
    if ($@) {
        print STDERR "Unable to load $full: $@\n";
    } else {
        $self->parseHelp($full);
    }
}

sub parseHelp {
    my ($self, $module) = @_;
    $module =~ s{::}{/}g;
    my $fullpath = $INC{$module . '.pm'};

    open my $fh, '>', \my $usage or die "Couldn't open filehandle: $!\n";
    pod2usage({
        -input   => $fullpath,
        -output  => $fh,
        -exitval => 'noexit',
    });

    $usage =~ s/^Usage://;
    $usage =~ s/(^\s+|\s+$)//gm;
    $self->addCommand("# $usage");
}

sub hear {
    my ($self, $regex, $callback) = @_;
    $self->addListener(new Hubot::TextListener(
        robot => $self,
        regex => $regex,
        callback => $callback
    ));
}

sub respond {
    my ($self, $regex, $callback) = @_;

    my $index = index "$regex", ':';
    my $stringRegex = substr "$regex", ($index + 1), -1;
    my $first = substr $stringRegex, 0, 1;

    ## TODO: $^ 에 따른 분기; perl version 에 따라서 Regex object 의 modifier 위치가 달라짐
    my $modifiers = '';
    my $modifiersLen = $index - 3;
    $modifiers = substr $stringRegex, 3, $modifiersLen if $modifiersLen > 0;
    if ($first eq '^') {
        print STDERR "Anchors don't work well with respond, perhaps you want to use 'hear'\n";
        print STDERR "The regex in question was $stringRegex\n";
    }

    my $newRegex;
    my $name = $self->name;
    if ($self->alias) {
        my $alias = $self->alias;
        $alias =~ s/[-[\]{}()\*+?.,\\^$|#\s]/\\$&/g; # escape alias for regexp

        ## TODO: fix to generate correct regex
        ## qr/regex/$var 처럼 modifier 에 변수가 들어갈 수 없음
        ## 일단 modifiers 가 있다면 `i` 라고 가정하고 들어감 WTH..
        if ($modifiers) {
            $newRegex = qr/^(?:$alias[:,]?|$name[:,]?)\s*(?:$stringRegex)/i;
        } else {
            $newRegex = qr/^(?:$alias[:,]?|$name[:,]?)\s*(?:$stringRegex)/
        }
    } else {
        if ($modifiers) {
            $newRegex = qr/^(?:$name[:,]?)\s*(?:$stringRegex)/i;
        } else {
            $newRegex = qr/^(?:$name[:,]?)\s*(?:$stringRegex)/
        }
    }

    print "$newRegex\n" if $ENV{DEBUG};
    $self->addListener(new Hubot::TextListener(
        robot => $self,
        regex => $newRegex,
        callback => $callback
    ));
}

sub http { ScopedClient->new($_[1]) }

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Hubot::Robot - the robot

=head1 SYNOPSIS

write something..

=cut
