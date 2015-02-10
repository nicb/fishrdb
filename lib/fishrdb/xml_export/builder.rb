require 'gyoku'
require 'debugger'

module Fishrdb

  module XmlExport
  
    module Builder
  
      class << self
  
        def build
          rw = Document.new(::Document.fishrdb_root)
          hash = rw.build
          xml = Gyoku.xml(hash)
          f = Fishrdb::XmlExport::File.new
          f.xml_header
          f.save(xml)
          f.path
        end
  
      end

      #
      # model wrappers
      #

      class DescriptionLevel

        attr_reader :dl

        def initialize(dlid)
          @dl = ::DescriptionLevel.find(dlid)
        end

        def build
          hash = { :description_level => self.dl.level }
        end

      end

      class AuthorityRecord

        attr_reader :ar

        def initialize(ar)
          @ar = ar
        end

        def build
          hash = {}
					ar_attrs = self.ar.attributes
					ar_attrs.update(:order! => ['id', 'type', 'first_name', 'name', 'pseudonym', 'organico', 'author_id', 'author', 'transcriber_id', 'transcriber', 'lyricist_id', 'lyricist', 'date_start_format', 'date_start_input_parameters', 'date_start', 'date_end_format', 'date_end_input_parameters', 'date_end', 'full_date_format', 'children_count', 'children', 'creator_id', 'last_modifier_id', 'created_at', 'updated_at', 'authority_record_id', 'authority_record', 'cn_equivalent_id', 'cn_equivalent'])
          hash.update(self.ar.type.to_s => self.ar.attributes)
          hash
        end

      end

      class Document

        attr_reader :doc

        def initialize(doc)
          @doc = doc
        end

        def build
          hash = {}
          hash.update(:document => self.doc.attributes)
          hdoc = hash[:document]
					hdoc.update(:order! => ['id', :description_level, 'name_prefix', 'name', 'description', 'note', 'public_visibility', 'public_access', 'quantity', 'corda_alpha', 'corda', 'container_type_id', 'container_number', 'fisold_reference_db_id', 'fisold_reference_score', 'lock_version', 'data_dal_input_parameters', 'full_date_format', 'last_modifier_id', 'anno_edizione_score', 'data_topica', 'misure_score', 'senza_data', 'record_locked', 'titoli_series', 'chiavi_accesso_series', 'forma_documento_score', 'titolo_uniforme_score', 'allowed_children_classes', 'autore_score', 'edizione_score', 'nota_data', 'children_count', 'data_al_format', 'data_dal_format', 'nomi_series', 'tipologia_documento_score', 'created_at', 'description_level_id', 'organico_score', 'parent_id', 'trascrittore_score', 'updated_at', 'consistenza', 'enti_series', 'luoghi_series', 'type', 'anno_composizione_score', 'creator_id', 'data_al', 'data_dal', 'data_al_input_parameters', 'luogo_edizione_score', 'position', 'autore_versi_score', 'allowed_sibling_classes', :children ])
          build_associate_data(hdoc)
          build_children(hdoc)
          build_description_level(hdoc)
          build_authority_records(hdoc)
          hash
        end

      private

        TWO_PART_DOCS =
        {
          'BibliographicRecord' => :bibliographic_data,
          'CdRecord' => :cd_data,
          'CdTrackRecord' => :cd_track,
          'TapeRecord' => :tape_data,
        }

        def build_associate_data(h)
          key = self.doc.type.to_s
          if TWO_PART_DOCS.has_key?(key)
            meth = TWO_PART_DOCS[key]
            h.update(meth => self.doc.send(meth).attributes)
						h[:order!] << meth
          end
          h
        end

        def build_children(h)
          h.update(:children => [])
          unless self.doc.children.empty?
            self.doc.children.each do
              |c|
              cw = Document.new(c)
              h[:children] << cw.build
            end
          end
          h
        end

        def build_description_level(h)
          dl = DescriptionLevel.new(self.doc.description_level_id)
          h.update(dl.build)
        end

        AUTHORITY_FILES = [:person_names, :score_titles, :site_names, :collective_names]

        def build_authority_records(h)
          AUTHORITY_FILES.each do
            |auth|
            coll = self.doc.send(auth)
            unless coll.empty?
              h.update(auth => [])
							h[:order!] << auth
              coll.each do
                |ar|
                arw = AuthorityRecord.new(ar)
                h[auth] << arw.build
              end
            end
          end
          h
        end

      end
  
    end
  
  end

end
