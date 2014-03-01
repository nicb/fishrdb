#
# $Id: document_helper.rb 15 2007-10-11 05:42:32Z nicb $
#
#

module DocumentHelper

private

	def initialize(parent, dl, user, arguments = {})
		@parent = parent
		@dl = dl
		@user = user
		super(arguments)
	end

	def create_related_document
		related_doc = Document.new(:content_id => self.id, :content_type => self.class.name,
						   :description_level_id => @dl.id,
						   :creator_id => @user.id, :last_modifier_id => @user.id)
		#
		# if it is the root document, then it should be nil
		#
		related_doc.parent_id = (@parent.class == Document ? @parent.id : @parent.document.id) unless !@parent
		related_doc.save!
		#
		# this gets attached to the 'document' variable in this object
		# but the object itself must be updated
		#
		self.reload
	end

	def update_related_document
		document.update_attributes(:last_modifier_id => @user.id)
	end
end
