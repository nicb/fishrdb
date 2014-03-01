#
# $Id: cd_track.rb 468 2009-10-17 02:21:36Z nicb $
#
require 'cd_track_participant'

class CdTrack < ActiveRecord::Base

  belongs_to :cd_track_record
  set_primary_key :cd_track_record_id

  validates_presence_of :cd_track_record_id
  validates_numericality_of :ordinal, :allow_nil => true

  #
  # authors
  #
  has_many :cd_track_authors, :dependent => :destroy
  has_many :authors, :through => :cd_track_authors, :uniq => true,\
           :order => 'position', :source => :name

  #
  # performers
  #
  has_many :cd_track_performers, :dependent => :destroy
  has_many :performers, :through => :cd_track_performers, :uniq => true,\
           :order => 'position'
  #
  # ensembles
  #
  has_many :cd_track_ensembles, :dependent => :destroy
  has_many :ensembles, :through => :cd_track_ensembles, :uniq => true,\
           :order => 'position'

  def inspect
    sel_attrs = [:ordinal, :for, :duration]
    sub_result = []
    result = two_part_inspect(sel_attrs, nil) do
      sub_result << subpart_inspect(:authors) 
      sub_result << subpart_inspect(:performers) { |p| p.name.inspect + ', ' + p.instrument.inspect }
      sub_result << subpart_inspect(:ensembles) do
        |e|
        ssr = e.name
        ssr += " conductor: " + e.conductor.inspect if e.conductor && e.conductor.valid?
        sub_result << ssr
      end
      sub_result.join(', ')
    end
    return result
  end

  def duration
    result = nil
    dt = read_attribute(:duration)
    if dt # maybe nil during validations
      comps = [ dt.hour, dt.min, dt.sec ].map { |t| sprintf("%02d", t) }
      result = comps.conditional_join(':')
    end
    return result
  end

  def display_players
    result = []
    performers.each do
      |p|
      sbr = []
      sbr << p.name.full_name
      sbr << p.instrument.name
      result << sbr.conditional_join(', ')
    end
    ensembles.each do
      |e|
      sbr = []
      sbr << e.name
      sbr << ['direttore', e.conductor.full_name].conditional_join(' ') if e.conductor
      result << sbr.conditional_join(', ')
    end
    return result.conditional_join('; ')
  end

private

  def subpart_inspect(subpart)
    result = []
    send(subpart).each do
      |sp|
      result << sp.inspect
      result << yield(sp) if block_given?
    end
    return "#{subpart.to_s}: [" << result.join(', ') << "]"
  end

public

  def clear_all_associations
    performers.clear
    ensembles.clear
    return authors.clear # removes all join records before re-adding them again
  end

end
