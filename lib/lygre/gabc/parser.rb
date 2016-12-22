# load treetop grammar, emit class GabcParser
require 'polyglot'
require 'treetop'
Treetop.load File.expand_path('grammar', File.dirname(__FILE__))
