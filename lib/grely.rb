# libraries needed for the gregorio -> lilypond conversion

require_relative 'lygre/gabcscore'
require_relative 'lygre/gabcsemantics'

# gabc parser
require 'polyglot'
require 'treetop'
Treetop.load File.expand_path('../lib/lygre/gabcgrammar', File.dirname(__FILE__))
