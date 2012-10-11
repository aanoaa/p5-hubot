package Hubot::Adapter::Campfire;
use Moose;
use namespace::autoclean;

extends 'Hubot::Adapter';

use AnyEvent;
use AnyEvent::HTTP;
use AnyEvent::Campfire::Client;
use MIME::Base64;
use JSON::XS;
use Encode 'encode_utf8';
use HTTP::Request;
use LWP::UserAgent;
use Try::Tiny;

use Hubot::Message;

has 'robot' => (
    is  => 'ro',
    isa => 'Hubot::Robot',
);

has 'cv' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'bot' => (
    is => 'rw',
);

has 'httpClient' => (
    is => 'ro',
    default => sub { LWP::UserAgent->new },
);

sub _build_cv  { AnyEvent->condvar }

sub send {
    my ( $self, $user, @strings ) = @_;
    $self->bot->speak($user->{room}, encode_utf8($_))
      for @strings;
}

sub reply {
    my ( $self, $user, @strings ) = @_;
    @strings = map { $user->{name} . ": $_" } @strings;
    $self->send( $user, @strings );
}

sub run {
    my $self = shift;

    my %options = (
        token => $ENV{HUBOT_CAMPFIRE_TOKEN},
        rooms => $ENV{HUBOT_CAMPFIRE_ROOMS},
        account => $ENV{HUBOT_CAMPFIRE_ACCOUNT},
    );

    $self->cv->begin;

    my $bot = AnyEvent::Campfire::Client->new(%options);
    $bot->on(
        'join',
        sub {
            my ($e, $data) = @_;
            $self->receive(new Hubot::EnterMessage);
        }
    );

    $bot->on(
        'message',
        sub {
            my ($e, $data) = @_;
            my $user = $self->userForId(
                $data->{user_id},
                {
                    room => $data->{room_id},
                }
            );

            if ($user->{name} eq $user->{id}) {
                my $req = HTTP::Request->new(
                    GET => sprintf(
                        "https://%s.campfirenow.com/users/%s",
                        $options{account},
                        $user->{id}
                    ),
                );
                $req->header('Accept', 'application/json');
                $req->header('Authorization', $bot->authorization);
                my $res = $self->httpClient->request($req);
                return unless $res->is_success;

                my $userData;
                try {
                    $userData = decode_json($res->content);
                } catch {
                    $bot->emit('error', $_);
                };

                $user->{name} = $userData->{user}{name};
            }

            $self->receive(
                new Hubot::TextMessage(
                    user => $user,
                    text => $data->{body},
                )
            );
        }
    );

    $bot->on(
        'error',
        sub {
            my ($e, $error) = @_;
            print STDERR "$error\n";
        }
    );

    $bot->on(
        'leave',
        sub {
            print "Goodbye, cruel world\n";
            $self->cv->send;
        }
    );

    $self->bot($bot);
    $self->emit('connected');
    $self->cv->recv;
}

sub close {
    my $self = shift;
    $self->bot->exit;
}

__PACKAGE__->meta->make_immutable;

1;
