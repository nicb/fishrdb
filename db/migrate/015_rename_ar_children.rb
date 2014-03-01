#
# $Id: 015_rename_ar_children.rb 208 2008-05-01 16:54:22Z nicb $
#
class RenameArChildren < ActiveRecord::Migration

	class FakeClass < ActiveRecord::Base
	  set_table_name "authority_records"
	  set_inheritance_column :ruby_type
	
	  def mytype
	    self[:type]
	  end
	
	  def mytype=(newtype)
	    self[:type] = newtype
	  end
	end

  def self.up
    ars = FakeClass.find(:all, :conditions => ["type like ?", '%Equivalent'])
    ActiveRecord::Base.transaction do
      ars.each do
        |ar|
        newname = ar.mytype.sub(/Equivalent/,'Variant')
        ar.mytype = newname
        ar.save!
      end
    end
  end

  def self.down
    ars = FakeClass.find(:all, :conditions => ["type like ?", '%Variant'])
    ActiveRecord::Base.transaction do
      ars.each do
        |ar|
        newname = ar.mytype.sub(/Variant/,'Equivalent')
        ar.mytype = newname
        ar.save!
      end
    end
  end
end
