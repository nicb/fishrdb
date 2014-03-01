#
# $Id: text_helper.rb 250 2008-07-21 20:40:27Z nicb $
#
# Helper functions that are needed in models rather than in views
#

module TextHelper

  def truncate(text, length = 30, truncate_string = "...")
    if text.blank? then return end
    l = length - truncate_string.chars.length
    (text.chars.length > length ? text.chars[0...l] + truncate_string : text).to_s
  end

end
