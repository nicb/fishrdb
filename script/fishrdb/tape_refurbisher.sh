#!/bin/sh
#
# $Id: tape_refurbisher.sh 493 2010-04-20 04:28:26Z nicb $
#
TDDIRBASE='public/private/session-notes'
V0DIRBASE="${TDDIRBASE}/version-0"
V1DIRBASE="${TDDIRBASE}/version-1"
REFURBDIR="${V1DIRBASE}/refurbished"

if [ $# -lt 1 ]
then
    echo "Usage: $0 <file tenth radix>" 1>&2
    exit -1
fi

NAMEGLOB="${V0DIRBASE}/*/NMGS0${1}?-*.txt"

for i in $(echo $NAMEGLOB)
do
    name=$(basename $i .txt)
    newdir="$REFURBDIR/$name"
    olddir=$(dirname $i)
    ptname=$(basename $i)
    oldnote=$olddir/note.txt

    mkdir $newdir
    if file $oldnote | grep -sqi 'iso-8859'
    then
        iconv -f iso8859-1 -t utf-8 $oldnote | sed -e '/Studio Schiavoni:$/s//Studio Schiavoni (Bernardini, Schiavoni):/' > $newdir/note.txt
    else
        cat $oldnote | sed -e '/Studio Schiavoni:$/s//Studio Schiavoni (Bernardini, Schiavoni):/' > $newdir/note.txt
    fi
    tr '\r' '\n' < $i > $newdir/$ptname
    echo $name
done

exit 0
