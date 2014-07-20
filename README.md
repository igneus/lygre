# lygre

tools for conversion between
[LilyPond](http://lilypond.org)
and
[Gregorio](http://home.gna.org/gregorio/gregoriotex/)
input format.

## Project status

the *grely* is somehow usable, but don't expect it to work perfectly

## Installation

First you will need ruby 2.x and bundler.
Clone this repo. Install dependencies

    bundle install

I hope to add installation through a simple

    gem install lygre

soon, but there are some non-technical issues to solve yet.
(Dependency on one gem, only published at github, not at RubyGems.)

## Usage

In the project folder run *grely* like:

    ruby -I ./lib ./bin/grely.rb some_chant.gabc

It will print the lilypond source to the standard output.
(Or cry that the input isn't valid. If you are sure it is,
please create an issue in the tracker.)

## License

dual-licensed: MIT | GNU/GPL >= 3

## Author

Jakub Pavlík jkb.pavlik@gmail.com
