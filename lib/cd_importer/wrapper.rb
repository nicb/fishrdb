#
# $Id: wrapper.rb 470 2009-10-18 16:18:58Z nicb $
#

module CdImporter

  class Wrapper

    attr_reader :default_args

    def initialize
      ct = ContainerType.find_by_container_type('Scatola')
      sess = CGI::Session::ActiveRecordStore::Session.first # pick the first available one
      raise(ActiveRecord::ActiveRecordError, "Invalid or non existent session") unless sess && sess.valid?
      creator_user_name = 'giorgio'
      lm_user_name = 'nicb'
      cuser = User.find_by_login(creator_user_name)
      raise(ActiveRecord::RecordNotFound, "Invalid or non existent user \"#{creator_user_name}\"") unless cuser && cuser.valid?
      lmuser = User.find_by_login(lm_user_name)
      raise(ActiveRecord::RecordNotFound, "Invalid or non existent user \"#{lm_user_name}\"") unless lmuser && lmuser.valid?
      @default_args = { :session => sess, :creator => cuser, :last_modifier => lmuser,
                        :container_type => ct,
                        :description_level_position => DescriptionLevel.unita_documentaria.position }
    end

    def import
			tmpdir = File.dirname(__FILE__) + '/../../tmp'
      logfile_name = tmpdir + '/cd_importer.out'
	    cdr = find_cd_root
	    raise(ActiveRecord::RecordNotFound, "Root Cd Folder #{cdr.name} was not found or could not be created: #{cdr.errors.full_messages.join(', ')}") unless cdr && cdr.valid?
			logfile = File.open(logfile_name, "w")
	    args = default_args.dup
	    args.update(:parent => cdr)
			cdi = CdImporter::Importer.new(CdImporter::Importer::DATA_FILE, logfile, args)
			parse_errors = cdi.import
			logfile.puts("IMPORT ERRORS:\n" + parse_errors.join("\n")) unless parse_errors.empty?
	    log_created_objects(cdr, logfile)
			logfile.close
      raise(ActiveRecord::ActiveRecordError, "PARSE ERRORS during CD IMPORT (please check the log #{logfile_name})\n#{parse_errors.join("\\n")}") unless parse_errors.empty?
      return cdr
    end

  private

    def find_cd_root
      result = nil
      previous_parent_id = nil
      ancs = [ '__Fondazione_Isabella_Scelsi__', 'Fondazione Isabella Scelsi', 'CD e DVD', ]
      ancs.each do
        |name|
        result = Folder.find_by_parent_id_and_name(previous_parent_id, name)
        raise(ActiveRecord::RecordNotFound, "Mandatory ancestor #{name} not found!") unless result
        previous_parent_id = result.id
      end
      return result
    end

	  def log_created_objects(root, log, tab = 0)
	    log.puts(("\t" * tab) + root.inspect)
	    root.children.each do
	      |c|
	      log_created_objects(c, log, tab + 1)
	    end
	  end

  end

end
