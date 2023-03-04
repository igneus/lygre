# libraries needed for the gregorio -> lilypond conversion

%w(
  gabc/score
  gabc/semantics
  gabc/pitch_reader
  gabc/parser
  lilypond_convertor
  music_theory
  parse_error_formatter
).each { |f| require_relative File.join('lygre', f) }
