#
# $Id: ard_reference_cleaner.rb 259 2008-07-28 18:26:12Z nicb $
#

require 'active_record'
require 'ard_reference'
require 'text_helper'

class ArdReferenceCleaner < ActiveRecord::Migration

  include TextHelper

  class << self

private

    def relink_one_ard(ar, doc_id, ar_method)
			# since we have deleted all identical records we recreate one
			doc = Document.find(doc_id)
			n_ars = doc.send(ar_method).size
			user = User.find(ar.creator_id)
			ard_created = doc.bind_authority_record(user, ar)
			raise ActiveRecord::RecordNotSaved, "doc(#{truncate(doc.name, 10)}).bind_authority_record(#{user.id}, #{ar.inspect}) failed" unless ard_created.valid?
    end

    def destroy_old_references(ar, docs)
      ard = ArdReference.find(:first, :conditions => ["authority_record_id = ?", ar.id])
      raise ActiveRecord::RecordNotFound, "No ard references found for AR #{ar.id} and #{docs.inspect}" unless ard
      #
      # one destroy will clear all ards for a given authority_record
      # because the authority record id is the primary key
      #
	    ard.destroy
      raise ActiveRecord::RecordNotSaved, "Ard reference(ar #{ar.id.to_s}, docs #{docs.inspect}) not destroyed" unless ard.frozen?
    end
    
    def relink(ar, docs)
      docs.each do
        |d|
        ar_method = ar.read_attribute('type').underscore.pluralize
        relink_one_ard(ar, d, ar_method)
      end
    end

    def relink_all_ards(ar, docs)
      destroy_old_references(ar, docs)
      relink(ar, docs)
    end

    def relink_variant_references(arv, docs)
      destroy_old_references(arv, docs)
      relink(arv.accepted_form, docs)
    end

    #
    # there are still strange things that should not be there :(
    # these should be destroyed mercilessly
    #
    EXCEPTION_RECORDS = %w{Konx-om-pax] [Sauh]}

    def clean_exception_records
      EXCEPTION_RECORDS.each do
        |n|
        ar = AuthorityRecord.find_by_name(n)
        if ar
          ar.destroy
          raise ActiveRecord::RecordNotSaved, "Exceptional AR #{ar.id.to_s} not destroyed" unless ar.frozen?
        end
      end
    end

public

		def clean_ard_references()
		  ars = AuthorityRecord.find(:all, :conditions => ["type not like ?", '%Variant'])
		  ars.each do
		    |ar|
        docs = Array.new
        if ar.documents.size > 1
          docs = ar.documents.map { |d| d.read_attribute(:id) } 
          udocs = docs.uniq
          docs = udocs
        end
        unless docs.empty?
		      say_with_time("Re-creating references between authority_record #{ar.id} and documents #{docs.inspect}") do
            relink_all_ards(ar, docs)
          end
        end
        ar.reload
        ar.variants.each do
          |arv|
          docs = arv.documents.map { |d| d.read_attribute(:id) }
          udocs = docs.uniq
          docs = udocs
	        unless docs.empty?
			      say_with_time("Re-linking variant references (#{arv.id}) to the parent AR #{ar.id}") do
	            relink_variant_references(arv, docs)
	          end
	        end
        end
      end
      clean_exception_records
		end

  end

end
