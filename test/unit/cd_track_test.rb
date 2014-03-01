#
# $Id: cd_track_test.rb 617 2012-07-15 16:30:06Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class CdTrackTest < ActiveSupport::TestCase

  include Test::Utilities

  fixtures :container_types, :users, :cd_tracks, :documents, :names, :instruments, :performers, :ensembles

  def setup
    assert @u = users(:staffbob)
    assert @cd_track_record = documents(:action_music_n_1_ctr)
    assert @cd_track_record_2 = documents(:action_music_n_2_ctr)
    assert @author = names(:gs)
    assert @performer = performers(:wambach_p)
    assert @performer_2 = performers(:tallini_p)
    assert @conductor = names(:dessy)
    assert @conductor_2 = names(:rundel)
    assert @conductor_3 = names(:salonen)
    assert @instrument = instruments(:piano)
    assert @instrument_2 = instruments(:celesta)
    assert @instrument_3 = instruments(:chitarra)
    assert @ensemble = ensembles(:wallonie)
    assert @ensemble_2 = ensembles(:modern)
    assert @dur = Time.local(0, 1, 1, (rand * 2).floor, (rand * 60).floor, (rand * 60).floor)
    assert @args = { :cd_track_record => @cd_track_record, :duration => @dur, :for => 'Pianoforte' }
    assert @c_args = { :creator_id => @u.id, :last_modifier_id => @u.id }
  end

  def test_create_and_destroy
    assert cdi = CdTrack.create(@args)
    assert cdi.valid?
    #
    cdi.destroy
    assert cdi.frozen?
    #
    assert cdi = CdTrack.create(@args)
    @cd_track_record.destroy
    assert @cd_track_record.frozen?
    assert_raise(ActiveRecord::RecordNotFound) { cdi.reload }
  end

  def test_validations
    [:cd_track_record].each do
      |nv|
      args_not_valid = @args.dup
      args_not_valid.delete(nv)
      assert cdi = CdTrack.create(args_not_valid)
      assert !cdi.valid?
    end
  end

  def perform_association(method, sub_method, args)
    proxy_method =  method.to_s =~ /^cd_track_/ ? method : ('cd_track_' + method.to_s).intern
    assert cdt = CdTrack.create(@args)
    assert cdt.valid?
    assert cdt.send(method).send(sub_method, args)
    assert_equal 1, cdt.send(proxy_method, true).size
    assert_equal 1, cdt.send(method, true).size
    assert cdt.send(method).first.valid?
    yield(cdt)
    #
    # all others must be blank
    #
    [:authors, :performers, :ensembles].each do
      |m|
      assert_equal 0, cdt.send(m, true).size unless m == method
    end
  end

  def test_author_association
    perform_association(:authors, :<<, @author) do
      |cdt|
      assert_equal @author, cdt.authors.first
    end
  end

  def test_performer_association
    perform_association(:performers, :<<, @performer) do
      |cdt|
      assert_equal @performer, cdt.performers.first
      assert_equal @performer.name, cdt.performers.first.name
      assert_equal @instrument, cdt.performers.first.instrument
    end
  end

  def test_ensemble_association_with_conductor
    perform_association(:ensembles, :<<, @ensemble) do
      |cdt|
      assert_equal @ensemble, cdt.ensembles.first
      assert_equal @conductor, cdt.ensembles.first.conductor
    end
  end

  def test_ensemble_association_without_conductor
    assert ewoc = Ensemble.find_or_create({ :name => random_string }, @c_args)
    perform_association(:ensembles, :<<, ewoc) do
      |cdt|
      assert_equal ewoc, cdt.ensembles.first
      assert_nil cdt.ensembles.first.conductor
    end
  end

  def test_multiple_conductor_associations_with_an_ensemble
    assert e1 = Ensemble.find_or_create({ :name => @ensemble.name, :conductor_id => @conductor.id }, @c_args)
    assert e2 = Ensemble.find_or_create({ :name => @ensemble_2.name, :conductor_id => @conductor_3.id }, @c_args)
    assert e3 = Ensemble.find_or_create({ :name => @ensemble.name, :conductor_id => @conductor_2.id }, @c_args)
    assert @cd_track_record.ensembles << e1
    assert @cd_track_record.ensembles << e2
    assert @cd_track_record_2.ensembles << e3
    [@cd_track_record, @cd_track_record_2].each do
      |cdtr|
      cdtr.ensembles.each do
        |cdte|
        assert cdte
        assert cdte.valid?
        assert cdte.conductor
        assert cdte.conductor.valid?
      end
    end
    [@conductor, @conductor_3].each_with_index do
      |cnd, i|
      assert_equal cnd, @cd_track_record.ensembles[i].conductor
    end
    assert_equal @conductor_2, @cd_track_record_2.ensembles.first.conductor
    [e1, e2].each_with_index do
      |e, i|
      assert_equal e, @cd_track_record.ensembles[i]
    end
    assert_equal e3, @cd_track_record_2.ensembles.first
  end

  def test_multiple_performer_associations
    assert p1 = Performer.find_or_create(:name_id => @performer.name.id, :instrument_id => @instrument.id, :creator_id => @u.id, :last_modifier_id => @u.id)
    assert p2 = Performer.find_or_create(:name_id => @performer.name.id, :instrument_id => @instrument_2.id, :creator_id => @u.id, :last_modifier_id => @u.id)
    assert p3 = Performer.find_or_create(:name_id => @performer.name.id, :instrument_id => @instrument_3.id, :creator_id => @u.id, :last_modifier_id => @u.id)
    assert @cd_track_record.performers << p1
    assert @cd_track_record.performers << p2
    assert @cd_track_record_2.performers << p3
    [p1, p2].each_with_index do
      |p, idx|
      assert @cd_track_record.performers[idx].name
      assert @cd_track_record.performers[idx].name.valid?
      assert @cd_track_record.performers[idx].instrument
      assert @cd_track_record.performers[idx].instrument.valid?
      assert_equal p, @cd_track_record.performers[idx]
      assert_equal p.name, @cd_track_record.performers[idx].name
      assert_equal p.instrument, @cd_track_record.performers[idx].instrument
    end
    assert_equal p3, @cd_track_record_2.performers[0]
    assert_equal p3.name, @cd_track_record_2.performers[0].name
    assert_equal p3.instrument, @cd_track_record_2.performers[0].instrument
  end

  def test_duration
    assert_equal @dur, @args[:duration]
    assert s_dur = [@dur.hour, @dur.min, @dur.sec].map { |t| sprintf("%02d", t) }.conditional_join(':')
    assert cdt = CdTrack.create(@args)
    assert cdt.valid?
    assert_equal s_dur, cdt.duration
  end

  def test_display_players
    names = []
    instruments = []
    performers = []
    ensembles = []
    0.upto(2) do
      assert names << Name.find_or_create({ :last_name => random_string, :first_name => random_string }, @c_args)
      assert names.last.valid?
      assert instruments << Instrument.find_or_create({ :name => random_string }, @c_args)
      assert instruments.last.valid?
      assert performers << Performer.find_or_create({ :name_id => names.last.id, :instrument_id => instruments.last.id }, @c_args)
      assert performers.last.valid?
    end
    assert ensembles << Ensemble.find_or_create({ :name => random_string, :conductor_id => names.last.id }, @c_args) 
    assert ensembles.last.valid?
    performers[0..1].each { |p| assert @cd_track_record.performers << p }
    assert @cd_track_record.ensembles << ensembles.last
    should_be_array = []
    performers[0..1].each do
      |p|
      should_be_array << (p.name.first_name + ' ' + p.name.last_name + ', ' + p.instrument.name)
    end
    should_be = should_be_array.conditional_join('; ')
    should_be += ('; ' + ensembles.last.name + ', direttore ' + ensembles.last.conductor.first_name + ' ' + ensembles.last.conductor.last_name)
    assert_equal should_be, @cd_track_record.display_players
  end

end
