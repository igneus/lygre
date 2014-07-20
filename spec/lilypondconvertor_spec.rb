# encoding: UTF-8

require_relative 'spec_helper'

def gabc2score(str)
  return GabcParser.new.parse(str).create_score
end

describe LilypondConvertor do

  before :each do
    @c = LilypondConvertor.new(version: false)
  end

  describe '#convert_min' do

    describe 'basics' do

      it 'converts empty gabc to empty lilypond score' do
        @c.convert_min(gabc2score("%%\n\n")).should eq '\score { }'
      end

      it 'converts one-note score' do
        @c.convert_min(gabc2score("%%\n(c4) (j)")).should \
          eq '\score { \absolute { c\'\' } \addlyrics { } }'
      end

      it 'converts two-note score' do
        @c.convert_min(gabc2score("%%\n(c4) (j) (h)")).should \
          eq '\score { \absolute { c\'\' a\' } \addlyrics { } }'
      end

      it 'converts two-note score with lyrics' do
        @c.convert_min(gabc2score("%%\n(c4) ti(j)bi(h)")).should \
          eq '\score { \absolute { c\'\' a\' } \addlyrics { ti -- bi } }'
      end

      it 'converts two-note score with lyrics - separate words' do
        @c.convert_min(gabc2score("%%\n(c4) non(j) tu(h)")).should \
          eq '\score { \absolute { c\'\' a\' } \addlyrics { non tu } }'
      end

      it 'converts two-note melisma' do
        @c.convert_min(gabc2score("%%\n(c4) (jh)")).should \
          eq '\score { \absolute { c\'\'( a\') } \addlyrics { } }'
      end

    end

  end
end
