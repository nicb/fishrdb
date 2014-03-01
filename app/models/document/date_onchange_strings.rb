#
# $Id: date_onchange_strings.rb 324 2009-03-06 04:26:22Z nicb $
#

module DocumentParts

  module DateOnChangeStrings

		def self.included(base)
		  base.extend ClassMethods
		end

    module ClassMethods
	
	    include OnchangeStringsHelper
	
	  protected
	
	    def common_string_suffix
	      return "+ '&data_topica=' + escape($('doc_data_topica').value) + '&nota_data=' + escape($('doc_nota_data').value)"
	    end
	
	  public
	
		  def date_onchange_string(tag)
		    return onchange_string("#{tag}_date_changed", 'data_dal', 'data_al', 'doc', 'doc') { common_string_suffix }
		  end
		
		  def format_onchange_string
		    return onchange_string("date_format_changed", 'data_dal', 'data_al', 'doc', 'doc') { common_string_suffix }
		  end
		
		  def sd_onchange_string
		    return onchange_string("senza_data_toggled", 'data_dal', 'data_al', 'doc', 'doc') { common_string_suffix + "+ '&senza_data=' + $('doc_senza_data').checked" }
		  end
	
    end # end of ClassMethods

  end

end
