#
# $Id: cd_importer_test.rb 599 2011-01-05 01:04:07Z nicb $
#
require 'test/test_helper'

require 'cd_importer'

class CdImporterTest < ActiveSupport::TestCase

  fixtures :container_types, :users, :sessions, :documents

  def setup
    make_sure_cd_tree_is_clean
  end

  def test_import
    assert cdw = CdImporter::Wrapper.new
    assert cdr = cdw.import
    assert_equal CdRecord.cd_root, cdr
    assert_equal 'Fondazione Isabella Scelsi', cdr.parent.name
    assert_equal Document.fishrdb_root, cdr.parent.parent
    search_for_authorities
  end

private

  def search_for_authorities
    assert cdr = CdRecord.cd_root
    assert cdr.valid?
    traverse_tree(cdr) do
      |r|
      case r.class.name
      when 'CdRecord' : check_cd_record_authorities(r)
      when 'CdTrackRecord' : check_cd_track_record_authorities(r)
      end
    end
  end

  def traverse_tree(r, &block)
    yield(r)
    unless r.children(true).blank?
      r.children.each do
        |c|
        traverse_tree(c, &block)
      end
    end
  end

  def check_cd_record_authorities(r)
    r.cd_data.booklet_authors(true).each do
      |ba|
      assert ar = PersonName.find_by_name_and_first_name(ba.last_name, ba.first_name)
      assert ar.valid?
      check_ard_link(ar, r)
    end
  end

  def check_cd_track_record_authorities(r)
    assert ar = ScoreTitle.find_by_name(r.name), "ScoreTitle Authority missing for track \"#{r.name}\" in record \"#{r.parent.name}\""
    r.authors(true).each do
      |n|
      m = :authors
      assert n
      assert n.valid?
      assert ar = PersonName.find_by_name_and_first_name(n.last_name, n.first_name), "PersonName Authority missing for #{m.to_s.singularize} #{n.last_name}, #{n.first_name}"
      assert ar.valid?, "PersonName Authority invalid for #{m.to_s.singularize} #{n.last_name}, #{n.first_name}"
      check_ard_link(ar, r)
    end
    r.performers(true).each do
      |p|
      m = :performers
      assert p
      assert p.valid?
      assert n = p.name
      assert n.valid?
      assert ar = PersonName.find_by_name_and_first_name(n.last_name, n.first_name), "PersonName Authority missing for #{m.to_s.singularize} #{n.last_name}, #{n.first_name}"
      assert ar.valid?, "PersonName Authority invalid for #{m.to_s.singularize} #{n.last_name}, #{n.first_name}"
      check_ard_link(ar, r)
    end
    r.ensembles(true).each do
      |e|
      assert e
      assert e.valid?
      c = e.conductor
	    assert ar = CollectiveName.find_by_name(e.name), "CollectiveName Authority missing for ensemble #{e.name}"
	    assert ar.valid?, "CollectiveName Authority invalid for ensemble #{e.name}"
      check_ard_link(ar, r)
      if c
	      assert ar = PersonName.find_by_name_and_first_name(c.last_name, c.first_name), "PersonName Authority missing for conductor #{c.last_name}, #{c.first_name}"
	      assert ar.valid?, "PersonName Authority invalid for conductor #{c.last_name}, #{c.first_name}"
        check_ard_link(ar, r)
      end
    end
  end

  def check_ard_link(ar, doc)
   assert ard = ArdReference.find_by_authority_record_id_and_document_id(ar.id, doc.id), "#{ard.class.name} reference not found between #{ar.class.name}##{ar.name} and #{doc.class.name}##{doc.name}"
   assert ard.valid?, "Invalid #{ard.class.name} reference between #{ar.class.name}.#{ar.name} and #{doc.class.name}##{doc.name}"
  end

  def make_sure_cd_tree_is_clean
    assert cdr = CdRecord.cd_root
    cdr.children(true).each do
      |c|
      assert c.delete_from_form
      assert c.frozen?
    end
    assert cdr.reload
    assert_equal 0, cdr.children(true).size
  end

end
