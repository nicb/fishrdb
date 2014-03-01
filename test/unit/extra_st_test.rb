#
# $Id: extra_st_test.rb 618 2012-09-23 04:40:09Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class ExtraStTest < ActiveSupport::TestCase

  #
  # fixture load order is important!
  #
	fixtures	:users, :documents
  
  require File.dirname(__FILE__) + '/authority_record_test_object'

  def setup
    assert @user     = User.authenticate('staffbob', 'testtest')
    assert @doc0     = documents(:partiture_GS)
		assert @doc0.valid?
    assert @doc1     = documents(:fondo_GS)
		assert @doc1.valid?
	end

  def test_single_score_title_records_created_multiple_times
    attrs = { :name => 'Ho' }
    assert @st0 = @doc0.create_score_title_record(@user, attrs)
    assert @st0.valid?
    assert @st1 = @doc1.create_score_title_record(@user, attrs)
    assert @st1.valid?
  end

end
