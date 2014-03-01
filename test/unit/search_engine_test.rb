#
# $Id: search_engine_test.rb 617 2012-07-15 16:30:06Z nicb $
#

require 'test/test_helper'
require 'test/extensions/subtest'

require 'search_engine/../../test/utilities/index_rebuild'

class SearchEngineTest < ActiveSupport::TestCase

  include Test::Extensions
  include SearchEngine::Test::Utilities::IndexRebuild

  fixtures :all

  def setup
    assert @ns_blocks = 5
    assert @ns_blocksize = 100
    assert @num_searches = @ns_blocksize * @ns_blocks
		assert @cdtr1 = documents(:action_music_n_1_ctr)
		assert @cdtr1.valid?
		assert @cdr1 = documents(:test_record_01)
		assert @cdr1.valid?
 		if @cdtr1.authors.empty?
 			assert gs = names(:gs)
 			assert gs.valid?
 			assert @cdtr1.cd_track.cd_track_authors.create(:name => gs)
 			assert !@cdtr1.authors(true).empty?
 		end
		if @cdtr1.performers.empty?
		  assert p = performers(:wambach_p)
			assert p.valid?
			assert @cdtr1.cd_track.cd_track_performers.create(:performer => p)
			assert !@cdtr1.performers(true).empty?
		end
		if @cdtr1.ensembles.empty?
		  assert e = ensembles(:wallonie)
			assert e.valid?
			assert @cdtr1.cd_track.cd_track_ensembles.create(:ensemble => e)
			assert !@cdtr1.ensembles(true).empty?
		end
		if @cdr1.booklet_authors.empty?
			assert acp = names(:acp)
			assert acp.valid?
			assert @cdr1.booklet_authors << acp
			assert !@cdr1.booklet_authors(true).empty?
		end
		#
		# rebuild the search indices to get proper indexing
		#
		assert SearchEngine::SearchIndex.delete_all
    rebuild_search_index
  end

	def test_that_all_indices_are_well_connected
		counter = 0
		SearchEngine::SearchIndex.all.each do
			|si|
			assert taint = '+'
			assert counter += 1
			assert si
			assert si.valid?
			assert !si.related_records.blank?
			assert_nil obj = nil
			si.search_index_classes.each do
				|sic|
				assert klass = sic.class_name.constantize
				begin
				  obj =	klass.find(si.record_id)
					next if obj && obj.valid?
				rescue ActiveRecord::RecordNotFound
				# if we didn't find anything, go to the next class
				end
			end
			taint = 'X' unless obj && obj.valid?
			assert counter %= 10
			subtest_finished(taint) if counter == 0
		end
	end

  def test_search_fields
    assert sem = SearchEngine::Manager.create
    assert sem.searchable_objects.size > 0
    sem.searchable_objects.each do
      |klass|
      assert klass.respond_to?(:allow_search_in)
      assert klass.search_engine_fields.size > 0
      subtest_finished
    end
  end

  def test_full_search
    common_search_test(@ns_blocks, @ns_blocksize) do
      |k, si, n|
      assert d = k.find(si.record_id)
      assert d.valid?
      assert_equal d.send(si.field).to_s.search_engine_cleanse, si.string
    end
  end

  def test_partial_search
    common_search_test(@ns_blocks, @ns_blocksize) do
      |k, si, n|
	    assert d = k.find(si.record_id)
	    assert d.valid?
      assert strsiz = si.string.size
      if strsiz < 4 # if string is too small perform a full search
	      assert_equal d.send(si.field).to_s.search_engine_cleanse, si.string
      else
        assert slicestart = (rand()*strsiz*0.5).round
        assert sliceend   = ((strsiz*0.5) * (rand() + 1)).round 
        #
        # what follows is a hack to bypass a bug in rails regexp handling
        #
        assert ss = Regexp.escape(si.string.slice(slicestart..sliceend))
        ss[ss.size-1] = '.' if ss[ss.size-1] > ?~ # replace last char with a dot if non-ascii
        assert substr = Regexp.compile(ss, 'U')
        assert d.send(si.field).to_s.search_engine_cleanse.grep(substr)
      end
    end
  end

	def test_series_search
    common_search_test(@ns_blocks, @ns_blocksize) do
      |k, si, n|
      assert rr = si.reference_roots
      assert doc = k.find(si.record_id)
      doc.related_records.each do
        |d|
	      assert d.valid?
        next if d.description_level <= DescriptionLevel.serie
        assert related_series_id = rr[d.id.to_s].to_i
        assert_equal d.reference_series, related_series_id
        assert s = Document.find(related_series_id)
        assert s.valid?
        assert_equal d.reference_series.id, s.id
        assert s.description_level <= DescriptionLevel.serie
      end
    end
  end

  def test_unconnected_authority_record
    assert uar = authority_records(:unconnected) # this one is not connected to documents
    assert uar.valid?
    assert sf = :name
    assert si = SearchEngine::SearchIndex.index(uar, uar.send(sf), sf)
    assert si.valid?
  end

  def test_funky_collation_problem
    assert fcar = authority_records(:funny_collation)
    assert fcar.valid?
    assert sf = :first_name
    assert si = SearchEngine::SearchIndex.index(fcar, fcar.send(sf), sf)
    assert si.valid?
  end

  #
  # NOTE: this test will fail when new searchable classes get added and will need to
  # be updated by hand
  #
  def test_class_reindexing_management
    assert classes_should_be =
    [
      'Series',
      'Score',
      # 'Folder', # Folder classes should be excluded from indexing
      'PrintedScore',
      'PersonName',
      'PersonNameVariant',
      'CollectiveName',
      'CollectiveNameVariant',
			'Name',
      'SiteName',
      'SiteNameVariant',
      'ScoreTitle',
      'ScoreTitleVariant',
      'BibliographicRecord',
      'CdRecord',
      'CdTrackRecord',
      'TapeRecord',
    ].sort
    assert classes = SearchEngine::Manager.searchable_objects.map { |c| c.name }.sort.delete_if { |x| x =~ /DocumentTest::/ }
    assert_equal classes_should_be, classes
  end

  def test_search_should_return_unique_results
    assert gs = authority_records(:two) # this one is not connected to documents
    assert gs.valid?
    assert fn = gs.first_name
    assert r = SearchEngine::Search.search_documents(fn)
  end

	def test_index_creation
    assert sem = SearchEngine::Manager.create
    assert sem.searchable_objects.size > 0
    sem.searchable_objects.each do
      |klass|
      assert klass.respond_to?(:allow_search_in)
      assert klass.search_engine_fields.size > 0
			if (kcount = klass.count) > 0
  			assert attrs = klass.first.attributes.keys
  			klass.search_engine_fields.each do
  				|sif|
  				assert num_of_attempts = kcount * 4
  				assert already_done = []
  				assert attempt_no = 0
  				assert_nil mock_object = nil
  				assert which = 0
  				if attrs.include?(sif)
  					mock_object = klass.first(:conditions => ["#{sif} is not null"])
  				else
    				1.upto(num_of_attempts) do
    					|n|
    					assert which = 0
    					assert retries = 0
    					begin
    						assert which = (rand() * (kcount - 1)).round
    						assert retries += 1
    						break if retries > kcount
    					end while already_done.include?(which)
    					assert already_done << which
    					assert mock_object = klass.first(:offset => which), "select first on object #{klass.name} with offset #{which} for method #{sif}"
    					break unless mock_object.send(sif).blank?
    					assert attempt_no += 1
    				end
  				end
  				unless mock_object.send(sif).blank?
  					assert mock_string = mock_object.send(sif)
  					assert si = SearchEngine::SearchIndex.index(mock_object, sif, mock_string)
  					assert si.valid?, "Invalid index for object #{mock_object.inspect}.#{sif} (== #{mock_string}) (#{si.errors.full_messages.join(', ')})"
        		subtest_finished
  				else
  					Rails.logger.debug(">>>> Could not test indexing for #{klass.name}##{sif} (attempt n.#{attempt_no})")
  					subtest_finished('X')
  				end
  			end
			else
				Rails.logger.debug(">>>> Not enough objects to test search indexing for model #{klass.name}")
			end
    end
	end

private

  def common_search_test(n_blocks, n_blocksize)
    assert (indices = SearchEngine::SearchIndex.all.size) > 0
    1.upto(n_blocks) do
      |nb|
      1.upto(n_blocksize) do
        |nbs|
	      assert idx = (rand()*(indices-1)).round + 1
	      assert si = SearchEngine::SearchIndex.find(idx)
	      assert si.valid?
        si.search_index_classes.each do
          |sic|
          assert k = sic.class_name.constantize
          yield(k, si, ((nb-1)*n_blocksize)+nbs)
        end
      end
      subtest_finished
    end
  end

end
