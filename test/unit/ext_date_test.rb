#
# $Id: ext_date_test.rb 618 2012-09-23 04:40:09Z nicb $
#
# ExtDate is an aggregation, not an ActiveRecord per se
#
require File.dirname(__FILE__) + '/../test_helper'

class ExtDateTest < ActiveSupport::TestCase

	fixtures	:container_types, :documents, :users

  def test_ext_date
    assert d = ExtDate::Base.new('2008-10-18', '--X')
    assert_equal d.to_display, '2008'
    assert d = ExtDate::Base.new('2008-10-18', '-XX', '%m/%Y')
    assert_equal d.to_display, '10/2008'
    assert d = ExtDate::Base.new({ :year => 2008 }, 'XXX', '==%m:%d:%Y==')
    assert_equal d.to_display, '==01:01:2008=='
    assert d = ExtDate::Base.new({ :year => '2008', :day => '18', :month => '10' }, 'XXX', '==%m:%d:%Y==')
    assert_equal d.to_display, '==10:18:2008=='
    assert_equal d.day, 18
    assert_equal d.month, 10
    assert_equal d.year, 2008
    assert d = ExtDate::From.new({ :year => 2008 }, 'XXX', '==%m:%d:%Y==')
    assert_equal d.to_display, '==01:01:2008=='
    assert d = ExtDate::To.new({ :year => 2008 }, 'XXX', '==%m:%d:%Y==')
    assert_equal '==12:31:2008==', d.to_display
  end

  def test_ext_year
    assert d = ExtDate::Year.new('2008')
    assert_equal '2008', d.to_display
    assert_equal d.to_date.strftime('%d-%m-%Y'),'01-01-2008'
  end

  def test_ext_interval
    assert di = ExtDate::Interval.new({ :year => 2008}, nil, '--X', '---', '%DD', '%Y')
    assert_equal di.to_display, '2008'
    assert di = ExtDate::Interval.new({ :year => '1988'}, { :year => '2008'}, '--X', '--X', 'dal %DD al %DA', '%Y', '%Y')
    assert_equal di.to_display, 'dal 1988 al 2008'
    assert di = ExtDate::Interval.new({ :year => '1988', :month => '08', :day => '09'},
                                   { :year => '2008', :month => '10', :day => '18'},
                                   'XXX', 'XXX',
                                   'dal %DD al %DA', '%a %d %b %Y', '%A %d %B %Y')
    assert_equal di.to_display, 'dal Tue 09 Aug 1988 al Saturday 18 October 2008'
    assert di = ExtDate::Interval.new({ :year => '1988' }, { :year => '2008' },
                                         '--X', '--X',
                                   'dal %DD al %DA', '%d %b %Y', '%d %B %Y')
    assert_equal 'dal 01 Jan 1988 al 31 December 2008', di.to_display
  end

  def test_input_parameter_mapping
    dh = { :year => '2008' }
    assert d = ExtDate::Base.new(dh, '--X')
    assert_equal d.input_parameters, '--X'
    assert d.year_was_set?
    assert !d.day_was_set?
    assert !d.month_was_set?
    #
    dh[:month] = '10'
    assert d = ExtDate::Base.new(dh, '-XX')
    assert_equal d.input_parameters, '-XX'
    assert d.year_was_set?
    assert !d.day_was_set?
    assert d.month_was_set?
    #
    dh[:day] = '20'
    assert d = ExtDate::Base.new(dh, 'XXX')
    assert_equal d.input_parameters, 'XXX'
    assert d.year_was_set?
    assert d.day_was_set?
    assert d.month_was_set?
  end

  def test_empty_creation
    assert dso = ExtDate::Base.default_date_select_options
    dso[:prefix] = 'test'
    dso[:disabled] = false
    assert db = ExtDate::Base.new
    assert_nil db.to_date
    assert_equal dso, db.date_select_options('test')
    assert_nil db.day
    assert_nil db.month
    assert_nil db.year
    assert df = ExtDate::From.new
    assert_nil df.to_date
    assert_equal dso, df.date_select_options('test')
    assert dt = ExtDate::To.new
    assert_nil dt.to_date
    assert_equal dso, dt.date_select_options('test')
    assert dy = ExtDate::Year.new
    assert_nil dy.to_date
    assert di = ExtDate::Interval.new
    assert_nil di.to_date_from
    assert_nil di.to_date_to
    assert_equal dso, di.date_from.date_select_options('test')
    assert_equal dso, di.date_to.date_select_options('test')
    #
    # test with empty hashes
    #
    assert di = ExtDate::Interval.new({}, {}, '---', '---')
    assert_nil di.to_date_from
    assert_nil di.to_date_to
    assert_equal dso, di.date_from.date_select_options('test')
    assert_equal dso, di.date_to.date_select_options('test')
    #
    assert di = ExtDate::Interval.new({:year => '1988'}, {}, '--X', '---')
    assert_equal di.to_date_from, Date.new(1988, 01, 01)
    assert_nil di.to_date_to
    assert_equal dso, di.date_to.date_select_options('test')
    #
    # test with empty values
    #
    empty_hash = {:year => '', :month => '', :day => ''}
    assert di = ExtDate::Interval.new(empty_hash, empty_hash, '---', '---')
    assert_nil di.to_date_from
    assert_nil di.to_date_to
    assert_equal dso, di.date_from.date_select_options('test')
    assert_equal dso, di.date_to.date_select_options('test')
  end

  def test_default_date_format
    dh = {}
    assert db = ExtDate::Base.new(dh)
    assert_equal db.default_date_format, ''
    dh[:year] = '2008'
    assert db = ExtDate::Base.new(dh, '--X')
    assert_equal db.default_date_format, '%Y'
    dh[:month] = '10'
    assert db = ExtDate::Base.new(dh, '-XX')
    assert_equal db.default_date_format, '%m/%Y'
    dh[:day] = '1'
    assert db = ExtDate::Base.new(dh, 'XXX')
    assert_equal db.default_date_format, '%d/%m/%Y'
  end

  def test_date_format
    dh = {}
    assert db = ExtDate::Base.new(dh)
    assert_equal db.date_format, ''
    fmt = 'ciao ciao'
    assert db = ExtDate::Base.new(dh, '---', fmt)
    assert_equal db.date_format, fmt
    dh[:year] = '2008'
    assert db = ExtDate::Base.new(dh, '--X')
    assert_equal db.date_format, '%Y'
    fmt = "l'anno e` il %Y"
    assert db = ExtDate::Base.new(dh, '--X', fmt)
    assert_equal db.date_format, fmt
    assert_equal db.to_display, "l'anno e` il 2008"
    dh[:month] = '10'
    assert db = ExtDate::Base.new(dh, '-XX')
    assert_equal db.date_format, '%m/%Y'
    fmt = "intorno al %m/%Y"
    assert db = ExtDate::Base.new(dh, '-XX', fmt)
    assert_equal db.date_format, fmt
    assert_equal db.to_display, "intorno al 10/2008"
    dh[:day] = '1'
    assert db = ExtDate::Base.new(dh, 'XXX')
    assert_equal db.date_format, '%d/%m/%Y'
    fmt = "la data e` il %d/%m/%Y"
    assert db = ExtDate::Base.new(dh, 'XXX', fmt)
    assert_equal db.date_format, fmt
    assert_equal db.to_display, "la data e` il 01/10/2008"
  end

  def test_aggregation_methods
    assert di = ExtDate::Interval.new({:year => '1988', :month => '08', :day => '09'},
                                         {:year => '2008'}, 'XXX', '--X', '%DD-%DA', '%d/%m/%Y', '%Y')
    assert_equal 'XXX', di.dfips
    assert_equal '--X', di.dtips
    assert_equal '%d/%m/%Y', di.from_format
    assert_equal '%Y', di.to_format
  end

  def test_save_to_db_and_recover_within_a_document
    assert doc = Series.find_by_name('Archivio Privato')
    assert di = ExtDate::Interval.new({:year => '1988', :month => '08', :day => '09'},
                                         {:year => '2008'}, 'XXX', '--X', '%DD-%DA', '%d/%m/%Y', '%Y')
    assert_equal '09/08/1988-2008', di.to_display
    assert doc.update_attributes!(:date => di)
    doc.reload
    assert_equal '09/08/1988-2008', doc.date.to_display
  end

  def test_save_to_db_and_recover_within_a_document
    assert u = User.authenticate('staffbob', 'testtest')
    assert ref_doc = documents(:fondo_FIS)
		assert ref_doc.valid?
    assert dl = ref_doc.description_level
    assert ct = ref_doc.container_type
    assert df_hash = {:year => 1988, :month => 8, :day => 9}
    assert dt_hash = {:year => 2008}
    assert di = ExtDate::Interval.new(df_hash, dt_hash, 'XXX', '--X', '%DD-%DA', '%d/%m/%Y', '%Y')
    assert doc = Series.new(:name => 'test save to db and recover within a document for dates',
                            :description_level_id => dl.id, :container_type => ct,
                            :creator_id => u.id, :last_modifier_id => u.id,
                            :date => di)
    assert_equal '1988-08-09', doc.data_dal.to_s
    assert_equal '2008-12-31', doc.data_al.to_s
    assert_equal '09/08/1988-2008', doc.date.to_display
    assert_equal '09/08/1988', doc.date.date_from.to_display
    assert_equal '2008', doc.date.date_to.to_display
    assert_equal 'XXX', doc.date.date_from.input_parameters
    assert_equal '--X', doc.date.date_to.input_parameters
    assert doc.save
    assert doc.valid?
    assert newdoc = Series.find(doc.id)
    assert_equal '1988-08-09', newdoc.data_dal.to_s
    assert_equal '2008-12-31', newdoc.data_al.to_s
    assert_equal '09/08/1988-2008', newdoc.date.to_display
    assert_equal '09/08/1988', newdoc.date.date_from.to_display
    assert_equal '2008', newdoc.date.date_to.to_display
    assert_equal 'XXX', newdoc.date.date_from.input_parameters
    assert_equal '--X', newdoc.date.date_to.input_parameters
  end

  def test_date_to_incomplete_date_creation
    assert di = ExtDate::Interval.new({}, { :month => 2, :year => 2001 }, '---', '-XX', '%DA', '', '%m/%Y')
    assert_equal '-XX', di.date_to.input_parameters
    assert_equal '02/2001', di.to_display
  end

end
