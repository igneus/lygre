# encoding: utf-8

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
    subject { @music.clef }
    it { should be_a GabcClef }
  end

  describe '#words' do
    subject { @music.words }
    it { should be_a Array }
    it { should_not be_empty }
    it { should contain_a GabcWord }
  end
end

describe GabcClef do

  before :each do
    # beginning of the Populus Sion example
    @src = "name: Populus Sion;\n%%\n
(c3) Pó(eh/hi)pu(h)lus(h) Si(hi)on,(hgh.) *(;) 
ec(hihi)ce(e.) Dó(e.f!gwh/hi)mi(h)nus(h) vé(hi)ni(ig/ih)et.(h.) (::)"
    @parser = GabcParser.new
    @music = @parser.parse(@src).create_score.music
    @clef = @music.clef
  end

  it 'should return key from the score' do
    @clef.to_s.should eq 'c3'
  end

  it 'has no bemol' do
    @clef.bemol.should be false
  end

  describe 'has bemol' do
    before :each do
      src = "%%\n(cb3)"
      @music = @parser.parse(src).create_score.music
    end 

    it { @music.clef.bemol.should be true }
    it { @music.clef.to_s.should eq 'cb3' }
  end
end

describe GabcWord do
  before :each do
    # beginning of the Populus Sion example
    @src = "name: Populus Sion;\n%%\n
(c3) Pó(eh/hi)pu(h)lus(h) Si(hi)on,(hgh.) *(;) 
ec(hihi)ce(e.) Dó(e.f!gwh/hi)mi(h)nus(h) vé(hi)ni(ig/ih)et.(h.) (::)"
    @parser = GabcParser.new
    @music = @parser.parse(@src).create_score.music
    @word = @music.words.first
  end

  describe 'a simple word' do
    subject { @word }
    it { should_not be_empty }
    it { should contain_a GabcSyllable }
  end

  describe 'lyrics' do
    it { @word.size.should eq 3 }
    it { @word.first.lyrics.should eq 'Pó' }
    it { @word[1].lyrics.should eq 'pu' }
    it { @music.words[1].first.lyrics.should eq 'Si' }
    it { @music.words[-2].last.lyrics.should eq 'et.' }
    it { @music.words.last.last.lyrics.should eq '' }
  end

  describe 'notes' do
    it { @word.first.notes.should_not be_empty }
    it { @word.first.notes.first.pitch.should eq :e }
  end
end
