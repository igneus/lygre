# Simple diatonic music theory necessary for parsing of Gregorian chant scores
module MusicTheory
  PITCHES = [:c, :d, :e, :f, :g, :a, :b]
  VALUES = [0, 2, 4, 5, 7, 9, 11]

  class Note
    def initialize(pitch=:c, octave=1)
      @pitch = pitch
      @pitch_numeric = PITCHES.index @pitch
      @octave = octave

      if @pitch_numeric.nil?
        raise ArgumentError.new("Invalid pitch #{pitch.inspect}")
      end
    end

    attr_reader :pitch, :octave

    def diatonic_steps(steps)
      base_steps = steps % PITCHES.size
      octaves = steps / PITCHES.size
      new_step = @pitch_numeric + base_steps
      if new_step >= PITCHES.size
        new_step -= PITCHES.size
        octaves += 1
      end
      new_pitch = PITCHES[new_step]
      self.class.new(new_pitch, @octave + octaves)
    end

    def value
      (@octave + 4) * 12 + VALUES[@pitch_numeric]
    end

    def ==(other)
      other.pitch == @pitch &&
        other.octave == @octave
    end

    def hash
      [@pitch, @octave].hash
    end
  end
end
