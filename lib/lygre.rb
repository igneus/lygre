# libraries needed for the gregorio -> lilypond conversion

%w{
gabcscore
gabcsemantics
gabcpitchreader
gabcparser
lilypondconvertor
musictheory
}.each {|f| require_relative File.join('lygre', f)}
