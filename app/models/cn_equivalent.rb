#
# $Id: cn_equivalent.rb 270 2008-11-09 12:06:14Z nicb $
#
# CnEquivalent is an object that connects together all the CollectiveName
# authority records which belong to the same name (in different periods)
# This means that the relationship is established as follows:
#
#                       CnEquivalent
#                            |
#         +------------------+-------------------+
#         |                  |                   |
#  CollectiveName1    CollectiveName2    CollectiveName3
#         |                  |                   |
#      Variant11         Variant21           Variant31
#
#  etc.
#
#require 'authority_record'

class CnEquivalent < ActiveRecord::Base
  has_many :collective_names, :order => 'name'

	belongs_to	:creator, :class_name => "User"
	belongs_to	:last_modifier, :class_name => "User"

  validates_presence_of   :name, :creator, :last_modifier
  validates_uniqueness_of :name

private

  def verify_uniqueness_of_collective_name(cn)
    result = true
    self.collective_names.each do
      |icn|
      result = false if icn === cn
    end
    return result
  end

public

  def add_collective_name(cn, user)
    if verify_uniqueness_of_collective_name(cn)
      self.collective_names << cn
      self.update_attribute(:last_modifier_id, user.id)
      cn.update_attributes(:cn_equivalent_id => self.id, :last_modifier_id => user.id)
    end
  end

  def remove_collective_name(cn, user)
    self.collective_names.each_index do
      |i|
      if self.collective_names[i] === cn
        self.collective_names[i] = nil
        cn.update_attribute(:cn_equivalent, nil)
        break
      end
    end
    self.collective_names.reload
    self.collective_names.compact
  end

  def self.view_dir
    return 'ar/cneq/'
  end

  def self.show_action
    return view_dir + 'show'
  end

end
