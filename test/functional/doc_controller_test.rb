#
# $Id: doc_controller_test.rb 638 2013-09-11 07:27:21Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../extensions/subtest'
require File.dirname(__FILE__) + '/../extensions/session'
require File.dirname(__FILE__) + '/../utilities/string'
require File.dirname(__FILE__) + '/../utilities/classes'
require File.dirname(__FILE__) + '/../utilities/multiple_test_runs'

#
# NOTE: this extension is necessary to the 
#       "description and notes carriage returns should be transformed" test
#       (this is probably a hack that should be fixed otherwise)
#
class Document < ActiveRecord::Base

  def description_level_position
    return DescriptionLevel.find_by_position(description_level_id).position
  end

end

require 'doc_controller'

class DocControllerTest < ActionController::TestCase

  include Test::Extensions
  include Test::Utilities::MultipleTestRuns
  include Test::Utilities

# number_of_runs(5)

  fixtures  :all

  class DocController; def rescue_action(e) raise e end; end

  def setup
    assert @ct = container_types(:aa_busta)
    assert @dl_pos = DescriptionLevel.unita_documentaria.position
    assert @user = users(:staffbob)
    assert @anon_user = users(:anonymous)
    assert @admin_user = users(:bootstrap)
    assert @public_user = users(:bob)
    assert @fis_parent = documents(:fondo_GS)
    assert @s_1 = sessions(:one)
    assert @name = names(:gs)
    @request.session.session_id = @s_1.session_id
    @request.session['user'] = @user
  end

  def test_front_page
    get :front, nil

    assert_response :success
  end

  def test_some_random_page_shows
    #
    # pick some random pages from all available Document subclasses
    #
    pool = Document.subclasses
    pool.each do
      |k|
      set = k.all
      assert set.size > 0, "Not enough documents to test, document pool is too small for class #{k.name}, aborting"
      pick = (rand() * set.size - 1).round
      d = set[pick]
      assert d
      assert d.valid?
      get :show, { :id => d.id }
      assert_response :success
      subtest_finished
    end
  end

  def pre_traverse_children(doc, &block)
    yield(doc)
    doc.children(true).each do
      |c|
      pre_traverse_children(c, &block)
    end
  end

  def post_traverse_children(doc, &block)
    doc.children(true).each do
      |c|
      post_traverse_children(c, &block)
    end
    yield(doc)
  end

  def test_sidebar_toggle
    froot = Document.fishrdb_root
    sb = SidebarTree.retrieve(@request.session)
    pre_traverse_children(froot) do
      |d|
      # open
      post :toggle, { :id => d.id }
      assert_redirected_to :action => :show, :id => d.id
      assert sbi = sb.sidebar_tree_items.find_by_document_id(d.id)
      if sbi.document == Document.fishrdb_root
        sbi.open # the root should be open by default, so an initial toggle
                 # would close it, so we re-open it
      end
      assert sbi.open?
      assert sbi.selected?
      d.ancestors.reverse.each do
        |a|
        assert asbi = sb.sidebar_tree_items.find_by_document_id(a.id)
        assert asbi.open?
        assert !asbi.selected?
      end
    end
    post_traverse_children(froot) do
      |d|
      # close
      post :toggle, { :id => d.id, :open_tree => 'false' }
      assert_redirected_to :action => :show, :id => d.id, :open_tree => 'false'
      assert sbi = sb.sidebar_tree_items.find_by_document_id(d.id)
      assert sbi.closed?
      assert sbi.selected?
    end
  end

  def test_search
    assert froot = Document.fishrdb_root

    get :search, {"commit"=>"Ricerca:", "action"=>"search",
                         "controller"=>"doc", "search"=>{"refine"=>"no", "root"=> froot.id,
                         "terms"=>"ho"}}
    assert_response :success
  end

  #
  # FIXME: this part has to be completely rewritten using cucumber and webrat.
  # As it is, it is next to impossible to maintain. ([ticket:213 #213])
  #
  # test_create_and_update
  #

#  class CreatorTesterNotImplemented < StandardError
#  end
#
#  class NonExistentKeyInCreationArgs < StandardError
#  end
#
#  class ValueIsNotAHashAsExpected < StandardError
#  end
#
#  class CreatorTester # abstract base class for all creator_testers
#    attr_reader :klass, :doc_cargs, :response
#
#    include Test::Utilities::Functional
#
#    def initialize(parent, resp)
#      @response = resp
#      @klass = self.class.name.sub(/^DocControllerTest::/,'').sub(/CreatorTester$/,'').constantize
#      u = User.find_by_login('staffbob')
#      ct = ContainerType.find_by_container_type('busta')
#      dl_pos = DescriptionLevel.unita_documentaria.position
#      @doc_cargs = {'doc' =>  {'num_items'=> NUM, 'consistenza'=> STRING, 'container_number'=> NUM,
#                                'name' => STRING,
#                                'position'=> NUM, 'corda_alpha'=> STRING,
#                                'corda'=> STRING,
#                                'creator_id'=> NUM,
#                                'last_modifier_id'=> NUM,
#                                'container_type_id'=> NUM,
#                                'type'=> @klass.name,
#                                'parent_id' => parent.id.to_s,
#                                'note'=> STRING,
#                                'name_prefix'=> STRING,
#                                'description_level_position'=> dl_pos,
#                                'public_access'=> BOOL,
#                                'public_visibility'=> BOOL,
#                              }, :update => ' salva ' }
#    end
#
#    def integrate_doc_args
#      yield(doc_cargs)
#    end
#
#    def verify(obj)
#      return true # TODO: this needs to be done, following the attributes and sub attributes
#    end
#
#    def fill_args_trees_from_reference(h, ref)
#      h.each do
#        |k, v|
#        raise(NonExistentKeyInCreationArgs, "key #{k} does not exist in creation args") unless ref.has_key?(k)
#        if v.is_a?(Hash)
#          raise(ValueIsNotAHashAsExpected, "value #{v.inspect} is not a hash as expected for key #{k}") unless ref[k].is_a?(Hash)
#          fill_args_trees_from_reference(v, ref[k])
#        else
#          h[k] = ref[k].produce
#        end
#      end
#    end
#
#    def fill_response_body
#      rb = parse_and_fill_response_body
#      fill_args_trees_from_reference(rb, doc_cargs)
#      return rb
#    end
#
#    def submit_args
#      return fill_response_body
#    end
#
#    def create_args
#      result = { 'creator_id' => doc_cargs['doc']['creator_id'],
#                 'last_modifier_id' => doc_cargs['doc']['last_modifier_id'] }
#      return result
#    end
#
#    def create_template
#      result = klass.new_form
#      pos = result.rindex('/')
#      return result.insert(pos+1, '_')
#    end
#
#  end
#
#  class FolderCreatorTester < CreatorTester
#
#    def initialize(parent, resp)
#      super(parent, resp)
#    end
#
#  end
#
#  class SeriesCreatorTester < CreatorTester
#
#    def initialize(parent, resp)
#      super(parent, resp)
#    end
#
#  end
#
#  class ScoreCreatorTester < CreatorTester
#
#    def initialize(parent, resp)
#      super(parent, resp)
#      integrate_extra_args do
#        |hash|
#        hash.update('anno_composizione_score' => YEAR, 'anno_edizione_score' => YEAR,
#                    'edizione_score' => STRING, 'consistenza' => STRING,
#                    'misure_score' => STRING)
#      end
#    end
#
#  end
#
#  class PrintedScoreCreatorTester < CreatorTester
#
#    def initialize(parent, resp)
#      super(parent, resp)
#      integrate_extra_args do
#        |hash|
#        hash.update('quantity' => NUM)
#      end
#    end
#
#  end
#
#  class CdRecordCreatorTester < CreatorTester
#
#    def initialize(parent, resp)
#      super(parent, resp)
#      integrate_extra_args do
#        |hash|
#        hash.update('quantity' => NUM,
#                    'cd_data' =>
#                    {
#                      'record_label' => STRING,
#                      'catalog_number' => STRING,
#                      'publishing_year' => YEAR,
#                   })
#      end
#    end
#
#  end
#
#  class CdTrackRecordCreatorTester < CreatorTester
#
#    def initialize(parent, resp)
#      super(parent, resp)
#      initialize_extra_args do
#        |hash|
#        t = TIME.produce
#        hash.update('cd_track' =>
#                    {
#                      'ordinal' => NUM,
#                      'for' => @STRING,
#                      'duration' => { 'hour' => t.hour, 'minute' => t.min, 'second' => t.sec }
#                    })
#      end
#    end
#
#  end
#
#  class BibliographicRecordCreatorTester < CreatorTester
#    # TODO: TBD
#  end
#
#  def test_create_and_update
#    models = [ FolderCreatorTester, SeriesCreatorTester, ScoreCreatorTester,
#               PrintedScoreCreatorTester , CdRecordCreatorTester,
#               CdTrackRecordCreatorTester, BibliographicRecordCreatorTester ]
#    models.each do
#      |k|
#      @controller = ::DocController.new # avoid carryovers from previous requests
#      assert p = Folder.create_from_form({ :name => 'Test folder', :parent => @fis_parent,
#                                         :creator => @user, :last_modifier => @user,
#                                         :container_type => @ct,
#                                         :description_level_position => DescriptionLevel.sottoserie.position }, @s_1)
#      assert p.valid?
#      m = k.new(p, @response)
#      #
#      # get the form first
#      #
#      post :new_child, { :position => '1', :classname => m.klass.name, :id => p.id }, { :user => @user }
#      assert_response :success
#      assert_template m.create_template
#      #
#      # fill it up and submit, then check that record was added
#      #
#      ksize = m.klass.all.size
#      psize = p.children(true).size
#      assert_difference(['p.children(true).size', 'm.klass.all.size']) do
#        post :create_or_update_form, m.submit_args, { :user => @user }
#      end
#      assert_redirected_to(:action => :show, :id => p.children(true)[0].id, :page => '1')
#      assert_equal m.klass, p.children(true)[0].class
#      assert m.verify(p.children[0]) # check internally
#      #
#      # now attempt an update of the same record
#      #
#      doc_id = p.children[0].id
#      args = HashWithIndifferentAccess.new(m.submit_args)
#      args[:doc].read_and_delete(:num_items)
#      args[:doc].update(:id => doc_id)
#      assert_no_difference(['p.children(true).size', 'm.klass.all.size']) do
#        post :create_or_update_form, args, { :user => @user }
#      end
#      assert_redirected_to(:action => :show, :id => doc_id, :page => '1')
#      assert m.verify(p.children[0]) # check internally
#      #
#      # destroy everything before looping back to the top
#      #
#      assert doc = p.children(true)[0]
#      assert p.delete_from_form
#      assert p.frozen?
#      assert_raise(ActiveRecord::RecordNotFound) { doc.reload }
#      subtest_finished
#    end
#  end

  #
  # xmlHttpRequest method tests
  # 
  class TestAssociation
    attr_reader :klass, :association, :single, :c_args

    include Test::Utilities

    def initialize(k, a, s)
      @klass = k; @association = a; @single = s
      u = User.find_by_login('staffbob')
      @c_args = { :creator_id => u.id, :last_modifier_id => u.id }
    end

    def create_item
      return Name.find_or_create({ :last_name => random_string, :first_name => random_string, :pseudonym => random_string }, c_args)
    end

    def remove_one_associate_record(parms, base = 'doc')
      key = parms[base][klass.subkey.to_s].keys.grep(/#{association}_/).last
      parms[base][klass.subkey.to_s].delete(key)
      return parms
    end
  end

  class TestPerformerAssociation < TestAssociation
    def create_item
      return Performer.find_or_create({ :name_id => Name.find_or_create({ :last_name => random_string, :first_name => random_string, :pseudonym => random_string }, c_args).id, :instrument_id => Instrument.find_or_create({ :name => random_string }, c_args).id }, c_args)
    end
  end

  class TestEnsembleAssociation < TestAssociation
    def create_item
      return Ensemble.find_or_create({ :conductor_id => Name.find_or_create({ :last_name => random_string, :first_name => random_string, :pseudonym => random_string }, c_args).id, :name => random_string }, c_args)
    end
  end

  def test_add_a_name_record_on_an_empty_record
    c_and_a = [
      TestAssociation.new(CdRecord, :booklet_authors, 'share/name'),
      TestAssociation.new(CdTrackRecord, :authors, 'share/name'),
      TestPerformerAssociation.new(CdTrackRecord, :performers, 'doc/cd_track_record/performer'),
      TestEnsembleAssociation.new(CdTrackRecord, :ensembles, 'doc/cd_track_record/ensemble'),
    ]
    c_and_a.each do
      |ta|
      c = ta.klass
      ndx = 0
      unitag = c.generate_association_adder_key(ta.association)
      xhr :post, :add_a_record_name, { :class => c.name, :index => ndx.to_s, :association => ta.association.to_s, :single => ta.single, :unitag => unitag }, { :user => @user, unitag => ndx.to_sss }
      assert_response :success
      assert_equal (ndx + 1).to_sss, session[unitag], "#{ta.klass.name}::#{ta.association.to_s}: "
      subtest_finished
    end
  end

  def test_add_a_record_name_on_a_filled_up_record
    c_and_a = [
      TestAssociation.new(CdRecord, :booklet_authors, 'share/name'),
      TestAssociation.new(CdTrackRecord, :authors, 'share/name'),
      TestPerformerAssociation.new(CdTrackRecord, :performers, 'doc/cd_track_record/performer'),
      TestEnsembleAssociation.new(CdTrackRecord, :ensembles, 'doc/cd_track_record/ensemble'),
    ]
    c_and_a.each_with_index do
      |ta, ndx|
      c = ta.klass
      doc = c.first
      ass = ta.association
      0.upto((rand()*3).round+1) do
        doc.send(ass).<<(ta.create_item)
      end
      size = doc.send(ass, true).size
      unitag = c.generate_association_adder_key(ass)
      xhr :post, :add_a_record_name, { :class => c.name, :index => ndx.to_s, :association => ass.to_s, :unitag => unitag, :single => ta.single }, { :user => @user, unitag => size.to_sss }
      assert_response :success
      assert_equal (size+1).to_sss, session[unitag], "#{ta.klass.name}::#{ta.association.to_s}: "
      subtest_finished
    end
  end

  def test_removing_a_record_name_on_a_filled_up_record
    c_and_a = [
      TestAssociation.new(CdRecord, :booklet_authors, 'share/name'),
      TestAssociation.new(CdTrackRecord, :authors, 'share/name'),
      TestPerformerAssociation.new(CdTrackRecord, :performers, 'doc/cd_track_record/performer'),
      TestEnsembleAssociation.new(CdTrackRecord, :ensembles, 'doc/cd_track_record/ensemble'),
    ]
    c_and_a.each_with_index do
      |ta, ndx|
      c = ta.klass
      doc = c.first
      assert doc
      assert doc.valid?
      ass = ta.association
      num = (rand()*3).round+2
      0.upto(num-1) do
        doc.send(ass).<<(ta.create_item)
      end
      assert_equal num, size = doc.send(ass, true).size
      unitag = c.generate_association_adder_key(ass)
      #
      # now let's remove a record
      #
      xhr :post, :edit, { :id => doc.id, :page => 1.to_s }, { :user => @user }
      assert_response :success
      #
      # FIXME: this can't really be tested like this. assert_select should be
      # used (or cucumber and webrat)
      #
#       parms = parse_and_fill_response_body
#       parms = ta.remove_one_associate_record(parms)
#       parms['submit'] = 'save'
#       post :create_or_update_form, parms, { :user => @user }
# #     post_response_body :create_or_update_form, :save, parms, { :user => @user }
#       assert_redirected_to :action => :show, :id => doc.id, :page => 1.to_s
#       assert_equal num-1, doc.send(ass, true).size
      subtest_finished
    end
  end

  #
  # renumbering of children cordas
  #

  def test_renumber_children_cordas
    classes = Document.subclasses
    p_args = { :creator => @user, :last_modifier => @user,
             :description_level_position => DescriptionLevel.unita_documentaria.position,
             :container_type => @ct }
    p_args.update(:name => 'Parent of renumbered cordas')
    assert p = Folder.create_from_form(p_args, @s_1)
    objs = []
    classes.each do
      |c|
      assert c_args = p_args.dup
      assert c_args.update(:name => "Child of class #{c.name}", :parent => p)
      assert obj = c.create_from_form(c_args, @s_1) 
    end
    assert_equal classes.size, p.children(true).size

    post_args = { "start_corda_number"=>"1", "id"=> p.id.to_s, "renumber"=>"rin. corde"}
    post :renumber_children_cordas, post_args, { :user => @user }

    p.children(true).each_with_index do
      |c, i|
      assert_equal i+1, c.corda
    end
    offset = 23

    post_args = { "start_corda_number"=> offset.to_s, "id"=> p.id.to_s, "renumber"=>"rin. corde" }
    post :renumber_children_cordas, post_args, { :user => @user }

    assert p.renumber_children_cordas(23)
    p.children(true).each_with_index do
      |c, i|
      assert_equal i+offset, c.corda
    end
  end

  def test_relative_renumber_children_cordas
    classes = Document.subclasses
    p_args = { :creator => @user, :last_modifier => @user,
              :description_level_position => DescriptionLevel.unita_documentaria.position,
              :container_type => @ct }
    p_args.update(:name => 'Parent of relative renumbered cordas')
    assert p = Folder.create_from_form(p_args, @s_1)
    objs = []
    ds = DateTime.now.to_date
    classes.each do
      |c|
      cur_d = ds
      0.upto(2) do
        |i|
        assert c_args = p_args.dup
        assert c_args.update(:name => "Child of class #{c.name}", :parent => p, :data_dal => cur_d + i.years)
        assert obj = c.create_from_form(c_args, @s_1) 
      end
    end
    assert_equal classes.size*3, p.children(true).size
 
    post_args = { "start_corda_number"=>"1", "id"=> p.id.to_s, "renumber"=>"rin. corde",  "corda_number_relative_to_year"=>"1" }
    post :renumber_children_cordas, post_args, { :user => @user }
 
    assert childs = p.children(true).sort { |a, b| a.corda_renumbering_scope <=> b.corda_renumbering_scope }
    offset = 1
    last_par = par = n = nil
    childs.each do
      |c|
      par = c.corda_renumbering_scope
      n = offset unless par == last_par
      assert_equal n, c.corda
      last_par = par
      n += 1
    end
  end

  def test_toggle_with_a_non_existing_document
    #
    # in order to test a non-existing document, we create a document, we pick
    # up its id and destroy it, so we make sure that it is a non-existing
    # document (any longer)
    #
    assert d = Folder.create(:name => 'Non-existing document', :parent => Document.fishrdb_root(),
                             :creator => @user, :last_modifier => @user,
                             :description_level_id => DescriptionLevel.serie.id,
                             :container_type => ContainerType.first)
    assert_valid d
    assert d_id = d.id
    assert d.destroy
    assert d.frozen?
    #
    # here d does not exist any longer
    #
    post :toggle, { :id => d_id }
    assert_redirected_to :action => :show
  end


  def test_show_with_a_non_existing_document
    #
    # in order to test a non-existing document, we create a document, we pick
    # up its id and destroy it, so we make sure that it is a non-existing
    # document (any longer)
    #
    assert d = Folder.create(:name => 'Non-existing document', :parent => Document.fishrdb_root(),
                             :creator => @user, :last_modifier => @user,
                             :description_level_id => DescriptionLevel.serie.id,
                             :container_type => ContainerType.first)
    assert_valid d
    assert d_id = d.id
    assert d.destroy
    assert d.frozen?
    #
    # here d does not exist any longer
    #
    get :show, { :id => d_id }
    assert_response :success
    assert_template 'doc/show'
    assert_select('td.errorExplanation')
  end

  def test_a_tape_record_without_images
    #
    # let's create a fake tape record which won't have any images
    # it should show just the same without crashing ([ticket:216 #216])
    #
    assert tr = TapeRecord.create_from_form({ :name => 'Tape without images', :parent => Document.fishrdb_root(),
                                  :creator => @user, :last_modifier => @user,
                                  :description_level_position => DescriptionLevel.serie.position,
                                  :container_type => ContainerType.first, :tape_data => { :tag => 'NMGSXXXX-XXX' } }, @s_1)
    assert_valid tr
    #
    # let's try to show it
    #
    get :show, { :id => tr.id }
    assert_response :success
    assert_template 'doc/show'
  end

  def test_insisting_deleting_a_deleted_object
    #
    # let's first create a document, picking up its id and  destroy  it,
    # so we make sure that it is a non-existing document (any longer)
    #
    assert d = Folder.create(:name => 'Non-existing document', :parent => Document.fishrdb_root(),
                             :creator => @user, :last_modifier => @user,
                             :description_level_id => DescriptionLevel.serie.id,
                             :container_type => ContainerType.first)
    assert_valid d
    assert d_id = d.id
    assert parent = d.parent
    assert_valid parent
    #
    # let's delete it via the controller
    #
    get :delete, { :id => d.id }, { :user => @user }
    assert_redirected_to :action => :show, :id => parent.id, :page => 1
    assert_raise(ActiveRecord::RecordNotFound) { d.reload }
    #
    # now let's try to run the delete action again on it
    #
    get :delete, { :id => d.id }, { :user => @user }
    assert_redirected_to :action => :show, :id => parent.id, :page => 1
    #
    # we need to reload the session before redirecting
    #
    @request.session.session_id = @s_1.session_id
    get :show, { :id => parent.id, :page => 1 }
    assert_select('td.errorExplanation', "Cancellazione del Record \"#{d.id}\" fallita (Couldn't find Document with ID=#{d.id}).")
  end

  def test_setting_the_senza_data_checkbox
    #
    # let's first create a document with a defined date
    #
    assert now = DateTime.now.to_date.year
    assert d = Folder.create_from_form({ :name => 'Non-existing document', :parent => Document.fishrdb_root(),
                             :creator => @user, :last_modifier => @user,
                             :description_level_position => DescriptionLevel.serie.position,
                             :data_dal => { :year => now },
                             :container_type => ContainerType.first }, @s_1)
    #
    # now let's set the senza data attribute via the xhr connected to it
    #
    xhr :post, :senza_data_toggled, {'from'=>{'month'=>'', 'day'=>'', 'year'=> now.to_s}, 'to_format'=>'', 'to'=>{'month'=>'', 'day'=>'', 'year'=>''}, 'senza_data'=>'true', 'nota_data'=>'', 'from_format'=>'%Y', 'intv_format'=>'%DD', 'data_topica'=>''}
    assert_template 'share/toggle_enabling_dates'
  end

  def test_description_and_notes_carriage_returns_should_be_transformed
    assert classes = editable_document_classes
    assert text = "First line\nSecond line"
    assert edit_addition = "\n\tedited"
    assert display_addition = "<br />\tedited"

    classes.each do
      |k|
      assert edited_text = displayed_text = text
      assert displayed_text = edited_text.gsub(/\n/, '<br />')
      assert parms = { 'doc' => { 'name' => "#{k.name} Description Carriage Returnt Test", 'parent_id' => Document.fishrdb_root().id,
                             'creator_id' => @user.id, 'last_modifier_id' => @user.id,
                             'description_level_position' => DescriptionLevel.serie.position,
                             'description' => text, 'note' => text,
                             'container_type_id' => ContainerType.first.id }}
      assert d = k.create_from_form(parms['doc'], @s_1)
      assert_valid d
      #
      assert_equal text, d.raw_description, "#{k.name} Description"
      assert_equal text, d.raw_note, "#{k.name} Note"
      #
      0.upto(3) do
        xhr :post, :edit, { :id => d.id, :page => 1.to_s }, { :user => @user }
        assert_response :success
        #
        assert_select('textarea', edited_text)
        #
        assert edited_text = edited_text + edit_addition
        assert displayed_text = displayed_text + display_addition
        parms['doc']['id'] = d.id
        parms['doc'].update('description' => parms['doc']['description'] + edit_addition, 'note' => parms['doc']['note'] + edit_addition)
        parms['submit'] = 'save'
        post :create_or_update_form, parms, { :user => @user }
        assert_redirected_to :action => :show, :id => d.id, :page => 1.to_s
        assert d.reload
        assert_equal edited_text, d.raw_description, "#{k.name} raw Description"
        assert_equal edited_text, d.raw_note, "#{k.name} raw Note"
        assert_equal displayed_text, d.description, "#{k.name} displayed Description"
        assert_equal displayed_text, d.note, "#{k.name} displayed Note"
        subtest_finished
      end
    end
  end

  def test_tape_record_display
    #
    # let's pick up the tape record fixture. It should have three tape box
    # marker collections filled up already
    #
    assert tr = documents(:tape_record_01)
    assert_valid tr
    #
    # count the number of marks we've got
    #
    num_marks = 0
    tr.tape_box_marker_collections(true).each { |tbmc| num_marks += tbmc.tape_box_marks(true).size }
    #
    # let's try to show it
    #
    get :show, { :id => tr.id }
    assert_response :success
    assert_template 'doc/show'
    tbmc = assert_select('table.tape_box_marker_collection')
    assert_equal tr.tape_box_marker_collections(true).size, tbmc.size
    tbmcl = assert_select('td.tape_box_marker_collection_location')
    assert_equal tr.tape_box_marker_collections(true).size, tbmcl.size
    tbms = assert_select('tr.tape_box_mark')
    assert_equal num_marks, tbms.size
    tbmc = assert_select('td.tape_box_mark_content')
    assert_equal num_marks, tbmc.size
    tbmc = assert_select('td.tape_box_mark_calligraphy')
    assert_equal num_marks, tbmc.size

  end

  #
  # security tests: editing pages should not be available to anonymous users
  #
  def test_security_on_editing_pages
    #
    # define user categories
    #
    assert lame_users = [ @anon_user, @public_user ]
    assert admin_users = [ @admin_user, @user ]
    #
    # try with an anonymous user first
    #
    assert doc = documents(:Parte__0904)
    lame_users.each do
      |lu|
      assert sess = @s_1.dup
      @request.session.session_id = sess
      @request.session['user'] = lu
      get :show, { :id => doc.id }, { 'user' => lu, 'session_id' => @s_1.session_id }
      assert_redirected_to :controller => :account, :action => :login
    end
    #
    # now try with admin and/or staff users (should go through)
    #
    admin_users.each do
      |au|
      assert sess = @s_1.dup
      assert @request.session.session_id = sess
      assert @request.session['user'] = au
      get :show, { :id => doc.id }, { 'user' => au, 'session_id' => sess.session_id }
      assert_response :success
      assert_template 'doc/show'
    end
  end

  #
  # Bug #351: series documents loose their corda number when they change their
  # visibility. Here is how to reproduce the bug:
  #
  # 1) create a Series Document with DescriptionLevel series and corda number
  # 2) save it non visible
  # 3) update it as visible
  # 4) poof! the corda number has become zero
  #
  def test_corda_number_bug_351
    assert docname = 'Fake to uncover bug 351'
    assert corda_arabic = 3
    assert corda_roman = 'III'
    #
    # go to the top
    #
    assert sess = @s_1.dup
    get :show, { :id => @fis_parent.id.to_s }, { 'user' => @admin_user, 'session_id' => sess.session_id }
    assert_response :success
    assert_template 'doc/show'
    #
    # open a new form as a child
    #
    xhr :post, :edit, { :position => '1', :id => @fis_parent.id.to_s }, { 'user' => @admin_user, 'session_id' => sess.session_id }
    assert_response :success
    assert_template 'folder/_edit'
    #
    # now save a new series document at series description level with a corda
    # number and visibility set to false
    #
    post :create_or_update_form, { 'update' => ' salva ',
                                  'parent_id' => @fis_parent.id.to_s,
                                  'doc' => { 'id' => '', 'position' => '',
                                  'parent_id' => @fis_parent.id.to_s,
                                  'creator_id' => @admin_user.id,
                                  'last_modifier_id' => @admin_user.id,
                                  'container_type_id' => @ct.id.to_s,
                                  'corda' => corda_arabic.to_s,
                                  'description_level_position' => DescriptionLevel.serie.position,
                                  'type' => 'Series',
                                  'name' => docname,
                                  'public_visibility' => 'on' } },
                                 { 'user' => @admin_user, 'session_id' => sess.session_id }
    assert created_doc = Document.find_by_name(docname)
    assert created_doc.valid?
    assert_equal corda_roman, created_doc.corda
    assert_redirected_to "doc/show/#{created_doc.id}?page=1"
    #
    # now edit the document and set 'public visibility' to 'off'
    #
    post :edit, { 'position' => '1', 'id' => created_doc.id.to_s, 'page' => '1',
                  'classname' => 'Series' }
    assert_response :success
    assert_template 'series/_edit'
    #
    # and save it...
    #
    post :create_or_update_form, { 'update' => ' salva ',
                                  'parent_id' => created_doc.parent.id.to_s,
                                  'doc' => { 'id' => created_doc.id.to_s,
                                  'position' => '',
                                  'parent_id' => created_doc.parent.id.to_s,
                                  'creator_id' => created_doc.creator_id,
                                  'last_modifier_id' => @admin_user.id,
                                  'container_type_id' => created_doc.container_type.id.to_s,
                                  'corda' => created_doc.corda_for_edit_forms,
                                  'description_level_position' => created_doc.description_level_position.to_s,
                                  'type' => created_doc.type,
                                  'name' => created_doc.name,
                                  'public_visibility' => 'off' } },
                                 { 'user' => @admin_user, 'session_id' => sess.session_id }
    assert created_doc.valid?
    assert created_doc.reload
    assert_equal corda_roman, created_doc.corda
    assert_redirected_to "doc/show/#{created_doc.id}?page=1"
  end

end
