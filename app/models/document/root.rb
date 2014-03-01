#
# $Id: root.rb 426 2009-08-22 22:35:49Z nicb $
#
#

module DocumentParts

  module Root

	public

    def self.included(base)
      base.extend ClassMethods
    end
	
    module ClassMethods

		  def fishrdb_root
				return first(:conditions => ["parent_id IS NULL AND name = ?", "__Fondazione_Isabella_Scelsi__"]) # root index
		  end

    end

  end

end
