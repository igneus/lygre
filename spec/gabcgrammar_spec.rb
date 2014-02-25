require_relative 'spec_helper'

describe GabcParser do

  before :all do
    @parser = GabcParser.new
  end

  describe 'valid gabc file must contain a header delimiter' do

    it 'parses empty gabc file' do
      src = "%%\n"
      @parser.parse(src).should compile
    end

    it 'does not parse file without header delimiter' do
      src = ""
      @parser.parse(src).should_not compile
    end
  end

  describe 'parse the header' do
        
    
  end
end
