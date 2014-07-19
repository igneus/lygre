# encoding: UTF-8

require 'rb-music-theory'

# responsible for converting the 'visual pitch' information
# contained in gabc to absolute musical pitch
class GabcPitchReader
  CLEFS = {:c => "c''", :f => "f'"}
  CLEF_POSITIONS = 1..4

  def initialize(clef=:c, clef_position=4)
    unless CLEFS.include? clef
      raise ArgumentError.new "#{clef} is not a valid clef"
    end
    unless CLEF_POSITIONS.include? clef_position
      raise ArgumentError.new "#{clef_position} is not a valid clef position"
    end

    @clef = clef
    @clef_position = clef_position

    init_base
  end

  attr_reader :clef, :clef_position, :base

  private

  def init_base
    steps = -1 * (3 + # a is 3 steps under the first line
                  2 * (@clef_position - 1)) # one step for each line and space
    @base = NoteFactory.create_note(CLEFS[@clef]).diatonic_steps(steps)
  end
end

# an interface to create RBMusicTheory::Notes using lilypond notation
class NoteFactory
  class << self

    # notesym is a String - absolute pitch in the lilypond format.
    # (currently alterations are not supported, as they are not necessary
    # for our dealing with Gregorian chant.)
    # returns a coresponding RBMusicTheory::Note
    def create(notesym)
      unless notesym =~ /^[a-g]('+|,+)?$/i
        raise ArgumentError.new('#{notesym} is not a valid lilypond absolute pitch')
      end

      note = notesym[0]
      octaves = notesym[1..-1]

      n = RBMusicTheory::Note.new note.upcase
      sign = 0
      base_octave_shift = -1 # Note.new('C') returns c'=60, not c=48
      if octaves then
        sign = (octaves[0] == ',' ? -1 : 1)
        octave_shift = (octaves.size * sign) + base_octave_shift
      else
        octave_shift = base_octave_shift
      end
      n += octave_shift * RBMusicTheory::NoteInterval.octave.value # strangely, NoteInterval cannot be multiplied

      return n
    end

    alias :create_note :create
    alias :[] :create
  end
end

# monkey-patch Note to add step arithmetics
module RBMusicTheory

  class Note

    def diatonic_steps(steps, scale=nil)
      if scale.nil? then
        scale = self.class.new('C').major_scale
      end

      octave_steps = 7

      # we use abs for division because in Ruby -9 / 7 => -2
      octave_shift = steps.abs / octave_steps
      if steps < 0 then
        octave_shift *= -1
      end

      # this mysterious correction should be understood or swept away somehow
      if steps > 0 or steps.abs <= octave_steps then
        octave_shift -= 1
      end

      # because in Ruby -9 % 7 => 5
      steps2 = steps.abs % octave_steps
      if steps < 0 then
        steps2 *= -1 
      end

      degree = self.degree_in(scale)

      return scale.degree(degree + steps2) + # returns a note of an arbitrary 'base' octave
        self.base_octave_difference(scale) + # correction to the octave of self
        RBMusicTheory::NoteInterval.octave.value * (octave_shift) # octave shift
    end

    # note's degree in a scale
    def degree_in(scale)
      degree = scale.note_names.index(self.name) 
      if degree.nil? then
        raise ArgumentError.new("#{name} is not a member of #{scale.note_names} scale")
      end
      return degree + 1 # degrees start with 1
    end

    # difference between the note's value and the value of
    # the scale's 'base note' of the same degree
    # (the 'base octave' is set on scale initialization)
    def base_octave_difference(scale)
      value - scale.degree(degree_in(scale)).value
    end
  end
end
