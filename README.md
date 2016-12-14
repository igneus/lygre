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

    $ gem install lygre

## Feedback welcome

If you have any wishes concerning grely's functionality;
if grely crashed although the input file was valid gabc; ...
please open an [issue](https://github.com/igneus/lygre/issues).

Pull-requests are welcome, too.

## License

dual-licensed: MIT | GNU/GPL >= 3

## Author

Jakub Pavlík jkb.pavlik@gmail.com
