#!/bin/bash

######################################################################
# Default values
######################################################################
source $(dirname $0)/encoder.conf

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

if [ ! -d "${MUSIC_DIR}" ]; then
    echo "Cannot find music dir at: ${MUSIC_DIR}"
    exit 1;
fi

if [ "$VERBOSE" -eq 1 ] 
    then
    set -x
fi
TEMP_DIR=`mktemp -d`

MOVIE_ABSOLUTE_PATH=${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/full
    
    if [ $PROGRESS -eq 1 ]; then
	dayno=0
	days=$(find ${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/ -type d -wholename "${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/????/??/??"|wc -l)
	max=$(find ${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/ -type f -wholename "${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/????/??/??/*.jpg" |wc -l)
    fi
    let "frameNo = 0"
    let "thumbNo = 0"
    for day in `find ${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/ -type d -wholename "${WEB_ABSOLUTE_DIR}/$BASE_RELATIVE_DIR/????/??/??" | sort`; do
	#grab a frame and see if conversion is needed
	RANDOM_FRAME=`find ${day} -name ??:??:??.jpg|head -n1`
#	RANDOM_FRAME=`ls ${day}/??:??:??.jpg|sort -R|head -n1`
	SOURCE_DIMENSION=`identify -verbose ${RANDOM_FRAME} | awk '{ if (/Geometry:/) print gensub(/\+0\+0/, "", "g", $2) }'`
	LINKONLY=`expr "$FRAME_SIZE" == "${SOURCE_DIMENSION}"`
	
	for file in `find ${day} -name ??:??:??_thumb.jpg | sort | head -n 10`; do
		output_path=${TEMP_DIR}/`printf %06d $thumbNo`_thumb.jpg
		ln -s $file ${output_path}
		let "thumbNo = $thumbNo + 1"
		if [ $PROGRESS -eq 1 ]; then
		    echo -ne "$dayno/$days $(expr $frameNo + $thumbNo )/$max $(expr \( \( $frameNo + $thumbNo \) \* 100 \) / $max)%\r"
		fi
	done
	for file in `find ${day} -name ??:??:??.jpg | sort | head -n 10`; do
		output_path=${TEMP_DIR}/`printf %06d $frameNo`.jpg
		if [ "$LINKONLY" == 1 ]; then
		    ln -s $file ${output_path}
		else
		    # error-handle.  If the incoming picture is bad, don't pass on a bad picture
		    CMD=`convert -scale ${FRAME_SIZE} $file ${output_path}`
		    if [ $? != 0 ];  then
			rm ${output_path}
			continue
		    fi
		fi
		let "frameNo = $frameNo + 1"
		if [ $PROGRESS -eq 1 ]; then
		    echo -ne "$dayno/$days $(expr $frameNo + $thumbNo )/$max $(expr \( \( $frameNo + $thumbNo \) \* 100 \) / $max)%\r"
		fi
	done
	let "dayno = $dayno + 1"
    done
    if [ $PROGRESS -eq 1 ]; then
	echo ""
    fi

######################################################################
# prepare the music 
######################################################################

    DURATION=`expr $frameNo / ${FRAMERATE}`
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
