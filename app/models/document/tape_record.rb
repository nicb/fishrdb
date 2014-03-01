#
# $Id: tape_record.rb 541 2010-09-07 06:08:21Z nicb $
#

class TapeRecord < Document

  include DocumentParts::TwoPartDocument # this is a composed two-part document

  has_one :tape_data, :dependent => :destroy
  has_one_proxy_readers :tape_data, :add =>
    [ 
      :display_reel_material,
      :display_tape_material,
      :display_brand_evidence,
      :box_thumbnail_collection,
      :snapshot_thumbnail,
      :sound_collection,
      :tape_box_marker_collections,
    ]

  set_subkey :tape_data

  validates_associated :tape_data

protected

  include TapeDataParts::ImageDisplay
  include TapeDataParts::Sound
  include TapeDataParts::TapeBoxMarkerCollectionDisplay

	FIELDS_TO_BE_DISPLAYED =
	[
		DisplayItem.new(:signature,     "Segnatura"),
		DisplayItem.new(:full_corda, 		"Corda", :display_corda_condition),
  	DisplayItem.new(:name, 		      "Codice"),
		DisplayItem.new(:description,		"Descrizione"),
		DisplayItem.new(:inventory,		  "Numero di Inventario"),
		DisplayItem.new(:bb_inventory,  "Numerazione Boido"),
    TapeSnapshotImageDisplayItem.new(:snapshot_thumbnail, "Sessione"),
    TapeBoxImageDisplayItem.new(:box_thumbnail_collection, "Immagini"),
    TapeBoxMarkerCollectionDisplayItem.new(:tape_box_marker_collections, "Annotazioni sul Contenitore"),
    TapeSoundDisplayItem.new(:sound_collection, "Tracce"),
		DisplayItem.new(:brand,			    "Marca del Nastro"),
		DisplayItem.new(:display_brand_evidence, "Evidenza della marca del nastro"),
		DisplayItem.new(:reel_diameter, "Diametro della bobina"),
		DisplayItem.new(:tape_length_m, "Lughezza del nastro (in m)"),
		DisplayItem.new(:display_tape_material, "Materiale"),
		DisplayItem.new(:display_reel_material, "Materiale della Bobina"),
		DisplayItem.new(:serial_number, "Numero di Partita"),
		DisplayItem.new(:speed,         "Velocit&agrave; di scorrimento (cm/sec)"),
		DisplayItem.new(:found,         "Testa/coda"),
		DisplayItem.new(:recording_typology,         "Tipologia di registrazione"),
		DisplayItem.new(:analog_transfer_machine,    "Lettore analogico"),
		DisplayItem.new(:digital_transfer_software,  "Software"),
		DisplayItem.new(:plugins,      "Plug-in utilizzati"),
		DisplayItem.new(:digital_file_format,      "Formato nativo dei files digitali"),
		DisplayItem.new(:digital_sampling_rate,    "Frequenza di campionamento"),
		DisplayItem.new(:bit_depth,    "Profondit&agrave; dei campioni"),
		DisplayItem.new(:transfer_session_start,    "Sessione iniziale di trasferimento"),
		DisplayItem.new(:transfer_session_end,    "Sessione finale di trasferimento"),
		DisplayItem.new(:transfer_session_location, "Sede del trasferimento"),
		SeparatorItem.new,
		DisplayItem.new(:display_container, "Contenitore"),
		DisplayItem.new(:public_access_display, "Consultabilit&agrave;"),
		DisplayItem.new(:public_visibility_display, "Visibilit&agrave;", :display_if_not_end_user),
	]

public

  allow_search_in [ :name, :inventory, :bb_inventory, \
    :brand, :reel_diameter, :tape_length_m, :display_tape_material, \
    :display_reel_material, :serial_number, :speed, :found, \
    :recording_typology, :analog_transfer_machine, :digital_transfer_software, \
    :plugins, :digital_file_format, :digital_sampling_rate, :bit_depth, \
    :transfer_session_start, :transfer_session_end, \
    :transfer_session_location, \
    :tape_box_marker_collection_indexing ]

  #
  # +tape_box_marker_collection_indexing+ is a method that allows compact
  # indexing of every box mark for this tape
  #
  def tape_box_marker_collection_indexing
    return tape_box_marker_collections.map do
      |tbmc|
      tbmc.tape_box_marks.map do
        |tbm|
        [ tbm.text, tbm.full_calligraphy_display ].join(' ')
      end
    end.join(' ')
  end

  class << self

    #
    # CRUD stuff
    #

    def create_from_form(parms = {}, session = nil)
      if parms[subkey]
        parms[:name] = parms[subkey][:tag]
      else
        parms[subkey] = {}
        parms[subkey][:tag] = parms[:name]
      end
      return super(parms, session)
    end

    def editable?
      return false
    end

  end

  #
  # TapeRecord should not be able to have children under normal conditions
  #

	def allowed_children_classes
    return specialized_allowed_classes('children') { nil }
	end

end
