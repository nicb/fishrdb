#
#
# To be run from the console in production
# like so:
#
# cat script/fishrdb/multi_bundle_creator.rb | script/console production
#
# This is a script to build multi-bundle bundles config files
#
tstart = 175 # start from NMGS0175 (for example)
tnum =   1   # run for a number of tapes
tcur = tstart

class YAMLCreator

  attr_reader :number, :tape

  def initialize(n)
    @number = n
    @tape = tape_finder
  end

  def to_yml
  end

  class << self

    def header
    end

    def trailer
    end

  end

private

  def tape_finder
    name = "NMGS%04d%%" % [ tcur ]
    Document.find(:first, :conditions => ['name like ?', name])
  end
  
end 

YAMLCreator.header

while(tcur < (tstart+tnum))
  t = YAMLCreator.new(tcur)
  tcur += 1
end

YAMLCreator.trailer
