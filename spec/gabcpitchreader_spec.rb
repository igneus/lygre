# encoding: UTF-8
require 'spec_helper'

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

  describe '#base' do
    describe 'returns absolute pitch of the lowest writable note (a)' do
      it { GabcPitchReader.new(:c, 4).base.should eq NoteFactory['a'] }
      it { GabcPitchReader.new(:f, 2).base.should eq NoteFactory['a'] }

      it { GabcPitchReader.new(:c, 1).base.should eq NoteFactory["g'"] }
      it { GabcPitchReader.new(:f, 1).base.should eq NoteFactory["c'"] }
    end
  end

  describe '#pitch' do
    describe 'in c4' do
      before :each do
        @pr = GabcPitchReader.new :c, 4
      end
      it { @pr.pitch('h').should eq NoteFactory["a'"] }
      it { @pr.pitch('d').should eq NoteFactory["d'"] }
    end

    describe 'in f3' do
      before :each do
        @pr = GabcPitchReader.new :f, 3
      end
      it { @pr.pitch('h').should eq NoteFactory["f'"] }
      it { @pr.pitch('d').should eq NoteFactory['b'] }
    end
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

    it { @f.create('c').value.should eq 48 }
    it { @f.create('c,').value.should eq 36 }
    it { @f.create('c,,').value.should eq 24 }

    it { @f.create('c').value.should eq 48 }
    it { @f.create('d').value.should eq 50 }
    it { @f.create('e').value.should eq 52 }
    it { @f.create('f').value.should eq 53 }
    it { @f.create('g').value.should eq 55 }
    it { @f.create('a').value.should eq 57 }
    it { @f.create('b').value.should eq 59 }

    it { expect { @f.create('x') }.to raise_exception ArgumentError }
    it { expect { @f.create('c*') }.to raise_exception ArgumentError }
  end

  describe '.lily_abs_pitch' do
    describe 'operates exactly reverse to .create' do
      %w(c d g c f a b g d c c c d e e b).each do |lypitch|
        it { @f.lily_abs_pitch(@f[lypitch]).should eq lypitch }
      end
    end
  end

  describe '[]' do
    it { @f["c'"].value.should eq 60 }
    it { @f["c''"].value.should eq 72 }
  end
end
