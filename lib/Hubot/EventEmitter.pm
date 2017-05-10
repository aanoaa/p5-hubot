package Hubot::EventEmitter;
use Moo;

has 'events' => ( is => 'rw', default => sub { {} } );

sub emit {
    my ( $self, $name ) = ( shift, shift );
    if ( my $s = $self->events->{$name} ) {
        for my $cb (@$s) {
            $self->$cb(@_);
        }
    }
    return $self;
}

sub on {
    my ( $self, $name, $cb ) = @_;
    push @{ $self->{events}{$name} ||= [] }, $cb;
    return $cb;
}

1;

=pod

=encoding utf-8

=head1 NAME

Hubot::EventEmitter - Listen events and trigger

=head1 SYNOPSIS

    package Foo;
    use Moo;
    extends 'Hubot::EventEmitter';

    package main;
    my $foo = Foo->new;
    $foo->on(
        'event1',
        sub {
            my ($e, @args) = @_;    # $e is `$foo` itself. ignore.
            print "@args\n";    # 1 2 3 4
        }
    );

    $foo->emit('event1', 1, 2, 3, 4);

=head1 DESCRIPTION

subscribe event via C<on> then execute callback via C<emit>.

=head1 METHODS

=head2 on( $name, $cb )

=head2 emit( $name, \@cb_args )

=head1 AUTHOR

Hyungsuk Hong <hshong@perl.kr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Hyungsuk Hong.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
