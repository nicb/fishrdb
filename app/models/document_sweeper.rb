#
# $Id: document_sweeper.rb 614 2012-05-11 17:25:14Z nicb $
#
# This is needed to expire the cached pages when they are not up-to-date
#

class DocumentSweeper < ActionController::Caching::Sweeper

  observe Document

	def after_create(doc)
    doc.logger.debug("========> DocumentSweeper after_create called for doc: #{doc.id}")
		expire_all(doc)
	end

	def after_update(doc)
    doc.logger.debug("========> DocumentSweeper after_update called for doc: #{doc.id}")
		expire_all(doc)
	end

	def after_destroy(doc)
    doc.logger.debug("========> DocumentSweeper after_destroy called for doc: #{doc.id}")
		expire_all(doc)
	end

private

	def expire_all(doc)
    doc.logger.debug("========> DocumentSweeper#expire_all called for doc: #{doc.id}")
		expire_action(:action => 'doc', :id => doc.id)
		expire_action(:action => 'doc', :id => doc.parent.id) if doc.parent
	end
end
