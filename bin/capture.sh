#!/bin/bash
# capture a photo from the webcam
WEB_ABSOLUTE_DIR=/var/www/webcam
CAM_RELATIVE_DIR=webcam
IP_CAM=cam.home
VERBOSE=0

######################################################################
# command line inputs
######################################################################

if [ "${VERBOSE}" == "1" ] 
    then
    set -x
fi

YEAR_STRING=`date +%Y`
MONTH_STRING=`date +%m`
DAY_STRING=`date +%d`
PIC_ABSOLUTE_DIR=${WEB_ABSOLUTE_DIR}/${CAM_RELATIVE_DIR}/${YEAR_STRING}/${MONTH_STRING}/${DAY_STRING}
if [ ! -d ${PIC_ABSOLUTE_DIR} ]; then mkdir -p ${PIC_ABSOLUTE_DIR} ; fi
BASE=`date +%H:%M:%S`
FILE_NAME=${BASE}.jpg
THUMB_NAME=${BASE}_thumb.jpg
PIC_ABSOLUTE_PATH=${PIC_ABSOLUTE_DIR}/${FILE_NAME}
THUMB_ABSOLUTE_PATH=${PIC_ABSOLUTE_DIR}/${THUMB_NAME}

wget -q --connect-timeout=5 http://${IP_CAM}/cgi-bin/snapshot.cgi?stream=0 -O${PIC_ABSOLUTE_PATH} || rm ${PIC_ABSOLUTE_PATH}
wget -q --connect-timeout=5 http://${IP_CAM}/cgi-bin/snapshot.cgi?stream=1 -O${THUMB_ABSOLUTE_PATH} || rm ${THUMB_ABSOLUTE_PATH}
if [ ! -s  ${PIC_ABSOLUTE_PATH} ]; then rm ${THUMB_ABSOLUTE_PATH}; fi
if [ ! -s  ${THUMB_ABSOLUTE_PATH} ]; then rm ${PIC_ABSOLUTE_PATH}; fi