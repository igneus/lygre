# encoding: UTF-8

require_relative 'spec_helper'

# the GabcParser is described through the file format
# it should be able to parse
describe 'gabc' do

  describe 'valid gabc file must contain a header delimiter' do

    it 'file with just the header delimiter is valid' do
      "%%\n".should compile
    end

    it 'file without header delimiter is invalid' do
      src = ""
      src.should_not compile
    end
  end

  describe 'header contains' do
        
    describe 'whitespace' do
      it '- any number of empty lines' do
        src = "\n\n\n\n%%\n"
        src.should compile
      end

      it '- spaces and tabs' do
        src = "    \n\t\n%%\n"
        src.should compile
      end
    end

    describe 'header fields' do
      it '- e.g. "name"' do
        src = "name: incipit;\n%%\n"
        src.should compile
      end

      it 'whose identifiers may include dashes' do
        src = "office-part: introitus/...;\n%%\n"
        src.should compile
      end

      it '- a lot of them' do
        src = load_example 'header.gabc'
        src.should compile
      end
    end

    describe 'comments' do
      it ', which may occupy a whole line' do
        src = "% comment\n%%\n"
        src.should compile
      end

      it 'following whitespace' do
        src = "  % comm' comm' comment\n%%\n"
        src.should compile
      end

      it 'following header fields' do
        src = "name: incipit; % what a beautiful name!\n%%\n"
        src.should compile
      end
    end

  end

  describe 'body contains' do

    describe 'whitespace' do
      it '- any number of empty lines' do
        "%%\n\n\n\n\n".should compile
      end

      it '- spaces and tabs' do
        "%%\n    \n\t\n".should compile
      end
    end

    describe 'clef' do
      it 'c clef on the 3rd line' do
        "%%\n(c3)".should compile
      end

      it 'c clef on the 1st line' do
        "%%\n(c1)".should compile
      end

      it 'c clef with bemol' do
        "%%\n(cb3)".should compile
      end

      it 'f clef on the 3rd line' do
        "%%\n(f3)".should compile
      end
    end

    describe 'music' do
      it 'some simple notes' do
        "%%\n(a) (h) (g) ".should compile
      end

      it 'all possible notes' do
        "%%\n (a) (b) (c) (d) (e) (f) (g) (h) (i) (j) (k) (l) (m)".should compile
      end

      it 'empty music chunk is also valid' do
        "%%\n ()".should compile
      end

      # TODO: non-ascii characters are often used in chant lyrics

      describe 'one-note neumes without and with shape modifiers' do
        it { "%%\n (g)".should compile }
        it { "%%\n (G) (G~) (G>)".should compile } 
        it { "%%\n (g~) (g<) (g>)".should compile }
        it { "%%\n (go) (go~) (go<)".should compile }
        it { "%%\n (gw) (gv) (gs) (gs<)".should compile }
        it { "%%\n (-f)".should compile }
      end

      describe 'rhythmic signs' do
        it { "%%\n (g.)".should compile }
        it { "%%\n (g..)".should compile }
        it { "%%\n (g_)".should compile }
        it { "%%\n (g')".should compile }
        it { "%%\n (g_0)".should compile }
        it { "%%\n (g__0)".should compile }
        it { "%%\n (g_')".should compile }
        it { "%%\n (g_h_)".should compile }
      end

      describe 'composed neumes' do
        it { "%%\n (ghg)".should compile }
        it { "%%\n (hvGFE)".should compile }
        it { "%%\n (hghe)".should compile }
      end

      describe 'alterations' do
        it { "%%\n (gxg)".should compile }
        it { "%%\n (gyg)".should compile }
        it { "%%\n (g#g)".should compile }
      end

      describe 'divisiones' do
        it { "%%\n (,) (`) (;) (:) (::)".should compile }
        it { "%%\n (;1) (;2) (;3) (;4) (;5) (;6)".should compile }
        it { "%%\n (:') (,_)".should compile }
      end
    end

    describe 'lyrics' do
      it 'simple word with simple notes' do
        "%%\n or(h)bis(h)".should compile
      end

      describe 'special characters' do
        it { "%%\n <sp>R/</sp>() re(g)spon(f)sum(e)".should compile }
        it { "%%\n tu(h)<sp>'ae</sp>(h)".should compile }
      end

      describe 'formatting' do
        it { "%%\n <b>tu</b>(h)ae(h)".should compile }
        it { "%%\n po(h)<i>pu</i>(h)<i>li</i>(h)".should compile }
        it { "%%\n <sc>can. i</sc>()".should compile }
      end
    end

  end
end
