#
# $Id: reference_ancestor_test.rb 537 2010-08-22 02:42:25Z nicb $
#
require 'test/test_helper'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define(:version => 1) do
    create_table :mixins do |t|
      t.column :type, :string
    end
  end
end

def teardown_db
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Mixin < ActiveRecord::Base; end

class SonOfMixin < Mixin; end

class NephewOfMixin < SonOfMixin; end

class ReferenceAncestorTest < ActiveSupport::TestCase

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  test "reference ancestor (called directly)" do
    [NephewOfMixin, SonOfMixin, Mixin].each { |klass| assert_equal Mixin, klass.reference_ancestor }
  end

  test "reference ancestor (called indirectly)" do
    [NephewOfMixin, SonOfMixin, Mixin].each do
      |klass|
      assert m = klass.create
      assert m.valid?
      assert_equal klass.name, m.class.name
      assert_equal Mixin, m.class.reference_ancestor
    end
  end

  class FakeClass; end

  class RealBadFakeClass
    #
    # we include the modules to stress test this
    #
    extend ReferenceAncestor::ActiveRecordExtensions::ClassMethods
  end

  test "reference ancestor of a non-ActiveRecord::Base class (should fail)" do
    assert_raise(NoMethodError) { FakeClass.reference_ancestor }
    assert_raise(ReferenceAncestor::ActiveRecordExtensions::ClassMethods::NotAnActiveRecord) { RealBadFakeClass.reference_ancestor }
  end

end
