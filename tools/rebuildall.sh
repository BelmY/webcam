#!/bin/bash
cd /var/www/webcam/webcam/
MUSIC="/data/music/Kulfoldi/Eric Serra/Le Grand Bleu (vol 1)"
for i in ????/??; do
  d=`echo $i|tr -d /`
  /opt/webcam/monthly_movie.sh -z640x480 -o "" -m "${MUSIC}" -1 -f 10 -i 1 -d ${d}01
done
#for i in ????/??/??; do
#  d=`echo $i|tr -d /`
#  /opt/webcam/daily_movie.sh -z640x480 -o "" -m "${MUSIC}" -1 -f 10 -i 1 -d $d
#done
