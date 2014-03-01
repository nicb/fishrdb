#
# $Id: fisold_compare_lib.rb 432 2009-08-30 21:44:20Z nicb $
#

require 'yaml'
top_prefix 			= File.expand_path(File.dirname(__FILE__) + '/..')
config_prefix		= top_prefix + '/config/'
model_prefix		= top_prefix + '/app/models/'
$data_migration_prefix = top_prefix + '/db/migrate/data-migrations'
$tmpdir = top_prefix + '/tmp'
require config_prefix + 'environment'
require 'active_record'
#require model_prefix + 'document'

#
# adding a function to class IO
#
class IO
  def vputs(string)
    puts(string) unless ENV['VERBOSE'].blank?
  end
end

class NonUniqueRecord < Exception
end

class AttrNotFound < Exception
end

module DocumentInstanceMethods

  def traverse_subtree(&block)
    self.children.each do
      |d|
      yield(d)
      d.traverse_subtree(&block)
    end
  end

end

module DocumentClassMethods

protected

	CONDS  = ['name', 'description', 'tipologia_documento_score', 'misure_score',
			'autore_score', 'organico_score',
			'consistenza', 'edizione_score',
			'luogo_edizione_score', 'note_score',
			'autore_versi_score' ]

  class DocumentAttribute
    #
    # has two methods: the attribute names for fishrdb and fisold,
    #
    attr_accessor   :fishrdb_attr, :fisold_attr
    def initialize(fdan, fodan, pre = '', post = '')
      @fishrdb_attr = fdan
      @fisold_attr  = fodan
      @pre = pre
      @post = post
    end
  protected

    def condition_string(string)
      if string.is_a?(String)
        string = string.strip
        string = string.gsub(/\r\n/, "\n")
      end
      return string
    end

  public

    def cstr
        return nil
    end
    def contour(string)
      string = condition_string(string)
      return string ? @pre + string + @post : string
    end
  end

  class DocumentStrictCompare < DocumentAttribute
    def cstr
      return '='
    end
  end

  class DocumentWeakCompare < DocumentAttribute
    def cstr
      return 'like'
    end
  end

  class DocumentOrganicoCompare < DocumentWeakCompare

    ORGANICO_SIZE = 512

    def contour(string)
      string = condition_string(string)
      result = string
      if string and string.size >= ORGANICO_SIZE
        result = super(string)
      end
      return result
    end
  end

	NEW_2_OLD_CONV = 
	{
		:name =>	DocumentWeakCompare.new(:name, :titolo_fascicolo, '', '%'),
		:tipologia_documento_score	=>	DocumentStrictCompare.new(:tipologia_documento_score, :tipologia_documento),
		:description	=>	DocumentStrictCompare.new(:description, :descrizione_contenuto),
		:misure_score	=>	DocumentStrictCompare.new(:misure_score, :misure),
		:consistenza	=>	DocumentStrictCompare.new(:consistenza, :consistenza),
		:autore_score	=>	DocumentStrictCompare.new(:autore_score, :autore),
		:organico_score	=>	DocumentOrganicoCompare.new(:organico_score, :organico, '', '%'),
		:anno_composizione_score	=>	DocumentStrictCompare.new(:anno_composizione_score, :anno_composizione),
		:edizione_score	=>	DocumentStrictCompare.new(:edizione_score, :edizione),
		:anno_edizione_score	=>	DocumentStrictCompare.new(:anno_edizione_score, :anno_edizione),
		:luogo_edizione_score	=>	DocumentStrictCompare.new(:luogo_edizione_score, :luogo_edizione),
		:trascrittore_score	=>	DocumentStrictCompare.new(:trascrittore_score, :trascrittore),
		:note_score	=>	DocumentStrictCompare.new(:note_score, :note),
		:autore_versi_score	=>	DocumentStrictCompare.new(:autore_versi_score, :autore_versi),
		:titolo_uniforme_score	=>	DocumentStrictCompare.new(:titolo_uniforme_score, :titolo_uniforme),
	}

	OLD_2_NEW_CONV =
	{
		:titolo_fascicolo =>	NEW_2_OLD_CONV[:name],
		:tipologia_documento	=>	NEW_2_OLD_CONV[:tipologia_documento_score],
		:descrizione_contenuto	=>	NEW_2_OLD_CONV[:description],
		:misure	=>	NEW_2_OLD_CONV[:misure_score],
		:consistenza	=>	NEW_2_OLD_CONV[:consistenza],
		:autore	=>	NEW_2_OLD_CONV[:autore_score],
		:organico	=>	NEW_2_OLD_CONV[:organico_score],
		:anno_composizione	=>	NEW_2_OLD_CONV[:anno_composizione_score],
		:edizione	=>	NEW_2_OLD_CONV[:edizione_score],
		:anno_edizione	=>	NEW_2_OLD_CONV[:anno_edizione_score],
		:luogo_edizione	=>	NEW_2_OLD_CONV[:luogo_edizione_score],
		:trascrittore	=>	NEW_2_OLD_CONV[:trascrittore_score],
		:note	=>	NEW_2_OLD_CONV[:note_score],
		:autore_versi	=>	NEW_2_OLD_CONV[:autore_versi_score],
		:titolo_uniforme	=>	NEW_2_OLD_CONV[:titolo_uniforme_score],
	}

public

  def fetch_subtree_root(root_name)
		root = self.find(:first, :conditions => ["name = ?", root_name])
		raise ActiveRecord::RecordNotFound, root_name unless root
    return root
  end

	def fetch_subtree(root_name)
    root = fetch_subtree_root(root_name)
		result = self.find(:all, :conditions => ["parent_id = ?", root.id])
		return result
	end
	
	def open_db(db)
		result = self.establish_connection(db.intern) || raise("Connection to #{db} failed")
	end

	def close_db
		self.remove_connection
	end

  def build_conditions_string(corr_instance, &block)
    pars = {}
	  conditions_string = ""
    ciklass = corr_instance.class
    ciklass.search_attributes.map do
		  |k|
			v = corr_instance.read_attribute(k)
			my_tag = ciklass.map_tag(k)
			if conditions_string.empty?
				conditions_string = ciklass.map_condition_string(my_tag, v)
			else
				conditions_string += ' and ' + ciklass.map_condition_string(my_tag, v)
			end
			pars[ciklass.map_value_key(my_tag)] = ciklass.map_value_value(my_tag, v)
      if block_given?
        yield(conditions_string, pars)
      end
    end
    return conditions_string, pars
  end

  def map_value_value(my_attr, value)
    return my_attr.contour(value)
  end

	def map_condition_string(my_attr, value)
    a = map_value_key(my_attr)
    result = "#{a} is null"
    if value
      result = "#{a} #{my_attr.cstr} :#{a}"
      if value.empty?
        result = "(" + result + " or #{a} is null)"
      end
    end
		return result
	end

  def find_exact_correspondant(corr_instance)
    conditions_string, pars = build_conditions_string(corr_instance)
		return find(:all, :conditions => [conditions_string, pars])
  end

	def find_correspondant(corr_instance)
		pars = {}
		conditions_string = lcs = ""
		unfound_attributes = []
    conditions_string, pars = build_conditions_string(corr_instance) do
      |cs, p|
		  temp_results = find(:all, :conditions => [cs, p])
		  if temp_results.empty?
			  conditions_string = lcs
			  unfound_attributes << k
		  end
		  lcs = conditions_string
		end
		#
		# return just the last clean result (if any)
		#
		results = find(:all, :conditions => [conditions_string, pars])

		return results, unfound_attributes
	end
end

class Document < ActiveRecord::Base
	include DocumentInstanceMethods
	include DocumentClassMethods
	extend  DocumentClassMethods

protected

public

	def self.map_tag(nt)
		nt = nt.intern unless nt.is_a?(Symbol)
		return NEW_2_OLD_CONV[nt]
	end

	def self.search_attributes
		return CONDS
	end
	
	def anno_edizione_score
		return read_attribute('anno_edizione_score').year.to_s
	end
	
	def anno_composizione_score
		return read_attribute('anno_composizione_score').year.to_s
	end

	def name
		return read_attribute('name')
	end

  def self.map_value_key(my_attr)
    return my_attr.fisold_attr
  end
end

class Fisold < ActiveRecord::Base
	include DocumentInstanceMethods
	include DocumentClassMethods
	extend  DocumentClassMethods

public
	def self.find_by_id(idnum)
		return self.find(:all, :conditions => ["contatore = ?", idnum])
	end

	def parent
		parent_record = []
		pid = self.read_attribute('figlia_di')
		if pid
			parent_record = self.class.find_by_id(figlia_di)
			raise ActiveRecord::RecordNotFound, "Parent #{pid} of record \"#{self.titolo_fascicolo}\" does not exist" unless parent_record
		end
		return parent_record
	end

	def self.map_tag(ot)
		ot = ot.iotern unless ot.is_a?(Symbol)
		return OLD_2_NEW_CONV[ot]
	end
	
	def self.search_attributes
		return CONDS.map { |a| NEW_2_OLD_CONV[a.intern].fisold_attr.to_s }
	end
	
  def self.map_value_key(my_attr)
    return my_attr.fishrdb_attr
  end
end

class FisoldGS < Fisold
	set_table_name 'Partiture_Scelsi'
end

class FisoldAA < Fisold
	set_table_name 'Partiture_altri_autori'
end

def truncate(s, v, tail = '...')
	return s.length > v ? s[0..v-1-tail.size] + tail : s
end

def issue_warning(d, od_parent)
	$stderr.printf("%-30s (%04d): figlia di \"#{d.parent.read_attribute('name')}\"(#{d.parent.id}) invece di \"#{od_parent.titolo_fascicolo}\"(#{od_parent.contatore})\n", truncate(d.read_attribute('name'), 30), d.id)
end

def yaml_header(driver)
	return "#\n# This file is produced automatically by the #{driver} script
# DO NOT EDIT! Your edits will be wiped out at the next run.
# This is the $Revision: 432 $ version of the #{File.basename(__FILE__)} library
# run on #{Time.now}\n#\n"
end

def save_record_to_be_changed(doc, new_parent, fh)
	yaml_comment = '#'
	yaml_tag = "          " # yaml_tag will be a random lowercase string
	yaml_indent = "   "
	0.upto(9) { |i| yaml_tag[i] = ((Kernel.rand * 25).to_i + 97).to_i }
	yaml_string = yaml_tag + ":\n"
	fields =
	{
		:name => doc.read_attribute('name'),
		:parent_name => doc.parent.read_attribute('name'),
		:id => '"' + doc.id.to_s + '"',
		:parent_id => '"' + doc.parent.id.to_s + '"',
		:parent_should_be => '"' + new_parent.id.to_s + '"',
		:parent_name_should_be => new_parent.read_attribute('name'),
	}
	fields.each do
		|k, v|
		yaml_string += yaml_indent + k.to_s + ': ' + v + "\n"
	end
	fh.puts(yaml_string + "\n")
end

def get_fisold_class(fisold_root_name)
  correspondance =
  {
    'Partiture Giacinto Scelsi' => FisoldGS,
    'Partiture Altri Autori' => FisoldAA,
  }
  return correspondance[fisold_root_name]
end

def fisold_log_not_found(doc, fisold_class)
  fh = File.open($tmpdir + "/#{fisold_class}_not_found.yml", 'a')
  fh.puts("#\n# #{doc.raw_name}\n#\n#{doc.id}:\n\tfisold: none")
  fh.close
end

def fisold_exception_list_lookup(doc, fisold_class)
  result = []
  fh = File.open($data_migration_prefix + '/score_fisold_reference.yml', 'r')
  exception_data = YAML.load(fh)
  key = "#{fisold_class.name}_#{doc.id}"
  data = exception_data[key]
  if data
    data_id = data['fisold']
    fod = data_id == 'none' ? data_id : fisold_class.find_by_contatore(data_id)
    result << fod
  end
  fh.close
  return result
end

def exact_compare_with_fisold(subtree_root_name, &block)
  fisold_class = get_fisold_class(subtree_root_name)
  subtree_root = Document.fetch_subtree_root(subtree_root_name)
  fisold_docs = []
  subtree_root.traverse_subtree do
    |d|
    fisold_docs = fisold_class.find_exact_correspondant(d)
    if fisold_docs.blank?
      fisold_docs = fisold_exception_list_lookup(d, fisold_class)
    end
		raise ActiveRecord::RecordNotFound, "#{fisold_class.name} record for Document record \"#{d.read_attribute('name')}\" (#{d.inspect}) not found" unless fisold_docs.size > 0
		$stderr.vputs("#{fisold_docs.size} *identical* Fisold records found for Document \"#{d.read_attribute('name')}\"(#{d.read_attribute('id')}): #{fisold_docs.map {|fd| "#{fd.contatore}" }.join(', ')}") if fisold_docs.size > 1
    unless fisold_docs[0] == 'none'
      yield(d, fisold_docs)
    end
  end
  return subtree_root
end

def raw_compare_with_fisold(subtree_root_name, &block)
  fisold_class = get_fisold_class(subtree_root_name)
  count = 0
  subtree_root = Document.fetch_subtree_root(subtree_root_name)
  subtree_root.traverse_subtree do
    |d|
		fisold_docs, attrs_not_found = fisold_class.find_correspondant(d)
		raise ActiveRecord::RecordNotFound, "Fisold record for Document record \"#{d.read_attribute('name')}\" not found" unless fisold_docs.size > 0
		raise AttrNotFound, "Document(#{d.id}) attributes #{attrs_not_found.inspect} mismatched for Fisold record \"#{fisold_docs[0].read_attribute('titolo_fascicolo')}\"(#{fisold_docs[0].read_attribute('contatore')})" unless attrs_not_found.empty?
		$stderr.vputs("#{fisold_docs.size} *identical* Fisold records found for Document \"#{d.read_attribute('name')}\"(#{d.read_attribute('id')}): #{fisold_docs.map {|fd| "#{fd.contatore}" }.join(', ')}") unless fisold_docs.size == 1
	  yield(d, fisold_docs, attrs_not_found)
		if d.children.size > 0
      dummy, cnt = raw_compare_with_fisold(d.read_attribute('name'), &block)
			count += cnt
		end
	end
	
	return subtree_root, count
end

def raw_parent_compare_with_fisold(subtree_root, &block)
  subtree, count = raw_compare_with_fisold(subtree) do
    |d, fods, anf|
    fods.each do
	    |fod|
	    fisold_doc_parents = fod.parent
	    unless fisold_doc_parents.empty?
	      fisold_doc_parents.each do
	        |fdp|
	        new_doc_parents, attrs_not_found = Document.find_correspondant(fdp)
		      raise ActiveRecord::RecordNotFound, "Document record for Fisold record \"#{fdp.read_attribute('titolo_fascicolo')}\" not found" unless new_doc_parents.size > 0
		      raise AttrNotFound, "Fisold attributes #{attrs_not_found.inspect} mismatched for Document record \"#{d.read_attribute('name')}\"(#{d.read_attribute('id')})" unless attrs_not_found.empty?
		      $stderr.vputs("#{new_doc_parents.size} *identical* Document records found for Fisold record \"#{fdp.read_attribute('titolo_fascicolo')}\"(#{fdp.read_attribute('contatore')}): #{new_doc_parents.map {|ndp| "#{ndp.id}" }.join(', ')}") unless new_doc_parents.size == 1
		      new_doc_parents.each do
	          |ndp|
		        if d.parent.read_attribute('id') != ndp.read_attribute('id')
		          issue_warning(d, fdp)
	            yield(d, ndp)
			        count += 1
		        end
	        end
	      end
	    end
	  end
	  if d.children.size > 0
	    count += raw_parent_compare_with_fisold(d.read_attribute('name'), &block)
	  end
  end
  return count
end

def compare_with_fisold(subtree_root, fh)
    return raw_parent_compare_with_fisold(subtree_root) do
      |d, ndp|
      save_record_to_be_changed(d, ndp, fh)
    end
end

def create_yaml_filename(path, driver, args)
	suffix = driver.chomp('.rb') + '-' + args[0]
	return "#{path}/records_to_be_changed-#{suffix}.yml"
end

def open_comparison_dbs(args, &block)
	db1 = args[0]
	db2 = 'fisold'

	Document.open_db(db1)
	Fisold.open_db(db2)

  yield

	Document.close_db
	Fisold.close_db
end

def compare_db(driver, path, args, subtree_root = 'Partiture Giacinto Scelsi')
	yaml_filename = create_yaml_filename(path, driver, args)
	fh = File.open(yaml_filename, "w")
	fh.puts(yaml_header(driver))

  open_comparison_dbs(args) { count = compare_with_fisold(subtree_root, fh) }

	$stderr.printf("Le schede da cambiare sono: %d\n", count)

	return yaml_filename
end
