#
# $Id: sound.rb 555 2010-09-12 19:53:28Z nicb $
#

require 'tape_name_caption'

class String

  def clean_url
    return self.gsub(/ /, '%20')
  end

end

module TapeDataParts

  module Sound

    class TapeSoundDisplayItem < DisplayItem

      def display_template(obj, user, nfnu)
        result = sub_display_template(obj, user) do
          |tbd|
          %{<tr valign=\"#{calc_valign}\">
              <td class=\"record_item_tag\">
                #{tag}:
              </td>
              <td class=\"record_item_content\">
                <%= render(:partial => 'doc/tape_data/sound', :object => @doc) -%>
              </td>
            </tr>}
        end
      end

    end

  private

    def sound_path
      root = "public/private/lofi"
      subdir = tape_record.parent.name
      (subsubdir, thrown_away) = tape_record.name.split('-')
      return root + '/' + subdir + '/' + subsubdir + '-*/Audio Files'
    end

  public

    def sound_collection
      result = Dir[sound_path + '/*-56.mp3'].map { |s| TapeNameCaption::Caption.new(s) }
      return result
    end

  end

end
