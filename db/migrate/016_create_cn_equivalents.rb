#
# $Id: 016_create_cn_equivalents.rb 212 2008-05-06 21:06:18Z nicb $
#
class CreateCnEquivalents < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :cn_equivalents do |t|
        t.string    'name',               :limit => 1024, :null => false
			  t.integer		'creator_id',         :null => false
			  t.integer		'last_modifier_id',   :null => false
	      t.timestamps
	    end
      add_column  'authority_records', 'cn_equivalent_id', :integer, :null => true
      add_index   'authority_records', ['cn_equivalent_id']
      add_index   'cn_equivalents', ['creator_id']
      add_index   'cn_equivalents', ['last_modifier_id']
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :cn_equivalents
      remove_index   'authority_records', 'cn_equivalent_id'
      remove_column  'authority_records', 'cn_equivalent_id'
    end
  end
end
