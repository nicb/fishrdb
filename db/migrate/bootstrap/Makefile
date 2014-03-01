#
# $Id: Makefile 32 2007-10-24 17:46:50Z nicb $
#
BOOTSTRAP_DBS=./bootstrapdbs.sh
RECREATE_DB=./re-createdb
CLEANSE_DB=./cleanse-db.rb
CONVERTDB=./convertdb.rb
CONVERTDATA=./convertdata.rb
REORDERDATA=./reorder-tree.rb
UGLY_HACKS=./ugly_hacks.sh
DUMP_ACCESS_FILES=./dump_access.sh
CLEANSED_DATA_DIR=./data/sql
CLEANSED_DATA=$(CLEANSED_DATA_DIR)/ArchivioMusicaAltriAutori-data.sql \
					$(CLEANSED_DATA_DIR)/ArchivioMusicaGS-data.sql\
					$(CLEANSED_DATA_DIR)/Serie-data.sql\
					$(CLEANSED_DATA_DIR)/ArchivioMusicaAltriAutori-tables.sql\
					$(CLEANSED_DATA_DIR)/ArchivioMusicaGS-tables.sql\
					$(CLEANSED_DATA_DIR)/Serie-tables.sql
CLEANSABLE_DATA=$(CLEANSED_DATA:.sql=.sql.in)
CLEANABLE_FILES=$(CLEANSED_DATA) $(CLEANSABLE_DATA)
MYSQL=mysql -u fishrdb --password=fishrdb
MYSQLDUMP=mysqldump -u fishrdb --password=fishrdb

all:	bootstrap create_new_db

bootstrap:
	$(BOOTSTRAP_DBS)

create_new_db:	recreate_fisold_db
	$(CONVERTDB)
	$(CONVERTDATA)
	$(REORDERDATA)
	$(UGLY_HACKS) development

recreate_fisold_db: $(CLEANSED_DATA)
	$(RECREATE_DB)

$(CLEANSABLE_DATA): raw_conversion

raw_conversion:
	$(DUMP_ACCESS_FILES) "SERIE DATABASE.mdb" Serie
	$(DUMP_ACCESS_FILES) "ARCHIVIO MUSICA ALTRI AUTORI.mdb" ArchivioMusicaAltriAutori
	$(DUMP_ACCESS_FILES) "ARCHIVIO MUSICA GS.mdb" ArchivioMusicaGS

$(CLEANSED_DATA): $(CLEANSABLE_DATA)

clone_test:
	$(MYSQLDUMP) fishrdb_development | $(MYSQL) fishrdb_test

clean:
	$(RM) $(CLEANABLE_FILES)

.PHONY: bootstrap create_new_db replicate_dbs raw_conversion clone_test

.SUFFIXES: .sql .sql.in

%.sql:	%.sql.in
	$(CLEANSE_DB) $< > $@
