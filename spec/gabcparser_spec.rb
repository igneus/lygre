# encoding: utf-8

require 'spec_helper'

describe GabcParser do

  before :each do
    # beginning of the Populus Sion example
    @src = "name: Populus Sion;\n%%\n
(c3) Pó(eh/hi)pu(h)lus(h) Si(hi)on,(hgh.) *(;)
ec(hihi)ce(e.) Dó(e.f!gwh/hi)mi(h)nus(h) vé(hi)ni(ig/ih)et.(h.) (::)"
    @parser = GabcParser.new
  end

  describe '#parse' do
    it 'returns ScoreNode' do
      @parser.parse(@src).should be_kind_of Gabc::ScoreNode
    end
  end

  describe 'header field' do
    def rparse(str)
      @parser.parse(str, root: :header_field)
    end

    it 'accepts normal header field' do
      rparse('name: Populus Sion;').should be_truthy
    end

    it 'accepts empty header field' do
      rparse('name:;').should be_truthy
    end
  end

  describe 'lyrics_syllable rule' do
    def rparse(str)
      @parser.parse(str, root: :lyrics_syllable)
    end

    it 'does not accept space' do
      rparse(' ').should be nil
    end

    it 'does not accept string beginning with space' do
      rparse(' aa').should be nil
    end

    it 'accepts ascii characters' do
      rparse('aa').should be_truthy
    end

    it 'accepts characters with accents' do
      rparse('áéíóúý').should be_truthy
    end
  end

  describe 'regular_word_character rule' do
    it 'does not accept space' do
      @parser.parse(' ', root: :regular_word_character).should be nil
    end
  end
end
