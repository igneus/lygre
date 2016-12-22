# encoding: UTF-8

# classes containing semantics of various nodes
# instantiated by the GabcParser

require 'treetop'
require_relative 'score'

# monkey-patch SyntaxNode
# to add a useful traversal method
class Treetop::Runtime::SyntaxNode
  def each_element
    return if elements.nil?
    elements.each { |e| yield e }
  end
end

module Gabc
  SyntaxNode = Treetop::Runtime::SyntaxNode

  # root node
  class ScoreNode < SyntaxNode
    # creates and returns a GabcScore from the syntax tree
    def create_score
      GabcScore.new do |s|
        s.header = header.to_hash
        s.music = body.create_music
      end
    end
  end

  module HeaderNode
    def to_hash
      r = {}

      each_element do |lvl1|
        lvl1.each_element do |field|
          if field.is_a? HeaderFieldNode
            r[field.field_id.text_value] = field.field_value.text_value
          end
        end
      end

      r
    end
  end

  class HeaderFieldNode < SyntaxNode
  end

  class BodyNode < SyntaxNode
    def create_music
      GabcMusic.new do |m|
        words = []
        each_element do |ele|
          if ele.is_a? WordNode
            words << ele.create_word
          else
            ele.each_element do |elel|
              elel.each_element do |elelel|
                words << elelel.create_word if elelel.is_a? WordNode
              end
            end
          end
        end
        m.words = words
      end
    end
  end

  module WordNode
    def create_word
      w = []

      each_element do |ele|
        next unless ele.is_a? SyllableNode
        w << GabcSyllable.new do |s|
          s.lyrics = ele.lyrics.text_value
          s.notes = collect_notes ele
        end
      end

      GabcWord.new w
    end

    private

    # recursively collects notes from a node
    def collect_notes(node, arr = [])
      node.each_element do |ele|
        if ele.is_a? NoteNode
          arr << GabcNote.new do |n|
            n.pitch = ele.note_pitch.text_value.downcase.to_sym
            n.text_value = ele.text_value
          end
        elsif ele.is_a? DivisioNode
          arr << GabcDivisio.new do |d|
            d.type = ele.text_value
            d.text_value = ele.text_value
          end
        elsif ele.is_a? ClefNode
          arr << GabcClef.new do |c|
            c.pitch = ele.clef_symbol.text_value.to_sym
            c.bemol = ele.bemol.text_value == 'b'
            c.line = ele.line_number.text_value.to_i
            c.text_value = ele.text_value
          end
        else
          collect_notes ele, arr
        end
      end

      arr
    end
  end

  module SyllableNode
  end

  class NoteNode < SyntaxNode
  end

  module DivisioNode
  end

  module ClefNode
  end
end
