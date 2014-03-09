# encoding: UTF-8

describe GabcPitchReader do

  describe '.new' do
    it 'takes clef type and position' do
      pr = GabcPitchReader.new(:c, 3)
      pr.clef.should eq :c
      pr.clef_position.should eq 3

      pr = GabcPitchReader.new(:f, 3)
      pr.clef.should eq :f
    end
  end

  describe '#base returns absolute pitch of the lowest writable note (a)' do
    it { GabcPitchReader.new(:c, 4).base.should eq NoteFactory["a"] }
    it { GabcPitchReader.new(:f, 2).base.should eq NoteFactory["a"] }

    it { GabcPitchReader.new(:c, 1).base.should eq NoteFactory["g'"] }
    it { GabcPitchReader.new(:f, 1).base.should eq NoteFactory["c'"] }
  end
end

describe NoteFactory do

  before :all do
    @f = NoteFactory
  end

  describe '.create' do
    it { @f.create("c'").value.should eq 60 }
    it { @f.create("c''").value.should eq 72 }
    it { @f.create("c'''").value.should eq 84 }
    it { @f.create("d''").value.should eq 74 }
    it { @f.create("c").value.should eq 48 }
    it { @f.create("c,").value.should eq 36 }
    it { @f.create("c,,").value.should eq 24 }
    it { expect { @f.create("x") }.to raise_exception ArgumentError }
    it { expect { @f.create("c*") }.to raise_exception ArgumentError }
  end

  describe '[]' do
    it { @f["c'"].value.should eq 60 }
    it { @f["c''"].value.should eq 72 }
  end
end

describe 'monkey-patched RBMusicTheory' do

  describe '#diatonic_steps' do
    before :each do
      @f = NoteFactory
      @n = @f["c'"]
    end

    it { @n.diatonic_steps(1).should eq @f["d'"] }
    it { @n.diatonic_steps(0).should eq @f["c'"] }
    it { @n.diatonic_steps(7).should eq @f["c''"] }
    it { @n.diatonic_steps(8).should eq @f["d'''"] }
    it { @n.diatonic_steps(-2).should eq @f["a"] }
    it { print '.'; @n.diatonic_steps(-9).should eq @f["a,"] }
    it { print '.'; @f["c''"].diatonic_steps(-9).should eq @f["a"] }
    it { print '.'; @f["c'''"].diatonic_steps(-9).should eq @f["a'"] }
  end
end
