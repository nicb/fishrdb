# encoding: utf-8
#
# $Id: description_level.rb 517 2010-07-10 20:55:56Z nicb $
#
# The description level is *not* an ActiveRecord::Base child any longer
# it is a fixed set of objects which must be edited by hand, so it does not
# need to be an ActiveRecord object
#

class DescriptionLevel

  attr_reader :id
  attr_accessor   :level, :position, :termination

  @@dl_factory = []

  def initialize(attrs)
    @id = attrs[:id]
    @level = attrs[:level]
    @position = attrs[:position]
    @termination = attrs[:termination]
  end

  class <<self

    #
    # the id is the array index
    # PLEASE NOTE: changing the order of the array will break the indexing of
    # documents! If other levels are needed, add them at the end of array and
    # change the 'position' value instead to place them correctly.
    #
    DLS =
    [
      { :level => 'Fondo', :position => 0, :termination => 'o' },
    	{ :level => 'Sezione', :position => 1, :termination => 'a' },
    	{ :level => 'SottoSezione', :position => 2, :termination => 'a' },
    	{ :level => 'Serie', :position => 3, :termination => 'a' },
    	{ :level => 'SottoSerie', :position => 4, :termination => 'a' },
    	{ :level => 'SottoSottoSerie', :position => 5, :termination => 'a' },
    	{ :level => 'Fascicolo', :position => 6, :termination => 'o' },
    	{ :level => 'SottoFascicolo', :position => 7, :termination => 'o' },
    	{ :level => 'Inserto', :position => 8, :termination => 'o' },
    	{ :level => 'Unità Documentaria', :position => 10, :termination => 'a' },
      #
    	{ :level => 'Allegato', :position => 9, :termination => 'o' },
    ]

    def create_dls
      DLS.each_with_index { |dl, i| @@dl_factory << DescriptionLevel.new(dl.update(:id => i)) }
      @@dl_factory.each do
        |dl|
	      DescriptionLevel.module_eval("def self.#{dl.cleansed_level}_level; return #{dl.position}; end")
	      DescriptionLevel.module_eval("def self.#{dl.cleansed_level}; return DescriptionLevel.find_by_position(#{dl.position}); end")
      end
    end

    def find_by_position(pos)
      result = nil
      levels.each do
        |dl|
        if dl.position == pos
          result = dl
          break
        end
      end
      return result
    end

    def levels
      create_dls if @@dl_factory.empty?
      return @@dl_factory.sort { |a, b| a.position <=> b.position }
    end

    def find(idx)
      return @@dl_factory[idx]
    end

    def selection
      return levels.sort { |a, b| a.position <=> b.position }.map { |dl| [ dl.level, dl.position ] }
    end

    def last
      return find_by_position(levels.size-1)
    end

    def first
      return find_by_position(0)
    end

  end

  def cleansed_level
    #
    # need to: downcase, sub spaces, normalize to pure ASCII
    #
    return level.downcase.gsub(/\s+/, '_').normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s
  end

  def ==(other)
    return position == other.position
  end

  def <=>(other)
    return position <=> other.position
  end

  def higher?(other)
    return position < other.position
  end

  def lower?(other)
    return position > other.position
  end

  def >(other)
    return lower?(other)
  end

  def <(other)
    return higher?(other)
  end

  def >=(other)
    return (higher?(other) || (self == other))
  end

  def <=(other)
    return (lower?(other) || (self == other))
  end

protected

  def arith(op, meth, &block)

    case
      when op.is_a?(Fixnum) then
        nxt = position.send(meth, op)
      when op.is_a?(DescriptionLevel) then
        nxt = position.send(meth, op.position)
      else
        raise UnknownDescriptionLevelOperand
    end

    nxt = yield(nxt)

    result = DescriptionLevel.find_by_position(nxt)

    return result

  end

public
  #
  # - goes higher in the hierarchy
  #

  def -(op)
    return arith(op, :-) do
      |newpos|
      first = DescriptionLevel.first.position
      newpos < first ? first : newpos 
    end
  end

  #
  # + goes lower in the hierarchy
  #
  def +(op)
    return arith(op, :+) do
      |newpos|
      last = DescriptionLevel.last.position
      newpos > last ? last : newpos
    end
  end

  #
  # this is needed to preload the object
  #
  levels

end
