#!/bin/sh
#
# $Id: rtunnel.cron.sh 591 2010-12-24 16:13:42Z nicb $
#
# This script checks if a given set of tunneling ports are setup,
# and if they are not they are re-initialized and restarted.
#
# this should be added into the crontab file with a line like this:
#
# 3/15 * * *  *     $FISHRDB_PRO_PATH/rtunnel.cron.sh
#
# (to check every 15 minutes starting at minute 03)
#
HOME=/home/nicb
FROM_PORTS="16222:16223:16224:16225:16226:16227:16228:16229"
RTUNNEL_CLIENT_APPLI="rtunnel_client"
RTUNNEL_CLIENT="/usr/local/bin/$RTUNNEL_CLIENT_APPLI"
TO_ADDR=22
RTUNNEL_SERVER="ssh.sme-ccppd.org"
PGREP="pgrep"

IFS=":"; for port in $FROM_PORTS
do
	pid=$($PGREP -f "${RTUNNEL_CLIENT_APPLI}.*${port}")
	if [ "${pid}xx" = "xx" ]
	then
#		echo "$RTUNNEL_CLIENT -c $RTUNNEL_SERVER -f $port -t $TO_ADDR > /dev/null 2>&1 &"
		$RTUNNEL_CLIENT -c $RTUNNEL_SERVER -f $port -t $TO_ADDR >/dev/null 2>&1 &
		sleep 3
	fi
done

exit 0
