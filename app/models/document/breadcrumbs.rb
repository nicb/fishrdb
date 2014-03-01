#
# $Id: breadcrumbs.rb 626 2012-12-15 11:37:30Z nicb $
#

module DocumentParts

  module Breadcrumbs

		#
		# +breadcrumbs+ produces the list of ancestors required to print the
	  # breadcrumbs wherever needed. It is essentially the reversed list of ancestors
		# skipping the very first root which remains invisible.
		#
		# if no ancestors are found, return an empty array.
		#
		def breadcrumbs
			sz = self.ancestors.size
			res = self.ancestors.reverse[1..sz-1]
			res ? res : []
		end

  end

end
