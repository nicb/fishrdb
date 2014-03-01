#
# $Id: confirm_delete.rb 324 2009-03-06 04:26:22Z nicb $
#

module AuthorityRecordParts

  module ConfirmDelete

	protected
	
	  def afv_confirm
	    return 'Sicuro?'
	  end
	
	  def af_confirm
	    emesg = afv_confirm
	    smesg = msg2 = msg3 = et = ''
	    unless variants.blank? and documents.blank?
	      smesg = 'Cancellando questo authority record cancellerai anche'
	    end
	    unless variants.blank?
	      sz = variants.size
	      msg2 = sz == 1 ? " una #{self.class.variant_form_term.downcase}" : " #{sz} #{self.class.variant_form_terms.downcase}" 
	      smesg = smesg + msg2
	    end
	    unless documents.blank?
	      sz = documents.size
	      msg3 = sz == 1 ? " un collegamento ad un documento (#{documents[0].read_attribute('id')})" : " #{sz} collegamenti a documenti (#{documents.map { |d| d.read_attribute('id').to_s }.join(', ')})"
	      et = ' e' unless variants.blank?
	      smesg = smesg + et + msg3
	    end
	    result = smesg.blank? ? emesg : smesg + '. ' + emesg
	
	    return result
	  end
	
	public
	
	  def confirm_delete_message
	    return variant? ? afv_confirm : af_confirm
	  end

  end

end
