#!/bin/sh
TARGET_DATE=0
VERBOSE=0

usage()
{
cat <<EOF
usage: $0 options

This script removes webcam pictures, and removes images with brightness under 10

OPTIONS:
   -d      Set the target date, as YYYYMMDD.  Defaults to yesterday
   -v      Be verbose
EOF
}

while getopts d:h:v o
do
    case "$o" in
        d)      TARGET_DATE="$OPTARG";;
	h)	usage; exit;;
        v)	VERBOSE=1;;
    esac
done

if [ "$VERBOSE" -eq 1 ]
   then
	set -x
fi

if [ "$TARGET_DATE" -eq 0 ]
    then
    TARGET_DATE=`date  +%Y-%m-%d`
else
    TARGET_DATE=`date -d $TARGET_DATE +%Y-%m-%d`
fi

for i in `ls /var/www/webcam/webcam/$(echo "${TARGET_DATE}"|sed 's+-+/+g')/??:??:??_thumb.jpg`; do
  BRIGHTNESS=`convert $i -colorspace hsb  -resize 1x1  txt:-|tail -n1|cut -d, -f3|cut -d\) -f1`
  if [ "$BRIGHTNESS" -lt 10 ]; then
	rm $i $(echo $i|sed "s/_thumb.jpg/.jpg/g")
  fi;
done
