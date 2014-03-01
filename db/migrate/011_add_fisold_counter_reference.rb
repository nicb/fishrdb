#
# $Id: 011_add_fisold_counter_reference.rb 173 2008-02-22 11:52:00Z nicb $
#
require 'add_fisold_reference'

class AddFisoldCounterReference < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column 'documents', 'fisold_reference_score', :integer, :default => nil, :unique => true
    end
    ActiveRecord::Base.transaction do
      AddFisoldReference.add_fisold_reference('Partiture Giacinto Scelsi')
    end
    ActiveRecord::Base.transaction do
      AddFisoldReference.add_fisold_reference('Partiture Altri Autori')
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column 'documents', 'fisold_reference_score'
    end
  end
end
