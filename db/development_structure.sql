CREATE TABLE `ard_references` (
  `authority_record_id` int(11) NOT NULL,
  `document_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `last_modifier_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `fk_drd_authority_record_id` (`authority_record_id`),
  KEY `fk_drd_document_id` (`document_id`),
  KEY `fk_drd_creator_id` (`creator_id`),
  KEY `fk_drd_last_modifier_id` (`last_modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9352 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `authority_records` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(1024) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `type` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `children_count` int(11) DEFAULT '0',
  `creator_id` int(11) NOT NULL,
  `last_modifier_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `first_name` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_start` date DEFAULT NULL,
  `date_end` date DEFAULT NULL,
  `authority_record_id` int(11) DEFAULT NULL,
  `cn_equivalent_id` int(11) DEFAULT NULL,
  `organico` text COLLATE utf8_unicode_ci,
  `author_id` int(11) DEFAULT NULL,
  `transcriber_id` int(11) DEFAULT NULL,
  `lyricist_id` int(11) DEFAULT NULL,
  `date_start_format` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `date_start_input_parameters` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT '---',
  `date_end_format` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `date_end_input_parameters` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT '---',
  `full_date_format` varchar(128) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `pseudonym` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ar_creator_id` (`creator_id`),
  KEY `fk_ar_last_modifier_id` (`last_modifier_id`),
  KEY `fk_ar_id` (`authority_record_id`),
  KEY `index_authority_records_on_cn_equivalent_id` (`cn_equivalent_id`),
  KEY `index_authority_records_on_author_id` (`author_id`),
  KEY `index_authority_records_on_transcriber_id` (`transcriber_id`),
  KEY `index_authority_records_on_lyricist_id` (`lyricist_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5415 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `bibliographic_data` (
  `bibliographic_record_id` int(11) NOT NULL,
  `author_last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `author_first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `journal` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `volume` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  `issue_year_db_record` date DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `publisher` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `publishing_date_db_record` date DEFAULT NULL,
  `publishing_date_format` varchar(32) COLLATE utf8_unicode_ci DEFAULT '',
  `publishing_date_input_parameters` varchar(3) COLLATE utf8_unicode_ci DEFAULT '---',
  `start_page` int(11) DEFAULT NULL,
  `end_page` int(11) DEFAULT NULL,
  `language` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `translator_last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `translator_first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `editor_last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `editor_first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `abstract` text COLLATE utf8_unicode_ci,
  `volume_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `academic_year` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  KEY `index_bibliographic_data_on_bibliographic_record_id` (`bibliographic_record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cd_data` (
  `cd_record_id` int(11) NOT NULL,
  `record_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `catalog_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `publishing_year_db_record` date DEFAULT NULL,
  KEY `index_cd_data_on_cd_record_id` (`cd_record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cd_participants` (
  `cd_data_id` int(11) NOT NULL,
  `name_id` int(11) NOT NULL,
  `position` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cd_track_participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cd_track_id` int(11) NOT NULL,
  `name_id` int(11) DEFAULT NULL,
  `name_type` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `performer_id` int(11) DEFAULT NULL,
  `ensemble_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cd_track_participants_on_cd_track_id` (`cd_track_id`),
  KEY `index_cd_track_participants_on_name_id` (`name_id`),
  KEY `index_cd_track_participants_on_performer_id` (`performer_id`),
  KEY `index_cd_track_participants_on_ensemble_id` (`ensemble_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8687 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cd_tracks` (
  `cd_track_record_id` int(11) NOT NULL,
  `ordinal` int(11) DEFAULT NULL,
  `for` varchar(8192) COLLATE utf8_unicode_ci DEFAULT NULL,
  `duration` time DEFAULT NULL,
  KEY `index_cd_tracks_on_cd_track_record_id` (`cd_track_record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `clipboard_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sidebar_tree_id` int(11) NOT NULL,
  `document_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_clipboard_items_on_sidebar_tree_id` (`sidebar_tree_id`),
  KEY `index_clipboard_items_on_document_id` (`document_id`)
) ENGINE=InnoDB AUTO_INCREMENT=354 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cn_equivalents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `creator_id` int(11) NOT NULL,
  `last_modifier_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cn_equivalents_on_creator_id` (`creator_id`),
  KEY `index_cn_equivalents_on_last_modifier_id` (`last_modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `container_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `container_type` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `container_type` (`container_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='Type of containers';

CREATE TABLE `documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL COMMENT 'NULL = root node',
  `type` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `creator_id` int(11) NOT NULL COMMENT 'Connected to the User table',
  `last_modifier_id` int(11) NOT NULL COMMENT 'Connected to the User table',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `position` int(11) NOT NULL,
  `lock_version` int(11) DEFAULT '0',
  `record_locked` enum('Y','N') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'N',
  `name` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `public_access` tinyint(1) NOT NULL DEFAULT '1',
  `data_dal` date DEFAULT NULL,
  `data_al` date DEFAULT NULL,
  `full_date_format` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `nota_data` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_topica` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `container_type_id` int(11) NOT NULL COMMENT 'Connected to the Container Type table',
  `container_number` int(11) DEFAULT NULL,
  `corda` int(11) DEFAULT NULL,
  `consistenza` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `chiavi_accesso_series` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'This will become an authority file',
  `nomi_series` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'This will become an authority file',
  `enti_series` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'This will become an authority file',
  `luoghi_series` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'This will become an authority file',
  `titoli_series` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'This will become an authority file',
  `tipologia_documento_score` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `misure_score` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `autore_score` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organico_score` text COLLATE utf8_unicode_ci,
  `anno_composizione_score` date DEFAULT NULL,
  `edizione_score` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `anno_edizione_score` date DEFAULT NULL,
  `luogo_edizione_score` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `trascrittore_score` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `autore_versi_score` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `titolo_uniforme_score` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Will be connected to an authority file',
  `children_count` int(11) DEFAULT '0',
  `fisold_reference_db_id` int(11) DEFAULT NULL,
  `fisold_reference_score` int(11) DEFAULT NULL,
  `data_dal_format` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `data_dal_input_parameters` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT '---',
  `data_al_format` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `data_al_input_parameters` varchar(3) COLLATE utf8_unicode_ci NOT NULL DEFAULT '---',
  `senza_data` varchar(1) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'N',
  `corda_alpha` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name_prefix` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `forma_documento_score` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description_level_id` int(8) NOT NULL,
  `public_visibility` tinyint(1) NOT NULL DEFAULT '1',
  `quantity` int(11) NOT NULL DEFAULT '1',
  `allowed_children_classes` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `allowed_sibling_classes` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_doc_parent` (`parent_id`),
  KEY `fk_doc_creator` (`creator_id`),
  KEY `fk_doc_last_modifier` (`last_modifier_id`),
  KEY `fk_doc_cti` (`container_type_id`),
  KEY `index_documents_on_fisold_reference_db_id` (`fisold_reference_db_id`),
  CONSTRAINT `fk_doc_creator` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_doc_cti` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_doc_last_modifier` FOREIGN KEY (`last_modifier_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_doc_parent` FOREIGN KEY (`parent_id`) REFERENCES `documents` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9105 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `ensembles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(4096) COLLATE utf8_unicode_ci NOT NULL,
  `conductor_id` int(11) DEFAULT NULL,
  `creator_id` int(11) NOT NULL,
  `last_modifier_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ensembles_on_conductor_id` (`conductor_id`),
  KEY `index_ensembles_on_creator_id` (`creator_id`),
  KEY `index_ensembles_on_last_modifier_id` (`last_modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `fisold_reference_dbs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `documents_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `instruments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(4096) COLLATE utf8_unicode_ci NOT NULL,
  `cd_track_participant_id` int(11) DEFAULT NULL,
  `creator_id` int(11) NOT NULL,
  `last_modifier_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_instruments_on_cd_track_participant_id` (`cd_track_participant_id`),
  KEY `index_instruments_on_creator_id` (`creator_id`),
  KEY `index_instruments_on_last_modifier_id` (`last_modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_name` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `first_name` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `disambiguation_tag` varchar(4096) COLLATE utf8_unicode_ci DEFAULT NULL,
  `creator_id` int(11) NOT NULL,
  `last_modifier_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pseudonym` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_names_on_creator_id` (`creator_id`),
  KEY `index_names_on_last_modifier_id` (`last_modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=594 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `performers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name_id` int(11) NOT NULL,
  `instrument_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `last_modifier_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_performers_on_name_id` (`name_id`),
  KEY `index_performers_on_instrument_id` (`instrument_id`),
  KEY `index_performers_on_creator_id` (`creator_id`),
  KEY `index_performers_on_last_modifier_id` (`last_modifier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=345 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `search_index_class_references` (
  `search_index_id` int(11) DEFAULT NULL,
  `search_index_class_id` int(11) DEFAULT NULL,
  KEY `index_search_index_class_references_on_search_index_id` (`search_index_id`),
  KEY `index_search_index_class_references_on_search_index_class_id` (`search_index_class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `search_index_classes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `class_name` varchar(512) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `search_indices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `string` varchar(16384) COLLATE utf8_unicode_ci NOT NULL,
  `field` varchar(512) COLLATE utf8_unicode_ci NOT NULL,
  `record_id` int(11) DEFAULT NULL,
  `reference_roots` varchar(4096) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_search_indices_on_record_id` (`record_id`)
) ENGINE=InnoDB AUTO_INCREMENT=51611 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=1346 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sidebar_tree_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sidebar_tree_id` int(11) NOT NULL,
  `document_id` int(11) NOT NULL,
  `status` enum('open','closed') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'closed',
  `copied_to_clipboard` varchar(4) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'no',
  PRIMARY KEY (`id`),
  KEY `index_sidebar_tree_items_on_sidebar_tree_id` (`sidebar_tree_id`),
  KEY `index_sidebar_tree_items_on_document_id` (`document_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1411158 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sidebar_trees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `selected_item_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sidebar_trees_on_session_id` (`session_id`),
  KEY `index_sidebar_trees_on_selected_item_id` (`selected_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6085 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tape_box_marker_collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `tape_data_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tape_box_marker_collections_on_tape_data_id` (`tape_data_id`)
) ENGINE=InnoDB AUTO_INCREMENT=788 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tape_box_marks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` text COLLATE utf8_unicode_ci NOT NULL,
  `marker` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `modifiers` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reliability` tinyint(1) NOT NULL DEFAULT '1',
  `css_style` varchar(4096) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `name_id` int(11) DEFAULT NULL,
  `tape_box_marker_collection_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tape_box_marks_on_name_id` (`name_id`),
  KEY `index_tape_box_marks_on_tape_box_marker_collection_id` (`tape_box_marker_collection_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2380 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `tape_data` (
  `tape_record_id` int(11) NOT NULL,
  `inventory` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `bb_inventory` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `brand` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `brand_evidence` varchar(1) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reel_diameter` float DEFAULT NULL,
  `tape_length_m` float DEFAULT NULL,
  `tape_material` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reel_material` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `serial_number` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `speed` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `found` varchar(4) COLLATE utf8_unicode_ci DEFAULT NULL,
  `recording_typology` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `analog_transfer_machine` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `plugins` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `digital_transfer_software` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `digital_file_format` varchar(8) COLLATE utf8_unicode_ci DEFAULT NULL,
  `digital_sampling_rate` int(11) DEFAULT NULL,
  `bit_depth` int(11) DEFAULT NULL,
  `transfer_session_start` date DEFAULT NULL,
  `transfer_session_end` date DEFAULT NULL,
  `transfer_session_location` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `analog_transfer_machine_serial_number` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  KEY `index_tape_data_on_tape_record_id` (`tape_record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(40) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(41) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_type` enum('public','specialist','staff','admin') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'public',
  `email` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `clipboard_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login` (`login`),
  KEY `fk_user_clipb` (`clipboard_id`),
  CONSTRAINT `fk_user_clipb` FOREIGN KEY (`clipboard_id`) REFERENCES `documents` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20080709171659');

INSERT INTO schema_migrations (version) VALUES ('20080709171734');

INSERT INTO schema_migrations (version) VALUES ('20080719043730');

INSERT INTO schema_migrations (version) VALUES ('20080720033207');

INSERT INTO schema_migrations (version) VALUES ('20080728180754');

INSERT INTO schema_migrations (version) VALUES ('20081017061228');

INSERT INTO schema_migrations (version) VALUES ('20081105125957');

INSERT INTO schema_migrations (version) VALUES ('20081230223546');

INSERT INTO schema_migrations (version) VALUES ('20090115161900');

INSERT INTO schema_migrations (version) VALUES ('20090116000011');

INSERT INTO schema_migrations (version) VALUES ('20090119151911');

INSERT INTO schema_migrations (version) VALUES ('20090119152155');

INSERT INTO schema_migrations (version) VALUES ('20090119213721');

INSERT INTO schema_migrations (version) VALUES ('20090123053401');

INSERT INTO schema_migrations (version) VALUES ('20090201014226');

INSERT INTO schema_migrations (version) VALUES ('20090202221407');

INSERT INTO schema_migrations (version) VALUES ('20090206203404');

INSERT INTO schema_migrations (version) VALUES ('20090222223435');

INSERT INTO schema_migrations (version) VALUES ('20090223133709');

INSERT INTO schema_migrations (version) VALUES ('20090314204631');

INSERT INTO schema_migrations (version) VALUES ('20090331212100');

INSERT INTO schema_migrations (version) VALUES ('20090401204340');

INSERT INTO schema_migrations (version) VALUES ('20090408071820');

INSERT INTO schema_migrations (version) VALUES ('20090410025802');

INSERT INTO schema_migrations (version) VALUES ('20090410045045');

INSERT INTO schema_migrations (version) VALUES ('20090411043621');

INSERT INTO schema_migrations (version) VALUES ('20090424031431');

INSERT INTO schema_migrations (version) VALUES ('20090706014944');

INSERT INTO schema_migrations (version) VALUES ('20090716191359');

INSERT INTO schema_migrations (version) VALUES ('20090826202113');

INSERT INTO schema_migrations (version) VALUES ('20090904015437');

INSERT INTO schema_migrations (version) VALUES ('20090904092933');

INSERT INTO schema_migrations (version) VALUES ('20090904232355');

INSERT INTO schema_migrations (version) VALUES ('20090904234648');

INSERT INTO schema_migrations (version) VALUES ('20090910170024');

INSERT INTO schema_migrations (version) VALUES ('20090928072431');

INSERT INTO schema_migrations (version) VALUES ('20091009095401');

INSERT INTO schema_migrations (version) VALUES ('20091014200120');

INSERT INTO schema_migrations (version) VALUES ('20100502085027');

INSERT INTO schema_migrations (version) VALUES ('20100502172321');

INSERT INTO schema_migrations (version) VALUES ('20100619033524');

INSERT INTO schema_migrations (version) VALUES ('20100908014943');

INSERT INTO schema_migrations (version) VALUES ('20120611141443');

INSERT INTO schema_migrations (version) VALUES ('20130909203911');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');