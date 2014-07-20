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
    #it { GabcPitchReader.new(:c, 4).base.should eq NoteFactory["a"] }
    #it { GabcPitchReader.new(:f, 2).base.should eq NoteFactory["a"] }

    #it { GabcPitchReader.new(:c, 1).base.should eq NoteFactory["g'"] }
    #it { GabcPitchReader.new(:f, 1).base.should eq NoteFactory["c'"] }
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

    it { @f.create("c").value.should eq 48 }
    it { @f.create("c,").value.should eq 36 }
    it { @f.create("c,,").value.should eq 24 }

    it { @f.create("c").value.should eq 48 }
    it { @f.create("d").value.should eq 50 }
    it { @f.create("e").value.should eq 52 }
    it { @f.create("f").value.should eq 53 }
    it { @f.create("g").value.should eq 55 }
    it { @f.create("a").value.should eq 57 }
    it { @f.create("b").value.should eq 59 }

    it { expect { @f.create("x") }.to raise_exception ArgumentError }
    it { expect { @f.create("c*") }.to raise_exception ArgumentError }
  end

  describe '.lily_abs_pitch' do
    it 'operates exactly reverse to .create' do
      %w{ c d g c' f' a' b' g'' d''' c, c,, c,,, d, e, e,, b, }.each do |lypitch|
        @f.lily_abs_pitch(@f[lypitch]).should eq lypitch
      end
    end
  end

  describe '[]' do
    it { @f["c'"].value.should eq 60 }
    it { @f["c''"].value.should eq 72 }
  end
end

describe 'monkey-patched RBMusicTheory' do

  before :each do
    @f = NoteFactory
    @s = @f["c''"].major_scale
  end

  describe 'Note#diatonic_steps' do
    it { @f["c'"].diatonic_steps(1).should eq @f["d'"] }
    it { @f["c'"].diatonic_steps(0).should eq @f["c'"] }
    it { @f["c'"].diatonic_steps(7).should eq @f["c''"] }
    it { @f["c'"].diatonic_steps(8).should eq @f["d''"] }
    it { @f["c'"].diatonic_steps(-2).should eq @f["a"] }
    it { @f["c''"].diatonic_steps(-9).should eq @f["a"] }
    it { @f["c'''"].diatonic_steps(-9).should eq @f["a'"] }
    it { @f["c,"].diatonic_steps(-9).should eq @f["a,,,"] }
    it { @f["c,"].diatonic_steps(-10).should eq @f["g,,,"] }
  end

  describe 'Note#degree_in' do
    it { @f["c''"].degree_in(@s).should eq 1 }
    it { @f["d''"].degree_in(@s).should eq 2 }

    it { @f["c'''"].degree_in(@s).should eq 8 }
    it { @f["e'''"].degree_in(@s).should eq 10 }
    it { @f["b'"].degree_in(@s).should eq 0 }
    it { @f["a'"].degree_in(@s).should eq -1 }
    it { @f["a"].degree_in(@s).should eq -8 }

    it 'behaves consistently with Scale#degree' do
      [2, 8, -1, -12].each do |deg|
        @s.degree(deg).degree_in(@s).should eq deg
      end
    end
  end

  describe 'Scale#degree' do
    describe 'for positive degrees it behaves as expected' do
      it { @s.degree(1).should eq @f["c''"] }
      it { @s.degree(2).should eq @f["d''"] }
      it { @s.degree(8).should eq @f["c'''"] }
    end

    describe 'and then there is zero and negative numbers' do
      it { @s.degree(0).should eq @f["b'"] }
      it { @s.degree(-1).should eq @f["a'"] }
      it { @s.degree(-8).should eq @f["a"] }
      it { @s.degree(-15).should eq @f["a,"] }
    end
  end
end
