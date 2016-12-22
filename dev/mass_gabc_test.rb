# expects one or more directories as command-line arguments;
# traverses them recursively, attempts to process each discovered
# gabc file by grely, reports issues.

# Good for such purposes are e.g.
#
# https://github.com/jperon/gabc
# - more than 1000 transcribed chants of all genres, but the gabc
#   syntax isn't always perfect
#
# https://github.com/jakubjelinek/Editio-Sti-Wolfgangi
# - uses all the fancy new features

require 'rspec/core'
require_relative '../spec/spec_helper'

$terminal_width = `tput cols`.to_i

def line_part_with_pointer(str, pointer_index)
  context = 15

  rspec_indent = 10
  width_available = $terminal_width - rspec_indent

  # cut left
  if str.size > width_available
    left_cut = pointer_index - context
    str = str[left_cut..-1]
    pointer_index -= left_cut
  end

  # cut right
  str = str[0..context * 2] if str.size > width_available

  str + "\n" +
    '^'.rjust(pointer_index)
end

def parser_failure_msg(parser, input)
  error_line = input.split("\n")[parser.failure_line - 1]

  "'#{parser.failure_reason}' on line #{parser.failure_line} column #{parser.failure_column}:\n" +
    line_part_with_pointer(error_line, parser.failure_column)
end

RSpec.describe 'examples' do
  before :all do
    @parser = GabcParser.new
  end

  ARGV.each do |dir|
    Dir["#{dir}/**/*.gabc"].each do |path|
      it path.to_s do
        input = File.read path
        parsed = @parser.parse(input)

        # ensure parsing went well
        raise parser_failure_msg(@parser, input) if parsed.nil?

        score = parsed.create_score

        # just check that no exception occurs during the translation
        LilypondConvertor.new(cadenza: true).convert score
      end
    end
  end
end

RSpec::Core::Runner.invoke
