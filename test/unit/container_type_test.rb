#
# $Id: container_type_test.rb 195 2008-04-13 22:05:42Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class ContainerTypeTest < Test::Unit::TestCase
  fixtures :container_types, :documents

  def setup
  	assert @busta = ContainerType.find(:first, :conditions => ["container_type = ?", "Busta"])
  	assert @scatola = ContainerType.find(:first, :conditions => ["container_type = ?", "Scatola"])
  	assert @no_container = ContainerType.find(:first, :conditions => ["container_type = ?", ''])
  end
  # Replace this with your real tests.
  def test_validity
  	assert @busta.valid?
  	assert @scatola.valid?
  	assert @no_container.valid?
  end
  def test_integrity
    assert_equal	@scatola.container_type, "Scatola"
    assert_equal	@busta.container_type, "Busta"
    assert_equal	@no_container.container_type, ""
  end
  def test_document_association
    assert doc = Document.find(:first, :conditions => ['name like ?', 'Khoom%'])
    assert ct = ContainerType.find(doc.container_type.id)
    found = false
    ct.documents.each do
      |d|
      if d.id == doc.id
        found = true
        break
      end
    end
    assert found, "#{doc.id} not found among ContainerType '#{ct.container_type}'s"
  end
end
