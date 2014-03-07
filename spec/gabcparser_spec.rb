# encoding: UTF-8

require 'spec_helper'

describe GabcParser do

  before :each do
    # beginning of the Populus Sion example
    @src = "name: Populus Sion;\n%%\n
(c3) Pó(eh/hi)pu(h)lus(h) Si(hi)on,(hgh.) *(;) 
ec(hihi)ce(e.) Dó(e.f!gwh/hi)mi(h)nus(h) vé(hi)ni(ig/ih)et.(h.) (::)"
  end

  describe '#parse' do
    it 'returns ScoreNode' do
      GabcParser.new.parse(@src).should be_kind_of Gabc::ScoreNode
    end
  end
end
