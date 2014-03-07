# encoding: UTF-8

# classes containing semantics of various nodes
# instantiated by the GabcParser

require 'treetop'
require_relative 'gabcscore'

module Gabc

  SyntaxNode = Treetop::Runtime::SyntaxNode

  # root node
  class ScoreNode < SyntaxNode

    # creates and returns a GabcScore from the syntax tree
    def create_score
      return GabcScore.new(header.to_hash)
    end
  end

  module HeaderNode

    def to_hash
      r = {}
      #puts inspect
      fields = elements.collect do |lvl1|
        lvl1.elements.collect do |lvl2|
          if lvl2.elements.nil? or lvl2.elements.empty? then
            nil
          else
            lvl2.elements.select do |lvl3|
              lvl3.is_a? HeaderFieldNode
            end
          end
        end
      end
      fields.flatten!.compact!

      fields.each do |elem|
        r[elem.field_id.text_value] = elem.field_value.text_value
      end
      return r
    end
  end

  class HeaderFieldNode < SyntaxNode
  end
end
