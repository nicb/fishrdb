#
# $Id: string_extensions.rb 613 2012-01-17 01:55:24Z nicb $
#

class String

private

  def common_gsub(gsub_method, re, string)
    return self.send(gsub_method, re, string)
  end

  def common_newlines_to_html(gsub_method)
    return common_gsub(gsub_method, /\n/, '<br />')
  end

public

  def newlines_to_html
    return common_newlines_to_html(:gsub)
  end

  def newlines_to_html!
    return common_newlines_to_html(:gsub!)
  end

  def cleanse
    return common_gsub(:gsub, /[_\W]+/, ' ')
  end

  def cleanse!
    return common_gsub(:gsub!, /[_\W]+/, ' ')
  end

  def escape_everything
    return Regexp.escape(self).gsub(/(["`'@#])/, '\\\\\1')
  end

  #
  # +clean_filename_for_dumb_operating_systems+:     when     generating
  # filenames, the generation must take into account the fact that  some
  # operating systems cannot deal with special  characters  cleanly.  In
  # particular, the following characters should be avoided: \/:*?"<>|
  # This is what this method is for.
  #
  def clean_filename_for_dumb_operating_systems
    return Regexp.escape(self).gsub(/[\\\/:*?"<>|]/, '_').gsub(/__/, '_')
  end

end
