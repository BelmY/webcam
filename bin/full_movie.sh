#!/bin/bash

######################################################################
# Default values
######################################################################
MUSIC_DIR="/data/music/Kulfoldi/Eric Serra/Le Grand Bleu (vol 1)"
FRAMERATE=30
FRAME_SIZE=640x480
FONT_SIZE=12

TEMP_DIR=`mktemp -d`
source /opt/webcam/encoder.conf

usage()
{
cat <<EOF
usage: $0 options

This script generates movies from webcam pictures,

OPTIONS:
   -b      Set the base directory, which should contain YYYY/MM/DD/HH:MM:SS.jpg 
           subdirectories.  Defaults to ${BASE_RELATIVE_DIR}
   -f      Framerate of movie.  Defaults to $FRAMERATE
   -h      Get help (this message)
   -m      Set the music directory.  Defaults to $MUSIC_DIR
   -q      Disable progress indication
   -v      Verbose output and preserve the temp output
   -x      Set web directory.  Defaults to $WEB_ABSOLUTE_DIR
   -z      Frame size.  Defaults to $FRAME_SIZE
EOF
}

while getopts b:f:hm:qvx:z: o; do
    case "$o" in
	b)	BASE_RELATIVE_DIR="$OPTARG";;
	f)	FRAMERATE="$OPTARG";;
	h)	usage
		exit 1;;
        m)      MUSIC_DIR="$OPTARG";;
        q)	PROGRESS=0;;
        v)      VERBOSE=1;;
        x)      WEB_ABSOLUTE_DIR="$OPTARG";;
        z)      FRAME_SIZE="$OPTARG";;
    esac
done

if [ "$VERBOSE" -eq 1 ] 
    then
    set -x
fi

MOVIE_ABSOLUTE_PATH=${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/full

function createAnnotated {
    srcfile=$1
    frameno=$2
#    ln -s $j ${TEMP_DIR}/`printf %06d $frameno`.jpg
    TARGET_DATE="$(echo $i|rev|cut -c-10|rev|tr '/' '-') $(echo $j|rev|cut -c5-12|rev)"
    PRETTY_DATE=`date -d "$TARGET_DATE" "+%Y. %b %e. %H:%M"`
    #felirat
    convert $j \
	-normalize \
	-gravity NorthWest \
	-font ${FONT} \
	-pointsize ${FONT_SIZE} \
	-fill gray -annotate +10+10 "${PRETTY_DATE}" \
	-fill gray -annotate +9+10 "${PRETTY_DATE}" \
	-fill gray -annotate +9+11 "${PRETTY_DATE}" \
	-fill black -annotate +11+9 "${PRETTY_DATE}" \
	-fill white -annotate +10+10 "${PRETTY_DATE}" \
	${TEMP_DIR}/`printf %06d $frameno`.jpg
}

    frameno=0
    if [ $PROGRESS -eq  1 ]; then
	dayno=0
	days=$(ls -d ${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/????/??/??|wc -l)
    fi
    
    for i in ${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/????/??/??; do 
	# use one hour of footage half an hour after sunrise
#	for j in $(ls $i/??:?[05]:??.jpg|head -n 18|tail -n 12); do
#	    createAnnotated $j $frameno
#	    let "frameno = $frameno + 1"
#	done
	# use one hour of footage half an hour before sunset
	for j in $(ls $i/??:?[05]:??.jpg|tail -n 24|head -n 12); do
	    createAnnotated $j $frameno
	    let "frameno = $frameno + 1"
	done
	if [ $PROGRESS -eq 1 ]; then
	    echo -ne "$dayno/$days $(expr \( $dayno \* 100 \) / $days)%\r"
	    let "dayno = $dayno + 1"
	fi
    done
    if [ $PROGRESS -eq 1 ]; then
	echo ""
    fi

######################################################################
# prepare the music 
######################################################################

    DURATION=`expr $frameno / ${FRAMERATE}`
    MUSIC_PATH=`find "${MUSIC_DIR}" -name \*mp3 | sort -R | tail -n 1`

    # sort -R is random sort
    # tail -n 1 includes only one line

    sox "${MUSIC_PATH}" ${FADE_PATH} fade t 0 $DURATION 8

    # t = linear fade type
    # 0 = no fade in
    # $DURATION is total length of clip
    # 8 = number of seconds before DURATION to begin fading 

    normalize-audio ${FADE_PATH}

    $FFMPEG_PATH -y -r ${FRAMERATE} -s ${FRAME_SIZE} -qscale 3 -i ${TEMP_DIR}/%06d.jpg -i $FADE_PATH -t $DURATION \
      -b 2000k ${FFMPEG_OUTPUT_OPTIONS_MP4_VID} ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD} $MOVIE_ABSOLUTE_PATH.mp4
    $FFMPEG_PATH -y -r ${FRAMERATE} -s ${FRAME_SIZE} -qscale 3 -i ${TEMP_DIR}/%06d.jpg -i $FADE_PATH -t $DURATION \
      -b 2000k ${FFMPEG_OUTPUT_OPTIONS_OGV_VID} ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD} $MOVIE_ABSOLUTE_PATH.ogv

######################################################################
# clean up
######################################################################

if [ "$VERBOSE" -eq 0 ] 
    then
    rm -rf $TEMP_DIR
fi
