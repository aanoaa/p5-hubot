package Hubot::Role::Adapter;

use Moo::Role;

sub send    { }
sub whisper { }
sub reply   { }
sub run     { }
sub close   { }
sub exist   { }

1;
