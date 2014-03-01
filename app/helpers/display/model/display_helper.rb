#
# $Id: display_helper.rb 343 2009-03-22 22:57:05Z nicb $
#

require 'array_extensions'

module Display
	module Model
		module DisplayHelper

		private
			
			def force_typecasting
				#
				# CRUDE HACK: since the attribute-related methods are not present
				# until we do an explicit call to at least one of them (they're not
				# even raw - no typecasting can be performed - to be
				# investigated), we do an extra call before starting the round
				#
				dummy = self.name
			end

			#
			# common_display_fields: general display function
			#
			# the rules to display fields are as follow:
			#
			# -	if a method returns *false* then it should not be displayed in any
			#   case
			# - if a method returns '' (empty string) or nil it should not be displayed if
			#   the user level is 'anonymous' || 'specialist'
			#
      def common_display_fields(user, fields)
				result = ""
				force_typecasting
        n = 0
				fields.each do
					|f|
					result += f.display_template(self, user, n)
          n += 1
				end

        return result
      end

		public

			def display_fields(user)
        return common_display_fields(user, fields_to_be_displayed)
			end

      def display_ar_fields(user)
        return common_display_fields(user, ar_fields_to_be_displayed)
      end
		
			#
			# display functions
			#
      def display_authority_records(arclass)
        result = []
        already_displayed = {}
        refmeth = arclass.reference_method
        armeth = "#{arclass.name.underscore.pluralize}".intern
        self.send(armeth).each do
          |ar|
          id = ar.is_a?(arclass.equivalent_class) ?
            ar.send(refmeth).read_attribute('id') : ar.read_attribute('id')
          unless already_displayed.has_key?(id.to_s)
            already_displayed[id.to_s] = 'y'
            result << ar.display
          end
        end
        return result.join('; ')
      end
		
			def fields_to_be_displayed
        return self.class::FIELDS_TO_BE_DISPLAYED
			end
		
			def to_be_implemented
				return ""
			end
		
			def year_only(d)
				return d.split('-')[0]	
			end

      def senza_data_boolean
        return senza_data == 'Y' ? true : false
      end
		
			def dates_to_be_displayed
        actual_date = senza_data_boolean ? 's.d.' : date.to_display
        return [data_topica, actual_date, nota_data.to_s].conditional_join(', ')
			end

			def display_container
        rctype = rcnum = ''

				ctype = container_type ? container_type.container_type : ''
				cnum = container_number
	
				rctype = ctype.blank? ? "" : sprintf("[%s]", ctype)
				rcnum  = cnum ? cnum.to_s : ""

				return rctype + " " + rcnum
			end

      def display_cleansed_name
        return cleansed_name
      end

      def display_cleansed_full_name
        return cleansed_full_name
      end

      def display_person_names
        return display_authority_records(PersonName)
      end

      def display_site_names
        return display_authority_records(SiteName)
      end

      def display_collective_names
        return display_authority_records(CollectiveName)
      end

      def display_score_titles
        return display_authority_records(ScoreTitle)
      end

			def display_nothing
				#
				# does nothing, successefully (for separators)
				#
				return ""
			end
		
			#
			# display conditions
			#
			# - true | false will display/not display unconditionally (if the
			#   general conditions are met, that is: non-empty strings for
			#   end_users, all strings for staff and admin)
			# - nil  | empty string will display for > admins, no display for anonymous
			#
			def display_always(ignored_user)
				return true
			end
		
			def display_never(ignored_user)
				return false
			end
			#
			# this part is to be hardened - this is temporary
			#
			def display_if_not_end_user(user)
				return !user.end_user?
			end

			#
			# this is used for private description data
      # NOTE: this is no longer used - the private data flag will be used in
      # another way.
			#
			def display_of_private_data(user)
				result = nil
				if raw_description_reserved == :no || !user.end_user?
					result = description
				end
				return result
			end
		
			#
			# "corda" should not be displayed if its description level is below the
			# CORDA_LOWER_DISPLAY_BOUNDARY
			#
			# CORDA_LOWER_DISPLAY_BOUNDARY = DescriptionLevel.fascicolo.id
			CORDA_LOWER_DISPLAY_BOUNDARY = 5
		
			def display_corda_condition(ignored_user)
#				return (description_level > DescriptionLevel.fascicolo
				return true
			end
		end
	end
end
