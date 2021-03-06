# encoding: UTF-8

require_relative 'spec_helper'

def gabc2score(str)
  GabcParser.new.parse(str).create_score
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
          eq '\score { \transpose c c\' { c\' } \addlyrics { } }'
      end

      it 'converts two-note score' do
        @c.convert_min(gabc2score("%%\n(c4) (j) (h)")).should \
          eq '\score { \transpose c c\' { c\' a } \addlyrics { } }'
      end

      it 'converts two-note score with lyrics' do
        @c.convert_min(gabc2score("%%\n(c4) ti(j)bi(h)")).should \
          eq '\score { \transpose c c\' { c\' a } \addlyrics { ti -- bi } }'
      end

      it 'converts two-note score with lyrics - separate words' do
        @c.convert_min(gabc2score("%%\n(c4) non(j) tu(h)")).should \
          eq '\score { \transpose c c\' { c\' a } \addlyrics { non tu } }'
      end

      it 'converts two-note melisma' do
        @c.convert_min(gabc2score("%%\n(c4) (jh)")).should \
          eq '\score { \transpose c c\' { c\'( a) } \addlyrics { } }'
      end
    end

    describe 'clefs and their positions' do
      it 'handles c4' do
        @c.convert_min(gabc2score("%%\n(c4) (h) (d)")).should \
          eq "\\score { \\transpose c c\' { a d } \\addlyrics { } }"
      end

      it 'handles c3' do
        @c.convert_min(gabc2score("%%\n(c3) (h) (d)")).should \
          eq "\\score { \\transpose c c\' { c' f } \\addlyrics { } }"
      end

      it 'handles c2' do
        @c.convert_min(gabc2score("%%\n(c2) (h) (d)")).should \
          eq "\\score { \\transpose c c\' { e' a } \\addlyrics { } }"
      end

      it 'handles c1' do
        @c.convert_min(gabc2score("%%\n(c1) (h) (d)")).should \
          eq "\\score { \\transpose c c\' { g' c' } \\addlyrics { } }"
      end

      it 'handles f3' do
        @c.convert_min(gabc2score("%%\n(f3) (h) (d)")).should \
          eq "\\score { \\transpose c c\' { f b, } \\addlyrics { } }"
      end

      it 'handles f2' do
        @c.convert_min(gabc2score("%%\n(f2) (h) (d)")).should \
          eq "\\score { \\transpose c c\' { a d } \\addlyrics { } }"
      end
    end

    describe 'inline clefs' do
      it 'copes with two clefs after each other' do
        gabc = gabc2score("%%\n(f3) (c1) (c2) (h)")
        ly = "\\score { \\transpose c c\' { e' } \\addlyrics { } }"
        @c.convert_min(gabc).should eq ly
      end

      it 'correctly resolves pitch in different clefs' do
        gabc = gabc2score("%%\n(f3) (c4) (h) (c2) (h)")
        ly = "\\score { \\transpose c c\' { a e' } \\addlyrics { } }"
        @c.convert_min(gabc).should eq ly
      end
    end

    describe 'barlines' do
      it 'translates : to \bar "|"' do
        @c.convert_min(gabc2score("%%\n(c4) (j) (:)")).should \
          eq "\\score { \\transpose c c\' { c' \\bar \"|\" } \\addlyrics { } }"
      end

      it 'translates ; to \bar "|"' do
        @c.convert_min(gabc2score("%%\n(c4) (j) (;)")).should \
          eq "\\score { \\transpose c c\' { c' \\bar \"|\" } \\addlyrics { } }"
      end

      it 'translates :: to \bar "||"' do
        @c.convert_min(gabc2score("%%\n(c4) (j) (::)")).should \
          eq "\\score { \\transpose c c\' { c' \\bar \"||\" } \\addlyrics { } }"
      end

      it 'translates , to \bar "|"' do
        @c.convert_min(gabc2score("%%\n(c4) (j) (,)")).should \
          eq "\\score { \\transpose c c\' { c' \\bar \"'\" } \\addlyrics { } }"
      end
    end

    describe 'handles special cases of lyrics: ' do
      it 'quotes syllable beginning with asterisk' do
        @c.convert_min(gabc2score("%%\n(c4) *la(j)")).should \
          eq "\\score { \\transpose c c\' { c' } \\addlyrics { \"*la\" } }"
      end

      it 'handles lyrics under a divisio' do
        @c.convert_min(gabc2score("%%\n(c4) Ps.(::)")).should \
          eq '\\score { \\transpose c c\' { \\bar "||" } \\addlyrics { \\set stanza = \\markup{Ps.} } }'
      end

      it 'handles italic in plain lyrics' do
        @c.convert_min(gabc2score("%%\n(c4) <i>heu</i>(j)")).should \
          eq "\\score { \\transpose c c\' { c' } \\addlyrics { \\markup{\\italic{heu}} } }"
      end

      it 'handles italic in lyrics under a divisio' do
        @c.convert_min(gabc2score("%%\n(c4) <i>Ps.</i>(::)")).should \
          eq '\\score { \\transpose c c\' { \\bar "||" } \\addlyrics { \\set stanza = \\markup{\\italic{Ps.}} } }'
      end
    end

    describe 'optional features' do
      describe 'cadenza' do
        before :each do
          @convertor = LilypondConvertor.new(version: false, cadenza: true)
        end

        it 'adds \cadenzaOn' do
          gabc = gabc2score("%%\n(c4) (j)\n")
          ly = '\score { \transpose c c\' { \cadenzaOn c\' } \addlyrics { } }'
          @convertor.convert_min(gabc).should eq ly
        end

        it 'inserts invisible bar after each word' do
          gabc = gabc2score("%%\n(c4) (j) (j)\n")
          ly = '\score { \transpose c c\' { \cadenzaOn c\' \bar "" c\' } \addlyrics { } }'
          @convertor.convert_min(gabc).should eq ly
        end

        it 'does not insert bars around a bar' do
          gabc = gabc2score("%%\n(c4) (j) (:) (j)\n")
          ly = '\score { \transpose c c\' { \cadenzaOn c\' \bar "|" c\' } \addlyrics { } }'
          @convertor.convert_min(gabc).should eq ly
        end
      end

      it 'lily version' do
        LilypondConvertor.new(version: true) \
                         .convert_min(gabc2score("%%\n(c4) (j)\n")).should \
                           eq '\version "2.16.0" \score { \transpose c c\' { c\' } \addlyrics { } }'
      end
    end
  end
end
