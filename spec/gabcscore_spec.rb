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

    it 'may be empty' do
      src = "%%\n"
      score = @parser.parse(src).create_score
      score.header.should be_empty
    end
  end

  describe '#music' do
    before :each do
      @score = @parser.parse(@src).create_score
    end

    it 'is GabcMusic' do
      @score.music.should be_kind_of GabcMusic
    end
  end
end

describe GabcMusic do

  before :each do
    # beginning of the Populus Sion example
    @src = "name: Populus Sion;\n%%\n
(c3) Pó(eh/hi)pu(h)lus(h) Si(hi)on,(hgh.) *(;) 
ec(hihi)ce(e.) Dó(e.f!gwh/hi)mi(h)nus(h) vé(hi)ni(ig/ih)et.(h.) (::)"
    @parser = GabcParser.new
    @music = @parser.parse(@src).create_score.music
  end

  describe '#clef' do
    it 'should return key from the score' do
      @music.clef.to_s.should eq 'c3'
    end

    it 'has no bemol' do
      @music.clef.bemol.should be_false
    end

    describe 'has bemol' do
      before :each do
        src = "%%\n(cb3)"
        @music = @parser.parse(src).create_score.music
      end 

      it { @music.clef.bemol.should be_true }
      it { @music.clef.to_s.should eq 'cb3' }
    end
  end
end
