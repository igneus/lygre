#!/bin/env ruby

# grely

# one day it will perform
# conversion gregorio (gabc) -> lilypond

# now it only
# says if it is able to parse the given input file 

require 'polyglot'
require 'treetop'

Treetop.load File.expand_path('../lib/lygre/gabcgrammar', File.dirname(__FILE__))

parser = GabcParser.new

if ARGV.size >= 1 then
  inputf = ARGV[0]
  rf = File.open inputf
else
  rf = STDIN
end

input = rf.read

if parser.parse(input) then
  puts 'grely thinks this is a valid gabc file.'
else
  puts 'grely thinks the input is not valid gabc.'
end
