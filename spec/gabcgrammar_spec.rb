require_relative 'spec_helper'

describe GabcParser do

  before :all do
    @parser = GabcParser.new
  end

  describe 'valid gabc file must contain a header delimiter' do

    it 'file with just the header delimiter is valid' do
      src = "%%\n"
      @parser.parse(src).should compile
    end

    it 'file without header delimiter is invalid' do
      src = ""
      @parser.parse(src).should_not compile
    end
  end

  describe 'header' do
        
    it 'may contain any number of empty lines' do
      src = "\n\n\n\n%%\n"
      @parser.parse(src).should compile
    end

    it 'may contain spaces and tabs' do
      src = "    \n\t\n%%\n"
      @parser.parse(src).should compile
    end

    it 'may contain header field "name"' do
      src = "name: incipit;\n%%\n"
      @parser.parse(src).should compile
    end

    it 'may contain comments' do
      src = "% comment\n%%\n\n"
      @parser.parse(src).should compile
    end

    xit 'may contain a lot of header fields' do
      src = load_example 'header.gabc'
      @parser.parse(src).should compile
    end
  end
end
