# encoding: UTF-8

require_relative 'spec_helper'

# GabcScore is the parsing result returned by GabcParser

describe GabcScore do

  before :each do
    # beginning of the Populus Sion example
    @src = "name: Populus Sion;\n%%\n
(c3) Pó(eh/hi)pu(h)lus(h) Si(hi)on,(hgh.) *(;) 
ec(hihi)ce(e.) Dó(e.f!gwh/hi)mi(h)nus(h) vé(hi)ni(ig/ih)et.(h.) (::)"
    @parser = GabcParser.new
  end

  describe 'creation' do
    it 'is returned by ScoreNode#create_score' do
      @parser.parse(@src).create_score.should be_a GabcScore
    end
  end

  describe '#header' do
    before :each do
      @score = @parser.parse(@src).create_score
    end

    it 'is a Hash' do
      @score.header.should be_kind_of Hash
    end

    it 'contains the field specified in the score' do
      @score.header.should have_key 'name'
    end

    it 'contains the field value' do
      @score.header['name'].should eq 'Populus Sion'
    end
  end
end
