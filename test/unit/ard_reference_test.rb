#
# $Id: ard_reference_test.rb 208 2008-05-01 16:54:22Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

require 'ard_reference'

class ArdReferenceTest < ActiveSupport::TestCase

  #
  # fixture load order is important!
  #
	fixtures	:documents, :users, :authority_records

  class TestObj
    attr_reader   :sym, :search, :content, :klass
    attr_accessor :var, :arvar, :varvar

    def initialize(sym, search, content, klass)
      @sym = sym
      @search = search
      @content = content
      @klass = klass
    end

    def like
      return "%#{@content[:name]}%"
    end

    def variant_form_class
      return @klass.variant_form_class
    end
  end

  def setup
    assert @user  = User.authenticate('staffbob', 'testtest')
    @objs = [
      TestObj.new(:torino, 'description like ?', { :name => 'Torino' }, SiteName),
      TestObj.new(:gs, 'description like ?', { :name => 'Scelsi', :first_name => 'Giacinto' }, PersonName),
      TestObj.new(:khoom, 'name like ?', { :name => 'Khoom' }, ScoreTitle),
      TestObj.new(:mf, 'description like ?', { :name => 'Ministero delle Finanze' }, CollectiveName),
    ]
    @objs.each do
      |obj|
      obj.var = Document.find(:all, :conditions => [obj.search, obj.like])
      assert !obj.var.blank?
      assert obj.arvar = obj.klass.find(:first, :conditions => ["name = ?", obj.content[:name]]), "#{obj.klass.name}.find(:first, :conditions => [\"name = ?\", #{obj.content}] fails"
      assert obj.varvar = obj.klass.variant_form_class.find(:first,
                              :conditions => ["authority_record_id = ?", obj.arvar.id])
    end
  end

  def create_ards
    @objs.each do
      |obj|
      armeth = "create_#{obj.klass.name.underscore}_record"
      varmeth = "#{obj.klass.name.underscore.pluralize}"
      obj.var.each do
        |d|
        assert d.send(armeth, @user, obj.content)
        d.reload
        assert !d.send(varmeth).empty?, "#{d.class.name}(\"#{d.name[0..10]}...\").#{varmeth}.empty? is #{d.send(varmeth).empty?} right after d.#{armeth}(@user, { #{obj.content.map { |k,v| "#{k} => #{v}"}.join(', ')} }) has been performed"
      end
    end
  end

   def test_creation
     create_ards
   end
   def test_htm
     create_ards
     @objs.each do
       |obj|
       ref_meth = obj.klass.name.underscore.pluralize
       obj.var.each do
         |d|
         d.reload
         assert !d.send(ref_meth).blank?, # docs are bound to authority records
                "Document #{d.class.name}(#{d.id}, #{d.name}).#{ref_meth} returns an empty array" 
       end
       assert !obj.arvar.documents.blank? # authority records are bound to docs
       assert_equal obj.var.size, obj.arvar.documents.size # loops forward
     end
   end
end
