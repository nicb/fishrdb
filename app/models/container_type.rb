#
# $Id: container_type.rb 270 2008-11-09 12:06:14Z nicb $
#
require	'search_system'

class ContainerType < ActiveRecord::Base

  has_many :documents

  class << self

    def default_container_type
      return ContainerType.find_by_container_type('')
    end

  end

	extend SearchHelper::Model::ClassMethods

#	make_searchable  [ :container_type ]

	def ContainerType.create_from_yaml_file
		file = File.dirname(__FILE__) + "/../../test/fixtures/container_types.yml"
		desc = YAML.load(File.open(file, "r"))
		desc.each do
			|key, value|
			dl = ContainerType.new(:container_type => value["container_type"].to_s, :id => value["id"])
			dl.save
		end
	end
end
