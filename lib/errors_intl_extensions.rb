#
# $Id: errors_intl_extensions.rb 257 2008-07-26 21:58:15Z nicb $
#
# This is an extension to the Errors class to  get  the  proper  italian
# attribute names in errors
#

class ActiveRecord::Errors

private

  ATTRIBUTE_MAP =
  {
    #
    # attributes must be expressed in string form otherwise this
    # scam will not work: the :each method passes attributes in
    # string form
    #
    :italian => {
      'name' => { :article => 'il', :tag =>  'nome' }
    }
  }

protected

  def to_whatever(lang, attr)
    result = { :article => '', :tag => attr }
    result = ATTRIBUTE_MAP[lang].has_key?(attr) ? ATTRIBUTE_MAP[lang][attr] : result if ATTRIBUTE_MAP.has_key?(lang)
    return result[:article] + ' ' + result[:tag]
  end

  def to_it(attr)
    return to_whatever(:italian, attr)
  end

public

  def italian_each(&block)
    each { |attr, msg| yield(to_it(attr), msg) }
  end

end
