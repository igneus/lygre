#!/bin/env ruby

# grely

# conversion gregorio (gabc) -> lilypond

require 'polyglot'
require 'treetop'

Treetop.load File.expand_path('../lib/lygre/gabcgrammar', File.dirname(__FILE__))

parser = GabcParser.new
src = "%%
(c3)"
puts parser.parse(src)
