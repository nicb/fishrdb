#
# $Id: reference_roots_helper.rb 565 2010-11-28 19:53:45Z nicb $
#

module ReferenceRootsHelper

  def reference_roots
    result = {}
    related_records.each { |d| result.update(d.id.to_s => d.reference_series.id.to_s) }
    return result
  end
	
end
