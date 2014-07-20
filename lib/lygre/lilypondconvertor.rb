# encoding: UTF-8

class LilypondConvertor

  # true - print if given; false - ignore; 'always' - print even if empty
  DEFAULT_SETTINGS = {
                      version: true,
                      notes: true,
                      lyrics: true,
                      header: true
                     }

  DEFAULT_CLEF = GabcClef.new(pitch: :c, line: 4, bemol: false)

  # maps gabc divisiones to lilypond bars
  BARS = {
          ':' => '\bar "|"',
          ';' => '\bar "|"',
          '::' => '\bar "||"',
          ',' => '\bar "\'"'
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

    clef = score.music.clef
    if clef == nil then
      clef = DEFAULT_CLEF
    end
    @gabc_reader = GabcPitchReader.new clef.pitch, clef.line

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
          if n.is_a? GabcNote then
            NoteFactory.lily_abs_pitch(@gabc_reader.pitch(n.pitch))

          elsif n.is_a? GabcDivisio then
            divisio = n.type
            unless BARS.has_key? divisio
              raise RuntimeError.new "Unhandled bar type '#{n.type}'"
            end

            BARS[divisio].dup

          else
            raise RuntimeError.new "Unknown music content #{n}"
          end
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
    word.collect do |syll|
      l = syll.lyrics

      if syll.lyrics.start_with? '*' then
        l = '"' + syll.lyrics + '"'
      end

      if syll.lyrics.include? '<' then
        l = syll.lyrics.gsub(/<i>([^<]+)<\/i>/) do |m|
          '\italic{' + $1 + '}'
        end
        l = '\markup{'+l+'}'
      end

      if syll.notes.size == 1 and
          syll.notes.first.is_a? GabcDivisio and
          syll.lyrics.size > 0 then

        unless l.start_with? '\markup'
          l = '\markup{'+l+'}'
        end
        l = '\set stanza = '+l
      end

      l
    end.join ' -- '
  end
end
