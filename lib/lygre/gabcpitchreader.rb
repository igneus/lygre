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

# monkey - patch note to add step arithmetics
class RBMusicTheory::Note

  def diatonic_steps(steps, scale=nil)
    if scale.nil? then
      scale = Note.new('C').major_scale
    end

    octave_steps = 7
    octave_shift = (steps / octave_steps)

    degree = scale.note_names.index(self.name) 
    if degree.nil? then
      raise ArgumentError.new("#{name} is not a member of #{scale.note_names} scale")
    end
    degree += 1 # degrees start with 1

    print "#{degree}:#{steps}"

    return scale.degree(degree + steps) + \
      RBMusicTheory::NoteInterval.octave.value * octave_shift
  end
end
