#!/bin/sh
#
# $Id: sub_tunnels.sh 417 2009-06-26 09:52:13Z nicb $
#
#
CHANNELS="16322:3000 16323:3010"
INTF=eth0
IP=$(ifconfig $INTF | grep 'inet addr' | cut -d ' ' -f 12 | cut -d ':' -f 2)

for i in $CHANNELS
do
    REMOTE_PORT=$(echo $i | cut -d ':' -f 1)
    LOCAL_PORT=$(echo $i | cut -d ':' -f 2)
    echo ssh -fnNT -R $REMOTE_PORT:${IP}:$LOCAL_PORT nicb@ssh.sme-ccppd.org
    ssh -fnNT -R $REMOTE_PORT:${IP}:$LOCAL_PORT nicb@ssh.sme-ccppd.org
done

exit 0
