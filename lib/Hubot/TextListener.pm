package Hubot::TextListener;
use Moo;

extends 'Hubot::Listener';

has 'regex' => ( is => 'ro' );

sub BUILD {
    my $self = shift;
    $self->matcher(
        sub {
            my $message = shift;
            if ( 'Hubot::TextMessage' eq ( ref $message ) ) {
                my $regex = $self->regex;
                return $message->text =~ m/$regex/;
            }
            return;
        }
    );
}

1;

=pod

=encoding utf-8

=head1 NAME

Hubot::TextListener - text Listener for hubot

=head1 SYNOPSIS

    use Hubot::TextListener;
    Hubot::TextListener->new(
        robot => $robot,    # $robot is Hubot::Robot
        regex => qr/hi/,
        callback => sub {
            my $msg = shift;    # $msg is Hubot::Response
            $msg->reply('hi');
        }
    );

=head1 DESCRIPTION

try to match L<Hubot::TextMessage> then execute callback with matching result and input messages.

=head1 SEE ALSO

<Hubot::TextMessage>

=head1 AUTHOR

Hyungsuk Hong <hshong@perl.kr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Hyungsuk Hong.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
