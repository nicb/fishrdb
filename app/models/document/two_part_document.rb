#
# $Id: two_part_document.rb 479 2010-03-04 00:21:21Z nicb $
#
# This is an abstract class that is to be used as the parent class of each
# document that is composed by record + data
#

class ActiveRecord::Base

protected

  def two_part_inspect(attrs, slave)
    result = ["#<#{self.class.name}"]
    attrs.each do
      |sa|
      result << "#{sa.to_s}: #{send(sa).to_s}"
    end
    result << "#{slave.to_s}: #{send(slave).inspect}" if slave
    result << yield if block_given?
    return result.join(', ') + ">"
  end

end

module DocumentParts

  module TwoPartDocument

    def self.included(base)
      base.extend ClassMethods
    end
	
    module ClassMethods

      attr_reader :subkey, :subkey_class

      #
      # set_subkey allows to set the subkey directly in the master model
      # Example:
      #
      # class MasterRecord
      #   set_subkey :slave_record
      # end
      # 
      # this will set the subkey to :slave_record and the slave class name to
      # SlaveRecord.
      #
      # subkey, subkey_class and subkey_accessor are then available as class
      # methods within the Master model
      # 
      #
      def set_subkey(sk)
        @subkey = sk
        @subkey_class = sk.to_s.camelcase.constantize
      end

      def subkey_accessor
        return subkey_class.name.underscore.intern
      end

      def generate_association_adder_key(association)
        return subkey.to_s + '_' + association.to_s + '_to_be_added'
      end

	    def condition_input(parms)
	      #
	      # this call must exist in order for the super create_from_form to work.
	      # However, its usage is deprecated and it should not be used by two-part
	      # subclasses.
	      #
	      return parms
	    end
      
      def decompose_parameters(parms)
        sub_data = parms.read_and_delete(subkey)
        sub_data = {} unless sub_data
        return sub_data
      end

      #
      # new_for_form(parms = {})
      #
      def new_for_form(parms = {})
        sub_data = decompose_parameters(parms)
        doc = super(parms)
        if doc
          sub_data = yield(sub_data) if block_given?
          sub_data_object = subkey_class.new(sub_data)
          doc.send(subkey_accessor.to_s + '=', sub_data_object)
        end
        return doc
      end
	
	    #
	    # create_from_form(parms = {}, session = nil)
	    # arguments:
	    # parms - usual ActiveRecord::Base create argument hash, completed with
	    #         the hash to complete the subclass (default: empty pars)
	    # session - the session needed for creation (default: nil)
	    #
	    def create_from_form(parms = {}, session = nil)
        sub_data = decompose_parameters(parms)
	      doc = super(parms, session)
	      if doc && doc.valid?
          begin
	          sub_data = yield(sub_data) if block_given?
	          subclass_create_method = 'create_' + subkey_accessor.to_s
	          doc.send(subclass_create_method, sub_data)
          rescue => error_msg # if child doesn't get created, we must destroy everything
            doc.destroy
            doc = nil
            raise(ActiveRecord::RecordNotSaved, error_msg)
          end
	      end
	      return doc
	    end

    protected

      def extract_has_many_items(fparams, key)
	      result = []
	      if fparams.has_key?(subkey) && fparams[subkey]
		      extracted = fparams[subkey].keys.map { |k| k.to_s }.grep(/^#{key.to_s}/)
		      extracted.sort.each do
		        |bah|
            local_copy = HashWithIndifferentAccess.new(fparams)
		        n = fparams[subkey].read_and_delete(bah)
            c_args = n.transfer(:creator_id, :last_modifier_id, :creator, :last_modifier)
            c_args = local_copy[subkey].transfer(:creator_id, :last_modifier_id, :creator, :last_modifier) if c_args.blank?
            c_args = local_copy.transfer(:creator_id, :last_modifier_id, :creator, :last_modifier) if c_args.blank?
            result << yield(n, c_args)
		      end
	      end
	      return result
      end

    end
    
	  def update_from_form(parms = {})
	    sub_data = self.class.decompose_parameters(parms)
      if sub_data
        sub_data = yield(sub_data) if block_given?
        sd_obj = self.class.subkey_class.find(id)
        sd_obj.update_attributes!(sub_data)
        reload
      end
	    return super(parms)
	  end

  end

end
