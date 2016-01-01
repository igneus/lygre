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

  # Array of GabcWords
  attr_accessor :words
end

class GabcClef < Immutable

  # 'c' or 'f'
  attr_accessor :pitch

  # Integer 1...4
  attr_accessor :line

  # Boolean
  attr_accessor :bemol

  def to_s
    "#{pitch}#{bemol ? 'b' : ''}#{line}"
  end
end

# collection of syllables
class GabcWord < Array

  def initialize(*args)
    super(*args)
    freeze
  end

  alias_method :each_syllable, :each
end

class GabcSyllable < Immutable

  # String; may be empty
  attr_accessor :lyrics

  # Array of GabcNotes and other objects; may be empty
  attr_accessor :notes
end

class GabcNote < Immutable

  attr_accessor :pitch
  attr_accessor :shape
  attr_accessor :initio_debilis
  attr_accessor :rhythmic_signs
  attr_accessor :accent
end

class GabcDivisio < Immutable

  attr_accessor :type
end
