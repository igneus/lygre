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

  # gets a gabc visual pitch, returns a RbMusicTheory::Note
  def pitch(visual_note)
    hnote = visual_note.to_s.ord - 'a'.ord # steps from a - the lowest writable gabc note
    return @base.diatonic_steps(hnote)
  end

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

    # returns a lilypond absolute pitch for the given RbMusicTheory::Note
    #
    # this method doesn't fit well in a *factory*, but
    # #create translates lilypond pitch to Note and #lily_abs_pitch
    # does the reverse translation, so maybe just the class should be renamed
    def lily_abs_pitch(note)
      octave_shifts = ''
      octave_diff = note.value - create('c').value

      octave_value = RBMusicTheory::NoteInterval.octave.value
      octave_shift = octave_diff.abs / octave_value
      if octave_diff < 0 and (octave_diff.abs % octave_value) > 0 then
        octave_shift += 1
      end

      octave_signs = (octave_diff >= 0 ? "'" : ",") * octave_shift
      note.name.downcase + octave_signs
    end
  end
end

# monkey-patch Note to add step arithmetics
module RBMusicTheory

  class Note

    def diatonic_steps(steps, scale=nil)
      if scale.nil? then
        scale = self.class.new('C').major_scale
      end

      deg = self.degree_in(scale)

      return scale.degree(deg + steps)
    end

    # note's degree in a scale
    def degree_in(scale)
      degree = scale.note_names.index(self.name)
      if degree.nil? then
        raise ArgumentError.new("#{name} is not a member of #{scale.note_names} scale")
      end
      degree += 1 # degrees start with 1

      in_base_octave = scale.degree(degree)
      octave_steps = scale.note_names.size
      octave_value = RBMusicTheory::NoteInterval.octave.value

      value_difference = self.value - in_base_octave.value
      octave_difference = value_difference.abs / octave_value
      if value_difference < 0 then
        octave_difference *= -1
      end

      degree += octave_difference * octave_steps

      return degree
    end
  end
end
