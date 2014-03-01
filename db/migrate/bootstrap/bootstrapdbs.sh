#!/bin/sh
#
# $Id: bootstrapdbs.sh 22 2007-10-15 23:27:36Z nicb $
#

. ./fishrdb_env.sh

MYSQL_ADMIN_USER="${MYSQL_ADMIN_USER:-root}"
DBS="${NEW_DBS}:${OLDDB}"
TMP_STRING="tmp-${RANDOM}.sql"
FISHRDB_HOST="${FISHRDB_HOST:-localhost}"
FISHRDB_USER_HOST="${FISHRDB_USER_HOST:-${FISHRDB_USER}@${FISHRDB_HOST}}"
RM="rm -f"
SECRET_FILE=${SECRET_FILE:-./secret}

trap "$RM $TMP_STRING" EXIT INT

IFS=":"; for i in ${DBS}
do
	echo "(Re)-creating Database $i..." 1>&2
	echo "DROP DATABASE IF EXISTS $i; CREATE DATABASE $i DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
done > $TMP_STRING

#
# the following statement is needed to circumvent the missing
# "DROP USER IF EXISTS" statement in mysql
#
echo "GRANT USAGE ON *.* TO ${FISHRDB_USER_HOST};" >> $TMP_STRING
echo "REVOKE ALL PRIVILEGES, GRANT OPTION from ${FISHRDB_USER_HOST};" >> $TMP_STRING
echo "DROP USER ${FISHRDB_USER_HOST}; FLUSH PRIVILEGES;" >> $TMP_STRING
echo "INSERT INTO mysql.user (Host, User, Password) VALUES ('localhost', '${FISHRDB_USER}', PASSWORD('${FISHRDB_USER}')); FLUSH PRIVILEGES;" >> $TMP_STRING

IFS=":"; for i in ${DBS}
do
	echo "GRANT ALL ON ${i}.* TO ${FISHRDB_USER_HOST};"
done >> $TMP_STRING
echo "FLUSH PRIVILEGES;" >> $TMP_STRING

if [ -r $SECRET_FILE ]
then
	cat $TMP_STRING | $MYSQL -u $MYSQL_ADMIN_USER --password=$(cat $SECRET_FILE) || exit 1
else
	echo "YOU WILL NOW BE ASKED THE $MYSQL_ADMIN_USER ADMINISTRATIVE PASSWORD FOR $(basename ${MYSQL})..."
	cat $TMP_STRING | $MYSQL -u $MYSQL_ADMIN_USER -p || exit 1
fi

exit 0
