#
# $Id: development.rb 620 2012-10-02 09:50:39Z nicb $
#
# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
#
# NOTE by nicb: I have set the cache to true because there are unsolved
# dependency problems that break the code erratically if classes are not
# cached. While I try to understand what goes on with dependencies, I'll keep
# this to true (and post a ticket on the track server)
#
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

#
# added by nicb: required to do the bootstrap migration
# also added multi-file object directories
#
config.load_paths += %W( #{RAILS_ROOT}/db/migrate/bootstrap )
#
# added by nicb: in order to test that the production environment
# logs properly we run a parallel setup on development. For development, this
# should always be set on :debug, but to test the actual results on
# production, it should be set to :warn
#
config.log_level = :debug # normal development functionality
# config.log_level = :warn  # to test production logging
