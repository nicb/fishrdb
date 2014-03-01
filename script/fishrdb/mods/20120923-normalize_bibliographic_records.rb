#
# $Id: 20120923-normalize_bibliographic_records.rb 630 2012-12-20 22:27:51Z nicb $
#
RAILS_ROOT = File.join(File.dirname(__FILE__), ['..'] * 3)
require File.join(RAILS_ROOT, 'config', 'environment')
require 'lib/debugger'

require 'singleton'

#
# This is what this script is supposed to do:
# 
# - Run through all bibliographic records (under
#   'Fondo Fondazione Isabella Scelsi' => 'Bibliografia')
# - three levels are supposed to be under 'Bibliografia':
#   'Scritti di Giacinto Scelsi' (pos.1), 'Bibliografia su Giacinto Scelsi'
#   (pos.2), 'Biblioteca' (pos.3)
# - each of these levels has children who might have other children, so:
#   - two sub-levels must be created for each of these levels: 'Monografie'
#     and 'Periodici'
#   - the ones who don't have children should go under 'Monografie'
#   - the ones who do have children should go under 'Periodici'
# - check if they are BibliographicRecord types
# - if they are not, transform them in BibliographicRecord types
# - collect all the records with the same .name (basically, journals)
#   under a single parent which will then have several numbers underneath
#   titled as the note
# - possibly reorder them using the by_author order which should in our case
#   default to 'author_last_name, editor_last_name, title, volume, date'
#
def find_bootstrap_user
	user = 'bootstrap'
	res = User.find_by_login(user)
	raise RuntimeError, "Invalid user #{user}: #{res.errors.full_time.join(', ')}" unless res.valid?
	res
end

u = find_bootstrap_user
ct = ContainerType.find_by_container_type('')
raise RuntimeError, "Invalid container type: #{ct.errors.full_time.join(', ')}" unless ct.valid?

bibroot = Folder.find_by_name('Bibliografia')
raise RuntimeError, "Cannot find \"Bibliografia\" folder" unless bibroot && bibroot.valid?

#
# FIRST PASS:
# 
# - for each first-level subdir:
#   - make sure the positioning is right
#   - create 'Monografie' and 'Periodici' sub-folders
#   - reparent children under one of those folders depending on whether they
#     have children or not
#
CORRECT_1st_lev_POSITION = { 'Scritti di Giacinto Scelsi' => 1, 'Bibliografia su Giacinto Scelsi' => 2, 'Biblioteca' => 3 }
common_attrs = { :creator => u, :last_modifier => u, :container_type => ContainerType.default_container_type, :bibliographic_data => {}, }
bibroot.children(true).each do
  |subroot|
	#
	# make sure position is right
	#
	correct_position = CORRECT_1st_lev_POSITION[subroot.name]
	raise RuntimeError, "Wrong positioning for subroot #{subroot.name} (perhaps the key is invalid? [keys are #{CORRECT_1st_lev_POSITION.keys.join(', ')}])" unless correct_position
	subroot.update_attributes!(:position => correct_position)
	subroot.reload
	#
	# now create subtrees
	#
  previous_children = subroot.children(true)
  args = common_attrs.dup
  dl = subroot.description_level + 1
  args.update(:description_level_id => dl.id, :parent => subroot)
  args.update(:name => 'Monografie', :position => 1)
  mono = BibliographicRecord.create_from_form(args)
  raise ActiveRecord::InvalidRecord.new(mono) unless mono && mono.valid?
  args.update(:name => 'Periodici', :position => 2)
  perio = BibliographicRecord.create_from_form(args)
  raise ActiveRecord::InvalidRecord.new(perio) unless perio && perio.valid?
  previous_children.each do
    |child|
    if child.children(true).size > 0
      child.reparent_me(perio)
    else
      child.reparent_me(mono)
    end
  end
end

#
# SECOND PASS:
#
# - migrate all Series objects to BibliographicRecord ones, preserving data
# - you should also make sure that these objects have children and are under a
#   'Periodici' sub-tree, otherwise move them under 'Monografie'
# - collect all records with the same name under a single record and
#   substitute their name with whatever is in the notes
#

class MapArg
  
  attr_reader :ref, :src_key, :dest_key, :proc

  def initialize(doc, sk, dk, p)
    @ref = doc
    @src_key = sk
    @dest_key = dk
    @proc = p
  end

  def map
    res = {}
    res = { self.dest_key => self.proc.call(self.ref.send(self.src_key)) } unless self.ref.send(self.src_key).blank?
    res
  end

	class << self

		def map_args
		end

	end

end

class BRCache

  include Singleton

  attr_reader :cache
  attr_accessor :count

  def initialize
    @count = 0
    @cache = {}
  end

  def add(args_obj)
		key = args_obj.input_doc.name.strip.downcase.gsub(/[àéèìòùüö]/,'_')
		unless self.cache.has_key?(key)
			self.cache[key] = []
			puts("Creating new cache key \"#{key}\" for object \"#{args_obj.input_doc.name}")
		else
			puts("Adding object \"#{args_obj.input_doc.name} to cache key \"#{key}\"")
		end
    self.cache[key] << args_obj
    self.count += 1 if args_obj.input_doc.class.name != 'BibliographicRecord'
  end

  def transfer
		self.cache.keys.each do
			|key|
			key_sz = self.cache[key].size
			if key_sz > 1
				u = find_bootstrap_user
				refdoc = self.cache[key].first.input_doc
				new_parent = BibliographicRecord.create(:name => refdoc.name, :parent => refdoc.parent,
						:description_level_id => refdoc.description_level_id,
						:container_type_id => refdoc.container_type_id,
						:creator => u, :last_modifier => u,
				    :public_visibility => refdoc.public_visibility,
						:public_access => refdoc.public_access)
				new_bd = BibliographicData.create(:bibliographic_record => new_parent)
				raise ActiveRecord::RecordInvalid.new(new_bd) unless new_bd && new_bd.valid?
				raise ActiveRecord::RecordInvalid.new(new_parent) unless new_parent && new_parent.valid? && new_parent.bibliographic_data
				self.cache[key].each do
					|obj|
					new_name = create_name_for(obj)
					d_id = (new_parent.description_level + 1).id 
					changed_options = { :name => new_name, :parent_id => new_parent.id,
						:description_level_id => d_id }
					do_transfer(obj, changed_options)
				end
			else
				do_transfer(self.cache[key].first)
			end
		end
  end

private

	def do_transfer(obj, options = {})
		res = obj.transfer(options)
		#
		# after transferring do check that all children have been transferred
		# properly
		#
	  raise RuntimeError, "BRCache#transfer: In/Out number of children mismatch (#{obj.num_children} != #{obj.output_doc.children(true).size} - cached record n.#{idx}: #{obj.output_doc.inspect})" unless obj.num_children == obj.output_doc.children(true).size
		res
	end

	def create_name_for(obj)
		volnumber = obj.input_doc.note.sub(/^n\./, '')
		vols = volnumber ? volnumber.split('/') : [volnumber]
		volstring = nil
		if vols.size == 1
			volstring = vols.first ? "Volume n. %03d" % vols.first : "Volume ---"
		else
			volstring_pfx = "Voll. "
			volstring_body = vols.join(', ')
			volstring = [volstring_pfx, volstring_body].join(', ')
		end
		volstring
	end

end

class BRArgs

  SERIES_MAP =
  {
    :name_prefix => :name_prefix,
    :name => :name,
    :parent_id => :parent_id,
		:position => :position,
    :nota_data => :nota_data,
    :container_type_id => :container_type_id,
    :description_level_id => :description_level_id,
    :creator_id => :creator_id,
    :last_modifier_id => :last_modifier_id,
    :public_visibility => :public_visibility,
    :public_access => :public_access,
    :quantity => :quantity,
    :note     => :note,
    :description => :description,
    :full_date_format => :full_date_format,
    :data_topica => :data_topica,
    :container_number => :container_number,
    :corda => :corda,
    :corda_alpha => :corda_alpha,
    :consistenza => :consistenza,
  }

  attr_reader :input_doc, :num_children, :output_doc

  def initialize(d)
    @input_doc = d
		@num_children = self.input_doc.children(true).size
		@output_doc = nil
  end

	#
	# +transfer(options = {}):
	#
	# - if it's a +BibliographicRecord+ it is simply copied to the output as is
	# - otherwise it must be a 'Series', and it gets transformed
	#
  def transfer(options = {})
    if self.input_doc.class.name == 'BibliographicRecord'
			self.input_doc.reload
			self.input_doc.update_attributes!(options) unless options.empty?
			res = self.input_doc
			res.reload
		else
      raise RuntimeError, "class is not a Series, aborting\n" unless self.input_doc.class.name == 'Series'
      doc_args = map_args(options)
      res = BibliographicRecord.create_from_form(doc_args)
      raise ActiveRecord::InvalidRecord.new(res) unless res.valid?
      self.input_doc.children.each do
  			|c|
  			c.reparent_me(res)
  			c.save!
  		end
  		nchildren_out = res.children(true).size
  		raise RuntimeError, "BRArgs#transfer: In document children are not zero after transfer" unless self.input_doc.children(true).size == 0
      self.input_doc.destroy
      raise RuntimeError, "Old Series record \"#{self.input_doc.name}\" was not destroyed" unless self.input_doc.frozen?
      @input_doc = nil # the procedure should *not* be idempotent
  		raise RuntimeError, "BRArgs#transfer: In/Out number of children mismatch (#{self.num_children} != #{nchildren_out} - new record: #{res.inspect})" unless nchildren_out == self.num_children
		end
		dl = res.no_children? ? DescriptionLevel.unita_documentaria : (res.parent.description_level + 1)
		res.update_attributes!(:description_level_id => dl.id)
 		@output_doc = res
  end

private

  def map_args(options = {})
    doc_res = {}
    SERIES_MAP.each { |from, to| doc_res.update(to => self.input_doc.send(from)) }
    bib_res = condition_arguments(
              [
                MapArg.new(self.input_doc, :note, :volume, Proc.new { |note| note.sub(/^n\./, '') }),
                MapArg.new(self.input_doc, :full_date_format, :publishing_date, Proc.new { |fdf| parse_date(fdf) }),
              ])
    doc_res.update(:bibliographic_data => bib_res)
		doc_res.update(options)
    doc_res
  end

  def parse_date(date_string)
    res = {}
    #
    # There's nothing we can do about idiotic string input like '2005-2007',
    # so in such cases we just get rid of the end term
    #
    sensible_date_string = date_string.split(/-/).first
    date_array = sensible_date_string.split(/\//)
    res = case date_array.size
          when 1 then { :year => date_array[0] }
          when 2 then { :month => date_array[0], :year => date_array[1] }
          when 3 then { :day => date_array[0], :month => date_array[1], :year => date_array[2] }
          else
            raise(ArgumentError, "Unable to parse date string #{date_string}")
          end
    res
  end

  def condition_arguments(args_to_check)
    args = {}
    args_to_check.each do
      |arg|
      args.update(arg.map)
    end
    args
  end

end

#
# the bibliographic records are three levels below
#
#
bibroot.children(true).each do # Scritti di, Scritti su, Biblioteca
  |subroot|
  mono = subroot.children.find_by_name('Monografie')
  perio = subroot.children.find_by_name('Periodici')
  perio.children(true).each do # the actual children
    |br|
    raise RuntimeError, "Record #{br.name} is under the wrong parent! (#{br.parent.name}) Aborting." unless br.parent.name == 'Periodici'
    unless br.children(true).size > 0
      puts("Record #{br.name} has no children! Reparenting to Monografie.")
      br.reparent_me(mono)
    end
    puts("\"#{br.name}\": '#{br.class.name}' => 'BibliographicRecord'") unless br.class.name == 'BibliographicRecord'
    bra = BRArgs.new(br)
    BRCache.instance.add(bra)
  end
end
puts("#{BRCache.instance.count} records requiring change were found")

BRCache.instance.transfer

def reorder_my_children(parent)
  parent.children(true).each do
    |child|
    reorder_my_children(child)
  end
	parent.children.reload
  parent.reorder_children(:author)
end

#
# We do not reorder the first two levels which are ok as they are
#
puts("now reordering children...")
bibroot.children(true).each do
	|l1|
	l1.children(true).each do
		|l2|
		reorder_my_children(l2) unless l2.children(true).size < 1
	end
end

#
# THIRD PASS:
#
# - run the renumber_children_cordas method on all bibroot children instances
#
def number_cordas_on_children(parent)
  parent.children(true).each do
    |child|
    number_cordas_on_children(child)
  end
	parent.children.reload
  parent.renumber_children_cordas
end

puts("now renumbering children cordas...")
number_cordas_on_children(bibroot)

exit(0)
