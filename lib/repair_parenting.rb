#
# $Id: repair_parenting.rb 173 2008-02-22 11:52:00Z nicb $
#
# This is a library of methods for the repair parenting migration script.
# It uses the fisold_compare_lib library, and:
#
# 1) it first scans the required database (indicated  by  the  RAILS_ENV
#    environment  library)  with  the  fisold_compare  library  to  find
#    documents that need reparenting;
# 2) it creates a yaml file in the tmp directory holding a hash of all
#    documents in need of reparenting
# 3) it reads the created yaml file
# 4) it does the actual reparenting
# 
# All of this is done by calling the 'repair' method.
#

require 'yaml'

module RepairParenting

	require 'fisold_compare_lib'
	
	def RepairParenting.modify_db(yfile, db, &block)
		Document.open_db(db)
		return unless yfile
		yfile.each_value do
			|v|
			begin
				yield(v)
			rescue ActiveRecord::RecordNotFound
				$stderr.puts("#{$!}: Document \"#{v['name']}\"(#{v['id']}) not found. Skipping.")
			end
		end
	end
	
	def RepairParenting.repair_db(yfile, db)
		modify_db(yfile, db) do
			|yrecord|
			doc = Document.find(yrecord['id'].to_i)
			#
			# make sure the new parent exists
			#
			new_parent = Document.find(:first, :conditions => ["id = ? and name = ?",
													yrecord['parent_should_be'], yrecord['parent_name']])
			if new_parent
				doc.update_attribute('parent_id', new_parent.id)
			end
		end
	end
	
	def RepairParenting.unrepair_db(yfile, db)
		modify_db(yfile, db) do
			|yrecord|
			doc = Document.find(yrecord['id'].to_i)
			#
			# make sure the old parent exists
			#
			old_parent = Document.find(:first, :conditions => ["id = ? and name = ?",
													yrecord['parent_id'], yrecord['parent_name']])
			if old_parent
				doc.update_attribute('parent_id', old_parent.id)
			end
		end
	end
	
	def RepairParenting.get_yaml_data(filename)
		return YAML.load(File.open(filename, 'r'))
	end
	
	def RepairParenting.repair_info
		tmp_path = File.dirname(__FILE__) + '/../tmp'
		args = [ ENV['RAILS_ENV'].blank? ? 'development' : ENV['RAILS_ENV'] ]
	
		return tmp_path, args
	end
	
	def RepairParenting.set_stderr(caller)
		path = File.dirname(__FILE__) + '/../log/'
		$stderr = File.open(path + "#{caller}.log", 'w')
	end
	
	def RepairParenting.repair(caller_file)
      begin
	    tmp_path, args = repair_info
	    set_stderr('repair')
	
	    yaml_filename = compare_db(caller_file, tmp_path, args)
	    yaml_data = get_yaml_data(yaml_filename)
	
	    repair_db(yaml_data, args[0])
      rescue ActiveRecord::RecordNotFound, NonUniqueRecord, AttrNotFound
        $stderr.puts($!)
      end
	end
	
	def RepairParenting.unrepair(caller_file)
      begin
		tmp_path, args = repair_info
		set_stderr('unrepair')
		yaml_data = get_yaml_data(create_yaml_filename(tmp_path, caller_file, args))
	
		unrepair_db(yaml_data, args[0])
      rescue ActiveRecord::RecordNotFound, NonUniqueRecord, AttrNotFound
        $stderr.puts($!)
      end
	end
end
