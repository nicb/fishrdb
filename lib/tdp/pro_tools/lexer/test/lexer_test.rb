#
# $Id: lexer_test.rb 576 2010-12-14 21:56:04Z nicb $
#
require 'test/test_helper'
require 'tdp/pro_tools/lexer'

class LexerTest < ActiveSupport::TestCase

  FIXTURE_DATA_PATH = File.join(File.dirname(__FILE__), '..', '..', '..', 'test')

  def setup
    assert @file0 = File.join(FIXTURE_DATA_PATH, 'NMGS0194-294.txt')
    assert @file1 = File.join(FIXTURE_DATA_PATH, 'NMGS0203-M102D.txt')
  end

  def test_lex_scan
    [ @file0, @file1 ].each do
      |f|
      assert l = Tdp::ProTools::Lexer::Scanner.new(f)
      assert l.pro_tools_session
      assert_equal l.pro_tools_session.num_of_audio_files, l.pro_tools_session.files_in_session.files.size, "# OF AUDIO FILES #{l.pro_tools_session.num_of_audio_files} != #{l.pro_tools_session.files_in_session.files.size}"
      assert_equal l.pro_tools_session.num_of_audio_regions, l.pro_tools_session.regions_in_session.regions.size, "# OF AUDIO REGIONS #{l.pro_tools_session.num_of_audio_regions} != #{l.pro_tools_session.regions_in_session.regions.size}"
      assert_equal l.pro_tools_session.num_of_audio_tracks, l.pro_tools_session.track_listing.tracks.size, "# OF AUDIO TRACKS #{l.pro_tools_session.num_of_audio_tracks} != #{l.pro_tools_session.track_listing.tracks.size}"
      l.pro_tools_session.track_listing.tracks.each do
        |t|
        t.events.each do
          |e|
          assert_equal Tdp::ProTools::Lexer::Event, e.class
          [ :channel, :event, :region_name, :start_time, :end_time, :duration ].each do
            |method|
            assert !e.send(method).blank?
          end
        end
      end
    end
  end

end
