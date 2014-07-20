# encoding: UTF-8

class LilypondConvertor

  # true - print if given; false - ignore; 'always' - print even if empty
  DEFAULT_SETTINGS = {
                      version: true,
                      notes: true,
                      lyrics: true,
                      header: true
                     }

  def initialize(settings={})
    @settings = DEFAULT_SETTINGS.dup.update(settings)

    # todo: make it possible to freely choose absolute c _pitch_
    @c_pitch = NoteFactory["c''"]

    @lily_scale = [:c, :d, :e, :f, :g, :a, :b]
    @gabc_lines = ['', :d, :f, :h, :j]
  end

  # converts GabcScore to Lilypond source
  def convert(score)
    header = score.header.keys.sort.collect do |k|
      "  #{k} = \"#{score.header[k]}\""
    end.join "\n"

    notes = []
    lyrics = []

    @gabc_reader = GabcPitchReader.new :c, 4

    clef = score.music.clef
    score.music.words.each do |word|
      notes << word_notes(word, clef)
      lyrics << word_lyrics(word)
    end

    r = ''

    r += "\\version \"2.16.0\"\n\n" if @settings[:version]
    r += "\\score {\n"

    if @settings[:notes] and
        (notes.size > 0 or @settings[:notes] == 'always') then
      r += "  \\absolute {\n" +
        "    #{notes.join(" ")}\n" +
        "  }\n"
    end

    if @settings[:lyrics] and
        (lyrics.size > 0 or @settings[:lyrics] == 'always') then
      r += "  \\addlyrics {\n" +
        "    #{lyrics.join(" ")}\n" +
        "  }\n"
    end

    if @settings[:header] and
        (header.size > 0 or @settings[:header] == 'always') then
      r += "  \\header {\n" +
        "    #{header}\n" +
        "  }\n"
    end

    r += "}\n"

    return r
  end

  # returns the output of #convert 'minimized', with whitespace reduced
  # and normalized (useful for testing)
  def convert_min(score)
    convert(score).gsub(/\s+/, ' ').strip
  end

  # makes a melisma from a group of notes
  def melisma(notes)
    notes[0] = (notes[0].to_s + '(').to_sym
    notes[-1] = (notes[-1].to_s + ')').to_sym
    return notes
  end

  def word_notes(word, clef)
    r = []
    word.each_syllable do |syl|
      notes = syl.notes

      if notes.empty? then
        r << 's'
      else
        sylnotes = notes.collect do |n| 
          NoteFactory.lily_abs_pitch(@gabc_reader.pitch(n.pitch))
        end

        if notes.size >= 2 then
          sylnotes = melisma sylnotes
        end
        r += sylnotes
      end
    end
    return r.join ' '
  end

  def word_lyrics(word)
    word.collect {|w| w.lyrics }.join ' -- '
  end
end
