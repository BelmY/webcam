#!/bin/bash
while [ 0 = 0 ]
do
    FILENAME=`date +%Y%m%d%H%M%S01`.jpg
    #uvccapture -x640 -y480 -w -o${FILENAME}
    avconv -f video4linux2 -s 640x480 -i /dev/video0 -frames:v 1 ${FILENAME}
    scp ${FILENAME} $1
    rm ${FILENAME}
    sleep 2
done

