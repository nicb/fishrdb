#
# $Id: save_conditioner.rb 13 2007-10-07 03:04:30Z nicb $
#
# This is a module that provides data conditioning for subsequent saves
# it should be a mixin for ActiveRecord classes
#
module SaveConditioner
	def condition_data_for_saving
		counter = Counter.new
		counter.owner_type = Counter.owner_type_id(self.class)
		counter.save
		@_counter_id_ = self.id = counter.id
#		THESE ARE TO BE REMOVED SOON
#		@auth_id = Auth.find(:first, :conditions => ["description = ?", "public"])
#		self.auth_id = @auth_id  # default maximum authority required for conversion
		#
		# this will change in the near future as soon as we have
		# the user table
		#
		self.creator = self.last_modifier = 0 # default creator - to be updated in future versions
	end
end
