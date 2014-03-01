#
# $Id: document_test.rb 632 2013-07-12 14:45:53Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../extensions/subtest'
require File.dirname(__FILE__) + '/../utilities/classes'

class DocumentTest < ActiveSupport::TestCase

  include Test::Extensions
  include Test::Utilities
  #
  # fixture load order is important!
  #
  fixtures	:container_types, :sessions, :users, :documents

  def setup
    @classes = document_classes
    assert @user  = User.authenticate('staffbob', 'testtest')
    @torino_docs = Document.find(:all, :conditions => ['description like ?', '%Torino%'])
    assert !@torino_docs.blank?
    @gs_docs = Document.find(:all, :conditions => ['description like ?', '%Giacinto Scelsi%'])
    assert !@gs_docs.blank?
    @khoom_docs = Document.find(:all, :conditions => ['name like ?', '%Khoom%'])
    assert !@khoom_docs.blank?
    @mf_docs = Document.find(:all, :conditions => ['description like ?', '%Ministero delle Finanze%'])
    assert !@mf_docs.blank?
    @ar_data = { :name => 'Scelsi', :first_name => 'Giacinto' }
    @arv_data = { :name => "D'Ajala Vilva" }
    assert @s_1 = sessions(:one)
    assert @sbt = SidebarTree.retrieve(@s_1)
    assert @ct = ContainerType.find_by_container_type('Busta')
    assert @dl = DescriptionLevel.fascicolo
    assert @default_args = { :creator => @user, :last_modifier => @user,
             :description_level_position => DescriptionLevel.unita_documentaria.position,
             :container_type => @ct }
  end

  #
  # counter cache tests
  #
  #TODO: to be written
  #
  # authority record test connection
  #
  def authority_record_evaluate(ar_type, data_set)
    loop_ctrl = n = 0
    create_meth = "create_#{ar_type}_record"
    ref_meth = ar_type.pluralize
    loop_ctrl = n
    ars = data_set.map do
      |ds|
      n += 1
      assert ar = ds.send(create_meth, @user, @ar_data)
      assert arv = ar.create_variant_form(@user, @arv_data)
      ar
    end
    assert n > loop_ctrl
    assert_equal ars.size, data_set.size
    data_set.each { |d| d.reload }
    ars.each { |ar| ar.reload }
    loop_ctrl = n
    data_set.each do
      |ds|
      assert ds.send(ref_meth).size > 0
      n += 1
    end
    assert n > loop_ctrl
    loop_ctrl = n
    ars.each do
      |ar|
      assert ar.documents.size > 0
      n += 1
    end
    assert n > loop_ctrl
    return data_set
  end

  def arclasses
    return [
      { :artype => 'person_name', :objs => @gs_docs },
      { :artype => 'site_name', :objs => @torino_docs },
      { :artype => 'collective_name', :objs => @mf_docs },
      { :artype => 'score_title', :objs => @khoom_docs },
    ]
  end

  def test_authority_records
   arclasses.each do
      |arc|
      authority_record_evaluate(arc[:artype], arc[:objs])
    end
    return arclasses
  end

  def test_authority_record_variant_chaining
    loop_ctrl = n = 0
    arcs = test_authority_records
    arcs.each do
      |arc|
      create_meth = "create_#{arc[:artype]}_record"
      loop_ctrl = n
      arc[:objs].each do
        |d|
        ar = d.send(create_meth, @user, @arv_data)
        ara = arc[:artype].camelize.constantize.find(:first, :conditions => ["name = :name and first_name = :first_name", @ar_data])
        assert_equal ar.id, ara.id
        n += 1
      end
      assert n > loop_ctrl
      n += 1
    end
    assert n > loop_ctrl
  end

  #
  # parenting tests
  #

  def create_family_almost(tag='')
    assert parent = Folder.create_from_form({ :name => 'I am the parent' + tag, :creator => @user, :last_modifier => @user, 
                             :description_level_position => @gs_docs[0].description_level.position,
                             :container_type => @ct }, @s_1)
    assert_equal parent.children.size, 0 
    assert child = Series.create_from_form({ :name => 'I am the child' + tag,  :creator => @user, :last_modifier => @user, 
                             :description_level_position => @gs_docs[0].description_level.position+1,
                             :container_type => @ct }, @s_1)
    assert_equal parent.children.size, 0 
    [parent, child].each do
      |d|
      [:creator, :last_modifier].each do
        |m|
        assert_equal d.send(m).id, @user.id, "create_family_almost: d(#{d.id}).send(#{m.to_s}).id failed! inspecting: #{d.inspect}"
      end
    end
    return [parent, child]
  end

  def test_parenting
    (parent, child) = create_family_almost
    assert_equal child.creator.id, @user.id
    assert_equal child.last_modifier.id, @user.id
    child.parent_me(parent)
    parent.reload
    parent.children.reload
    assert_equal parent.children.size, 1, "parent.children.size should be 1 and it is #{parent.children.size} instead"
    assert_equal child.parent.name, 'I am the parent'
    assert_equal parent.children[0].name, 'I am the child'
    assert parent.children[0].destroy
    parent.children.reload
    assert_equal parent.children.size, 0
  end

  def test_reparenting
    (parent1, child1) = create_family_almost(' number 1')
    (parent2, child2) = create_family_almost(' number 2')

    assert_not_equal parent1.id, parent2.id

    child1.parent_me(parent1)
    child2.parent_me(parent1, 2)

    assert_equal parent1.children[0].name, child1.name
    assert_equal parent1.children[1].name, child2.name
    
    assert_equal parent1.children.size, 2
    assert_equal parent2.children.size, 0

    child2.reparent_me(parent2)
    parent1.children.reload
    parent2.children.reload

    assert_equal parent2.children.size, 1, "parent2.children.size wrong after reparenting (should be 1 and instead it is #{parent2.children.size})"
    assert_equal parent1.children.size, 1, "parent1.children.size wrong after reparenting (should be 1 and instead it is #{parent1.children.size})"
  end

  def test_hash
    pars = { 'gino' => 42, 'lino' => 43 }
    res1 = pars.read_and_delete('gino')
    res2 = pars.read_and_delete('lino')
    assert pars.empty?
    assert res1,42
    assert res2,43
  end

  def create_a_parent_with_some_childs(num_childs, user)
    assert root = Document.fishrdb_root
    assert parent = Folder.create_from_form({ :name => 'I am the parent', :creator => @user, :last_modifier => @user, 
                             :parent => documents(:fondo_FIS),
                             :description_level_position => @gs_docs[0].description_level.position,
                             :container_type => @ct }, @s_1)
    assert parent.parent.sidebar_tree_item(@s_1).rebuild_children_tree
    assert parent.reload
    assert parent.sidebar_tree_item(@s_1)
    child_names = "#{num_childs} children documents"
    params = {
      "parent"	=>	parent,
      "num_items"	=>	num_childs,
      "name"	=>	child_names,
      "container_number"	=>	"",
      "public_access"	=>	"yes",
      "corda"	=>	"",
      "consistenza"	=>	"",
      "enti_series"	=>	"",
      "luoghi_series"	=>	"",
      "titoli_series"	=>	"",
      "creator"	=>	@user,
      "last_modifier"	=>	@user,
      "description_level_position"	=>	parent.description_level.position+1,
      "data_dal"	=>	{},
      "data_al"	=>	{},
      "data_dal_input_parameters" => '---',
      "data_al_input_parameters" => '---',
      "data_dal_format" => "",
      "data_al_format" => "",
      "nota_data"	=>	"",
      "senza_data"	=>	"N",
      "container_type_id"	=>	@ct.id,
      "description"	=>	"",
      "data_topica"	=>	"",
      "nomi_series"	=>	"",
      "position"	=>	"",
    }
    assert Folder.create_from_form(params, @s_1)
    parent.children.reload
    assert_equal parent.children.count, num_childs 
    assert_equal parent.children.size, num_childs 
    parent.children.each do
      |c|
      assert_equal c.name, child_names
    end
    parent.children(true).each_with_index do
      |c, i|
      c.update_attributes!(:name => c.name + ' ' + (i+1).to_s)
    end

    return parent
  end

  def test_create_from_form
    assert create_a_parent_with_some_childs(100, @user)
  end

  def test_update_from_form
    assert eu = User.authenticate('editbob', 'testtest')
    assert p = create_a_parent_with_some_childs(10, @user)
    params = { 'name' => 'I am an updated parent',  'last_modifier_id' => eu.id }
    p.reload
    assert p.update_from_form(params)
    updated_child_names = []
    n = 0
    p.reload
    p.children.reload
    name_prefix = 'I am the child '
    p.children.each do
      |c|
      c.reload
      updated_child_names[n] = params['name'] = name_prefix + "n.#{n}"
      assert c.update_from_form(params)
      n += 1
    end
    p.reload
    p.children.reload
    n = 0
    p.children.each do
      |c|
      assert_equal updated_child_names[n], c.name
      n += 1
    end
    #
    # test that it will fail without a last_modifier
    #
    params = { 'name' => 'I am an attempt to update without an editor user' }
    params.delete('last_modifier_id')
    begin
      assert p.update_from_form(params)
      assert_not_equal p.name, params['name']
    rescue MissingEditorException # this is raised by the model
      assert_not_equal p.name, params['name']
    end
    
  end

  def test_delete_from_form
    num_childs = 10
    assert p = create_a_parent_with_some_childs(num_childs, @user)
    n = 0
    p.children.each do
      |c|
      c.delete_from_form
      assert c.frozen?, "Child #{c.class.name}(#{c.id}) not frozen after delete_from_form"
      n += 1
      p.children.reload
      assert_equal p.children.size, num_childs - n
    end
    p.delete_from_form
    assert p.frozen?
    assert p = create_a_parent_with_some_childs(num_childs, @user)
    p.reload
    p.delete_from_form
    assert p.frozen?
    assert_equal p.children.size, 0
  end

  def test_description_level_association
    num_childs = 10
    assert p = create_a_parent_with_some_childs(num_childs, @user)
    p.children.reload
    assert_equal p.children.size,num_childs, "Expecting a children.size of #{num_childs} and getting #{p.children.size} instead"
    assert p.children[num_childs-1].valid?
    assert_equal p.description_level.id, @gs_docs[0].description_level.id
    assert_equal p.children[num_childs-1].description_level.id, @gs_docs[0].description_level.id+1,
      "The dl of the new children is #{p.children[num_childs-1].description_level.id} while it should be #{@gs_docs[0].description_level.id+1}"
  end

  def test_repositioning
    assert eu = User.authenticate('editbob', 'testtest')
    num_childs = 4
    assert p = create_a_parent_with_some_childs(num_childs, @user)
    p.reload
    p.children.reload
    assert_equal p.children.size,num_childs, "Expecting a children.size of #{num_childs} and getting #{p.children.size} instead"
    names = ['n.0', 'n.1', 'n.2', 'n.3']
    params = { 'last_modifier_id' => eu.id }
    p.children.each_with_index do
      |c, i|
      c.reload
      params['name'] = names[i]
      c.update_from_form(params)
    end
    p.children.reload
    #
    # put last first, empty argument
    #
    assert_equal names, p.children.map { |c| c.name }
    nm = names.pop
    names.unshift(nm)
    p.children[num_childs-1].insert_me('')
    p.children.reload
    assert_equal names, p.children.map { |c| c.name }
    #
    # put last first, full argument
    #
    nm = names.pop
    names.unshift(nm)
    p.children[num_childs-1].insert_me(1)
    p.children.reload
    assert_equal names, p.children.map { |c| c.name }
    #
    # put last first, no argument
    #
    nm = names.pop
    names.unshift(nm)
    p.children[num_childs-1].insert_me
    p.children.reload
    assert_equal names, p.children.map { |c| c.name }
    #
    # put second last
    #
    nm = names[1]
    names[1] = nil
    names.compact!
    names << nm
    p.children[1].insert_me(num_childs)
    p.children.reload
    assert_equal names, p.children.map { |c| c.name }
  end

  def test_reparent_me_on_the_same_parent
    num_childs = 4
    assert p = create_a_parent_with_some_childs(num_childs, @user)
    p.children(true).each_with_index { |c, i| c.update_attributes!(:corda => i+1) }
    assert_equal [1, 2, 3, 4], p.children(true).map { |c| c.corda }
    #
    # reparent from above (take child 1 and place it over child 4)
    # final result should be [2, 3, 1, 4]
    #
    assert c1 = p.children(true)[0]
    assert c4 = p.children(true)[3]
    c1.reparent_me(p, c4.position)
    assert_equal [2, 3, 1, 4], p.children(true).map { |c| c.corda }
    #
    # now reorder children for a new test
    #
    p.reorder_children(:location)
    assert_equal [1, 2, 3, 4], p.children(true).map { |c| c.corda }
    #
    # reparent from below (take child 4 and place it over child 1)
    # final result should be [4, 1, 2, 3]
    assert c1 = p.children(true)[0]
    assert c4 = p.children(true)[3]
    c4.reparent_me(p, c1.position)
    assert_equal [4, 1, 2, 3], p.children(true).map { |c| c.corda }
  end

  def test_authority_record_display
    displays = 
    [
      { :create_action => 'pn/form', :edit_action => 'pn/edit', :method => :person_names, :tag => 'Nomi' },
      { :create_action => 'form', :edit_action => 'edit', :method => :collective_names, :tag => 'Enti' },
      { :create_action => 'form', :edit_action => 'edit', :method => :site_names, :tag => 'Luoghi' },
      { :create_action => 'form', :edit_action => 'edit', :method => :score_titles, :tag => 'Titoli' },
    ]
    arclasses.each do
      |arc|
      arc[:objs].each do
        |d|
        coll = d.authority_record_collection
        assert_equal  coll.size, 4
        coll.each_index do
          |n|
          assert_equal coll[n].number, n+1
          assert_equal coll[n].doc.id, d.id
          assert coll[n].all_records.empty?, "authority record collection n.#{coll[n].number} of\ndocument(#{d.id})(\"#{d.name[0..10]}...\") is not empty!\n(it contains #{coll[n].all_records.size} records: #{coll[n].all_records.map { |ar| ar.name }.join(", ")})"
          assert_equal coll[n].class.tag, displays[n][:tag]
          assert_equal coll[n].class.calc_valign, (coll[n].class.tag.size > 11 ? 'bottom' : 'top')
          assert_equal coll[n].class.arclass.name, displays[n][:method].to_s.singularize.camelize
          coll[n].class.arclass do
            |arc|
            assert_equal arc.create_action, displays[n][:create_action]
            assert_equal arc.edit_action, displays[n][:edit_action]
            assert_equal arc.variant_form_method, displays[n][:method]
          end
        end
      end
    end
    error = 0
    begin
      DocumentParts::AuthorityRecordCollection::Base.tag # should raise an exception
    rescue DocumentParts::AuthorityRecordCollection::Base::PureVirtualCalled
      error += 1
    end
    assert_equal 1, error, "DocumentParts::AuthorityRecordCollection::Base::PureVirtualCalled exception not raised when it should have been!"
  end

  def test_delete_document_with_ar
    @classes.each do
      |c|
      args = { :name => "created by the test delete_document_with_ar (class #{c})",
               :creator => @user, :last_modifier => @user,
               :container_type => @ct,
               :description_level_position => @gs_docs[0].description_level.position }
#     args.update(:tape_data => { :tag => 'NMGSTEST' }) if c == TapeRecord
      assert doc = c.create_from_form(args, @s_1)
      arclasses = [PersonName, SiteName, CollectiveName, ScoreTitle]
      ars = []
      arclasses.each do
        |arc|
        meth = "create_#{arc.name.underscore}_record"
        assert ars << doc.send(meth, @user, :name => "test_delete_document #{arc.name}")
      end
      doc.reload
      assert_equal doc.authority_record_collection.size, first_size = ars.size
      doc.authority_record_collection.each do
        |arc|
        doc.reload
        assert_equal doc.send(arc.class.method).size, 1, "Document('#{name[0..10]}...').#{arc.class.method}.size returns #{doc.send(arc.class.method).size} rather then 1"
        doc.send(arc.class.method).each do
          |ar|
          assert ar.valid?
        end
      end
      assert doc.destroy
      assert doc.frozen?
      assert_equal ars.size, first_size
      ars.each do
        |ar|
        ar.reload
        assert ar.valid?
        assert_equal ar.documents.size, 0
        assert ar.destroy
      end
      subtest_finished
    end
  end

  def test_dates
    @classes.each do
      |c|
      assert d = ExtDate::Interval.new({ :day => '8', :month => '8', :year => '1988' },
                                    { :day => '19', :month => '10', :year => '2008' },
                                    'XXX', 'XXX',
                                    'dal %DD al %DA', '%d/%m/%Y', '%d/%m/%Y')
      args = { :name => "created by the test dates (class #{c})",
                     :creator => @user, :last_modifier => @user,
                     :container_type => @ct,
                     :description_level_position => @gs_docs[0].description_level.position,
                     :date => d }
      assert doc = c.create_from_form(args, @s_1)
      doc.reload
      assert_equal 'dal 08/08/1988 al 19/10/2008', doc.date.to_display
      assert d = ExtDate::Interval.new({ :year => '2008' }, nil, '--X', '---', '%DD', '%Y')
      assert doc.update_attributes!(:date => d)
      doc.reload
      assert_equal '2008', doc.date.to_display
      assert d = ExtDate::Interval.new({ :year => '2008' }, nil, '--X', '---', 'dal %DD al %DA', '%d/%m/%Y', '%d/%m/%Y')
      assert doc.update_attributes!({ :date => d })
      doc.reload
      assert_equal 'dal 01/01/2008 al ', doc.date.to_display
      assert d = ExtDate::Interval.new({ :year => '2008' }, { :year => '2008' }, '--X', '--X', 'dal %DD al %DA', '%d/%m/%Y', '%d/%m/%Y')
      assert doc.update_attributes!({ :date => d })
      doc.reload
      assert_equal 'dal 01/01/2008 al 31/12/2008', doc.date.to_display
      assert doc.destroy
      subtest_finished
    end
  end

  def test_empty_dates
    @classes.each do
      |c|
      args = { :name => "created by the test empty dates (class #{c})",
                     :creator => @user, :last_modifier => @user,
                     :container_type => @ct,
                     :description_level_position => @gs_docs[0].description_level.position }
      assert doc = c.create_from_form(args, @s_1)
      doc.reload
      assert_equal '', doc.date.to_display
      assert_equal '', doc.date.from_format
      assert_equal '', doc.date.to_format
      assert_equal '', doc.date.intv_format
      subtest_finished
    end
  end

  def test_empty_doc
    @classes.each do
      |c|
      assert doc = c.new
      assert_nil doc.id
      assert !doc.valid?
      assert_nil doc.date.intv_format
      subtest_finished
    end
  end

  def test_score_years
    #
    # init with proper dates
    #
    assert yc = ExtDate::Year.new('1988')
    assert ye = ExtDate::Year.new('2008')
    assert score = Score.create_from_form({ :name => "created by the test dates (class Score)",
                     :creator => @user, :last_modifier => @user,
                     :container_type => @ct,
                     :description_level_position => @gs_docs[0].description_level.position,
                     :anno_composizione => yc, :anno_edizione => ye }, @s_1)
    assert score.valid?
    score.reload
    assert_equal ExtDate::Year, score.anno_composizione.class
    assert_equal ExtDate::Year, score.anno_edizione.class
    assert_equal '1988', score.anno_composizione.to_display
    assert_equal '2008', score.anno_edizione.to_display
    assert ns = Score.find(score.read_attribute('id'))
    assert_equal '1988', ns.anno_composizione.to_display
    assert_equal '2008', ns.anno_edizione.to_display
    assert score.destroy
    #
    # test with something that arrives from a form
    #
    assert test_parent = Document.find_by_name('Partiture Giacinto Scelsi')
    assert test_parent.valid?
    yc = '1987'
    ye = '1988'
    test_params = {"doc"=>{"name"=>"sorella di anche tante partiture (prova date)",
              "consistenza"=>"", "edizione_score"=>"", "public_access"=>"yes",
              "container_number"=>"", "position"=>"2",
              "corda_alpha"=>"",
                   "data_al"=>{"month"=>"", "day"=>"", "year"=>""},
                   "data_al_format"=>"",
                   "autore_score"=>"Eanche, Johnny",
                   "organico_score"=>"",
                   "data_dal"=>{"month"=>"", "day"=>"", "year"=>""},
                   "trascrittore_score"=>"", "autore_versi_score"=>"",
                   "description_level_position"=>"6",
                   "corda"=>"", "id"=>"", "creator_id"=> @user.id, "data_dal_input_parameters"=>"---",
                   "full_date_format"=>"", "senza_data"=>"N", "luogo_edizione_score"=>"",
                   "container_type_id"=> @ct.id, "type"=>"Score", "last_modifier_id"=> @user.id,
                   "nota_data"=>"", "forma_documento_score"=>"",
                   "anno_composizione_score"=>{"year"=> yc},
                   "note"=>"", "parent_id"=> test_parent.id, "name_prefix"=>"La",
                   "data_dal_format"=>"", "misure_score"=>"", "description"=>"",
                   "data_topica"=>"", "tipologia_documento_score"=>"", "data_al_input_parameters"=>"---",
                   "anno_edizione_score"=>{"year"=> ye }},
                   "action"=>"create_or_update_form", "page"=>"1",
                   "controller"=>"doc", "update"=>" salva "}
    assert klass = test_params['doc'].read_and_delete('type').constantize
    assert score = klass.create_from_form(test_params['doc'], @s_1)
    assert score.valid?
    score.reload
    assert_equal yc, score.anno_composizione.to_display
    assert_equal ye, score.anno_edizione.to_display
    assert ns = Score.find(score.read_attribute('id'))
    assert_equal yc, ns.anno_composizione.to_display
    assert_equal ye, ns.anno_edizione.to_display
    assert score.destroy
    #
    # init with strings
    #
    assert yc = '1988'
    assert ye = '2008'
    assert score = Score.create_from_form({ :name => "created by the test dates (class Score)",
                     :creator => @user, :last_modifier => @user,
                     :container_type => @ct,
                     :description_level_position => @gs_docs[0].description_level.position,
                     :anno_composizione_score => yc, :anno_edizione_score => ye }, @s_1)
    assert score.valid?
    score.reload
    assert_equal yc, score.anno_composizione.to_display
    assert_equal ye, score.anno_edizione.to_display
    assert ns = Score.find(score.read_attribute('id'))
    assert_equal yc, ns.anno_composizione.to_display
    assert_equal ye, ns.anno_edizione.to_display
    assert score.destroy
  end


  def test_dates_as_updated_from_form
    assert d = ExtDate::Interval.new({ :day => '8', :month => '8', :year => '1988' },
                                     { :day => '19', :month => '10', :year => '2008' },
                                     'XXX', 'XXX',
                                     'dal %DD al %DA', '%d/%m/%Y', '%d/%m/%Y')
    @classes.each do
      |c|
      args = { :name => "created by the test dates (class #{c})",
                     :creator => @user, :last_modifier => @user,
                     :container_type => @ct,
                     :description_level_position => @gs_docs[0].description_level.position,
                     :date => d }
      assert doc = c.create_from_form(args, @s_1)
      assert_equal 'dal 08/08/1988 al 19/10/2008', doc.date.to_display
      assert attrs_to_be_updated = doc.attributes
      assert attrs_to_be_updated['data_dal'] =  {'year' => '1989', 'month' => '9', 'day' => '9'}
      assert adjusted_attrs = doc.class.adjust_dates(attrs_to_be_updated)
			doc.reload
      assert doc.update_attributes!(adjusted_attrs), "update_attributes! failed for class #{doc.class.name}"
      assert_equal 'dal 09/09/1989 al 19/10/2008', doc.date.to_display
			doc.destroy
			assert doc.frozen?
      subtest_finished
    end
    #
    # now scores only
    #
    assert s = Score.create_from_form({ :name => "created by the test dates (class Score)",
                   :creator => @user, :last_modifier => @user,
                   :container_type => @ct,
                   :description_level_position => @gs_docs[0].description_level.position,
                   :date => d }, @s_1)
    s.reload
    assert_equal 'dal 08/08/1988 al 19/10/2008', s.date.to_display
    assert s.update_attributes!(s.class.adjust_dates(:anno_composizione_score => 1958,
                                :anno_edizione_score => 1985))
    s.reload
    assert_equal '1958', s.anno_composizione.to_display
    assert_equal '1985', s.anno_edizione.to_display
		s.destroy
		assert s.frozen?
    subtest_finished
  end

  def test_descendants
    assert root = Document.fishrdb_root
    assert root.valid?
    assert_not_nil root.num_descendants
    assert_not_nil root.num_descendants
    assert root.num_descendants > 1
  end

  def test_pagination_methods
    assert d = Document.first(:conditions => ['name like ?', 'Okanagon%'])
    assert d.valid?
    assert d.num_pages(5) > 0
    assert d.my_page(5) > 1
  end

  def test_corda
    corda = 23
    assert s = Folder.create_from_form({ :name => "created by the test dates (class Folder)",
                     :creator => @user, :last_modifier => @user,
                     :container_type => @ct,
                     :description_level_position => DescriptionLevel.serie.position,
                     :corda => corda }, @s_1)
    r = corda.to_roman
    assert_equal r, s.corda
  end

  def test_signature
		assert p = documents(:fondo_privato)
    assert s = Folder.create_from_form({ :name => 'series folder', :creator => @user,
														 :parent => p,
                             :last_modifier => @user,
                             :container_type => @ct,
                             :corda => 23,
                             :description_level_position => DescriptionLevel.serie.position }, @s_1)
    assert c1 = Series.create_from_form({ :name => 'sub-series document', :creator => @user,
                             :last_modifier => @user, :parent => s,
                             :container_type => @ct,
                             :corda => 24,
                             :description_level_position => DescriptionLevel.sottoserie.position }, @s_1)
    assert c2 = Series.create_from_form({ :name => 'unit document', :creator => @user,
                             :last_modifier => @user, :parent => c1,
                             :corda => 25, :corda_alpha => 'bis',
                             :container_type => @ct,
                             :description_level_position => DescriptionLevel.unita_documentaria.position }, @s_1)
    assert sig_should_be = 'GS.1.XXIII.24.25bis'
    assert_equal sig_should_be, c2.signature
    #
    # test empty signatures
    #
    assert sig_should_be = 'GS.1'
    s.reload
    s.update_attributes(:corda => nil)
    c1.reload
    c1.update_attributes(:corda => nil)
    c2.reload
    c2.update_attributes(:corda => nil, :corda_alpha => nil)
    assert_equal sig_should_be, c2.signature
  end

  def test_full_name
    #
    # creation/display
    #
    pfx = 'Cinque'
    name = "created by the test full_name (class Folder)"
    dl = DescriptionLevel.fascicolo
    ct = @ct
    assert f = Folder.create_from_form({ :name => name, :name_prefix => pfx,
                     :creator => @user, :last_modifier => @user,
                     :container_type => ct, :description_level_position => dl.position }, @s_1)
    assert f.valid?
    assert_equal pfx + ' ' + name, f.full_name
    f.destroy
    assert f = Folder.create_from_form({ :name => name, # no prefix
                     :creator => @user, :last_modifier => @user,
                     :container_type => ct, :description_level_position => dl.position }, @s_1)
    assert f.valid?
    assert_equal f.name, f.full_name
    f.destroy
    #
    # ordering
    #
    full_names = [[ 'Sei', 'AAA - test order' ], [ 'Cinque', 'BBB - test order' ]]
    full_names.each_with_index do
      |fn, i|
      assert x = Series.create_from_form({ :name_prefix => fn[0], :name => fn[1],
                               :creator => @user, :last_modifier => @user,
                               :container_type => ct, :description_level_position => dl.position }, @s_1)
      assert x.valid?
    end
    assert fdocs = Series.find(:all, :conditions => ["name like ?", '%test order'],
                               :order => Document.by_alpha)
    sorted_docs = full_names.sort { |a,b| a[1] <=> b[1] }.map { |fn| fn[0] + ' ' + fn[1] }
    assert_equal sorted_docs, fdocs.map { |f| f.full_name }
  end

  def test_forma_documento_score
    #
    # creation/display
    #
    pfx = 'Cinque'
    name = "created by the test full_name (class Folder)"
    dl = DescriptionLevel.fascicolo
    ct = @ct
    fds = 'partitura runica'
    assert f = Folder.create_from_form({ :name => name, :name_prefix => pfx,
                     :creator => @user, :last_modifier => @user,
                     :container_type => ct, :description_level_position => dl.position,
                     :forma_documento_score => 'partitura runica' }, @s_1)
    assert f.valid?
    assert fds, f.forma_documento_score
    f.destroy
    assert f = Folder.create_from_form({ :name => name, # no forma documento score
                     :creator => @user, :last_modifier => @user,
                     :container_type => ct, :description_level_position => dl.position }, @s_1)
    assert f.valid?
    assert_nil f.forma_documento_score
    f.destroy
  end

  def test_sidebar_name
    #
    # take a series document and test with that (and its children)
    #
    assert d = Series.find(:first)
    assert c = Series.create_from_form({ :name => d.raw_name, :parent => d,
                             :description_level_position => d.description_level.position + 1, 
                             :container_type => d.container_type, :creator => @user,
                             :last_modifier => @user }, @s_1)
    assert c.valid?
    assert_equal c.name, c.sidebar_name
    c.destroy
    #
    # now try with a score
    #
    fd = 'partitura'
    td = 'copia eliografica'
    assert s = Score.find(:first)
    assert c = Score.create_from_form({ :name => s.raw_name, :parent => s,
                            :autore_score => s.autore_score,
                            :organico_score => 'fucile a pompa',
                            :forma_documento_score => fd,
                            :tipologia_documento_score => td,
                            :description_level_position => (d.description_level + 1).position, 
                            :container_type => d.container_type, :creator => @user,
                            :last_modifier => @user }, @s_1)
    assert c.valid?
    assert_equal fd + ', ' + td, c.sidebar_name
    assert c3 = Score.create_from_form({ :name => c.raw_name, :parent => c,
                            :autore_score => s.autore_score,
                            :organico_score => 'supplì al telefono',
                            :forma_documento_score => 'parte staccata',
                            :tipologia_documento_score => td,
                            :description_level_position => DescriptionLevel.unita_documentaria.position,
                            :container_type => d.container_type, :creator => @user,
                            :last_modifier => @user }, @s_1)
    assert c3.valid?
    assert c3.is_a_part?
    assert_equal c3.organico_score, c3.sidebar_name
  end

  def test_consultability
    @classes.each do
      |k|
      #
      # test consultability first
      #
      args = { :name => "Consultable #{k}", :creator => @user,
                          :last_modifier => @user,
                          :description_level_position => DescriptionLevel.unita_documentaria.position,
                          :container_type => @ct }
      assert d = k.create_from_form(args, @s_1)
      assert d.valid?, "Class #{k.name}: #{d.errors.full_messages.join(', ')}"
      assert d.public_access?
      assert d.public_access_display =~ /S\&Igrave;/i
      #
      # test non-consultability after
      #
      d.user_update_attribute(@user, :public_access, false)
      d.reload
      assert d.valid?
      assert !d.public_access?
      assert d.public_access_display =~ /NO/i
      subtest_finished
    end
  end

  def test_visibility
    @classes.each do
      |k|
      #
      # test visibility first (should be visible by default)
      #
      args = { :name => "Visible #{k.name}", :creator => @user,
                          :last_modifier => @user,
                          :description_level_position => DescriptionLevel.unita_documentaria.position,
                          :container_type => @ct }
      assert d = k.create_from_form(args, @s_1), "Class #{k.name}"
      assert d.valid?, "Class #{k.name}"
      assert d.public_visibility?, "Class #{k.name}"
      assert d.public_visibility_display =~ /S\&Igrave;/i, "Class #{k.name}: wanted 'S&Igrave;' and got #{d.public_visibility} instead"
      #
      # test non-visibility after
      #
      d.user_update_attribute(@user, :public_visibility, false)
      d.reload
      assert d.valid?, "Class #{k.name}"
      assert !d.public_visibility?, "Class #{k.name}"
      assert d.public_visibility_display =~ /NO/i, "Class #{k.name}"
      #
      # test with children
      #
      args = { :parent => d, :name => "Visible children of #{k.name}",
               :creator => @user, :last_modifier => @user,
               :public_visibility => false,
               :description_level_position => DescriptionLevel.unita_documentaria.position,
               :container_type => @ct }
      assert c = k.create_from_form(args, @s_1)
      c.reload
      assert c.valid?, "Class #{k.name}"
      assert !c.public_visibility?, "Class #{k.name}"
      assert c.public_visibility_display =~ /NO/i, "Class #{k.name}"
      assert_equal 0, d.public_children.size, "Class #{k.name}"
      #
      # now I change the parent
      #
      d.reload
      d.user_update_attribute(@user, :public_visibility, true)
      d.reload
      assert d.valid?, "Class #{k.name}"
      assert d.public_visibility?, "Class #{k.name}"
      c.reload
      assert c.public_visibility?, "Class #{k.name}"
      assert_equal 1, d.public_children.size, "Class #{k.name}"
      subtest_finished
    end
  end

  def test_breadcrumbing
      ndocs = 30
      ipp = 10
      assert troot = Folder.create_from_form({ :name => "Breadcrumb root", :creator => @user,
                          :last_modifier => @user,
                          :description_level_position => DescriptionLevel.fascicolo.position,
                          :container_type => @ct }, @s_1)
      0.upto(ndocs-1) do
        |i|
        assert c = Folder.create_from_form({ :parent => troot, :name => "Breadcrumb child n.#{i}",
                                 :creator => @user, :last_modifier => @user,
                                 :description_level_position => DescriptionLevel.fascicolo.position,
                                :container_type => @ct }, @s_1)
      end
      troot.reload
      troot.children(true).each do
        |c|
        p = c.my_page(ipp)
        p = p > 1 ? p : nil
        c.breadcrumbs_with_paging(ipp) do
          |d, np|
          assert d.valid?
          assert_equal p, np, "Pages do not match: #{p.to_s} <> #{np.to_s}"
        end
      end
      #
      # test with root document
      #
      troot.breadcrumbs_with_paging(ipp) do
        |d, np|
        assert d.valid?
        assert_nil np
      end
  end

  def test_find_children_most_prominent_class
    def_args = { :creator => @user, :last_modifier => @user,
             :description_level_position => DescriptionLevel.fascicolo.position,
             :container_type => @ct, :name => 'test find children most prominent class' }
    assert p = Folder.create_from_form(def_args, @s_1)
    def_args.update(:parent => p)
    @classes.each do
      |c|
      @classes.each do
        |c2| 
        l2_args = def_args.dup
        assert obj = c2.create_from_form(l2_args, @s_1)
        assert obj.valid?
      end
      args = def_args.dup
      assert obj = c.create_from_form(args, @s_1) # extra one for each class in turn
      assert obj.valid?
      #
      assert p.reload
      assert_equal c, p.find_children_most_prominent_class
      p.children.each { |c| c.destroy }
      assert p.reload
      assert_equal 0, p.children.size
      subtest_finished
    end
  end

  def test_validations
    validations = [ :creator, :last_modifier, :description_level_position, :container_type, :name ]
    args = { :creator => @user, :last_modifier => @user,
             :description_level_position => DescriptionLevel.fascicolo.position,
             :container_type => @ct, :name => 'test document validations' }
    @classes.each do
      |c|
      validations.each do
        |v|
        cur_args = args.dup
        cur_args.delete(v)
        assert_raise(ActiveRecord::RecordNotSaved) do
          created = c.create_from_form(cur_args, @s_1)
        end
      end
      subtest_finished
    end
  end

private

  def create_branch(parent, klass, args, branch_number, depth)
    max_depth = 30
    cur_args = args.dup
    cur_args.update(:name => args[:name] + " => #{klass.name}-B.#{branch_number}.#{depth}",
                :description_level_position => DescriptionLevel.sottoserie.position,
                :parent => parent)
    assert leaf = klass.create_from_form(cur_args, @s_1)
    assert leaf.valid?
    create_branch(leaf, klass, cur_args, branch_number, depth + 1) if depth < max_depth-1
  end

public

  def test_stress_test_visibility
    #
    # create a deep and wide tree with plenty of documents
    # turn on and off visibility from the top of the tree
    #
    num_branches = 5
    start_class = Folder
    args = { :creator => @user, :last_modifier => @user,
             :description_level_position => DescriptionLevel.serie.position,
             :container_type => @ct, :name => 'top parent' }
    assert top = start_class.create_from_form(args, @s_1)
    assert top.valid?
    @classes.each do
      |klass|
	    0.upto(num_branches-1).each do
	      |branch|
	      create_branch(top, klass, args, branch, 0)
	    end
      subtest_finished
    end
    assert top.valid?
    assert top.public_visibility?
    assert top.public_visibility_display =~ /S\&Igrave;/i, "Wanted 'S&Igrave;' and got #{top.public_visibility} instead"
    #
    # test non-visibility after
    #
    top.reload
    top.user_update_attribute(@user, :public_visibility, false)
    top.reload
    assert top.valid?
    assert !top.public_visibility?
    assert top.public_visibility_display =~ /NO/i
  end

  def test_base_class_document_creation
    #
    # base class Document records should not be created, so an exception is
    # raised when this is attempted
    #
    args = { :creator => @user, :last_modifier => @user,
             :description_level_position => DescriptionLevel.serie.position,
             :container_type => @ct, :name => 'failed document' }
    assert_raise(DocumentParts::Crud::AttemptedDocumentCreation) do
      d = Document.create_from_form(args, @s_1)
    end
    args.update(:name => 'right document')
    @classes.each do
      |c|
      cur_args = args.dup
      assert d = c.create_from_form(cur_args, @s_1)
      assert d.valid?
      d.destroy
      subtest_finished
    end
  end

  def test_renumber_children_cordas
    p_args = @default_args.dup
    p_args.update(:name => 'Parent of renumbered cordas')
    assert p = Folder.create_from_form(p_args, @s_1)
    objs = []
    @classes.each do
      |c|
      assert c_args = @default_args.dup
      assert c_args.update(:name => "Child of class #{c.name}", :parent => p)
      assert obj = c.create_from_form(c_args, @s_1) 
      subtest_finished
    end
    assert_equal @classes.size, p.children(true).size
    assert p.renumber_children_cordas
    p.children(true).each_with_index do
      |c, i|
      assert_equal i+1, c.corda
    end
    offset = 23
    assert p.renumber_children_cordas(23)
    p.children(true).each_with_index do
      |c, i|
      assert_equal i+offset, c.corda
    end
  end

 def test_relative_renumber_children_cordas
   p_args = @default_args.dup
   p_args.update(:name => 'Parent of relative renumbered cordas')
   assert p = Folder.create_from_form(p_args, @s_1)
   objs = []
   ds = DateTime.now.to_date
   @classes.each do
     |c|
     cur_d = ds
     0.upto(2) do
       |i|
       assert c_args = @default_args.dup
       assert c_args.update(:name => "Child of class #{c.name}", :parent => p, :data_dal => cur_d + i.years)
       assert obj = c.create_from_form(c_args, @s_1) 
     end
     subtest_finished
   end
   assert_equal @classes.size*3, p.children(true).size
   assert p.relative_renumber_children_cordas
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

 #
 # allowed_{children|sibling}_classes_test
 #
 class FolderTester < Document
   def self.acc
     result = AVAILABLE_CLASSES.dup
     result.delete(CdTrackRecord)
     return result.keys
   end
 end

 def test_default_allowed_classes
	 acc_default_behaviour =
	 {
	   Folder => FolderTester.acc,
	   CdTrackRecord => { :children => nil, :sibling => 'CdTrackRecord' },
	   CdRecord => { :children => 'CdTrackRecord', :sibling => 'CdRecord'  },
	   Series   => 'Series',
	   Score    => 'Score',
	   PrintedScore => 'PrintedScore',
     BibliographicRecord => 'BibliographicRecord',
     TapeRecord => { :children => nil, :sibling => 'TapeRecord' },
	 }
   ['children', 'sibling'].each do
     |kind|
	   @classes.each do
	     |c|
	     assert args = @default_args.dup
	     assert args.update(:name => "Test for class #{c.name}#allowed_#{kind}_classes")
	     assert obj = c.create_from_form(args, @s_1)
	     assert obj.valid?, "Class #{c}: #{obj.errors.full_messages.join(', ')}"
       should_be = acc_default_behaviour[c].is_a?(Hash) ? acc_default_behaviour[c][kind.intern] : acc_default_behaviour[c]
       meth = "allowed_#{kind}_classes"
	     if should_be.is_a?(Array)
	       assert_equal should_be.map { |cc| cc.name }.sort, obj.send(meth).map { |cc| cc.name }.sort, "Class #{c.name}"
	     elsif should_be.nil?
	       assert_nil obj.send(meth), "Class #{c}"
	     else
	       assert_equal should_be, obj.send(meth).name, "Class #{c}"
	     end
	     subtest_finished
	   end
   end
 end

 def test_specialized_allowed_classes_single
   possible_children = @classes.map { |c| c.name }
   ['children', 'sibling'].each do
     |kind|
	   @classes.each do
	     |c|
	     assert args = @default_args.dup
	     assert args.update(:name => "Test for class #{c.name}#allowed_#{kind}_classes (specialized version)")
	     chidx = (rand()*(possible_children.size-1)).round
	     should_be = possible_children[chidx]
	     assert args.update("allowed_#{kind}_classes" => should_be)
	     assert obj = c.create_from_form(args, @s_1)
	     assert obj.valid?, "Class #{c}: #{obj.errors.full_messages.join(', ')}"
	     assert_equal should_be, obj.send("allowed_#{kind}_classes")[0].name, "Class #{c}"
	     subtest_finished
	   end
   end
 end

 def test_specialized_allowed_classes_multiple
   possible_children = @classes.map { |c| c.name }
   ['children', 'sibling'].each do
     |kind|
	   @classes.each do
	     |c|
	     assert args = @default_args.dup
	     assert args.update(:name => "Test for class #{c.name}#allowed_#{kind}_classes (specialized version)")
	     lastidx = (rand()*(possible_children.size-1)).round
	     should_be = possible_children[0..lastidx]
       meth = "allowed_#{kind}_classes"
	     assert args.update(meth => should_be.join('|'))
	     assert obj = c.create_from_form(args, @s_1)
	     assert obj.valid?, "Class #{c}: #{obj.errors.full_messages.join(', ')}"
	     assert_equal should_be.map { |cc| cc }.sort, obj.send(meth).map { |cc| cc.name }.sort, "Class #{c.name}"
	     assert_equal should_be.size, obj.send(meth).size
	     subtest_finished
	   end
   end
 end

 def test_default_dashboard_behaviour
   page = 1
   default_locals = {
     :add_sibling => { :locals => { :label => 'Nuova Sorella', :method => 'new_sibling', :page => page } },
     :add_child =>   { :locals => { :label => 'Nuova Figlia', :method => 'new_child', :page => page } },
     :edit      =>   { :locals => { :label => 'Modifica', :method => 'edit', :page => page } },
   }
	 class_map =
	 {
	   Folder => { :add_child => :multiple, :add_sibling => :multiple, :edit => :single },
	   CdTrackRecord => { :add_child => :icon_only, :add_sibling => :single, :edit => :single },
	   CdRecord => :single,
	   Series   => :single,
	   Score    => :single,
	   PrintedScore => :single,
     BibliographicRecord => :single,
#    TapeRecord => { :add_child => :icon_only, :add_sibling => :single, :edit => :single },
     TapeRecord => :icon_only,
	 }
   functions = [ :add_child, :add_sibling, :edit ]
   functions.each do
     |f|
     path = DocumentParts::Dashboard::DASHBOARD_PATH
	   @classes.each do
	     |c|
	     assert args = @default_args.dup
	     assert args.update(:name => "Test for class #{c.name}#dashboard functions")
	     assert obj = c.create_from_form(args, @s_1)
	     assert obj.valid?, "Class #{c}: #{obj.errors.full_messages.join(', ')}"
       assert partial_part = class_map[c].is_a?(Hash) ? class_map[c][f] : class_map[c]
       assert kind = f.to_s =~ /child/ ? 'children' : 'sibling'
	     assert should_be = default_locals[f].dup
       assert should_be.update(:partial => path + '/' + partial_part.to_s, :object => obj)
       assert should_be[:locals].update(:icon => f.to_s + '_16', :kind => kind)
       assert method = f.to_s.sub(/^add_/,'') + '_button'
       assert_equal should_be, obj.send(method, page), "#{c.name}##{f}"
       subtest_finished
	   end
   end
 end

  #
  # this brings the system down to a halt so it should be carefully avoided
  #
  def test_a_document_that_is_the_parent_of_itself
    assert root = Document.fishrdb_root
    assert parent = Folder.create_from_form({ :name => 'I am the parent', :creator => @user, :last_modifier => @user, 
                             :parent => root,
                             :description_level_position => @gs_docs[0].description_level.position,
                             :container_type => @ct }, @s_1)
    assert parent.valid?
    @classes.each do
      |c|
      assert args = @default_args.dup
      assert args.update(:name => "Test for document dashboard functions", :parent => parent)
      assert d = c.create_from_form(args, @s_1)
	    assert d.valid?, "Class #{c}: #{d.errors.full_messages.join(', ')}"
      #
      # now re-parent to itself (this should fail)
      #
      assert d.reload
      p_id = d.id
      assert !d.update_attributes(:parent_id => p_id)
      assert !d.valid?
      assert_equal 'Parent cannot have the same id as the object itself', d.errors.full_messages.uniq.join(', ')
      #
      # now re-parent to a regular parent (this should succeed)
      #
      assert d.reload
      p_id = parent.id
      assert d.update_attributes(:parent_id => p_id)
      assert d.valid?, "Class #{c}: #{d.errors.full_messages.join(', ')}"
    end
  end

  def test_tree_structure
    assert d = documents(:Okanag_0899)
    assert p = documents(:partiture_GS)
    assert d.valid?
    assert_equal d.parent.name, p.name
  end

  def test_search_engine_hook
    classes = document_classes
    classes.unshift(Document)

    classes.each do
      |klass|
      assert klass.respond_to?(:allow_search_in), "class #{klass.name} does not respond to method :allow_search_in"
      subtest_finished
    end
  end

  def test_reference_series
    assert doc = documents(:not_a_son_of_a_series)
    assert doc.valid?
    assert s = doc.reference_series
    assert s.valid?
    assert s.description_level < doc.description_level, "Referenced series level is #{s.description_level.level} against a referencer level #{doc.description_level.level}"
  end

	def test_breadcrumbs
		assert doc = documents(:Okanag_0899)
		assert doc.valid?
		assert sz = doc.ancestors.size
		assert bcs_should_be = doc.ancestors.reverse[1..sz-1].map { |d| d.name }
		assert_equal bcs_should_be, doc.breadcrumbs.map { |d| d.name }
	end

	#
	# +test_sidebar_tip_functionality+: the +sidebar_tip+ method is critical
	# because if it breaks it blocks all displays and the application is
	# unusable. So we make triple sure that it works even with minimal
	# information
	#
	def test_sidebar_tip_functionality
		assert args = @default_args.dup
		assert args.update(:name => 'Test Title')
		#
		# Since we can't create a Document base class, we create one of its
		# immediate children which do not overwrite the sidebar_tip method
		#
		assert s = Series.create_from_form(args, @s_1)
		assert s.valid?
		assert str = s.sidebar_tip
		assert !str.empty?
	end

private

  def plunge(d, level = 0, &block)
    level += 1
    d.children(true).each do
      |c|
      yield(c, level)
      plunge(c, level, &block)
    end
  end

end
