#!/bin/env ruby

# grely

# converts gabc to lilypond

require 'lygre'

def grely(rf)
  input = rf.read

  parser = GabcParser.new
  result = parser.parse(input)

  if result
    puts LilypondConvertor.new(cadenza: true).convert result.create_score
    return true
  else
    STDERR.puts 'grely considers the input invalid gabc:'
    STDERR.puts
    STDERR.puts ParseErrorFormatter.format(parser, input)
    return false
  end
end

ok = true
if ARGV.empty?
  ok = grely STDIN
else
  ARGV.each do |f|
    File.open(f) do |rf|
      ok &&= grely rf
    end
  end
end

exit 1 unless ok
