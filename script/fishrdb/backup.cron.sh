#!/bin/sh
#
# $Id$
#
# this should be added into the crontab file with a line like this:
#
# 30 14 * *  *     $FISHRDB_PRO_PATH/backup.cron.sh
#
HOME=/home/nicb
BACKUP_DIR=$HOME/backups
LAST_BACKUP=LAST_BACKUP
BACKUP_NAME="FISHRDB_BACKUP-$(date '+%Y%m%d%H%M%s').mysql.bz2"
BACKUP_TEMP_NAME="${BACKUP_NAME}.temp"
CMP_TEMP_NAME="${BACKUP_TEMP_NAME}.ASCII_stripped"
CMP_TEMP_NAME_SRC="${CMP_TEMP_NAME}.src"
CMP_TEMP_NAME_DST="${CMP_TEMP_NAME}.dst"
DB=fishrdb_production
MYSQLOPTS="-u fishrdb --password=fishrdb"
MYSQLDUMP="mysqldump $MYSQLOPTS"
MYSQL="mysql $MYSQLOPTS"
COMPRESS="bzip2 -9"
REMOTE_DEST="nicb@ssh.sme-ccppd.org:Storage/backups/fishrdb/database/."

cd $BACKUP_DIR
($MYSQLDUMP $DB | $COMPRESS > $BACKUP_TEMP_NAME) || exit -1 
bunzip2 -c $LAST_BACKUP | sed '/^-- Dump completed on/d' > $CMP_TEMP_NAME_SRC
bunzip2 -c $BACKUP_TEMP_NAME | sed '/^-- Dump completed on/d' > $CMP_TEMP_NAME_DST
if cmp -s $CMP_TEMP_NAME_SRC $CMP_TEMP_NAME_DST
then
	rm $BACKUP_TEMP_NAME
else
	rm $LAST_BACKUP
	mv $BACKUP_TEMP_NAME $BACKUP_NAME
	scp -q $BACKUP_NAME $REMOTE_DEST
	ln -s $BACKUP_NAME $LAST_BACKUP
fi
rm $CMP_TEMP_NAME_SRC $CMP_TEMP_NAME_DST

exit 0
