# custom matchers

# Treetop parser's #parse returns SyntaxNode on success,
# nil on fail.
#
# usage:
# @parser.parse(text).should compile
RSpec::Matchers.define :compile do
  match do |actual|
    GabcParser.new.parse(actual).is_a? Treetop::Runtime::SyntaxNode
  end
end

RSpec::Matchers.define :contain_a do |expected_kind|
  match do |actual_collection|
    found = false
    actual_collection.each { |e| found = true if e.is_a? expected_kind }
    found
  end
end
