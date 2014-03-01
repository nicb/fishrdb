#
# $Id: children.rb 468 2009-10-17 02:21:36Z nicb $
#
#

module DocumentParts

  module Children

	public
	
		# The doc.children#size method is not always reliable due to the fact that the
		# cache is updated correctly all the time. We put this crude hack up to solve
		# the problem, at least temporarily.
	  def children_size
	    return children(true).size
	  end
	
	  def children_empty?
	    return children(true).empty?
	  end

	protected
	
		AVAILABLE_CLASSES =
    {
      Folder => 'Cartelle',
      Series => 'Documenti',
      Score  => 'Partiture',
      PrintedScore => 'Partiture a Stampa',
      BibliographicRecord => 'Schede Bibliografiche',
      CdRecord => 'CD',
      CdTrackRecord => 'Traccia CD',
    }

    def specialized_allowed_classes(column)
      result = nil
      full_col = "allowed_#{column}_classes"
      result = read_attribute(full_col).split('|').map { |c| c.constantize } if read_attribute(full_col)
      unless result
        result = yield
      end
      return result
    end

	public 
	
    #
    # the default behaviour of the allowed_{children|sibling}_classes is to return
    # the same class type the instance belongs to
    #
		def allowed_children_classes
      return specialized_allowed_classes('children') { self.class }
		end

		def allowed_sibling_classes
      return specialized_allowed_classes('sibling') { self.class }
		end
    #
    # this returns an array of arrays which is suitable for the 'select' form
    # tags that appear in the editing dashboard of documents
    #
  private

    def display_allowed_classes(column)
      result = [['scegli', '']]
      send("allowed_#{column}_classes").map { |acc| result << [ AVAILABLE_CLASSES[acc], acc ] }
      return result
    end

  public

    def display_allowed_children_classes
      return display_allowed_classes('children')
    end

    def display_allowed_sibling_classes
      return display_allowed_classes('sibling')
    end

  end

end
