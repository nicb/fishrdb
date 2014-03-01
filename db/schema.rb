# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130909203911) do

  create_table "ard_references", :force => true do |t|
    t.integer  "authority_record_id", :limit => 11,  :null => false
    t.integer  "document_id",         :limit => 11,  :null => false
    t.integer  "creator_id",          :limit => 11,  :null => false
    t.integer  "last_modifier_id",    :limit => 11,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                :limit => 128, :null => false
  end

  add_index "ard_references", ["authority_record_id"], :name => "fk_drd_authority_record_id"
  add_index "ard_references", ["document_id"], :name => "fk_drd_document_id"
  add_index "ard_references", ["creator_id"], :name => "fk_drd_creator_id"
  add_index "ard_references", ["last_modifier_id"], :name => "fk_drd_last_modifier_id"

  create_table "authority_records", :force => true do |t|
    t.string   "name",                        :limit => 1024, :default => "",    :null => false
    t.string   "type",                        :limit => 128,  :default => "",    :null => false
    t.integer  "children_count",              :limit => 11,   :default => 0
    t.integer  "creator_id",                  :limit => 11,                      :null => false
    t.integer  "last_modifier_id",            :limit => 11,                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",                  :limit => 1024
    t.date     "date_start"
    t.date     "date_end"
    t.integer  "authority_record_id",         :limit => 11
    t.integer  "cn_equivalent_id",            :limit => 11
    t.text     "organico"
    t.integer  "author_id",                   :limit => 11
    t.integer  "transcriber_id",              :limit => 11
    t.integer  "lyricist_id",                 :limit => 11
    t.string   "date_start_format",           :limit => 32,   :default => "",    :null => false
    t.string   "date_start_input_parameters", :limit => 3,    :default => "---", :null => false
    t.string   "date_end_format",             :limit => 32,   :default => "",    :null => false
    t.string   "date_end_input_parameters",   :limit => 3,    :default => "---", :null => false
    t.string   "full_date_format",            :limit => 128,  :default => "",    :null => false
    t.string   "pseudonym",                   :limit => 128
  end

  add_index "authority_records", ["creator_id"], :name => "fk_ar_creator_id"
  add_index "authority_records", ["last_modifier_id"], :name => "fk_ar_last_modifier_id"
  add_index "authority_records", ["authority_record_id"], :name => "fk_ar_id"
  add_index "authority_records", ["cn_equivalent_id"], :name => "index_authority_records_on_cn_equivalent_id"
  add_index "authority_records", ["author_id"], :name => "index_authority_records_on_author_id"
  add_index "authority_records", ["transcriber_id"], :name => "index_authority_records_on_transcriber_id"
  add_index "authority_records", ["lyricist_id"], :name => "index_authority_records_on_lyricist_id"

  create_table "bibliographic_data", :id => false, :force => true do |t|
    t.integer "bibliographic_record_id",          :limit => 11,                     :null => false
    t.string  "author_last_name"
    t.string  "author_first_name"
    t.string  "journal"
    t.string  "volume",                           :limit => 64
    t.integer "number",                           :limit => 11
    t.date    "issue_year_db_record"
    t.string  "address"
    t.string  "publisher"
    t.date    "publishing_date_db_record"
    t.string  "publishing_date_format",           :limit => 32,  :default => ""
    t.string  "publishing_date_input_parameters", :limit => 3,   :default => "---"
    t.integer "start_page",                       :limit => 11
    t.integer "end_page",                         :limit => 11
    t.string  "language"
    t.string  "translator_last_name"
    t.string  "translator_first_name"
    t.string  "editor_last_name"
    t.string  "editor_first_name"
    t.text    "abstract"
    t.string  "volume_title"
    t.string  "academic_year",                    :limit => 128
  end

  add_index "bibliographic_data", ["bibliographic_record_id"], :name => "index_bibliographic_data_on_bibliographic_record_id"

  create_table "cd_data", :id => false, :force => true do |t|
    t.integer "cd_record_id",              :limit => 11, :null => false
    t.string  "record_label"
    t.string  "catalog_number"
    t.date    "publishing_year_db_record"
  end

  add_index "cd_data", ["cd_record_id"], :name => "index_cd_data_on_cd_record_id"

  create_table "cd_participants", :id => false, :force => true do |t|
    t.integer "cd_data_id", :limit => 11, :null => false
    t.integer "name_id",    :limit => 11, :null => false
    t.integer "position",   :limit => 11, :null => false
  end

  create_table "cd_track_participants", :force => true do |t|
    t.string  "type",         :limit => 256
    t.integer "cd_track_id",  :limit => 11,  :null => false
    t.integer "name_id",      :limit => 11
    t.string  "name_type",    :limit => 256
    t.integer "position",     :limit => 11
    t.integer "performer_id", :limit => 11
    t.integer "ensemble_id",  :limit => 11
  end

  add_index "cd_track_participants", ["cd_track_id"], :name => "index_cd_track_participants_on_cd_track_id"
  add_index "cd_track_participants", ["name_id"], :name => "index_cd_track_participants_on_name_id"
  add_index "cd_track_participants", ["performer_id"], :name => "index_cd_track_participants_on_performer_id"
  add_index "cd_track_participants", ["ensemble_id"], :name => "index_cd_track_participants_on_ensemble_id"

  create_table "cd_tracks", :id => false, :force => true do |t|
    t.integer "cd_track_record_id", :limit => 11,   :null => false
    t.integer "ordinal",            :limit => 11
    t.string  "for",                :limit => 8192
    t.time    "duration"
  end

  add_index "cd_tracks", ["cd_track_record_id"], :name => "index_cd_tracks_on_cd_track_record_id"

  create_table "clipboard_items", :force => true do |t|
    t.integer "sidebar_tree_id", :limit => 11, :null => false
    t.integer "document_id",     :limit => 11
  end

  add_index "clipboard_items", ["sidebar_tree_id"], :name => "index_clipboard_items_on_sidebar_tree_id"
  add_index "clipboard_items", ["document_id"], :name => "index_clipboard_items_on_document_id"

  create_table "cn_equivalents", :force => true do |t|
    t.string   "name",             :limit => 1024, :null => false
    t.integer  "creator_id",       :limit => 11,   :null => false
    t.integer  "last_modifier_id", :limit => 11,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cn_equivalents", ["creator_id"], :name => "index_cn_equivalents_on_creator_id"
  add_index "cn_equivalents", ["last_modifier_id"], :name => "index_cn_equivalents_on_last_modifier_id"

  create_table "container_types", :force => true do |t|
    t.string "container_type", :limit => 64, :null => false
  end

  add_index "container_types", ["container_type"], :name => "container_type", :unique => true

  create_table "documents", :force => true do |t|
    t.integer   "parent_id",                 :limit => 11
    t.string    "type",                      :limit => 128,                         :null => false
    t.integer   "creator_id",                :limit => 11,                          :null => false
    t.integer   "last_modifier_id",          :limit => 11,                          :null => false
    t.timestamp "created_at",                                                       :null => false
    t.timestamp "updated_at",                                                       :null => false
    t.integer   "position",                  :limit => 11,                          :null => false
    t.integer   "lock_version",              :limit => 11,       :default => 0
    t.enum      "record_locked",             :limit => [:Y, :N], :default => :N,    :null => false
    t.string    "name",                      :limit => 1024,                        :null => false
    t.text      "description"
    t.boolean   "public_access",                                 :default => true,  :null => false
    t.date      "data_dal"
    t.date      "data_al"
    t.string    "full_date_format",          :limit => 128
    t.string    "nota_data",                 :limit => 128
    t.string    "data_topica",               :limit => 256
    t.integer   "container_type_id",         :limit => 11,                          :null => false
    t.integer   "container_number",          :limit => 11
    t.integer   "corda",                     :limit => 11
    t.string    "consistenza",               :limit => 100
    t.string    "chiavi_accesso_series",     :limit => 1024
    t.string    "nomi_series",               :limit => 1024
    t.string    "enti_series",               :limit => 1024
    t.string    "luoghi_series",             :limit => 1024
    t.string    "titoli_series",             :limit => 1024
    t.string    "tipologia_documento_score", :limit => 256
    t.string    "misure_score",              :limit => 128
    t.string    "autore_score",              :limit => 256
    t.text      "organico_score"
    t.date      "anno_composizione_score"
    t.string    "edizione_score",            :limit => 256
    t.date      "anno_edizione_score"
    t.string    "luogo_edizione_score",      :limit => 256
    t.string    "trascrittore_score",        :limit => 256
    t.text      "note"
    t.string    "autore_versi_score",        :limit => 256
    t.string    "titolo_uniforme_score",     :limit => 1024
    t.integer   "children_count",            :limit => 11,       :default => 0
    t.integer   "fisold_reference_db_id",    :limit => 11
    t.integer   "fisold_reference_score",    :limit => 11
    t.string    "data_dal_format",           :limit => 32,       :default => "",    :null => false
    t.string    "data_dal_input_parameters", :limit => 3,        :default => "---", :null => false
    t.string    "data_al_format",            :limit => 32,       :default => "",    :null => false
    t.string    "data_al_input_parameters",  :limit => 3,        :default => "---", :null => false
    t.string    "senza_data",                :limit => 1,        :default => "N",   :null => false
    t.string    "corda_alpha",               :limit => 16
    t.string    "name_prefix",               :limit => 128
    t.string    "forma_documento_score",     :limit => 512
    t.integer   "description_level_id",      :limit => 8,                           :null => false
    t.boolean   "public_visibility",                             :default => true,  :null => false
    t.integer   "quantity",                  :limit => 11,       :default => 1,     :null => false
    t.string    "allowed_children_classes",  :limit => 1024
    t.string    "allowed_sibling_classes",   :limit => 1024
  end

  add_index "documents", ["parent_id"], :name => "fk_doc_parent"
  add_index "documents", ["creator_id"], :name => "fk_doc_creator"
  add_index "documents", ["last_modifier_id"], :name => "fk_doc_last_modifier"
  add_index "documents", ["container_type_id"], :name => "fk_doc_cti"
  add_index "documents", ["fisold_reference_db_id"], :name => "index_documents_on_fisold_reference_db_id"

  create_table "ensembles", :force => true do |t|
    t.string   "name",             :limit => 4096, :null => false
    t.integer  "conductor_id",     :limit => 11
    t.integer  "creator_id",       :limit => 11,   :null => false
    t.integer  "last_modifier_id", :limit => 11,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ensembles", ["conductor_id"], :name => "index_ensembles_on_conductor_id"
  add_index "ensembles", ["creator_id"], :name => "index_ensembles_on_creator_id"
  add_index "ensembles", ["last_modifier_id"], :name => "index_ensembles_on_last_modifier_id"

  create_table "fisold_reference_dbs", :force => true do |t|
    t.string  "name"
    t.integer "documents_count", :limit => 11, :default => 0
  end

  create_table "instruments", :force => true do |t|
    t.string   "name",                    :limit => 4096, :null => false
    t.integer  "cd_track_participant_id", :limit => 11
    t.integer  "creator_id",              :limit => 11,   :null => false
    t.integer  "last_modifier_id",        :limit => 11,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instruments", ["cd_track_participant_id"], :name => "index_instruments_on_cd_track_participant_id"
  add_index "instruments", ["creator_id"], :name => "index_instruments_on_creator_id"
  add_index "instruments", ["last_modifier_id"], :name => "index_instruments_on_last_modifier_id"

  create_table "names", :force => true do |t|
    t.string   "last_name",          :limit => 1024
    t.string   "first_name",         :limit => 1024
    t.string   "disambiguation_tag", :limit => 4096
    t.integer  "creator_id",         :limit => 11,   :null => false
    t.integer  "last_modifier_id",   :limit => 11,   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pseudonym",          :limit => 128
  end

  add_index "names", ["creator_id"], :name => "index_names_on_creator_id"
  add_index "names", ["last_modifier_id"], :name => "index_names_on_last_modifier_id"

  create_table "performers", :force => true do |t|
    t.integer  "name_id",          :limit => 11, :null => false
    t.integer  "instrument_id",    :limit => 11, :null => false
    t.integer  "creator_id",       :limit => 11, :null => false
    t.integer  "last_modifier_id", :limit => 11, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "performers", ["name_id"], :name => "index_performers_on_name_id"
  add_index "performers", ["instrument_id"], :name => "index_performers_on_instrument_id"
  add_index "performers", ["creator_id"], :name => "index_performers_on_creator_id"
  add_index "performers", ["last_modifier_id"], :name => "index_performers_on_last_modifier_id"

  create_table "search_index_class_references", :id => false, :force => true do |t|
    t.integer "search_index_id",       :limit => 11
    t.integer "search_index_class_id", :limit => 11
  end

  add_index "search_index_class_references", ["search_index_id"], :name => "index_search_index_class_references_on_search_index_id"
  add_index "search_index_class_references", ["search_index_class_id"], :name => "index_search_index_class_references_on_search_index_class_id"

  create_table "search_index_classes", :force => true do |t|
    t.string "class_name", :limit => 512, :null => false
  end

  create_table "search_indices", :force => true do |t|
    t.string  "string",          :limit => 16384, :null => false
    t.string  "field",           :limit => 512,   :null => false
    t.integer "record_id",       :limit => 11
    t.string  "reference_roots", :limit => 4096,  :null => false
  end

  add_index "search_indices", ["record_id"], :name => "index_search_indices_on_record_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sidebar_tree_items", :force => true do |t|
    t.integer "sidebar_tree_id",     :limit => 11,                                    :null => false
    t.integer "document_id",         :limit => 11,                                    :null => false
    t.enum    "status",              :limit => [:open, :closed], :default => :closed, :null => false
    t.string  "copied_to_clipboard", :limit => 4,                :default => "no",    :null => false
  end

  add_index "sidebar_tree_items", ["sidebar_tree_id"], :name => "index_sidebar_tree_items_on_sidebar_tree_id"
  add_index "sidebar_tree_items", ["document_id"], :name => "index_sidebar_tree_items_on_document_id"

  create_table "sidebar_trees", :force => true do |t|
    t.string  "session_id",       :limit => 32, :null => false
    t.integer "selected_item_id", :limit => 11
  end

  add_index "sidebar_trees", ["session_id"], :name => "index_sidebar_trees_on_session_id"
  add_index "sidebar_trees", ["selected_item_id"], :name => "index_sidebar_trees_on_selected_item_id"

  create_table "tape_box_marker_collections", :force => true do |t|
    t.string  "location",     :limit => 256, :null => false
    t.integer "tape_data_id", :limit => 11,  :null => false
  end

  add_index "tape_box_marker_collections", ["tape_data_id"], :name => "index_tape_box_marker_collections_on_tape_data_id"

  create_table "tape_box_marks", :force => true do |t|
    t.text    "text",                                                            :null => false
    t.string  "marker",                        :limit => 256,                    :null => false
    t.string  "modifiers",                     :limit => 256
    t.boolean "reliability",                                   :default => true, :null => false
    t.string  "css_style",                     :limit => 4096, :default => "",   :null => false
    t.integer "name_id",                       :limit => 11
    t.integer "tape_box_marker_collection_id", :limit => 11,                     :null => false
  end

  add_index "tape_box_marks", ["name_id"], :name => "index_tape_box_marks_on_name_id"
  add_index "tape_box_marks", ["tape_box_marker_collection_id"], :name => "index_tape_box_marks_on_tape_box_marker_collection_id"

  create_table "tape_data", :id => false, :force => true do |t|
    t.integer "tape_record_id",                        :limit => 11,   :null => false
    t.string  "inventory",                             :limit => 8
    t.string  "bb_inventory",                          :limit => 8
    t.string  "brand",                                 :limit => 64
    t.string  "brand_evidence",                        :limit => 1
    t.float   "reel_diameter"
    t.float   "tape_length_m"
    t.string  "tape_material",                         :limit => 32
    t.string  "reel_material",                         :limit => 32
    t.string  "serial_number",                         :limit => 16
    t.string  "speed",                                 :limit => 16
    t.string  "found",                                 :limit => 4
    t.string  "recording_typology",                    :limit => 16
    t.string  "analog_transfer_machine",               :limit => 32
    t.string  "plugins",                               :limit => 128
    t.string  "digital_transfer_software",             :limit => 32
    t.string  "digital_file_format",                   :limit => 8
    t.integer "digital_sampling_rate",                 :limit => 11
    t.integer "bit_depth",                             :limit => 11
    t.date    "transfer_session_start"
    t.date    "transfer_session_end"
    t.string  "transfer_session_location"
    t.string  "analog_transfer_machine_serial_number", :limit => 1024
  end

  add_index "tape_data", ["tape_record_id"], :name => "index_tape_data_on_tape_record_id"

  create_table "users", :force => true do |t|
    t.string  "login",        :limit => 40,                                                          :null => false
    t.string  "name",         :limit => 256
    t.string  "password",     :limit => 41
    t.enum    "user_type",    :limit => [:public, :specialist, :staff, :admin], :default => :public, :null => false
    t.string  "email",        :limit => 1024,                                                        :null => false
    t.integer "clipboard_id", :limit => 11
  end

  add_index "users", ["login"], :name => "login", :unique => true
  add_index "users", ["clipboard_id"], :name => "fk_user_clipb"

end
