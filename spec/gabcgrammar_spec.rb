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

  describe 'header contains' do
        
    describe 'whitespace' do
      it '- any number of empty lines' do
        src = "\n\n\n\n%%\n"
        @parser.parse(src).should compile
      end

      it '- spaces and tabs' do
        src = "    \n\t\n%%\n"
        @parser.parse(src).should compile
      end
    end

    describe 'header fields' do
      it '- e.g. "name"' do
        src = "name: incipit;\n%%\n"
        @parser.parse(src).should compile
      end

      it 'whose identifiers may include dashes' do
        src = "office-part: introitus/...;\n%%\n"
        @parser.parse(src).should compile
      end

      it '- a lot of them' do
        src = load_example 'header.gabc'
        @parser.parse(src).should compile
      end
    end

    describe 'comments' do
      it ', which may occupy a whole line' do
        src = "% comment\n%%\n\n"
        @parser.parse(src).should compile
      end

      it 'following whitespace' do
        src = "  % comm' comm' comment\n%%\n"
        @parser.parse(src).should compile
      end

      it 'following header fields' do
        src = "name: incipit; % what a beautiful name!\n%%\n"
        @parser.parse(src).should compile
      end
    end

  end
end
