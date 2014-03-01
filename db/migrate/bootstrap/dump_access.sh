#!/bin/bash
#
# $Id: dump_access.sh 22 2007-10-15 23:27:36Z nicb $
#
# this script is needed to dump the Access databases into the new mysql one
#
# Usage:
# ./dump_access.sh <table name> <output prefix>
#
USAGE="$0 <table name> <output prefix>"
ACCESS_DIR=./data/access
OUTPUT_DIR=./data/sql
INPUT_FILE="${ACCESS_DIR}/$1"
OUTPUT_PFX="$2"
OUTPUT_TABLES=${OUTPUT_DIR}/${OUTPUT_PFX}-tables.sql.in
OUTPUT_DATA=${OUTPUT_DIR}/${OUTPUT_PFX}-data.sql.in
BACKEND=${BACKEND:-mysql}
DUMP_TABLES="${DUMP_TABLES:-mdb-tables -d '|'}"
DUMP_SCHEMA="${DUMP_SCHEMA:-mdb-schema -S}"
EXPORT_ACCESS=${EXPORT_ACCESS:-mdb-export}
SED=sed

if [ $# -ne 2 ]
then
	echo "Usage: $USAGE" 1>&2
	exit 1
fi

TABLES=$($DUMP_TABLES "$INPUT_FILE" | $SED -e "s/'//g")

$DUMP_SCHEMA "$INPUT_FILE" $BACKEND | $SED -e 's/DROP TABLE/& IF EXISTS/' > $OUTPUT_TABLES || exit 1

> $OUTPUT_DATA
IFS='|'; for i in $TABLES
do
	echo $EXPORT_ACCESS $EXPORT_ACCESS_OPTIONS $INPUT_FILE $i ">>" $OUTPUT_DATA
	$EXPORT_ACCESS -q "'" -S -H -I -D '%Y-%m-%d' $INPUT_FILE "$i" |\
		$SED -e 's/)$/);/' >> $OUTPUT_DATA || exit 1
done

exit 0
