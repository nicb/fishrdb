#
# $Id: image_display.rb 490 2010-04-18 00:59:22Z nicb $
#

require 'display/model/display_item'

module TapeDataParts

  module ImageDisplay

    require 'exifr'

    class ImageDisplay
      attr_reader :filename, :exif_data, :width, :height, :bms_width, :bms_height

      def initialize(f)
        @filename = f
        @exif_data = EXIFR::JPEG.new(f)
        @width = @exif_data.width
        @height = @exif_data.height
        (@bms_width, @bms_height) = calculate_bms_size
      end

      def rails_name
        return filename.sub(/\Apublic/, '')
      end

      def stripped_filename
        return File.basename(filename, '.jpg').sub(/-[0-9]{3}\Z/, '')
      end

      def ms_equivalent
        return rails_name.sub(/-128\.jpg/, '-768.jpg')
      end

      def fs_equivalent
        return rails_name.sub(/-128\.jpg/, '.jpg')
      end

      def <=>(other)
        return filename <=> other.filename
      end

    private

      MAX_RESCALED_HEIGHT = 466.0
      MAX_RESCALED_WIDTH  = 916.0

      #
      # rescale according to the largest element, then
      # check that the maximum height is not overflown,
      #                   otherwise rescale accordingly
      # then
      # check that the maximum width is not overflown,
      #                   otherwise rescale accordingly
      #
      def calculate_scale_factor
        result = 1.0
        wscale = MAX_RESCALED_WIDTH/width
        hscale = MAX_RESCALED_HEIGHT/height
        if width >= height
          result = wscale
          result = (height*result > MAX_RESCALED_HEIGHT) ? hscale : wscale
        else
          result = hscale
          result = (width*result > MAX_RESCALED_WIDTH) ? wscale : hscale
        end
        return result
      end

      def calculate_bms_size
        scale = calculate_scale_factor
        return [width * scale, height * scale]
      end

    end

    class TapeBoxImageDisplayItem < ::DisplayItem

      def display_template(obj, user, nfnu)
        result = sub_display_template(obj, user) do
          |tbd|
          %{<tr valign=\"#{calc_valign}\">
              <td class=\"record_item_tag\">
                #{tag}:
              </td>
              <td class=\"record_item_content\">
                  <%= render(:partial => 'doc/tape_data/box_image', :collection => @doc.box_thumbnail_collection) -%>
              </td>
            </tr>}
        end
      end

    end

    class TapeSnapshotImageDisplayItem < ::DisplayItem

      def display_template(obj, user, nfnu)
        result = sub_display_template(obj, user) do
          |tbd|
          %{<tr valign=\"#{calc_valign}\">
              <td class=\"record_item_tag\">
                #{tag}:
              </td>
              <td class=\"record_item_content\">
                  <%= render(:partial => 'doc/tape_data/box_image', :object => @doc.snapshot_thumbnail) -%>
              </td>
            </tr>}
        end
      end

    end

  private

    def thumbnail_path
      root = "public/private/lofi"
      subdir = tape_record.parent.name
      (subsubdir, thrown_away) = tape_record.name.split('-')
      return root + '/' + subdir + '/' + subsubdir + '-*/Images'
    end

  public

    def box_thumbnail_collection
      # NOTE: this must be made relative to the *image* path
      return Dir[thumbnail_path + '/[0-9]*-128.jpg'].map { |fn| ImageDisplay.new(fn) }.sort
    end

    def snapshot_thumbnail_path
      # NOTE: this must be made relative to the *image* path
      return Dir[thumbnail_path + '/[Ss]napshot*-128.jpg'].first
    end

    def snapshot_thumbnail_rails_path
      return snapshot_thumbnail_path.sub(/\Apublic\//, '')
    end

    def snapshot_thumbnail
      t_snap = snapshot_thumbnail_path
      if t_snap
        result = ImageDisplay.new(t_snap)
      else
        result = nil
      end
      return result
    end

  end

end
