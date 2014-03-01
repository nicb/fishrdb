#
# $Id: auto_complete_helper.rb 277 2008-12-29 21:29:50Z nicb $
#

module AutoCompleteHelper

protected

  def auto_complete_finder(search_term, column, klass, options = {})
    opts =
    {
      :conditions => ["lower(#{column}) like ? and authority_records.type = '#{klass.name}'", '%' + search_term.downcase + '%'],
      :order => "#{column}"
    }
    opts.merge(options)
    return klass.find(:all, opts) unless search_term.blank?
  end

  def auto_complete_render(partial, results)
    render :partial => partial, :object => results
  end

  def auto_completer(search_term, column, klass, partial, options = {})
    results = auto_complete_finder(search_term, column, klass, options)
    auto_complete_render(partial, results)
  end

end
