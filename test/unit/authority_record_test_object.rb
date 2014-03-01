#
# $Id: authority_record_test_object.rb 208 2008-05-01 16:54:22Z nicb $
#
class TestObject
  attr_reader :klass, :attrs, :varattrs, :varklass, :varmeth, :refmeth, :kmeths
  attr_accessor :var, :varvar

  def initialize(klass, attrs, varattrs, user, non_matchers = [])
    @klass = klass
    @kmeths = attrs.keys
    @varklass = eval("#{@klass.name}Variant")
    @attrs = attrs
    @varattrs = varattrs
    [:creator, :last_modifier].each { |attr| @attrs[attr] = user; @varattrs[attr] = user }
    @var = @varvar = nil
    @varmeth = "#{@klass.name.underscore}_variants".intern
    @refmeth = "#{@klass.name.underscore}"
  end

  def non_matchers
    result = {}
    @kmeths.each { |k| result[k] = @attrs[k] + " @@NON_MATCHING@@" }
    return result
  end
end

