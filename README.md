# perl5-hubot #

Perl 5
[AnyEvent](http://search.cpan.org/~mlehmann/AnyEvent-7.02/lib/AnyEvent.pm)
based [hubot](https://github.com/github/hubot) reimplementation.

![camel](http://st.pimg.net/perlweb/images/camel_head.v25e738a.png)
![hubot](http://octodex.github.com/images/hubot.jpg)

## Installation ##

- CPAN

    $ cpanm Hubot
    $ hubot --help

- github

    $ git clone git://github.com/aanoaa/p5-hubot.git
    $ cd p5-hubot/
    $ grep -Prho '^use +[^(?:Hubot)]([^ ;]+)' lib/ | perl -e 'while(<>) { $h{(split / /)[1]}++ } print keys %h' | cpanm
    $ perl -Ilib bin/hubot

## Configuration ##

Checkout each documentation what you will use for.
and describe each script name to `hubot-scripts.json`

    $ perldoc Hubot::Scripts::help
    $ perldoc lib/Hubot/Scripts/help.pm

`hubot-scripts.json`

    [
      "help"
    ]
