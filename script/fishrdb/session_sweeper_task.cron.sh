#!/bin/sh
#
# $Id: session_sweeper_task.cron.sh 202 2008-04-15 09:49:01Z nicb $
#
RAILS_ENV=${RAILS_ENV:-production}

echo 'delete from sessions where now() - updated_at > 14400;' |\
        mysql -u fishrdb --password=fishrdb fishrdb_${RAILS_ENV} >/dev/null 2>&1

exit $?
