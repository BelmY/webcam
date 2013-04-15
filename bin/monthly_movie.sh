#!/bin/bash
# make a movie out of the pictures for the specified month
######################################################################
# Default values
######################################################################

TARGET_DATE=0
FRAMERATE=30
DURATION=0
VERBOSE=0
FRAME_SIZE='1920x1080'
OFFSET='+792+477'
MONTAGE_HEIGHT=18
MAKE_MOVIE=0
UPDATE_INDEX=0
REPLACE_SOUNDTRACK=0

TEMP_DIR=`mktemp -d`

source /opt/webcam/encoder.conf

######################################################################
# command line inputs
######################################################################

usage()
{
cat <<EOF
usage: $0 options

This script generates movies from webcam pictures,

OPTIONS:
   -a      Time(s) to use in month view
   -b      Set the base directory, which should contain YYYY/MM/DD/HH:MM:SS.jpg 
           subdirectories.  Defaults to ${BASE_RELATIVE_DIR}
   -d      Set the target date, as YYYYMMDD.  Defaults to yesterday
   -f      Framerate of movie.  Defaults to $FRAMERATE
   -h      Get help (this message)
   -m      Set the music directory.  Defaults to $MUSIC_DIR
   -o      Offset for cropping.  Set to zero to scale instead of crop.  
           Defaults to $OFFSET
   -q      Disable progress indication
   -v      Verbose output and preserve the temp output
   -x      Set web directory.  Defaults to $WEB_ABSOLUTE_DIR
   -z      Frame size.  Defaults to $FRAME_SIZE
   -1      Make the movie
   -2      Update the web page indexes
   -0      Replace soundtrack on existing movie.  Overrides any of 1
EOF
}

while getopts a:b:d:f:hi:m:o:qvx:z:012 o; do
    case "$o" in
	a)      MONTAGE_HEIGHT="$OPTARG";;
	b)	BASE_RELATIVE_DIR="$OPTARG";;
	d)	TARGET_DATE="$OPTARG";;
	f)	FRAMERATE="$OPTARG";;
	h)	usage
		exit 1;;
        m)      MUSIC_DIR="$OPTARG";;
	o)      OFFSET="$OPTARG";;
        q)	PROGRESS=0;;
        v)      VERBOSE=1;;
        x)      WEB_ABSOLUTE_DIR="$OPTARG";;
        z)      FRAME_SIZE="$OPTARG";;
        1)      MAKE_MOVIE=1;;
        2)      UPDATE_INDEX=1;;
        0)      REPLACE_SOUNDTRACK=1
		MAKE_MOVIE=0
		UPDATE_INDEX=0
    esac
done

if [ "$VERBOSE" -eq 1 ] 
    then
    set -x
fi

if [ "$TARGET_DATE" -eq 0 ]  
    then
    TARGET_DATE=`date +%Y-%m-%d`
else
    TARGET_DATE=`date -d $TARGET_DATE +%Y-%m-%d`
fi

PRETTY_DATE=`date -d $TARGET_DATE +%e\ %b\ %Y`
PRETTY_MONTH=`date -d $TARGET_DATE +%b\ %Y`
YEAR=`date -d $TARGET_DATE +%Y`
MONTH=`date -d $TARGET_DATE +%m`

BASE_ABSOLUTE_DIR=${WEB_ABSOLUTE_DIR}/${BASE_RELATIVE_DIR}
YEAR_ABSOLUTE_DIR=${BASE_ABSOLUTE_DIR}/${YEAR}
YEAR_RELATIVE_DIR=${BASE_RELATIVE_DIR}/${YEAR}
MONTH_ABSOLUTE_DIR=${YEAR_ABSOLUTE_DIR}/${MONTH}
MONTH_RELATIVE_DIR=${YEAR_RELATIVE_DIR}/${MONTH}

MOVIE_NAME=${YEAR}-${MONTH}
MOVIE_LOW_NAME=${YEAR}-${MONTH}_low
MOVIE_ABSOLUTE_PATH=${YEAR_ABSOLUTE_DIR}/${MOVIE_NAME}
MOVIE_RELATIVE_PATH=${YEAR_RELATIVE_DIR}/${MOVIE_NAME}
MOVIE_LOW_ABSOLUTE_PATH=${YEAR_ABSOLUTE_DIR}/${MOVIE_LOW_NAME}
MOVIE_LOW_RELATIVE_PATH=${YEAR_RELATIVE_DIR}/${MOVIE_LOW_NAME}

THUMB_ABSOLUTE_PATH=${YEAR_ABSOLUTE_DIR}/${YEAR}-${MONTH}_thumb.jpg
THUMB_RELATIVE_PATH=${YEAR_RELATIVE_DIR}/${YEAR}-${MONTH}_thumb.jpg
THUMB_DATED_ABSOLUTE_PATH=${YEAR_ABSOLUTE_DIR}/${YEAR}-${MONTH}_thumb_dated.jpg
THUMB_DATED_RELATIVE_PATH=${YEAR_RELATIVE_DIR}/${YEAR}-${MONTH}_thumb_dated.jpg
MONTH_THUMB_ABSOLUTE_PATH=${YEAR_ABSOLUTE_DIR}/${YEAR}-${MONTH}_thumb.jpg
MONTH_THUMB_RELATIVE_PATH=${YEAR_RELATIVE_DIR}/${YEAR}-${MONTH}_thumb.jpg
MONTH_THUMB_DATED_ABSOLUTE_PATH=${YEAR_ABSOLUTE_DIR}/${YEAR}-${MONTH}_thumb_dated.jpg
MONTH_THUMB_DATED_RELATIVE_PATH=${YEAR_RELATIVE_DIR}/${YEAR}-${MONTH}_thumb_dated.jpg

if [ "$MAKE_MOVIE" -eq 1 ]
then
    ######################################################################
    # prepare input files for ffmpeg
    ######################################################################

    #grab a frame and see if conversion is needed
    RANDOM_FRAME=`ls ${MONTH_ABSOLUTE_DIR}/??/??:??:??.jpg|sort -R|head -n1`
    SOURCE_DIMENSION=`identify -verbose ${RANDOM_FRAME} | awk '{ if (/Geometry:/) print gensub(/\+0\+0/, "", "g", $2) }'`
    LINKONLY=`expr "$FRAME_SIZE" == "${SOURCE_DIMENSION}"`

    let "i = 0"
    dayno=0
    if [ $PROGRESS -eq 1 ]; then
	days=$(ls -d ${MONTH_ABSOLUTE_DIR}/??|wc -l)
	let "max = $(ls -d ${MONTH_ABSOLUTE_DIR}/??|wc -l) * 60"
    fi
    for day in `ls -d ${MONTH_ABSOLUTE_DIR}/??`; do
	for file in `ls ${day}/??:??:??.jpg | tail -n 90| head -n 60`; do
		output_path=${TEMP_DIR}/`printf %06d $i`.jpg
		FORMATED_DATE=`date -d "$(echo $file|rev|cut -c14-23|rev|tr '/' '-') $(echo $file|rev|cut -c5-12|rev)" "+%Y. %b %e. %H:%M"`
		if [ "$LINKONLY" == 1 ]; then
#			ln -s $file ${output_path}
		    CMD=`convert $file \
			-normalize \
			-gravity NorthWest \
			-font ${FONT} \
			-pointsize 12 \
			-fill gray -annotate +10+10 "${FORMATED_DATE}" \
			-fill gray -annotate +9+10 "${FORMATED_DATE}" \
			-fill gray -annotate +9+11 "${FORMATED_DATE}" \
			-fill black -annotate +11+9 "${FORMATED_DATE}" \
			-fill white -annotate +10+10 "${FORMATED_DATE}" \
			${output_path}`
		    if [ $? != 0 ]; then
			rm ${output_path}
			continue
		    fi
		else
		    # error-handle.  If the incoming picture is bad, don't pass on a bad picture
#		    CMD=`convert -scale ${FRAME_SIZE} $file ${output_path}`
		    CMD=`convert -scale ${FRAME_SIZE} $file \
			-normalize \
			-gravity NorthWest \
			-font ${FONT} \
			-pointsize 12 \
			-fill gray -annotate +10+10 "${FORMATED_DATE}" \
			-fill gray -annotate +9+10 "${FORMATED_DATE}" \
			-fill gray -annotate +9+11 "${FORMATED_DATE}" \
			-fill black -annotate +11+9 "${FORMATED_DATE}" \
			-fill white -annotate +10+10 "${FORMATED_DATE}" \
			${output_path}`
		    if [ $? != 0 ];  then
			rm ${output_path}
			continue
		    fi
		fi
		let "i = $i + 1"
		if [ $PROGRESS -eq 1 ]; then
		    echo -ne "$dayno/$days $i/$max $(expr \( $i \* 100 \) / $max)%\r"
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

    DURATION=`expr $i / ${FRAMERATE}`
    MUSIC_PATH=`find "${MUSIC_DIR}" -name \*mp3 | sort -R | tail -n 1`

    # sort -R is random sort
    # tail -n 1 includes only one line

    sox "${MUSIC_PATH}" ${FADE_PATH} fade t 0 $DURATION 8

    # t = linear fade type
    # 0 = no fade in
    # $DURATION is total length of clip
    # 8 = number of seconds before DURATION to begin fading 

    normalize-audio ${FADE_PATH}

    ######################################################################
    # make the movie
    ######################################################################

    $FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -r ${FRAMERATE} -s ${FRAME_SIZE} -qscale 3 -i ${TEMP_DIR}/%06d.jpg -i $FADE_PATH -t $DURATION \
      -b 2000k ${FFMPEG_OUTPUT_OPTIONS_MP4_VID} ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD} $MOVIE_ABSOLUTE_PATH.mp4
    $FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -r ${FRAMERATE} -s ${FRAME_SIZE} -qscale 3 -i ${TEMP_DIR}/%06d.jpg -i $FADE_PATH -t $DURATION \
      -b 2000k ${FFMPEG_OUTPUT_OPTIONS_OGV_VID} ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD} $MOVIE_ABSOLUTE_PATH.ogv
    # -r output framerate
    # -i input files (pictures and sound)
    # -s size
    # -qscale quality
    # -t duration
    # -y overwrite output

    # make the low-def version
    $FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -i $MOVIE_ABSOLUTE_PATH.mp4 -fs 5000000 -s 320x240 \
      -acodec copy ${FFMPEG_OUTPUT_OPTIONS_MP4_VID} $MOVIE_LOW_ABSOLUTE_PATH.mp4
    $FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -i $MOVIE_ABSOLUTE_PATH.ogv -fs 5000000 -s 320x240 \
      -acodec copy ${FFMPEG_OUTPUT_OPTIONS_OGV_VID} $MOVIE_LOW_ABSOLUTE_PATH.ogv
    # -fs maximum output file size
fi

if [ "$UPDATE_INDEX" -eq 1 ]; then
        #####################################################################
        # rebuild the movie thumbnail for the day
        #####################################################################

	convert $STRIP_ABSOLUTE_PATH -resize x${MONTAGE_HEIGHT} $THUMB_ABSOLUTE_PATH

	convert $STRIP_ABSOLUTE_PATH \
	    -resize x${MONTAGE_HEIGHT} \
	    -gravity center \
	    -font ${FONT} \
	    -pointsize ${FONT_SIZE} \
	    -fill gray -annotate +1+1 "${PRETTY_DATE}" \
	    -fill gray -annotate -1-1 "${PRETTY_DATE}" \
	    -fill gray -annotate -1+1 "${PRETTY_DATE}" \
	    -fill black -annotate +1-1 "${PRETTY_DATE}" \
	    -fill white -annotate +0+0 "${PRETTY_DATE}" \
	    $THUMB_DATED_ABSOLUTE_PATH

fi

if [ "$REPLACE_SOUNDTRACK" -eq 1 ]; then
    # TODO: duplicates previous code; ought to be in a function
    ffmpeg_duration=`$FFMPEG_PATH -i $MOVIE_ABSOLUTE_PATH.mp4 2>&1 | grep Duration`
    minutes=`echo $ffmpeg_duration | grep -o ':[0-9]\{2\}:' | grep -o '[0-9]\{2\}'`
    seconds=`echo $ffmpeg_duration | grep -o ':[0-9]\{2\}\.' | grep -o '[0-9]\{2\}'`
    DURATION=`expr $minutes \* 60 + $seconds`

    # TODO: duplicates previous code; ought to be in a function
    MUSIC_PATH=`find $MUSIC_DIR -name \*mp3 | sort -R | tail -n 1`
    sox "$MUSIC_PATH" $FADE_PATH fade t 0 $DURATION 8
    normalize-audio $FADE_PATH
    $FFMPEG_PATH -y -i $MOVIE_ABSOLUTE_PATH.mp4 -i $FADE_PATH -map 0:0 -map 1:0 -vcodec copy ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD} $TEMP_DIR/hd.mp4
    $FFMPEG_PATH -y -i $MOVIE_LOW_ABSOLUTE_PATH.mp4 -i $FADE_PATH -map 0:0 -map 1:0 -vcodec copy ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD}  $TEMP_DIR/low.mp4
    $FFMPEG_PATH -y -i $MOVIE_ABSOLUTE_PATH.ogv -i $FADE_PATH -map 0:0 -map 1:0 -vcodec copy ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD} $TEMP_DIR/hd.ogv
    $FFMPEG_PATH -y -i $MOVIE_LOW_ABSOLUTE_PATH.ogv -i $FADE_PATH -map 0:0 -map 1:0 -vcodec copy ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD}  $TEMP_DIR/low.ogv
    mv $TEMP_DIR/hd.mp4 $MOVIE_ABSOLUTE_PATH.mp4
    mv $TEMP_DIR/low.mp4 $MOVIE_LOW_ABSOLUTE_PATH.mp4
    mv $TEMP_DIR/hd.ogv $MOVIE_ABSOLUTE_PATH.ogv
    mv $TEMP_DIR/low.ogv $MOVIE_LOW_ABSOLUTE_PATH.ogv
fi

######################################################################
# clean up
######################################################################
if [ "$VERBOSE" -eq 0 ]; then
    rm -rf $TEMP_DIR
fi
