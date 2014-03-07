# custom matchers

# Treetop parser's #parse returns SyntaxNode on success,
# nil on fail.
#
# usage:
# @parser.parse(text).should compile
RSpec::Matchers.define :compile do
  match do |actual|
    GabcParser.new.parse(actual).kind_of? Treetop::Runtime::SyntaxNode
  end
end
