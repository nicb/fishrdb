#
# $Id: gitversions.sh 229 2008-07-08 20:38:01Z nicb $
#
# This script is used to mark down the releases of git repositories into a
# STATUS.log file (to be committed under svn), in order to be able to have
# identical repositories in production deployment.
#
ECHO='/bin/echo -e'
HERE=$(pwd)
RAILS_ROOT=${RAILS_ROOT:-$HERE}
VENDORDIR="$RAILS_ROOT/vendor"
PLUGINDIR=$VENDORDIR/plugins
STATUSFILE=$VENDORDIR/STATUS.log


cat > $STATUSFILE << EOF
#
# \$Id: gitversions.sh 229 2008-07-08 20:38:01Z nicb $
#
# This file has been produced automatically by the gitversions.sh script
#
EOF

HERE=$(pwd)
for i in $VENDORDIR/rails $PLUGINDIR/*/
do
    cd $i
    if [ -d .git ]
    then
       name=$(basename $i)
       ($ECHO -n "${name}:\t"; git log | head -1) >> $STATUSFILE
    fi
    cd $HERE
done

exit 0
