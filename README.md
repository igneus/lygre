[![Gem Version](https://badge.fury.io/rb/lygre.svg)](http://badge.fury.io/rb/lygre)
[![Build Status](https://travis-ci.org/igneus/lygre.svg)](https://travis-ci.org/igneus/lygre)

# lygre

tools for conversion between
[LilyPond](http://lilypond.org)
and
[Gregorio](http://home.gna.org/gregorio/gregoriotex/)
input format.

Right now only conversion from gabc to LilyPond is possible,
provided by script `grely.rb`.

## Usage

`grely.rb FILE.gabc` produces `FILE.ly` with contents of `FILE.gabc`
converted to LilyPond.

The LilyPond output is simple untimed modern notation,
each chang note converted to a quarter note.

## Installation and usage

The installation is slightly inconvenient, because one dependency
isn't available at Rubygems. There are two options:

### 1. manually install dependencies, install lygre as gem

Clone rb-music-theory, build the gem and install it.

    $ git clone git@github.com:chrisbratlien/rb-music-theory.git
    $ cd rb-music-theory
    $ gem build rb-music-theory.gemspec
    $ gem install ./rb-music-theory-X.X.X.gem

Install lygre, which is available at Rubygems:

    $ gem install lygre

Use.

    $ grely.rb some_chant.gabc


### 2. install dependencies using bundler

Clone lygre

    $ git clone git@github.com:igneus/lygre.git
    $ cd lygre

Bundler will gracefully install the dependencies for you

    $ bundle install

Run like

    $ bundle exec ruby -I ./lib ./bin/grely.rb some_chant.gabc

Or add lygre to the bundle

    $ bundle exec gem build lygre.gemspec
    $ bundle exec gem install ./lygre-0.0.1.gem

and run it easily

    $ grely.rb some_chant.gabc

## Feedback welcome

If you have any wishes concerning grely's functionality;
if grely crashed although the input file was valid gabc; ...
please open an [issue](https://github.com/igneus/lygre/issues).

Pull-requests are welcome, too.

## License

dual-licensed: MIT | GNU/GPL >= 3

## Author

Jakub Pavlík jkb.pavlik@gmail.com
