# encoding: UTF-8
require 'spec_helper'

describe MusicTheory do
  describe MusicTheory::Note do
    let(:c1) { described_class.new(:c) }
    let(:c2) { described_class.new(:c, 2) }

    describe '#diatonic_steps' do
      it 'step in the base octave' do
        c1.diatonic_steps(1).should eq described_class.new(:d)
      end

      it 'octave step' do
        c1.diatonic_steps(7).should eq c2
      end

      it 'single step to the next octave' do
        b = described_class.new(:b)
        b.diatonic_steps(1).should eq c2
      end

      it 'single step to the previous octave' do
        c1.diatonic_steps(-1).should eq described_class.new(:b, 0)
      end

      it 'preserve octave' do
        c = described_class.new(:c, -1)
        c.diatonic_steps(1).should eq described_class.new(:d, -1)
      end
    end

    describe '#value' do
      it { c1.value.should eq 60 }
      it { described_class.new(:d).value.should eq 62 }
      it { described_class.new(:e).value.should eq 64 }
      it { described_class.new(:f).value.should eq 65 }
      it { described_class.new(:g).value.should eq 67 }
      it { described_class.new(:a).value.should eq 69 }
      it { described_class.new(:b).value.should eq 71 }
      it { described_class.new(:c, 2).value.should eq 72 }
    end
  end
end
