#
# $Id: onchange_strings_helper.rb 270 2008-11-09 12:06:14Z nicb $
#

module OnchangeStringsHelper

protected

  def onchange_string(method, from_tag, to_tag, obj, cntrl, &block)
    result = "new Ajax.Updater('', '/#{cntrl}/#{method}/?'"
    arguments = 
    [
      [ 'from[day]', "#{obj}_#{from_tag}_day" ],
      [ 'from[month]', "#{obj}_#{from_tag}_month" ],
      [ 'from[year]', "#{obj}_#{from_tag}_year" ],
      [ 'to[day]', "#{obj}_#{to_tag}_day" ],
      [ 'to[month]', "#{obj}_#{to_tag}_month" ],
      [ 'to[year]', "#{obj}_#{to_tag}_year" ],
      [ 'from_format', "#{obj}_#{from_tag}_format" ],
      [ 'to_format', "#{obj}_#{to_tag}_format" ],
      [ 'intv_format', "#{obj}_full_date_format" ],
    ]
    arguments.each do
      |a|
      result += "+ '&#{a[0]}=' + escape($('#{a[1]}').value)"
    end
    if block_given?
      result += yield
    end
    result += ', { asynchronous: true, evalScripts: true });'
    return result
  end

end
