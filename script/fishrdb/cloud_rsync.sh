#!/bin/sh
#
# This backs up over to the cloud
#
#
HOME=${HOME:-/home/nicb}
TMPDIR=$HOME/tmp
LOGFILE=$TMPDIR/cloud_tape_backup.log
RSYNC="rsync -avz --log-file=${LOGFILE}"
LOCAL=tapes_lofi/1
REMOTE=tapes_lofi/.
REMOTE_CLOUD=ca@fiscloud

. $TMPDIR/agent # load agent keys

cd $HOME

$RSYNC $LOCAL $REMOTE_CLOUD:$REMOTE

exit 0
