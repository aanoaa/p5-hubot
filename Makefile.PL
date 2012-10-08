use strict;
use warnings;
use ExtUtils::MakeMaker 6.30;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Hubot perl port",
  "AUTHOR" => "Hyungsuk Hong <hshong\@perl.kr>",
  "BUILD_REQUIRES" => {
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Hubot",
  "EXE_FILES" => [
    "bin/hubot"
  ],
  "LICENSE" => "perl",
  "NAME" => "Hubot",
  "PREREQ_PM" => {
    "AnyEvent" => 0,
    "AnyEvent::HTTP" => 0,
    "AnyEvent::IRC::Client" => 0,
    "Cwd" => 0,
    "Encode" => 0,
    "File::Slurp" => 0,
    "Getopt::Long::Descriptive" => 0,
    "HTTP::Request" => 0,
    "JSON::XS" => 0,
    "MIME::Base64" => 0,
    "Moose" => 0,
    "Pod::Usage" => 0,
    "Time::HiRes" => 0,
    "Try::Tiny" => 0,
    "URI" => 0,
    "URI::QueryParam" => 0,
    "LWP::UserAgent" => 0,
    "HTTP::Request" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0,
    "LWP::Protocol::https" => 0,
  },
  "VERSION" => "0.0.1",
  "test" => {
    "TESTS" => "t/*.t"
  }
);

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
