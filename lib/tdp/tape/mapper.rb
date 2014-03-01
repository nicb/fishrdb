#
# $Id: mapper.rb 546 2010-09-08 22:44:40Z nicb $
#
require 'logger'
require 'active_record/fixtures'
require 'lib/tdp/builder'
require 'document/tape_record'
require 'lib/tdp/tape'

module Tdp

  module Tape

    class MapperKeyNotFound < StandardError
    end

    class Mapper

    private

      TAPE_ITEM_MAP =
      {
        'TAG' => :tag,
        'BB'  => :bb_inventory,
        'BOX' => :brand,
        'Rilev. nome nastro su [N]astro/[B]ox' => :brand_evidence,
        'DIA' => :reel_diameter,
        'MT'  => :tape_length_m,
        'TAPE' => :tape_material,
        'REEL' => :reel_material,
        'PARTITA' => :serial_number,
        'VEL' => :speed,
        'OUT' => :found,
        'ST/MO' => :recording_typology,
        'Lettore' => :analog_transfer_machine,
        'Matricola Registratore' => :analog_transfer_machine_serial_number,
        'Plugin' => :plugins,
        'SOFTWARE' => :digital_transfer_software,
        'FILE' => :digital_file_format,
        'SF' => :digital_sampling_rate,
        'BD' => :bit_depth,
        'DATA IN' => :transfer_session_start,
        'DATA FI' => :transfer_session_end,
      }

    public

      class << self

      private

        def convert_attributes(tape_item)
          result = {}
          tape_item.attributes.keys.each do
            |k|
            actual_key = TAPE_ITEM_MAP[k]
            if actual_key # some keys are omitted in mapping
              method = Tdp::Csv::TapeItem.convert_to_method_name(k)
              result[TAPE_ITEM_MAP[k]] = tape_item.send(method)
            end
          end
          return result
        end

        def default_mandatory_arguments
          user = User.find_by_login('nicb')
          ct = ContainerType.find_by_container_type('Scatola')
          dl_id = DescriptionLevel.unita_documentaria.id
          result =
          {
            :creator => user,
            :last_modifier => user,
            :container_type => ct,
            :description_level_position => DescriptionLevel.unita_documentaria.position,
          }
          return result
        end

        def define_appropriate_parent_name(tag)
          return TapeData.deduced_parent_name(tag)
        end

        def find_or_create_appropriate_parent(tag, session_data)
          root_parent = TapeData.tape_root
          apn = define_appropriate_parent_name(tag)
          result = Folder.find_by_name_and_parent_id(apn, root_parent.id)
          unless result
            args = default_mandatory_arguments
            ct = ContainerType.find_by_container_type('')
            args.update(:description_level_position => DescriptionLevel.sottoserie.position,
                        :parent => root_parent, :name => apn,
                        :container_type => ct)
            result = Folder.create_from_form(args, session_data)
          end
          return result
        end

        def default_document_attributes(tag, session_data)
          result = default_mandatory_arguments
          parent = find_or_create_appropriate_parent(tag, session_data)
          result.update(:parent => parent)
          return result
        end

        def csv_file_path
          root_path = File.dirname(__FILE__) + '/../../..'
          file_path = '/public/private/session-notes'
          filename = 'ScelsiDataBase.csv'
          return root_path + file_path + '/' + filename
        end

        def find_integrated_tape_by_tag(tag, db)
          result = nil
          db.integrated_tapes.each do
            |it|
            if tag == it.content.attributes['TAG']
              result = it
              break
            end
          end
          return result
        end

        def add_description(tag, db)
          result = ''
          it = find_integrated_tape_by_tag(tag, db)
          if it
            result = it.physical.description.description.gsub(/\n+\s*/, '<br />').gsub(/\n\s*/, ' ')
          end
          return result
        end

        def add_tape_box_markers(tape, db)
          it = find_integrated_tape_by_tag(tape.name, db)
          tbm = Tdp::Box::Mapper.new(it, tape)
          tbm.map
        end

      public

        #
        # tape_record_creator: if the record is already in the database,
        # avoid creating it one more time (skip creation)
        #
        def tape_record_creator(tape_item, db, session_data)
          result = TapeRecord.find_by_name(tape_item.tag)
          unless result
	          document_attributes = default_document_attributes(tape_item.tag, session_data)
	          document_attributes[:tape_data] = convert_attributes(tape_item)
            document_attributes[:description] = add_description(tape_item.tag, db)
	          result = TapeRecord.create_from_form(document_attributes, session_data)
	          raise "Mapping failed for tape record #{tape_item.tag} (#{result.errors.full_messages.join(', ')})" unless result.valid?
            add_tape_box_markers(result, db)
          end
          return result
        end

        def create_tape_records(session_data)
          result = 0
          db = Tdp::Builder::TapeFactory.new(csv_file_path)
          db.build
          db.csv.tape_items.each do
            |ti|
            tape_record_creator(ti, db, session_data)
            result += 1
          end
          return result
        end

        def create_tape_records_from_scratch
          #
          # let's put a mock session into it
          #
          Test::Unit::TestCase.fixtures(:sessions, :users)
          s = Session.first
          u = User.find_by_login('bootstrap')
          s['user'] = u
          return create_tape_records(s)
        end

        def drop_tape_records
          tr = TapeData.tape_root
          tr.children.each do
            |f|
            f.children.clear
            tr.children.reload
          end
        end

      end

    end

  end

end
