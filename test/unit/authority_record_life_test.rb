#
# $Id: authority_record_life_test.rb 637 2013-09-10 12:56:40Z nicb $
#
require File.expand_path(File.join(['..'] * 2, 'test_helper'), __FILE__)

#
# These tests were made to uncover a bug described in
#
# http://redmine.scelsi.nicolabernardini.info/issues/352
#
# We create several documents and we attach some common authority files to
# them. Then we delete one of the documents and we check that 
# that the links do not get deleted from the other documents
#
class AuthorityRecordLifeTest < ActiveSupport::TestCase

  fixtures :users, :documents

  def setup
    assert @user     = users(:staffbob)
    assert @ndocs    = 5
    assert @nars     = 5
    assert @ars = [:person_names, :site_names, :score_titles, :collective_names]
    create_appropriate_environment(@ndocs, @nars)
  end

  #
  # This tests whether detaching an authority record from a document
  # removes the connection only to that document
  #
  def test_detachment_of_authority_records
    assert firstdoc = @docs.first
    assert firstdoc.valid?, firstdoc.errors.full_messages.join(', ')
    [[@pns, @ars[0]], [@sns, @ars[1]], [@sts, @ars[2]], [@cns, @ars[3]]].each do
      |ary, method|
      assert ar = ary.first
      assert ar.valid?
      assert firstdoc.detach_authority_record(ar)
      assert_equal @nars - 1, firstdoc.send(method).count
    end
    #
    # now check that all other connections are intact
    #
    @docs[1..@docs.size-1].each do
      |doc|
      @ars.each do
        |method|
        assert_equal @nars, doc.send(method, true).count
      end
    end
  end

  #
  # This tests whether deleting a document destroys the connection of
  # authority records from other documents
  #
  def test_deletion_of_documents
    assert firstdoc = @docs.first
    assert firstdoc.valid?, firstdoc.errors.full_messages.join(', ')
    #
    # delete this document
    #
    assert firstdoc.destroy
    assert firstdoc.frozen?
    #
    # now check that all other connections are intact
    #
    @docs[1..@docs.size-1].each do
      |doc|
      @ars.each do
        |method|
        assert_equal @nars, doc.send(method, true).count
      end
    end
  end

  #
  # This tests whether deleting an authority_record
	# damages the other documents
  #
  def test_deletion_of_authority_records
		[@pns, @sns, @sts, @cns].each do
			|ars|
			assert ar = ars.first
			assert ar.destroy
			assert ar.frozen?
		end
    #
    # now check that all other connections are intact
		# for all documents
    #
    @docs.each do
      |doc|
			assert doc.valid?
			assert !doc.frozen?
      @ars.each do
        |method|
        assert_equal @nars - 1, doc.send(method, true).count
      end
    end
  end

private

  def create_appropriate_environment(num_records, num_ars)
    assert @docs = Document.all(:limit => num_records)
    assert @pns = []
    assert @sns = []
    assert @sts = []
    assert @cns = []
    1.upto(num_ars) do
      |n|
      assert pn = PersonName.create(:first_name => "PN First #{n}", :name => "PN Last #{n}", :creator => @user, :last_modifier => @user)
      assert pn.valid?, pn.errors.full_messages.join(', ')
      assert @pns << pn
      assert sn = SiteName.create(:name => "SN #{n}", :creator => @user, :last_modifier => @user)
      assert sn.valid?, sn.errors.full_messages.join(', ')
      assert @sns << sn
      assert st = ScoreTitle.create(:name => "ST #{n}", :creator => @user, :last_modifier => @user)
      assert st.valid?, sn.errors.full_messages.join(', ')
      assert @sts << st
      assert cn = CollectiveName.create(:name => "CN #{n}", :creator => @user, :last_modifier => @user)
      assert cn.valid?, sn.errors.full_messages.join(', ')
      assert @cns << cn
      @docs.each do
        |doc|
        [@pns, @sns, @sts, @cns].each do
          |ary|
          assert doc.bind_authority_record(@user, ary.last)
        end
      end
    end
  end

end
