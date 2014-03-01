#
# $Id: form_helper.rb 270 2008-11-09 12:06:14Z nicb $
#

module FormHelper

private
	@parms_to_be_deleted = []
	
	def FormHelper.delete_at_end(parm)
		@parms_to_be_deleted << parm
	end

public

	def FormHelper.parse_corda(parms)
		parms['corda'] =  parms['corda_number'].to_s + parms['corda_alpha']
		FormHelper.delete_at_end('corda_number')
		FormHelper.delete_at_end('corda_alpha')
		return true
	end

	#
	# this should be called at the end of conditioning
	#
	def FormHelper.close_conditioning(parms)
		@parms_to_be_deleted.each do
			|k|
			parms.delete(k)
		end
	end
end
