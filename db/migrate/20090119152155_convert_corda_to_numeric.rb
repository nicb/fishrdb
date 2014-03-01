#
# $Id: 20090119152155_convert_corda_to_numeric.rb 296 2009-01-23 05:31:25Z nicb $
#
class ConvertCordaToNumeric < ActiveRecord::Migration

  class <<self

	  def recombine_fields(d_id, d_corda)
      doc = Document.find(d_id)
	    corda_numeric = d_corda.to_i
	    corda_alpha_idx = d_corda.index(/\D/)
	    corda_alpha = corda_alpha_idx ? d_corda[corda_alpha_idx..d_corda.size] : ''
	
	    doc.update_attributes!(:corda => corda_numeric, :corda_alpha => corda_alpha)
	  end
	
	  def decombine_fields(d_id, d_corda)
      doc = Document.find(d_id)

      doc.update_attributes!(:corda => d_corda, :corda_alpha => nil)
	  end

  end

  def self.up
    ActiveRecord::Base.transaction do
      docs = Document.find(:all, :conditions => ["corda is not null"]).map { |d| [ d.id, d.corda.dup ] }

      change_column :documents, :corda, :integer

      docs.each do
        |d|
        recombine_fields(d[0], d[1])
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      docs = Document.find(:all, :conditions => ["corda is not null or corda_alpha is not null"]).map { |d| [ d.id, d.full_corda.dup ] }

      change_column :documents, :corda, :string

      docs.each do
        |d|
        decombine_fields(d[0], d[1])
      end
    end
  end
end
