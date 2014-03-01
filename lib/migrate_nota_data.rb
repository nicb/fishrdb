#
# $Id: migrate_nota_data.rb 274 2008-11-14 12:33:47Z nicb $
#
# This script is to migrate the note data which contain date information to
# the appropriate date fields. It is not idempotent, and it should be run only
# once on a given data set.
#

require File.dirname(__FILE__) + '/../app/models/document'

class MigrateNotaData

  def initialize
    @logfh = File.open(File.dirname(__FILE__) + '/../log/migrate_nota_data.log', 'w')
  end

  def log(string)
    @logfh.puts(string)
  end

	def taint_nota_data(nd)
#   return nd + " @@MIGRATED@@"
    return nil
	end
	
	def process_senza_data(d)
	  nd = taint_nota_data(d.nota_data)
	  log(">>>> process_senza_data(#{d.id}, \"#{d.nota_data}\") leads to set the senza_data flag, nota_data=\"#{nd}\"")
	  d.update_attributes!(:senza_data => 'Y', :nota_data => nd)
	end
	
	def process_year_only(d, method)
	  date_hash = { :year => d.send(method).gsub(/^[\[]?/,'').gsub(/[\]]$/,'') }
	  date = ExtDate::Interval.new(date_hash, {}, '--X', '---', '%DD', '%Y')
	  nd = taint_nota_data(d.send(method))
	  log(">>>> process_year_only(#{d.id}, #{method.to_s} =>  \"#{d.send(method)}\") leads to date_hash=#{date_hash.inspect} and date=#{date.inspect}, nota_data=\"#{nd}\"")
	  d.update_attributes!(:date => date, method => nd)
	end
	
	def process_year_range(d)
	  (from, to) = d.nota_data.split('-')
	  dh_from = { :year => from }
	  dh_to = { :year => to }
	  date = ExtDate::Interval.new(dh_from, dh_to, '--X', '--X', '%DD-%DA', '%Y', '%Y')
	  nd = taint_nota_data(d.nota_data)
	  log(">>>> process_year_range(#{d.id}, \"#{d.nota_data}\") leads to dh_from=#{dh_from.inspect}, dh_to=#{dh_to.inspect} and date=#{date.inspect}, nota_data=\"#{nd}\"")
	  d.update_attributes!(:date => date, :nota_data => nd)
	end
	
	def process_year_w_month(d)
	  months = {
	    'gen.' => 1, 'feb.' => 2, 'mar.' => 3, 'apr.' => 4, 'mag.' => 5, 'giu.' => 6,
	    'lug.' => 7, 'ago.' => 8, 'set.' => 9, 'ott.' => 10, 'nov.' => 11, 'dic.' => 12,
	  }
	  (y, m) = d.nota_data.split(/,\s+/)
	  dh_from = { :year => y, :month => months[m] }
	  date = ExtDate::Interval.new(dh_from, {}, '-XX', '---', '%DD', '%m/%Y')
	  nd = taint_nota_data(d.nota_data)
	  log(">>>> process_year_w_month(#{d.id}, \"#{d.nota_data}\") leads to date_hash=#{dh_from.inspect} and date=#{date.inspect}, nota_data=\"#{nd}\"")
	  d.update_attributes!(:date => date, :nota_data => nd)
	end
	
	def leave_unprocessed(d, method)
	  log(">>>> leave_unprocessed(#{d.id}, #{method.to_s} => \"#{d.send(method)}\") called")
	end
	
	def parse_nota_data(doc)
	
	  case doc.nota_data
	    when "s.d." :  process_senza_data(doc)
	    when /^[\[]?\d{4}[\]]?$/ : process_year_only(doc, :nota_data)
	    when /^\d{4}-\d{4}$/ : process_year_range(doc)
	    when /^\d{4}, \w{3}\.$/: process_year_w_month(doc)
	    else
	      leave_unprocessed(doc, :nota_data)
	  end
	
	end

  def parse_dates(doc)
    ifmt_fields = []
    if doc.data_dal
      if doc.data_dal.month == 1 && doc.data_dal.day == 1
	      dfips = '--X'
	      ffmt = '%Y'
      else
	      dfips = 'XXX'
	      ffmt = '%d/%m/%Y'
      end
	    ifmt_fields << '%DD'
    else
      dfips = '---'
      ffmt = ''
    end
    if doc.data_al
      if doc.data_al.month == 12 && doc.data_al.day == 31
        dtips = '--X'
        tfmt = '%Y'
      else
        dtips = 'XXX'
        tfmt = '%d/%m/%Y'
      end
      ifmt_fields << '%DA'
    else
      dtips = '---'
      tfmt = ''
    end
    ifmt = ifmt_fields.join('-')
    date = ExtDate::Interval.new(doc.data_dal, doc.data_al, dfips, dtips, ifmt, ffmt, tfmt)
	  log(">>>> parse_dates(#{doc.id}, #{doc.data_dal.to_s}, #{doc.data_al.to_s}) leads to date=#{date.inspect}")
	  doc.update_attributes!(:date => date)
  end

  def parse_data_topica(doc)

	  case doc.data_topica
	    when /^[\[]?\d{4}[\]]?$/ : process_year_only(doc, :data_topica)
	    else
	      leave_unprocessed(doc, :data_topica)
	  end

  end
	
	def process_nota_data
	  docs = Document.find(:all, :conditions => ["nota_data is not null and nota_data != ''"])
	  docs.each { |d| parse_nota_data(d) }
	end 

  def process_dates
	  docs = Document.find(:all, :conditions => ["data_dal is not null or data_al is not null"])
    docs.each { |d| parse_dates(d) }
  end

  def process_data_topica
	  docs = Document.find(:all, :conditions => ["data_topica is not null and data_topica != ''"])
    docs.each { |d| parse_data_topica(d) }
  end

  def process
    process_dates
    process_nota_data
  end

end
