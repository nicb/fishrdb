#!/usr/bin/env ruby
# 
# $Id: fisold.rb 113 2007-12-18 18:50:11Z nicb $
#
# This script uses ActiveRecord and it is used to convert from the old
# database schema to the new one. Running it should produce two fully
# populated new databases 'fishrdb_development' and 'fishrdb_test'
#

require 'convert_environment'

module Fisold

	module NoLuogo
		def Luogo
			return nil
		end
	end

	module NoNotaData
		def Nota_Data
			return nil
		end
	end

	module DateExtractor
	private
		def year_extract
			name = self.class.table_name.dup
			name = name.sub(/^.*_([1-2][0-9][0-9][0-9]_[1-2][0-9][0-9][0-9])$/, '\1')
			if name.empty?
				dstart, dend = nil
			else
				(dstart, dend) = name.split('_')
				dstart = "#{dstart}-01-01"
				dend = "#{dend}-12-31"
			end
			return dstart, dend
		end
	public
		def DataDal
			ds, de = year_extract
			return ds
		end
		def DataAl
			ds, de = year_extract
			return de
		end
	end

	class Series < ActiveRecord::Base
	end

	class DocumentiPersonaliPatrimoniali < Series
		set_table_name "01_Documenti_personali_e_patrimoniali_1923_1988"
		FISHRDB_SERIES = "Documenti Personali e Patrimoniali"
		include NoLuogo
	end

	class Corrispondenza < Series
		set_table_name "02_Corrispondenza_1934_1991"
		FISHRDB_SERIES = "Corrispondenza"
		include NoLuogo
	end

	class ScrittiFilosoficiPoetici < Series
		set_table_name "03_Scritti_filosofici_e_poetici_sd"
		FISHRDB_SERIES = "Scritti Filosofici e Poetici"
		include NoLuogo
		include NoNotaData
	end

	class AppuntiNote < Series
		set_table_name "04_Appunti_e_note_1935_1991"
		FISHRDB_SERIES = "Appunti e Note"
		include NoNotaData
	end

	class CarteIsabellaScelsi < Series
		set_table_name "05_Carte_Isabella_Scelsi_1928_1975"
		FISHRDB_SERIES = "Carte Isabella Scelsi"
		include NoLuogo
	end

	class MaterialiAStampaBrochuresDepliants < Series
		set_table_name "06_Materiali_a_stampa___Brochure_e_d__pliant"
		FISHRDB_SERIES = "Brochures e Dépliants"
		include NoNotaData
	end

	class MaterialiAStampaInviti < Series
		set_table_name "06_Materiali_a_stampa___Inviti"
		FISHRDB_SERIES = "Inviti"
		include NoNotaData
	end

	class MaterialiAStampaManifestiLocandine < Series
		set_table_name "06_Materiali_a_stampa___Manifesti_e_locandine"
		FISHRDB_SERIES = "Manifesti e Locandine"
		include NoNotaData
	end

	class MaterialiAStampaOpuscoli < Series
		set_table_name "06_Materiali_a_stampa___Opuscoli"
		FISHRDB_SERIES = "Opuscoli"
		include NoNotaData
	end

	class MaterialiAStampaProgrammi < Series
		set_table_name "06_Materiali_a_stampa___Programmi"
		FISHRDB_SERIES = "Programmi"
		include NoNotaData
	end

	class MaterialiAStampaRivistePeriodici < Series
		set_table_name "06_Materiali_a_stampa___Riviste__periodici_"
		FISHRDB_SERIES = "Riviste"
		include NoNotaData
	end

	class RassegnaStampa < Series
		set_table_name "07_Rassegna_stampa_1934_1991"
		FISHRDB_SERIES = "Rassegna Stampa"
		include NoNotaData
	end

	class DisegniCollezioneFotografica < Series
		set_table_name "08_Disegni_e_collezione_fotografica"
		FISHRDB_SERIES = "Collezione di Disegni e di Fotografie"
		include NoNotaData
	end

	module SeriesCollection
		COLLECTION =
		[
			DocumentiPersonaliPatrimoniali,
			Corrispondenza,
			ScrittiFilosoficiPoetici,
			AppuntiNote,
			CarteIsabellaScelsi,
			MaterialiAStampaBrochuresDepliants,
			MaterialiAStampaInviti,
			MaterialiAStampaManifestiLocandine,
			MaterialiAStampaOpuscoli,
			MaterialiAStampaProgrammi,
			MaterialiAStampaRivistePeriodici,
			RassegnaStampa,
			DisegniCollezioneFotografica,
		]
		HCOLL = {}

	private
		def self.load_keys
			COLLECTION.each { |c| HCOLL[c::FISHRDB_SERIES] = c }
		end

	public
	
		def self.index(key)
			SeriesCollection.load_keys if HCOLL.empty?
			return HCOLL[key]
		end

		def self.each
			SeriesCollection.load_keys if HCOLL.empty?
			HCOLL.each { |k, v| yield(k, v) }
		end
	end

	#
	# we need this until the rails schema dumper can recognize the 'year'
	# mysql type
	#
	module YearDateConverter

	private

		def year_detector(field)
			result = read_attribute(field)
			result = "#{result}-01-01" if result
			return result	
		end

	public

		def anno_composizione
			return year_detector('anno_composizione')
		end

		def anno_edizione
			return year_detector('anno_edizione')
		end

	end

	class Scores < ActiveRecord::Base
		attr_accessor :children, :printing_prefix

		include YearDateConverter

		def initialize
			super
			@children = nil
		end
	end

	class ScoresGiacintoScelsi < Scores
		@@FISOLD_TABLE = "Partiture_Scelsi"
		FISHRDB_SCORE = "Partiture Giacinto Scelsi"
		set_table_name @@FISOLD_TABLE

		def titolo_uniforme
			return nil
		end
		def trascrittore
			return nil
		end
		def self.table_name
			return @@FISOLD_TABLE
		end
	end

	class ScoresAltriAutori < Scores
		set_table_name "Partiture_altri_autori"
		FISHRDB_SCORE = "Partiture Altri Autori"
	end

	module ScoreCollection
		COLLECTION =
		[
			ScoresAltriAutori,
			ScoresGiacintoScelsi,
		]
		HCOLL = {}

	private
		def self.load_keys
			COLLECTION.each { |c| HCOLL[c::FISHRDB_SCORE] = c }
		end

	public
	
		def self.index(key)
			ScoreCollection.load_keys if HCOLL.empty?
			return HCOLL[key]
		end

		def self.each
			ScoreCollection.load_keys if HCOLL.empty?
			HCOLL.each { |k, v| yield(k, v) }
		end
	end

end
