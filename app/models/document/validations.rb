#
# $Id: validations.rb 481 2010-04-02 01:43:24Z nicb $
#
#

module DocumentParts

  module Validations

	public

    def parent_cannot_be_self
      result = true
      if (self.id && parent && parent.id) && (self.id == parent.id)
        msg = 'cannot have the same id as the object itself'
        errors.add(:parent, msg)
        result = false
      end
      return result
    end

  end

end
