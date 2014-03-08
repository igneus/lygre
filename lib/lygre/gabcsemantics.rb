# encoding: UTF-8

# classes containing semantics of various nodes
# instantiated by the GabcParser

require 'treetop'
require_relative 'gabcscore'

# monkey-patch SyntaxNode
# to add a useful traversal method
class Treetop::Runtime::SyntaxNode

  def each_element
    return if elements.nil?
    elements.each {|e| yield e }
  end
end

module Gabc

  SyntaxNode = Treetop::Runtime::SyntaxNode

  # root node
  class ScoreNode < SyntaxNode

    # creates and returns a GabcScore from the syntax tree
    def create_score
      return GabcScore.new do |s|
        s.header = header.to_hash
        s.music = body.create_music
      end
    end
  end

  module HeaderNode

    def to_hash
      r = {}
      
      each_element do |lvl1|
        lvl1.each_element do |lvl2|
          lvl2.each_element do |field|
            if field.is_a? HeaderFieldNode then
              r[field.field_id.text_value] = field.field_value.text_value
            end
          end
        end
      end

      return r
    end
  end

  class HeaderFieldNode < SyntaxNode
  end

  class BodyNode < SyntaxNode

    def create_music
      GabcMusic.new do |m|

        clef = elements.find {|e| e.respond_to? :clef_symbol }
        if clef != nil then
          m.clef = GabcClef.new(pitch: clef.clef_symbol.text_value, 
                                line: clef.line_number.text_value.to_i,
                                bemol: (clef.bemol.text_value == 'b'))
        end

      end
    end
  end
end
