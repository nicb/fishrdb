#
# $Id: tape_importer_test.rb 599 2011-01-05 01:04:07Z nicb $
#
require 'test/test_helper'

require 'lib/tdp/tape'

class TapeImporterTest < ActiveSupport::TestCase

  fixtures :sessions, :users, :container_types, :documents

  def setup
    make_sure_tape_tree_is_clean
    clear_logs
  end

  def test_create_tape_records
    assert (sz = create_tape_records_from_scratch) > 0
    assert_equal sz, TapeRecord.all.size
  end

  def test_drop_tape_records
    #
    # first try to drop an empty tape archive
    #
    Tdp::Tape::Mapper.drop_tape_records
    #
    # now fill it in an then drop it
    #
    assert (sz = create_tape_records_from_scratch) > 0
    Tdp::Tape::Mapper.drop_tape_records
    assert tr = TapeData.tape_root
    assert tr.valid?
    assert tr.children(true).clear
    assert_equal 0, TapeRecord.all.size
  end

private

  def create_tape_records_from_scratch
    return Tdp::Tape::Mapper.create_tape_records_from_scratch
  end

  def make_sure_tape_tree_is_clean
    assert tdr = TapeData.tape_root
    assert tdr.children.clear
    assert_equal 0, tdr.children(true).size
    assert_equal 0, TapeRecord.all.size
    assert_equal 0, TapeData.all.size
  end

  def clear_logs
    tt_log = Tdp::Builder::TapeFactory.logfile_name
    begin
      assert_equal 1, File.unlink(tt_log)
    rescue Errno::ENOENT
      # ignore exception if file does not exist
    end
    assert !File.exist?(tt_log)
  end

end
