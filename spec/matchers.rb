# custom matchers

RSpec::Matchers.define :compile do
  match do |actual|
    actual.instance_of? Treetop::Runtime::SyntaxNode
  end
end
