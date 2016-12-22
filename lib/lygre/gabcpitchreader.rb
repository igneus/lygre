# encoding: UTF-8

# responsible for converting the 'visual pitch' information
# contained in gabc to absolute musical pitch
class GabcPitchReader
  CLEFS = { c: "c''", f: "f'" }.freeze
  CLEF_POSITIONS = 1..4

  def initialize(clef = :c, clef_position = 4)
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
    @base.diatonic_steps(hnote)
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

      sign = 0
      octave = 0
      if octaves
        sign = (octaves[0] == ',' ? -1 : 1)
        octave += (octaves.size * sign)
      end
      MusicTheory::Note.new note.to_sym, octave
    end

    alias create_note create
    alias [] create

    # returns a lilypond absolute pitch for the given RbMusicTheory::Note
    #
    # this method doesn't fit well in a *factory*, but
    # #create translates lilypond pitch to Note and #lily_abs_pitch
    # does the reverse translation, so maybe just the class should be renamed
    def lily_abs_pitch(note)
      octave_signs = (note.octave >= 0 ? "'" : ',') * note.octave.abs
      note.pitch.to_s + octave_signs
    end
  end
end
