#
# $Id: authority_record_life_test.rb 637 2013-09-10 12:56:40Z nicb $
#
require File.expand_path(File.join(['..'] * 2, 'test_helper'), __FILE__)

class AuthorityRecordLifeTest < ActionController::IntegrationTest
  # fixtures :your, :models

  fixtures :users, :container_types, :documents, :authority_records

  def setup
    assert @user     = users(:staffbob)
    assert @user.valid?, @user.errors.full_messages.join(', ')
    assert @user_password = 'testtest'
    assert @docs = [documents(:series_dump_0001), documents(:series_dump_0003), documents(:series_dump_0004)]
    @docs.each { |doc| assert doc.valid?, doc.errors.full_messages.join(', ') }
    assert @pn_ar = authority_records(:two)
    assert @pn_ar.valid?
    assert @cn_ar = authority_records(:four)
    assert @cn_ar.valid?
    assert @ln_ar = authority_records(:one)
    assert @ln_ar.valid?
    assert @st_ar = authority_records(:three)
    assert @st_ar.valid?
    assert @ars =
    [
       { :number => '1', :options => { 'person_name' => { 'first_name' => @pn_ar.first_name, 'name' => [@pn_ar.name, @pn_ar.first_name, @pn_ar.id.to_s].join('|') }, }, :ar => @pn_ar },
       { :number => '2', :options => { 'collective_name' => { 'name' => [@cn_ar.name, '', @cn_ar.id.to_s].join('|') }, }, :ar => @cn_ar },
       { :number => '3', :options => { 'site_name' => { 'name' => @ln_ar.name }, }, :ar => @ln_ar },
       { :number => '4', :options => { 'score_title' => { 'name' => [@st_ar.name, @st_ar.organico, @st_ar.id.to_s].join('|') }, }, :ar => @st_ar },
    ]
    assert @ars_methods = [:person_names, :collective_names, :site_names, :score_titles]
  end

  #
  # +the_life_of_an_authority_record+
  #
  # This test consist in the following steps:
  # - log in as staff
  # - pick some documents
  # - attach one authority record for each ar type to all documents
  # - verify that it is correctly counted
  # - detach from *one* of the documents
  # - verify that all other documents still count the ar
  #
  def test_the_life_of_an_authority_record
    staff = staff_logs_in
    
    @docs.each do
      |doc|

      staff.picks_a_document(doc)

      @ars.each { |ar| staff.connects_an_authority_record_to_it(doc, ar) }

    end
    #
    # - test that all documents now hold these authority record
    #
    @docs.each do
      |doc|
      @ars_methods.each do
        |meth|
        assert_equal 1, doc.send(meth, true).count
      end
    end

    #
    # remove authority records from first document
    #
    assert d1 = @docs.first
    staff.picks_a_document(d1.id)
    @ars.each { |ar| staff.detachs_an_authority_record(d1, ar) }
    @ars_methods.each { |meth| assert_equal 0, d1.send(meth, true).count }

    @docs[1..@docs.size-1].each do
      |doc|
      @ars_methods.each { |meth| assert_equal 1, doc.send(meth, true).count }
    end
  end

  #
  # +deleting_a_document_with_authorities+
  #
  # This test consist in the following steps:
  # - log in as staff
  # - pick some documents
  # - attach one authority record for each ar type to all documents
  # - verify that it is correctly counted
  # - delete *one* of the documents
  # - verify that all other documents still count the ar
  #
  def test_deleting_a_document_with_authorities
    staff = staff_logs_in
    
    @docs.each do
      |doc|

      staff.picks_a_document(doc)

      @ars.each { |ar| staff.connects_an_authority_record_to_it(doc, ar) }

    end
    #
    # - test that all documents now hold these authority record
    #
    @docs.each do
      |doc|
      @ars_methods.each do
        |meth|
        assert_equal 1, doc.send(meth, true).count
      end
    end

    #
    # remove authority records from first document
    #
    assert d1 = @docs.first
    staff.picks_a_document(d1.id)
		staff.deletes_a_document(d1)

    @docs[1..@docs.size-1].each do
      |doc|
      @ars_methods.each { |meth| assert_equal 1, doc.send(meth, true).count }
    end
  end

private

  module ArExtensions

    def picks_a_document(id)
      self.get 'doc/show', { :id => id }
      self.assert_response :success
      self.assert_template 'doc/show'
    end

		def deletes_a_document(doc)
			parent = doc.parent
      self.get 'doc/delete', { :id => doc.id }
      self.assert_redirected_to "doc/show/#{parent.id}?page=1"
		end

    def connects_an_authority_record_to_it(doc, options)
      num = options[:number]
      parms = { 'add' => 'aggiungi', :id => doc.id, 'doc' => { 'ar_form_number' => num, 'id' => doc.id } }
      parms.merge!(options[:options])
      self.xhr(:post, 'doc/add_authority_record', parms)
      self.assert_response :success
      self.assert_template 'doc/_ar_show_inner'
    end

    def detachs_an_authority_record(doc, options)
      # {"controller"=>"doc", "ar_record_id"=>"163",
      # "ar_form_number"=>"1",
      # "id"=>"10", "action"=>"detach_authority_record"}
      num = options[:number]
      ar = options[:ar]
      parms = { 'ar_record_id' => ar.id, 'ar_form_number' => num, 'id' => doc.id }
      self.xhr(:post, 'doc/detach_authority_record', parms)
      self.assert_response :success
      self.assert_template 'doc/_ar_show_inner'
    end

  end

  def staff_logs_in
    res = open_session do
      |sess|
      sess.extend ArExtensions
      sess.get url_for(:controller => :account, :action => :login)
      sess.post '/account/login', { :user => { :login => @user.login, :password => @user_password } }
      sess.assert_redirected_to 'doc/front'
    end
    res
  end

end
