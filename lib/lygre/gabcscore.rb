# encoding: UTF-8

# todo: wrap in a module

# initialized by arguments or by assignment in a block;
# frozen thereafter
class Immutable
  def initialize(args={})
    args.each_pair do |k,v|
      writer = (k.to_s + '=').to_sym
      self.send(writer, v)
    end

    yield self if block_given?

    freeze
  end
end

# clean and easy to use music data produced by
# Gabc::ScoreNode#create_score
# from the syntax tree created by GabcParser
class GabcScore < Immutable

  # header fields as Hash
  attr_accessor :header

  # music information as GabcMusic
  attr_accessor :music
end

class GabcMusic < Immutable

  attr_accessor :clef
end

class GabcClef < Immutable

  # 'c' or 'f'
  attr_accessor :pitch
  
  # Integer 1...4
  attr_accessor :line

  # Boolean
  attr_accessor :bemol

  def to_s
    pitch + (bemol ? 'b' : '') + line.to_s
  end
end
