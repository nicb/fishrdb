
XML_EXPORT_PATH = File.expand_path(File.join('..', 'xml_export'), __FILE__)

%w(
	file
  builder
).each { |f| require File.join(XML_EXPORT_PATH, f) }
