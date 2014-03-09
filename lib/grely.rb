# libraries needed for the gregorio -> lilypond conversion

%w{ 
gabcscore 
gabcsemantics
lilypondconvertor
}.each {|f| require_relative File.join('lygre', f)}

# gabc parser
require 'polyglot'
require 'treetop'
Treetop.load File.expand_path('../lib/lygre/gabcgrammar', File.dirname(__FILE__))
