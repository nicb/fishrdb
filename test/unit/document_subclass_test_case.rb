#
# $Id: document_subclass_test_case.rb 632 2013-07-12 14:45:53Z nicb $
#
# This is a helper class to test the sorting methods
# for subclasses of documents, since they basically
# all must test the same things with different objects
# and methods.
#
require 'test/extensions/subtest'
require 'test/utilities/string'

require 'string_extensions'

module DocumentSubclassTestCase

 include Test::Extensions

 ActiveSupport::TestCase.fixtures :container_types, :users, :sessions

private

  def display_map(attr, a)
    result = "[" + a.map { |i| i.name + "(" + i.send(attr).to_s + ")[" + i.position.to_s + "]" }.join(", ") + "]"
    return result
  end

  def display_document(attr, header, s, template, verbose = false)
    $stderr.puts(display_map(attr, s) + " vs. " + display_map(attr, template)) if verbose
  end

  #
  # TODO: until we do not step up from rails 2.1.0 into some later version we
  # can't use the ActiveSupport::Multibyte extension here which means we don't
  # have access to the mb_chars method for supporting multibyte. So we won't
  # use UTF-8 strings to do tests. However, the db sorting seems to be working
  # allright anyway.
  #
  def sort_template(sym, attr, t)
    if attr.to_s =~ /^sort_by_/
      result = t.first.class.send(attr, t.first.parent)
    else
      if sym.to_s !~ /DESC$/i
          result = t.sort { |a, b|  a.send(attr).to_s.cleanse.gsub(/\s+/,'').downcase <=> b.send(attr).to_s.cleanse.gsub(/\s+/,'').downcase }
      else
          result = t.sort { |a, b|  b.send(attr).to_s.cleanse.gsub(/\s+/,'').downcase <=> a.send(attr).to_s.cleanse.gsub(/\s+/,'').downcase } # reverse
      end
    end
    return result
  end

protected

  def setup_config_variables(actual_class, verbose = false)
    @verbose = verbose
    assert @myclass = actual_class
    assert @dl = DescriptionLevel.fascicolo
    assert @u  = User.find(:first, :conditions => ["login = ?", "bootstrap"])
    assert @ct = ContainerType.find_by_container_type('Busta')
    assert @s_1 = sessions(:one)
  end

  def configure(actual_class, extra_args, verbose = false, &block)
    setup_config_variables(actual_class, verbose)
    #
    # please see the TODO above concering testing with utf strings
    #
    #assert string_pool = self.class.create_random_strings_utf8
    assert string_pool = self.class.create_random_strings
    @num_docs = string_pool.size
    @s = []
    i = 0
    if extra_args.has_key?(:parent)
      #
      # if there is a parent defined we adopt it, but to simplify testing we
      # clean it up of "previous" (i.e. fixture-driven) documents
      #
      @s[0] = extra_args[:parent]
      @s[0].children(true).each { |c| c.destroy }
      assert @s[0].children(true).empty?
      @num_docs += 1
      i += 1
    end
    string_pool.each do
      |string|
      s = ""; s << string
      dto = (Time.now - (3600*24*2*i)).to_date; dfro = (Time.now - (3600*24*i)).to_date
      corda = ""; corda << 64+@num_docs; corda << (i*351%7).to_s
      n = 1
      all_args = { :name => "#{string}", :description => "F = #{i+n}",
              :description_level_position => @dl.position, :creator => @u, :last_modifier => @u,
              :container_type => @ct, :corda => corda }
      extra_args.each do 
        |k, arg|
        next_arg = case arg
        when :time_arg then { k => dto }
        when :string_arg then n += 1; { k => "#{string}#{i+n}" }
        else { k => arg }
        end
        all_args.update(next_arg)
      end
      n += 1
      yield(all_args, s, i+n) if block_given?
      assert @s[i] = @myclass.create_from_form(all_args, @s_1)
      assert @s[0].children << @s[i] unless i == 0
      assert @s[0].children.reload
      i += 1
    end
    assert_equal @num_docs, @s.size
    assert_equal @num_docs-1, @s[0].children(true).count
    assert @s[0].reload
    assert @s[0].update_attributes(:position => 1)
    @starting_order = @s[0].children.dup
    return @s
  end

  def run_subtests
    subtest_new_for_form
    subtest_existence
    subtest_tree
    subtest_validations
    subtest_update
    subtest_reparent
    subtest_delete
  end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    include Test::Utilities

  end

private
  #
  def subtest_new_for_form
   assert string_pool = self.class.create_random_strings
   string_pool.each_with_index do
     |s, i|
     all_args = { :name => "#{s}", :description => "F = #{i}",
                  :description_level_position => @dl.position, :creator => @u, :last_modifier => @u,
                  :container_type => @ct }
     assert tpdoc = @myclass.new_for_form(all_args)
     assert tpdoc.send(tpdoc.class.subkey_accessor) if tpdoc.class.respond_to?(:subkey_accessor)
   end
    subtest_finished
  end

  def subtest_existence
    @s.each do
      |s|
      s_id = s.id
      assert doc = Document.find(s.id)
      assert doc.valid?
      #
      # if the class of the document is *not* a @myclass
      # then the rest of the test does not apply
      #
      if (doc.class.name == @myclass.name)
        assert sdoc = @myclass.find(s.id)
        assert sdoc.valid?
        assert_equal doc.id, sdoc.id
      end
    end
    subtest_finished
  end

  def subtest_delete
    assert doc_id = @s[@num_docs-1].id
    assert @s[0]; assert @s[@num_docs-1]
    assert @s[@num_docs-1].destroy
    assert !Document.find(:first, :conditions => ["id = ?", doc_id])
    assert !Score.find(:first, :conditions => ["id = ?", doc_id])
    assert @s[0].reload
    assert @s[0].children.size, @num_docs-2
    subtest_finished
  end

  def subtest_tree
    assert_equal  @num_docs-1, @s[0].children(true).size
    1.upto(@num_docs-1) do
      |i|
      assert @s[i].children.empty?
    end
    subtest_finished
  end

  def subtest_validations
    #
    # validations on create
    #
    assert invalid = @myclass.new(:name => "", :description => "Empty name",
            :description_level_id => @dl.id, :creator => @u, :last_modifier => @u,
            :container_type => @ct)
    assert !invalid.save
    assert invalid = @myclass.new(:name => "invalid", :description => "no description level",
            :description_level_id => nil, :creator => @u, :last_modifier => @u,
            :container_type => @ct)
    assert !invalid.save
    assert invalid = @myclass.new(:name => "invalid", :description => "no creator",
            :description_level_id => @dl.id, :creator => nil, :last_modifier => @u,
            :container_type => @ct)
    assert !invalid.save
    assert invalid = @myclass.new(:name => "invalid", :description => "no modifier",
            :description_level_id => @dl.id, :creator => @u, :last_modifier => nil,
            :container_type => @ct)
    assert !invalid.save
    assert invalid = @myclass.new(:name => "invalid", :description => "no container",
            :description_level_id => @dl.id, :creator => @u, :last_modifier => @u,
            :container_type => nil)
    assert !invalid.save
    assert this_one = @myclass.new(:name => "valid!", :description => "This one is valid!",
            :description_level_id => @dl.id, :creator => @u, :last_modifier => @u,
            :container_type => @ct)
    assert this_one.save
    #
    # validations on update
    #
    assert !this_one.update_attributes(:name => "", :description => "no name!")
    this_one.reload
    assert !this_one.update_attributes(:description_level_id => nil, :description => "no dl!")
    this_one.reload
    assert !this_one.update_attributes(:creator => nil, :description => "no creator!")
    this_one.reload
    assert !this_one.update_attributes(:last_modifier => nil, :description => "no last_modifier!")
    this_one.reload
    assert !this_one.update_attributes(:container_type => nil, :description => "no container!")
    this_one.reload
    #
    # validations on delete
    #
    assert this_one.destroy
    subtest_finished
  end

  def subtest_update
    changed_desc = "This is a CHCHCHANGED description!"
    assert @s[1].update_attributes(:description => changed_desc)
    assert_equal @s[1].description, changed_desc
    subtest_finished
  end

  def subtest_reparent
    child0_nchilds = @s[0].children.size
    child1_nchilds = @s[1].children.size
    assert @s[2].update_attributes(:parent => @s[1])
    @s[0].reload
    @s[1].reload
    @s[2].reload
    assert_equal @s[1].children(true).size, child1_nchilds + 1
    assert_equal @s[0].children(true).size, child0_nchilds - 1
    assert @s[2].children(true).empty?
    subtest_finished
  end

protected

  def do_reorder(sym, attr, p)
    current_order = @starting_order.dup
    reordered_template = sort_template(sym, attr, @starting_order.dup)
    assert p.reorder_children(sym)
    assert p.reload
    display_document(attr, "test_reorder(#{sym.to_s})", p.children, reordered_template, @verbose)
    if attr.to_s =~ /^sort_by_/
      rmapattr = reordered_template.map { |t| t.class.send(attr, t).to_s }
      chattr = p.children.map { |t| t.class.send(attr, p).to_s }
    else
      rmapattr = reordered_template.map { |t| t.send(attr).to_s }
      chattr = p.children.map { |t| t.send(attr).to_s }
    end
    assert_equal reordered_template.map { |t| t.name }, p.children.map { |t| t.name }, "In order #{sym.to_s} (#{attr.to_s}), [ #{rmapattr}.join(', ')} ] vs [ #{chattr}.join(', ')} ]"
    subtest_finished
  end

  def run_reorder_subtests(orders)
    #
    # position (:logic) should always be tested first
    #
    okeys = orders.keys
    if orders.has_key?(:logic)
      okeys.delete(:logic)
      okeys.unshift(:logic)
    end
    okeys.each do
      |k|
      do_reorder(k, orders[k], @s[0])
    end

  end

public

  class YearPoolMaxSizeReached < StandardError
  end
  
  @@year_pool = []
  YEAR_POOL_MAX_SIZE = 30

  def unique_random_year
    raise(YearPoolMaxSizeReached, "cannot generate more than #{YEAR_POOL_MAX_SIZE} unique random years in a row") if @@year_pool.size >= YEAR_POOL_MAX_SIZE
    ry = nil
    while true
      ry = (Time.now.year - (rand()*YEAR_POOL_MAX_SIZE).floor)
      unless @@year_pool.index(ry)
        @@year_pool << ry
        break
      end
    end
    return ry
  end

  def clear_year_pool
    @@year_pool.clear
  end

  alias_method :original_teardown, :teardown if respond_to?(:teardown)

  def teardown
    clear_year_pool
    original_teardown if respond_to?(:original_teardown)
  end

end
