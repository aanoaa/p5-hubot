package Hubot::Robot;
use Moose;
use namespace::autoclean;

use Pod::Usage;

use Hubot::User;
use Hubot::Brain;
use Hubot::Listener;
use Hubot::TextListener;
use ScopedClient;

has 'name' => ( is => 'ro', isa => 'Str' );
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
        $user = Hubot::User->new({
            id      => $id,
            options => $options
        });

        $self->brain->data->{users}{$id} = $user;
    }

    my $options_room = $options->{room} || '';
    if ($options_room ne $user->get('room')) {
        $self->brain->data->{users}{$id} = $user;
    }

    return $user;
}

sub shutdown {
    my $self = shift;
    $self->adapter->close;
    $self->brain->close;
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
    ## TODO: 존나 복잡해서 대충 처리 했음, 제대로 구현해야함
    $self->addListener(new Hubot::TextListener(
        regex => $regex,
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
