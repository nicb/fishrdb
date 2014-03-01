#
# $Id: tape_creation_test.rb 502 2010-05-30 20:56:50Z nicb $
#

require 'test/test_helper'

class TapeCreationTest < ActiveSupport::TestCase

  def setup
    ENV['FISHRDB_SESSION_NEEDED'] = 'true'
    #
    # make sure there are no tapes in the database
    #
    TapeRecord.all.each { |tr| tr.destroy }
    assert_equal 0, TapeRecord.all.size
  end

  test "creation" do
    Tdp::Tape::Mapper.create_tape_records_from_scratch
  end

end

