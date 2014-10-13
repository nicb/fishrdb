#
# $Id$
#
# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
#
Inflector.inflections do |inflect|
  inflect.uncountable %w( bibliographic_data tape_data cd_data )

	#
	# italian rules
	#

	inflect.plural /[oe]$/i, 'i'
	inflect.plural /a$/i, 'e'
	inflect.plural /(erie)$/i, '\1'

end
