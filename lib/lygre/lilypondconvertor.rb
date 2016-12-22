# encoding: UTF-8

class LilypondConvertor
  # true - print if given; false - ignore; 'always' - print even if empty
  DEFAULT_SETTINGS = {
    version: true,
    notes: true,
    lyrics: true,
    header: true,
    cadenza: false
  }.freeze

  DEFAULT_CLEF = GabcClef.new(pitch: :c, line: 4, bemol: false)

  # maps gabc divisiones to lilypond bars
  BARS = {
    ':' => '\bar "|"',
    ';' => '\bar "|"',
    '::' => '\bar "||"',
    ',' => '\bar "\'"',
    '`' => '\breathe \bar ""'
  }.freeze

  def initialize(settings = {})
    @settings = DEFAULT_SETTINGS.dup.update(settings)

    # TODO: make it possible to freely choose absolute c _pitch_
    @c_pitch = NoteFactory["c''"]

    @lily_scale = [:c, :d, :e, :f, :g, :a, :b]
    @gabc_lines = ['', :d, :f, :h, :j]
  end

  # converts GabcScore to Lilypond source
  def convert(score)
    header = score.header.keys.sort.collect do |k|
      "    #{k} = \"#{score.header[k]}\""
    end.join "\n"

    notes = []
    lyrics = []

    clef = DEFAULT_CLEF
    @gabc_reader = GabcPitchReader.new clef.pitch, clef.line

    score.music.words.each_with_index do |word, _i|
      current = word_notes(word, clef)
      if @settings[:cadenza] &&
         !(notes.empty? || current.empty? ||
            notes.last.include?('\bar') || current.include?('\bar'))
        notes << '\bar ""'
      end
      notes << current unless current.empty?
      lyrics << word_lyrics(word)
    end

    r = ''

    r += "\\version \"2.16.0\"\n\n" if @settings[:version]
    r += "\\score {\n"

    if @settings[:notes] &&
       (!notes.empty? || (@settings[:notes] == 'always'))
      r += "  \\absolute {\n"

      r += "    \\cadenzaOn\n" if @settings[:cadenza]

      r += "    #{notes.join(' ')}\n" \
           "  }\n"
    end

    if @settings[:lyrics] &&
       (!lyrics.empty? || (@settings[:lyrics] == 'always'))
      r += "  \\addlyrics {\n" \
           "    #{lyrics.join(' ')}\n" \
           "  }\n"
    end

    if @settings[:header] &&
       (!header.empty? || (@settings[:header] == 'always'))
      r += "  \\header {\n" \
           "#{header}\n" \
           "  }\n"
    end

    r += "}\n"

    r
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
    notes
  end

  def word_notes(word, _clef)
    r = []
    word.each_syllable do |syl|
      notes = syl.notes

      if notes.empty?
        r << 's'
      else
        sylnotes = []
        notes.each do |n|
          if n.is_a? GabcNote
            pitch = @gabc_reader.pitch(n.pitch)
            sylnotes << NoteFactory.lily_abs_pitch(pitch)
          elsif n.is_a? GabcDivisio
            divisio = n.type
            unless BARS.key? divisio
              raise RuntimeError.new "Unhandled bar type '#{n.type}'"
            end

            sylnotes << BARS[divisio].dup

          elsif n.is_a? GabcClef
            @gabc_reader = GabcPitchReader.new n.pitch, n.line

          else
            raise RuntimeError.new "Unknown music content #{n}"
          end
        end

        sylnotes = melisma sylnotes if notes.size >= 2
        r += sylnotes
      end
    end
    r.join ' '
  end

  def word_lyrics(word)
    word.collect do |syll|
      l = syll.lyrics

      l = '"' + syll.lyrics + '"' if syll.lyrics.start_with? '*'

      if syll.lyrics.include? '<'
        l = syll.lyrics.gsub(/<i>([^<]+)<\/i>/) do |_m|
          '\italic{' + Regexp.last_match(1) + '}'
        end
        l = '\markup{' + l + '}'
      end

      if (syll.notes.size == 1) &&
         syll.notes.first.is_a?(GabcDivisio) &&
         !syll.lyrics.empty?

        l = '\markup{' + l + '}' unless l.start_with? '\markup'
        l = '\set stanza = ' + l
      end

      l
    end.join ' -- '
  end
end
