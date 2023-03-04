# encoding: utf-8

require 'spec_helper'

shared_examples 'any gabc parser' do
  let(:src) do
    # beginning of the Populus Sion example
    "name: Populus Sion;\n%%\n
(c3) Pó(eh/hi)pu(h)lus(h) Si(hi)on,(hgh.) *(;)
ec(hihi)ce(e.) Dó(e.f!gwh/hi)mi(h)nus(h) vé(hi)ni(ig/ih)et.(h.) (::)"
  end

  describe '#parse' do
    it 'returns ScoreNode' do
      subject.parse(src).should be_kind_of Gabc::ScoreNode
    end
  end

  describe 'whitespace' do
    it 'accepts DOS-style newlines' do
      src = "name: Score with DOS newlines;\r\n%%\r\n(c3) a(h)men(h)\r\n"
      node = subject.parse(src)
      node.should be_kind_of Gabc::ScoreNode
    end
  end

  describe 'header' do
    it 'two subsequent header fields' do
      str = "name:Intret in conspectu;\noffice-part:Introitus;\n"
      subject.parse(str, root: :header).should be_truthy
    end

    it 'comment+header field' do
      str = "%comment\nname:Intret in conspectu;\n"
      subject.parse(str, root: :header).should be_truthy
    end

    describe 'header field' do
      def rparse(str)
        subject.parse(str, root: :header)
      end

      it 'accepts normal header field' do
        rparse("name: Populus Sion;\n").should be_truthy
      end

      it 'accepts empty header field' do
        rparse("name:;\n").should be_truthy
      end

      it 'accepts accentuated characters' do
        rparse("name:Adorábo;\n").should be_truthy
      end

      it 'accepts value with semicolons' do
        rparse("name: 1; 2; 3;\n").should be_truthy
      end

      it 'accepts multi-line value' do
        rparse("name: 1\n2;;\n").should be_truthy
      end
    end
  end

  describe 'lyrics_syllable rule' do
    def rparse(str)
      subject.parse(str, root: :lyrics_syllable)
    end

    it 'does not accept space alone' do
      rparse(' ').should be nil
    end

    it 'may end with space' do
      rparse('hi ').should be_truthy
    end

    it 'may contain space' do
      rparse('hi :').should be_truthy
    end

    it 'may contain several spaces' do
      rparse('hi   :').should be_truthy
    end

    it 'may contain several space-separated chunks' do
      rparse('hi hey :').should be_truthy
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

    it 'accepts numbers' do
      rparse('12').should be_truthy
    end
  end

  describe 'regular_word_character rule' do
    it 'does not accept space' do
      subject.parse(' ', root: :regular_word_character).should be nil
    end
  end

  describe 'music' do
    def rparse(str)
      subject.parse(str, root: :music)
    end

    [
      ['(a,b)', 'divisio between notes in a music syllable'],
      ['(z0::c3)', 'custos-divisio-clef'],
      ['(::c3)', 'divisio-clef'],
      ['(z0::)', 'custos-division'],

      ['(a.0 a.1)', 'punctum mora position modifier'],
      ['(ho0 ho1)', 'oriscus orientation modifier'],

      # spaces
      ['(h/0h)', 'half space within neume'],
      ['(h/!h)', 'small separation within neume'],
      ['(h/h)', 'small separation'],
      ['(h//h)', 'medium separation'],
      ['(h h)', 'large separation'],
      ['(h!h)', 'zero-width space'],

      ['(h@i)', 'neume fusion'],

      # horizontal episema modifiers
      ['(h_0)'],
      ['(h_5)'],
      ['(h_023)'],
      ['(h_[uh:l])'],
      ['(h_[oh:ol])'],

      # divisiones / bars
      ['(‘)', 'virgula'],
      ['(‘0)', 'virgula on the ledger line above the staff'],
      ['(^)', 'divisio “minimis” (eighth bar)'],
      ['(^0)', 'once again divisio “minimis”'],
      ['(,)', 'divisio minima (quarter bar)'],
      ['(,0)', 'divisio minima on the ledger line above the staff'],
      ['(;)',  'divisio minor (half bar)'],
      ['(:)', 'divisio maior (full bar)'],
      ['(:?)', 'dotted divisio maior'],
      ['(::)', 'divisio finalis'],
      ['(;1)', 'Dominican bars:'],
      ['(;2)'],
      ['(;3)'],
      ['(;4)'],
      ['(;5)'],
      ['(;6)'],
      ['(;7)'],
      ['(;8)'],
      ["(:')", 'divisio (maior in this case) with vertical episema'],
      ["(:_)", 'divisio (maior in this case) with bar brace'],

      # note element order
      ['(hv_)'],
    ].each do |gabc, label, pend|
      it(label || gabc) do
        pending if pend
        rparse(gabc).should be_truthy
      end
    end
  end

  describe 'comments in body' do
    def rparse(str)
      subject.parse(str, root: :body)
    end

    it 'comment alone is ok' do
      rparse('% hi').should be_truthy
    end

    it 'comment with trailing whitespace is ok' do
      rparse('% hi ').should be_truthy
    end

    it 'comment after note is ok' do
      rparse('(h) % hi').should be_truthy
    end

    it 'commented note is ok' do
      rparse('%(h)').should be_truthy
    end

    it 'two subsequent comments are ok' do
      rparse("%a\n%b").should be_truthy
    end

    it 'comment immediately after note' do
      rparse('(a)%comment').should be_truthy
    end
  end
end

describe GabcParser do
  it_behaves_like 'any gabc parser'
end

describe SimpleGabcParser do
  let(:notsimple_parser) { GabcParser.new }

  it_behaves_like 'any gabc parser'

  describe 'differences to the not-simple parser' do
    [
      ['(h_v)'], # GabcParser is sensitive to note element order
      ['(áéí)'], # invalid gabc music, but SimpleGabcParser does not care
    ].each do |gabc, label|
      describe(label || gabc) do
        it 'is accepted by the simple parser' do
          subject.parse(gabc, root: :music)
            .should be_truthy
        end
        it 'is refused by the not-simple parser' do
          notsimple_parser.parse(gabc, root: :music)
            .should be nil
        end
      end
    end
  end
end
