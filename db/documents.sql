/*
 * $Id: documents.sql 103 2007-12-11 05:26:57Z nicb $
 *
 * Document is used to have a common id system between nodes and documents.
 * It has a polymorphic association with the kind of documents we have in the
 * archives.
 * This is a condition to make the LiveTree work
 */

DROP TABLE IF EXISTS documents;
CREATE TABLE documents (
    /*
	 * Common Document Part
	 */
	id						INT NOT NULL AUTO_INCREMENT,
	parent_id				INT DEFAULT NULL COMMENT 'NULL = root node',
	type				 	VARCHAR(128) NOT NULL /* inheritance sub-class */,
	creator_id				INT NOT NULL COMMENT 'Connected to the User table',
	last_modifier_id		INT NOT NULL COMMENT 'Connected to the User table',
	created_at 				TIMESTAMP NOT NULL,
	updated_at				TIMESTAMP NOT NULL,
	description_level_id	INT NOT NULL COMMENT 'Connected to the Description Level table',
	position				INT NOT NULL,
	children_ordering		ENUM('logic','timeasc','timedesc','alpha','location') NOT NULL DEFAULT 'logic',
	lock_version			INT DEFAULT 0,
	record_locked			ENUM('Y','N') NOT NULL DEFAULT 'N',
	documents_count			INT DEFAULT 0,
												   PRIMARY KEY (id),
	CONSTRAINT				fk_doc_parent		   FOREIGN KEY (parent_id) REFERENCES documents(id),
	CONSTRAINT				fk_doc_creator 	   	   FOREIGN KEY (creator_id) REFERENCES users(id),
	CONSTRAINT				fk_doc_last_modifier   FOREIGN KEY (last_modifier_id) REFERENCES users(id),
	CONSTRAINT				fk_doc_dl			   FOREIGN KEY (description_level_id) REFERENCES description_levels(id),
	/*
	 * Folder + Series + Scores + ... common Part
	 */
	name					VARCHAR(1024) COLLATE UTF8_UNICODE_CI NOT NULL,
	description				TEXT COLLATE UTF8_UNICODE_CI,
	description_reserved	ENUM('yes','no') NOT NULL DEFAULT 'no',
	data_dal				DATE DEFAULT NULL, 
	data_al					DATE DEFAULT NULL, 
	data_visualizzata		VARCHAR(128) DEFAULT NULL,
	nota_data				VARCHAR(128) DEFAULT NULL,
	data_topica				VARCHAR(256) DEFAULT NULL,
	/*
	 * Series + Scores + ... common Part
	 */
	container_type_id			int(11) NOT NULL COMMENT 'Connected to the Container Type table',
	container_number			int(11) DEFAULT NULL, 
	CONSTRAINT					fk_doc_cti		FOREIGN KEY (container_type_id) REFERENCES container_types(id),
	corda						varchar(128) default NULL COMMENT 'Only from description_level_id > Fascicolo',
	consistenza					varchar (100) DEFAULT NULL, 
	/*
	 * Series Part
	 */
	chiavi_accesso_series		varchar (1024) DEFAULT NULL COMMENT 'This will become an authority file',
	nomi_series					varchar (1024) DEFAULT NULL COMMENT 'This will become an authority file',
	enti_series					varchar (1024) DEFAULT NULL COMMENT 'This will become an authority file',
	luoghi_series				varchar (1024) DEFAULT NULL COMMENT 'This will become an authority file',
	titoli_series				varchar (1024) DEFAULT NULL COMMENT 'This will become an authority file',
	/*
	 * Score Part
	 */
	tipologia_documento_score	varchar(256) DEFAULT NULL,
	misure_score				varchar(128) DEFAULT NULL,
	autore_score				varchar(256) DEFAULT NULL,
	organico_score				varchar(512) DEFAULT NULL,
	anno_composizione_score		date DEFAULT NULL,
	edizione_score				varchar(256) DEFAULT NULL,
	anno_edizione_score			date DEFAULT NULL,
	luogo_edizione_score		varchar(256) DEFAULT NULL,
	trascrittore_score			varchar(256) DEFAULT NULL,
	note_score					text DEFAULT NULL,
    autore_versi_score			varchar(256) DEFAULT NULL,
	titolo_uniforme_score		varchar(1024) DEFAULT NULL COMMENT 'Will be connected to an authority file'
) TYPE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;
