#
# $Id: auth_migrator.rb 202 2008-04-15 09:49:01Z nicb $
#

require 'authority_record'
require 'ard_reference'

module AuthMigrator

protected

  def self.randstring(prefix='')
    return sprintf("%s_%05d", prefix, (rand*32768).to_i)
  end

	class OldAuth
		attr_reader		:name, :type, :yml_tag, :doc_id

	private
		OLD_2_NEW_MAP = {
			'enti_series'			=> CollectiveName,
			'nomi_series'			=> PersonName,
			'luoghi_series' 		=> SiteName,
			'titoli_series' 		=> ScoreTitle,
			'titolo_uniforme_score'	=> ScoreTitle,
		}

		NEW_2_OLD_MAP = OLD_2_NEW_MAP.invert

    def self.create_yml_tag(string)
      rs = AuthMigrator.randstring
      result = string.gsub(/[^A-Za-z0-9]+/, '_') + rs
    end

		def initialize(doc_id, string, type)
      @doc_id = doc_id
			@name = string
			@type = type
      @yml_tag = self.class.create_yml_tag(@name)
		end

	protected

    def old_field
      return @type
    end

		def find_conditions
			return ["name = ?", self.name]
		end

		def create_new_auth_record(&block)
			klass  = self.new_class
			result = klass.find(:first, :conditions => self.find_conditions)
			result = yield(klass) unless result
			return result
		end

    def add_to_yaml_properties(yaml_struct, key, value)
      yaml_struct[@yml_tag.to_s][key] = value
    end

	public

		def new_class
			return OLD_2_NEW_MAP[@type]
		end

		def new_auth_record(user)
			return create_new_auth_record { |c| c.create(:name => self.name, :creator_id => user.id, :last_modifier_id => user.id) }
		end

		def self.old_auth_field(klass)
			return NEW_2_OLD_MAP[klass]
		end

    def my_to_yaml
      return { @yml_tag => { 'doc_id' => @doc_id, 'name' => @name, 'type' => @type } }
    end

    def create_yaml_record
      result = "--- <#{self.class}:#{self.object_id}>\n#{@yml_tag}:\n"
      result += my_to_yaml[@yml_tag].map { |k, v| "  #{k}: \"#{v.to_s}\"" }.join("\n")
      return result
    end

    def attributes
      result = {}
      [:name, :type].each { |k| result[k] = self.send(k) }
      return result
    end
	end

  module AuthEquivalent

		def new_auth_record_with_reference(user, ref)
			nar = new_auth_record(user)
      ref.equivalents << nar
      return nar
		end

    def attributes
      result = super
      result[:reference_record] = self.reference_record
      return result
    end

    def my_to_yaml
      result = super
      add_to_yaml_properties(result, 'reference_record', @reference_record.to_s)
      return result
    end

  end

  class OldAuthEquivalent < OldAuth
    attr_reader  :reference_record

    include AuthEquivalent

		def initialize(doc_id, string, rr, type)
      super(doc_id, string, type)
      @reference_record = rr
		end

  end

	class OldAuthName < OldAuth
		attr_reader		:first_name

	private

		def initialize(doc_id, string, stype = 'nomi_series')
      (last_name, first_name) = string.split(/,\s*/)
			super(doc_id, last_name, stype)
			@first_name = first_name
		end

	protected
	
		def find_conditions
			return ["name = ? and first_name = ?", self.name, self.first_name]
		end

	public

		def new_auth_record(user)
      result = super(user)
      result.update_attribute('first_name', self.first_name)
      return result
		end

    def my_to_yaml
      result = super
      add_to_yaml_properties(result, 'first_name', @first_name.to_s)
      return result
    end

    def attributes
      result = super
      result[:first_name] = self.first_name
      return result
    end
	end

  class OldAuthNameEquivalent < OldAuthName
    attr_reader  :reference_record

    include AuthEquivalent

    def initialize(doc_id, string, rr, stype = 'nomi_series')
      super(doc_id, string, stype)
      @reference_record = rr
    end

    def my_to_yaml
      result = super
      add_to_yaml_properties(result, 'reference_record', @reference_record.to_s)
      add_to_yaml_properties(result, 'first_name', @first_name.to_s)
      return result
    end

  end

	OLD_AUTH_FIELDS = ['nomi_series', 'enti_series', 'luoghi_series', 'titoli_series', 'titolo_uniforme_score']
	#
	# Going forward internal plumbing...
	#
	def self.create_find_conditions
		result = OLD_AUTH_FIELDS.map { |f| "((#{f} is not null) and (#{f} != ''))" }.join(" or ")
		return result
	end

	def self.get_all_interesting_documents
		return Document.find(:all, :conditions => [create_find_conditions])
	end

	def self.extract_old_authority_records(all_records, doc)
    nullsep = /XXX---XXX/ # something that will not appear :(
    std_rs = /\][;,\s]*\[/
    std_es = /\s*;\s*/
    classmap =
    {
      'nomi_series'   =>  { :main => OldAuthName, :equiv => OldAuthNameEquivalent, :es => std_es, :rs => std_rs },
      'enti_series'    => { :main => OldAuth, :equiv => OldAuthEquivalent, :es => std_es, :rs => std_rs },
      'luoghi_series'    => { :main => OldAuth, :equiv => OldAuthEquivalent, :es => std_es, :rs => std_rs },
      'titoli_series'    => { :main => OldAuth, :equiv => OldAuthEquivalent, :es => std_es, :rs => std_rs },
      'titolo_uniforme_score'    => { :main => OldAuth, :equiv => OldAuthEquivalent, :es => nullsep, :rs => nullsep },
    }
		OLD_AUTH_FIELDS.each do
			|t|
			attr = doc.read_attribute(t)
			if !attr.blank?
        main_class = classmap[t][:main]
        equiv_class = classmap[t][:equiv]
        split_ar = attr.sub(/^\s*\[/,'').sub(/\]\s*$/,'').split(classmap[t][:rs])
				split_ar.each do
					|ar|
          (main_record, equivs) = ar.split(classmap[t][:es])
					mr =  main_class.new(doc.id, main_record, t)
          all_records[mr.yml_tag] = mr
          if equivs
            equivs.each do
              |e|
              er = equiv_class.new(doc.id, e, mr.yml_tag, t)
              all_records[er.yml_tag] = er
            end
          end
				end
			end
		end
		return all_records
	end

  def self.generate_old_authority_records
    oars = {}
    docs = get_all_interesting_documents
    docs.each do
      |d|
      extract_old_authority_records(oars, d)
    end
    return oars
  end

	def self.create_and_link_new_authority_records(user)
    oars = generate_old_authority_records
    unless oars.blank?
      oars.each do
        |k, oar|
        doc = Document.find(oar.doc_id)
        attrs = oar.attributes.dup
        [:type, :doc_id].each { |s| attrs.delete(s) }
        if oar.class == OldAuthEquivalent or oar.class == OldAuthNameEquivalent
          roar = oars[oar.reference_record]
          rr = roar.new_auth_record(user)
          attrs.delete(:reference_record)
          nar = doc.create_equivalent_authority_record(rr, user, attrs)
        else
          create_method = "create_#{oar.new_class.name.underscore}_record"
          nar = doc.send(create_method, user, attrs)
        end
      end
		end
	end
	#
	# Going backwards internal plumbing...
	#
	def self.get_all_authority_records
		return AuthorityRecord.find(:all)
	end

	def self.restore_old_authority_fields(ar, user)
		field_name = OldAuth.old_auth_field(ar.class)
		ar.documents.each do
			|doc|
			attr = doc.read_attribute(field_name)
			attr += "; " unless attr.blank?
			attr += ar.to_s
			doc.user_update_attribute(user, field_name, attr)
		end
	end

  def self.create_intermediate_yaml_file(filename)
    oars = generate_old_authority_records
    unless oars.blank?
      File.open(filename, 'w') do
        |f|
        oars.each { |k, oar| f.puts(oar.create_yaml_record) }
      end
    end
  end

public
  #
  # Verify quality of translation
  #
  def self.verify_authority_record_migration
    rs = randstring('/../tmp/auth_tmpfile_')
    tmpfilename = File.dirname(__FILE__) + rs + '.yml'
    $stderr.puts("#{self.class.name}: Creating #{tmpfilename} yaml file...")
    create_intermediate_yaml_file(tmpfilename)
    $stderr.puts("#{self.class.name}: Done.")
  end
	#
	# Going forward....
	#
	def self.create_authority_records_from_documents(user)
    create_and_link_new_authority_records(user)
	end

	#
	# Going backwards...
	#
	def self.restore_authority_records_in_documents(user)
		auths = get_all_authority_records
		auths.each { |a| restore_old_authority_fields(a, user) }
	end

end

class AuthorityRecord < ActiveRecord::Base

  def create_from_old_authority_record(user)
    doc = Document.find(self.doc_id)
    create_method = "create_#{self.new_class.name.underscore}_record"
    return doc.send(create_method, user, self.attributes)
  end

end
