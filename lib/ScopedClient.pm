package ScopedClient;
use Moose;
use namespace::autoclean;

use utf8;
use URI;
use Try::Tiny;
use MIME::Base64;
use HTTP::Request;
use Encode qw/encode_utf8/;
use AnyEvent::HTTP;

has 'options' => (
    is  => 'ro',
    isa => 'HashRef',
);

has 'defaultPort' => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub {
        {
            http  => 80,
            https => 443,
        };
    },
);

sub request {
    my ( $self, $method, $reqBody, $callback ) = @_;
    if ( 'CODE' eq ref($reqBody) ) {
        $callback = $reqBody;
        undef $reqBody;
    }

    my %options = %{ $self->options };
    try {
        my %headers = %{ $options{headers} };
        my $sendingData =
          ( $method =~ m/^P/ && $reqBody && length $reqBody > 0 ) ? 1 : 0;
        $headers{Host} = $options{url}->host;
        $headers{'Content-Length'} = length $reqBody if $sendingData;

        if ( $options{auth} ) {
            $headers{Authorization} =
              'Basic ' . encode_base64( $options{auth} );
        }

        http_request(
            $method,
            $options{url},
            timeout => 3,
            headers => \%headers,
            body    => $sendingData ? encode_utf8($reqBody) : undef,
            $callback
        );
    }
    catch {
        $callback->($_) if $callback;
    };

    return $self;
}

sub fullPath {
    my ( $self, $p ) = @_;
}

sub scope {
    my ( $self, $url, $options, $callback ) = @_;
}

sub join {
    my ( $self, $suffix ) = @_;
}

sub path {
    my ( $self, $p ) = @_;
}

sub query {
    my ( $self, $key, $value ) = @_;
}

sub host {
    my ( $self, $h ) = @_;
}

sub protocol {
    my ( $self, $p ) = @_;
}

sub auth {
    my ( $self, $user, $pass ) = @_;
    if ( !$user ) {
        $self->options->{auth} = undef;
    }
    elsif ( !$pass && $user =~ m/:/ ) {
        $self->options->{auth} = $user;
    }
    else {
        $self->options->{auth} = "$user:$pass";
    }

    return $self;
}

sub header {
    my ( $self, $name, $value ) = @_;
    $self->options->{headers}{$name} = $value;
    return $self;
}

sub headers {
    my ( $self, $h ) = @_;
}

sub buildOptions {
    my ( $self, $url, $params ) = @_;
    $params->{options}{url} = URI->new($url);
    $params->{options}{headers} ||= {};
}

sub BUILDARGS {
    my ( $self, $url, %params ) = @_;
    $self->buildOptions( $url, \%params );
    return \%params;
}

sub get    { shift->request( 'GET',    @_ ) }
sub post   { shift->request( 'POST',   @_ ) }
sub patch  { shift->request( 'PATCH',  @_ ) }
sub put    { shift->request( 'PUT',    @_ ) }
sub delete { shift->request( 'DELETE', @_ ) }
sub head   { shift->request( 'HEAD',   @_ ) }

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 NAME

ScopedClient - L<AnyEvent::HTTP> wrapper

=cut
