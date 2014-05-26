#!/bin/bash
# capture a photo from the webcam
WEB_ABSOLUTE_DIR=/var/www/webcam
CAM_RELATIVE_DIR=webcam
IP_CAM=cam.home
VERBOSE=0

source $(dirname $0)/encoder.conf

######################################################################
# command line inputs
######################################################################
while getopts v o
do	
    case "$o" in
        v)      VERBOSE=1;;
    esac
done


if [ "${VERBOSE}" == "1" ] 
    then
    set -x
fi

YEAR_STRING=`date +%Y`
MONTH_STRING=`date +%m`
DAY_STRING=`date +%d`
PIC_ABSOLUTE_DIR=${WEB_ABSOLUTE_DIR}/${CAM_RELATIVE_DIR}/${YEAR_STRING}/${MONTH_STRING}/${DAY_STRING}
MOVIE_ABSOLUTE_PATH=${WEB_ABSOLUTE_DIR}/${CAM_RELATIVE_DIR}/${YEAR_STRING}/${MONTH_STRING}/${YEAR_STRING}-${MONTH_STRING}-${DAY_STRING}
if [ ! -d ${PIC_ABSOLUTE_DIR} ]; then mkdir -p ${PIC_ABSOLUTE_DIR} ; fi
BASE=`date +%H:%M:%S`
FILE_NAME=${BASE}.jpg
THUMB_NAME=${BASE}_thumb.jpg
PIC_ABSOLUTE_PATH=${PIC_ABSOLUTE_DIR}/${FILE_NAME}
THUMB_ABSOLUTE_PATH=${PIC_ABSOLUTE_DIR}/${THUMB_NAME}

function appendframe {
    MOVIE=$1
    PICS=$2
    FRAME=$3
    OPTIONS=$4

    if [ -e ${MOVIE} ]; then 
        mv ${MOVIE} ${MOVIE}.orig
	$FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -r ${FRAMERATE} -qscale 3 -i ${MOVIE}.orig -i ${FRAME} \
          -b 2000k ${OPTIONS} ${MOVIE}
	rm ${MOVIE}.orig
    else
	TEMP_DIR=`mktemp -d`
	counter=0
	for i in ${PICS}; do 
	    output_path=${TEMP_DIR}/`printf %06d $counter`.jpg
	    ln -s $i $output_path
	    let "counter = $counter + 1"
	done
	$FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -r ${FRAMERATE} -qscale 3 -i "${TEMP_DIR}/%06d.jpg" \
          -b 2000k ${OPTIONS} ${MOVIE}
        rm -rf $TEMP_DIR
    fi
}

wget -q --connect-timeout=5 http://${IP_CAM}/cgi-bin/snapshot.cgi?stream=0 -O${PIC_ABSOLUTE_PATH}
RES=$?
if [[ $RES -eq 0 ]]; then
    appendframe ${MOVIE_ABSOLUTE_PATH}.mp4 "${PIC_ABSOLUTE_DIR}/??:??:??.jpg" ${PIC_ABSOLUTE_PATH} "${FFMPEG_OUTPUT_OPTIONS_MP4_VID} ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD}"
    appendframe ${MOVIE_ABSOLUTE_PATH}.ogv "${PIC_ABSOLUTE_DIR}/??:??:??.jpg" ${PIC_ABSOLUTE_PATH} "${FFMPEG_OUTPUT_OPTIONS_OGV_VID} ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD}"
else 
    echo rm ${PIC_ABSOLUTE_PATH}
fi

wget -q --connect-timeout=5 http://${IP_CAM}/cgi-bin/snapshot.cgi?stream=1 -O${THUMB_ABSOLUTE_PATH}
RES=$?
if [[ $RES -eq 0 ]]; then 
    appendframe ${MOVIE_ABSOLUTE_PATH}_low.mp4 "${PIC_ABSOLUTE_DIR}/??:??:??_thumb.jpg" ${THUMB_ABSOLUTE_PATH} "${FFMPEG_OUTPUT_OPTIONS_MP4_VID} ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD}"
    appendframe ${MOVIE_ABSOLUTE_PATH}_low.ogv "${PIC_ABSOLUTE_DIR}/??:??:??_thumb.jpg" ${THUMB_ABSOLUTE_PATH} "${FFMPEG_OUTPUT_OPTIONS_OGV_VID} ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD}"
else
    echo rm ${THUMB_ABSOLUTE_PATH}
fi

if [ ! -s  ${PIC_ABSOLUTE_PATH} ]; then rm ${THUMB_ABSOLUTE_PATH}; fi
if [ ! -s  ${THUMB_ABSOLUTE_PATH} ]; then rm ${PIC_ABSOLUTE_PATH}; fi

