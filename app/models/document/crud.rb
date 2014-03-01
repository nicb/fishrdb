#
# $Id: crud.rb 627 2012-12-16 17:46:17Z nicb $
#
# CRUD functions
#

require 'hash_extensions'

class MissingEditorException < RuntimeError
end

module DocumentParts

  module Crud

    class AttemptedDocumentCreation < ActiveRecord::ActiveRecordError; end

    def self.included(base)
      base.extend ClassMethods
    end

    def user_update_attribute(user, attr, value)
      ActiveRecord::Base.transaction do
        self.update_attribute(attr, value)
        self.update_attribute('last_modifier_id', user.id)
        self.save
      end
    end
  
    def delete_confirm_message
      result = "Stai per cancellare dal database "
      result += count_children_in_records + ". "
      result += "Sicuro?"
      return result
    end
  
    module ClassMethods
  
    protected
  
      def get_date_interval(fparams)
        result = ExtDate::Interval.new(fparams.read_and_delete_returning_empty_if_null('data_dal'),
                                       fparams.read_and_delete_returning_empty_if_null('data_al'),
                                       fparams.read_and_delete_returning_empty_if_null('data_dal_input_parameters'),
                                       fparams.read_and_delete_returning_empty_if_null('data_al_input_parameters'),
                                       fparams.read_and_delete_returning_empty_if_null('full_date_format'),
                                       fparams.read_and_delete_returning_empty_if_null('data_dal_format'),
                                       fparams.read_and_delete_returning_empty_if_null('data_al_format'))
    
        return result
      end
    
    public
  
      def adjust_dates(fparams)
        fparams[:date] = get_date_interval(fparams) unless fparams.has_key?(:date) && fparams[:date].class == ExtDate::Interval
        return fparams
      end

      def adjust_description_level(fparams)
        unless fparams.has_key?('description_level_id')
          if fparams.has_key?('description_level_position')
            dl_position = fparams.read_and_delete('description_level_position').to_i
            dl_id = DescriptionLevel.find_by_position(dl_position).id
            fparams.update(:description_level_id => dl_id)
          else
            fparams.update(:description_level_id => nil) # shouldn't pass validation
          end
        end
        return fparams
      end

      def new_for_form(fparams)
        raise(AttemptedDocumentCreation, "Can't create base class Document record from form") if name == 'Document'
        fparams = HashWithIndifferentAccess.new(fparams)
        fparams = adjust_description_level(fparams)
        return new(fparams)
      end

      def create_from_form(fparams, session)
        raise(AttemptedDocumentCreation, "Can't create base class Document record from form") if name == 'Document'
        fparams = HashWithIndifferentAccess.new(fparams)
        first_doc = nil
        logger.debug("======> Document.create_from_form(#{fparams.inspect})")
        fparams.delete('id') # can't be mass-assigned
        num_items = fparams.read_and_delete('num_items').to_i
        num_items = 1 unless num_items > 1
        if fparams.has_key?('parent_id')
          pid = fparams.read_and_delete('parent_id').to_i
          parent = Document.find(pid)
        end
        fparams = adjust_dates(fparams)
        fparams = adjust_description_level(fparams)
        new_doc = nil
        iv = condition_input(fparams)
        logger.debug("======> Document.create_from_form(iv = #{iv.inspect})")
        (1..num_items).each do
          |i|
          new_doc = create(iv)
          if new_doc && new_doc.valid?
            new_doc.parent_me(parent, fparams['position']) if parent
            first_doc = new_doc unless i > 1
          else
            msg = new_doc ? new_doc.errors.full_messages.join(', ') : "unknown error"
            raise(ActiveRecord::RecordNotSaved, msg)
          end
        end
        if new_doc and parent
          user = User.find(fparams['last_modifier_id'])
          new_doc.parent_reorder_children
          new_doc.parent.reset_num_descendants_cache
          if session
            new_doc.parent.sidebar_tree_item(session).rebuild_children_tree unless new_doc.parent.sidebar_tree_item(session).blank?
          end
          new_doc.reload
        end
    
        return first_doc
    
      end

      #
      # editable? defines whether the top CRUD buttons do work;
      # generally true by default, it becomes false whenever there is a brand
      # new class which does not have the CRUD cycle ready yet
      #
      def editable?
        return true
      end

    end # end of class methods
  
    def update_from_form(attrs)
      result = self
      attrs = HashWithIndifferentAccess.new(attrs)
      attrs.delete(:id)     # can't be mass-assigned
      attrs.delete(:type)   # can't be mass-assigned
      attrs = self.class.adjust_dates(attrs)
      attrs = self.class.adjust_description_level(attrs) if attrs.has_key?(:description_level_position)
  
      raise(MissingEditorException, "Cannot update document \"#{self.name}\" without editor user information!") unless attrs.has_key?('last_modifier_id') || attrs.has_key?('last_modifier')

      if self.update_attributes(attrs)
          self.parent_reorder_children
      else
        result = nil
        msg = self ? self.errors.full_messages.join(', ') : "unknown error"
        raise(ActiveRecord::RecordNotSaved, msg)
      end
  
      return result
    end
  
    def delete_from_form
      parent.reset_num_descendants_cache if parent
      children(true).each { |n| n.delete_from_form }
      reload
      destroy
    end

  end

end
