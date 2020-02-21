#
# $Id: mapper.rb 502 2010-05-30 20:56:50Z nicb $
#

require 'calligraphy_description'

module Tdp

  module Box

    class Mapper

      class AlreadyMapped < StandardError; end
      class TapeBoxMarkerCollectionCreationFailure < ActiveRecord::ActiveRecordError; end
      class NameCreationFailure < ActiveRecord::ActiveRecordError; end
      class AcroMapFailure < StandardError; end
      class TapeBoxMarkCreationFailure < ActiveRecord::ActiveRecordError; end
      class NonExistingTapeItem < StandardError; end

      attr_reader :tape_record, :tape_item

      def initialize(ti, tr)
        @tape_item   = ti  # the tape item we read from
        @tape_record = tr  # the tape record we're going to write into
      end

      def map
        if tape_item
          raise(AlreadyMapped, "Cowardly refusing to map already mapped tape box (tape: #{tape_record.name} - #{tape_record.id})") unless tape_record.tape_box_marker_collections.size == 0
          tape_item.physical.box.each do
            |b|
            tbmc = TapeBoxMarkerCollection.create(:tape_data => tape_record.tape_data, :location => b.location)
            raise(TapeBoxMarkerCollectionCreationFailure, "#{tbmc.errors.full_messages.join(', ')}") unless tbmc && tbmc.valid?
            b.notes.each do
              |m|
              (name, rel) = name_map(m.calligraphy.author)
              tbm = TapeBoxMark.create(:tape_box_marker_collection => tbmc, :text => m.lines, :name => name,
                                       :reliability => rel, :marker => m.calligraphy.pen,
                                       :modifiers => m.calligraphy.additional_info)
              raise(TapeBoxMarkCreationFailure, "#{tbm.errors.full_messages.join(', ')}") unless tbm && tbm.valid?
            end
          end
        end
      end

    private

      def name_map(author)
        name = nil
        rel = author =~ /\?+$/ ? false : true
        acro = author.sub(/\?+$/, '')
        unless acro.blank?
          u = User.find_by_login('nicb')
          (ln, fn) = acro_to_name(acro)
          name = Name.find_or_create({ :last_name => ln, :first_name => fn }, { :creator => u, :last_modifier => u })
          raise(NameCreationFailure, "#{name.errors.full_messages.join(',')}") unless name && name.valid?
        end
        return [ name, rel ]
      end

      ACRO_MAP =
      {
        'GS' => { :last_name => 'Scelsi', :first_name => 'Giacinto' },
        'FMU' => { :last_name => 'Uitti', :first_name => 'Frances-Marie' },
        'AC' => { :last_name => 'Curran', :first_name => 'Alvin' },
        'NB' => { :last_name => 'Bernardini', :first_name => 'Nicola' },
        'PS' => { :last_name => 'Schiavoni', :first_name => 'Pietro' },
      }

      def acro_to_name(acro)
        result = ACRO_MAP[acro]
        raise(AcroMapFailure, "could not map \"#{acro}\" to any name") unless result
        return [ result[:last_name], result[:first_name] ]
      end

    end

  end

end
