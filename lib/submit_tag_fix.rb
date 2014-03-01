#
# $Id: submit_tag_fix.rb 217 2008-05-14 03:46:00Z nicb $
#
# This is a fix for a problem with submit_tag and form_remote_tag,
# reported in: http://dev.rubyonrails.org/ticket/3231
# This fix allows to have multiple submit buttons with different values (e.g.:
# 'save', 'cancel', etc.) and for them to actually work
#
class ActionView::Base

  alias_method :_old_rails_submit_tag, :submit_tag

  def submit_tag(value = "Save changes", options = {})
    options[:id] = (options[:id] || options[:name] || :commit)
    options.update(:onclick => "$('#{options[:id]}').value = '#{value}'")
    _old_rails_submit_tag(value, options)
  end

end
