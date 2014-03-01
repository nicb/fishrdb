#
# $Id: tape_box_marker_collection_display.rb 502 2010-05-30 20:56:50Z nicb $
#

require 'display/model/display_item'

module TapeDataParts

  module TapeBoxMarkerCollectionDisplay

    class TapeBoxMarkerCollectionDisplayItem < ::DisplayItem

      def display_template(obj, user, nfnu)
        result = sub_display_template(obj, user) do
          |tbd|
          %{<tr class=\"tape_box_marker_collection_tag\">
              <td class=\"tape_box_marker_collection_tag\">
                #{tag}:
              </td>
              <td class=\"tape_box_marker_collection\">
                  <%= render(:partial => 'doc/tape_data/tape_box_marker_collection', :collection => @doc.tape_box_marker_collections) -%>
              </td>
            </tr>}
        end
        return result
      end

    end

  end

end
