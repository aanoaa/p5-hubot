package Hubot::User;
use strict;
use warnings;

sub new {
    my ( $class, $ref ) = @_;
    $ref->{name} ||= $ref->{id};
    bless $ref, $class;
}

1;
