#
# $Id: build_helper.rb 541 2010-09-07 06:08:21Z nicb $
#

require 'test/utilities/random_string'
require 'search_engine/index_system'
require 'search_engine/string_extensions'

require 'db/migrate/create_search_index_and_friends'

module SearchEngine

  module Test

		module BuildHelper

      ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

			def setup_db
   		  ActiveRecord::Migration.verbose = false
			  ActiveRecord::Schema.define(:version => 1) do
			    create_table :mock_bases do |t|
			      t.string :type
            t.boolean :visible, :default => true
            0.upto(6) { |n| t.string "field_#{n}".intern }
            t.string :one_more_field
			    end
          create_table :wrong_mock_objects do |t|
            t.string :dummy # nothing interesting here
          end
          SearchEngine::CreateSearchIndexAndFriends.up
			  end
			end
			
			def teardown_db
  		  ActiveRecord::Migration.verbose = false
			  ActiveRecord::Base.connection.tables.each do |table|
			    ActiveRecord::Base.connection.drop_table(table)
			  end
			end

      class MockBase < ActiveRecord::Base

        #
        # we have to mock this one too
        #
		    def reference_roots
 	      return { self.id.to_s => self.id.to_s }
		    end

        def related_records
          return [ self ]
        end
		
        allow_search_in [ :field_0 ], { :exclude_method => :visible, :exclude_classes => [ MockBase ] }
		
      end
		
		  class MockObject1 < MockBase
		
		    allow_search_in [ :field_1, :field_2, :field_3 ]
		
		  end

      class SubMockObject < MockObject1
      end

      class SubMockObjectWithMoreFields < MockObject1

        allow_search_in [ :one_more_field ]

      end
		
		  class MockObject2 < MockBase
		
		    allow_search_in [ :field_4, :field_5, :field_6 ]
		
		  end

      class StringVerifier
        attr_reader :class_name, :field
        attr_accessor :id, :string

        def initialize(s,ct,f)
          @id = nil
          @string = s
          @class_name = ct
          @field = f
        end

      end
		
      attr_reader :test_classes, :all_test_classes

		private
		
		  include Utilities::RandomString
		
      attr_reader :saved_strings

		  def initialize(parms)
        @test_classes = [MockObject1, MockObject2, SubMockObject, SubMockObjectWithMoreFields]
        @all_test_classes = @test_classes.dup
        @all_test_classes << MockBase
        clear_saved_strings
		    super(parms)
		  end

		  def create_n_random_mocks(n, p = nil)
        @saved_strings = []
        1.upto(n) do
          |n|
          klass = pick_a_random_class
          temp_cache = []
          parms = {}
          klass.search_engine_fields.each do
            |field|
  		      rs = ActiveSupport::Multibyte::Chars.new(create_random_strings_utf8(50).join(' '))
  		      parms.update(field => rs)
  		      record = StringVerifier.new(rs, klass.name, field)
            temp_cache << record
          end
          assert obj = klass.create(parms)
          assert obj.valid?
          temp_cache.each { |r| r.id = obj.id }
          @saved_strings.concat(temp_cache)
        end
        return @saved_strings.size
		  end
		
      def pick_a_random_class
        n_classes = self.test_classes.size
        idx = (rand()*(n_classes-1)).round
        return self.test_classes[idx]
      end

		  def calc_number_of_indices
        saved_strings = []
		    SearchEngine::Manager.searchable_objects(self.test_classes).each do
		      |so|
          coll = so.all
          coll.each do
            |obj|
            if obj.included_in_indexing?
              so.search_engine_fields.each do
                |sf|
                string = obj.send(sf).to_s.search_engine_cleanse
                saved_strings << string unless (string.blank? || saved_strings.index(string))
              end
            end
          end
		    end
		    return saved_strings.size
		  end

      def clear_saved_strings
        @saved_strings = []
      end

		end

  end

end
