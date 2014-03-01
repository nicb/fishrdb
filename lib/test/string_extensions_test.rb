#
# $Id: string_extensions_test.rb 613 2012-01-17 01:55:24Z nicb $
#

require File.expand_path(File.join(File.dirname(__FILE__), ['..'] * 2, 'test', 'test_helper'))

class StringExtensionsTest < ActiveSupport::TestCase

  #
  # TODO: no time now to do all the tests for each string extension. Will do
  # them later, when (badly) needed.
  #
  
  def test_clean_filename_for_dumb_operating_systems
    assert clean_filename = 'ugly_file_name'
    assert ugly_filenames = %w(ugly/file/name ugly\\file\\name ugly:file:name ugly*file*name ugly?file?name ugly"file"name ugly<file<name ugly>file>name ugly|file|name)
    ugly_filenames.each do
      |bad|
      assert_equal clean_filename, bad.clean_filename_for_dumb_operating_systems
    end
  end

end
