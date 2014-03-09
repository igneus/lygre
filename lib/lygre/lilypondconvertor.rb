# encoding: UTF-8

# a very naive implementation
class SimpleLilypondConvertor

  def initialize
    @c_octave = :"''" # absolute octave of the gregorio c key
    # todo: make it possible to freely choose absolute c _pitch_
    @lily_scale = [:c, :d, :e, :f, :g, :a, :b]
    @gabc_lines = ['', :d, :f, :h, :j]
  end
  
  # converts GabcScore to Lilypond source
  def convert(score)
    indent = ' ' * 2

    header = score.header.keys.sort.collect do |k|
      indent + "#{k} = \"#{score.header[k]}\""
    end.join "\n"

    notes = []
    lyrics = []

    clef = score.music.clef
    score.music.words.each do |word|
      notes << word_notes(word, clef)
      lyrics << word_lyrics(word)
    end

    return "\\version \"2.16.0\"

\\score {
  \\relative c#{@c_octave} { 
    #{notes.join(" ")} 
  }
  \\addlyrics { 
    #{lyrics.join(" ")} 
  }
  \\header {
    #{header}
  }
}
"
  end

  def lilypitch(gabcpitch, clef)
    raise 'not yet implemented' if clef.pitch != :c

    hlowest = 'a'.ord

    # distance of the clef from the lowest writable note
    hclef = @gabc_lines[clef.line].to_s.ord - hlowest
    # distance of the note from the lowest writable note
    hnote = gabcpitch.to_s.ord - hlowest

    # pitch of the lowest writable note:
    plowest = @c_pitch - (clef.line + (clef.line > 1 ? clef.line - 1 : 0) + 3) 
    
    
    return gabcpitch
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
        sylnotes = notes.collect {|n| lilypitch n.pitch, clef }
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
