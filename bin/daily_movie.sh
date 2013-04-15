#!/bin/bash
# make a movie out of the pictures for the specified day

######################################################################
# Default values
######################################################################

TARGET_DATE=0
FRAMERATE=30
DURATION=0
VERBOSE=0
MONTAGE_FRAME_COUNT=24
MONTAGE_INTERVAL=
TAPESTRY_DIM=64x36
MONTAGE_HEIGHT=18
MONTAGE_WHITESPACE=+0+0
MONTAGE_MINIMUM=25
FRAME_SIZE='1920x1080'
PIP_SIZE='640x480'
OFFSET='+792+477'
SECOND_PIC_DIR=
MAKE_MOVIE=0
MAKE_MONTAGE=0
UPDATE_INDEX=0
REPLACE_SOUNDTRACK=0
MONTH_THUMB_WIDTH=256

TEMP_DIR=`mktemp -d`
PIP_RESIZE_PATH=${TEMP_DIR}/pip.jpg
ANNOTATE=

source /opt/webcam/encoder.conf
######################################################################
# command line inputs
######################################################################

usage()
{
cat <<EOF
usage: $0 options

This script generates movies from webcam pictures, and makes montage indexes

OPTIONS:
   -a      Set height of montage strips.  Defaults to ${MONTAGE_HEIGHT}
   -b      Set the base directory, which should contain YYYY/MM/DD/HH:MM:SS.jpg 
           subdirectories.  Defaults to ${BASE_RELATIVE_DIR}
   -d      Set the target date, as YYYYMMDD.  Defaults to yesterday
   -e      Interval between montage pictures, in seconds.  Only used if 
           montage frame count is blank.  Defaults to blank.
   -f      Framerate of movie.  Defaults to $FRAMERATE
   -h      Get help (this message)
   -i      Minimum number of seconds for montage, below which montage is skipped.  
           Defaults to $MONTAGE_MINIMUM
   -m      Set the music directory.  Defaults to $MUSIC_DIR
   -n      Number of frames to use in montage.  Defaults to $MONTAGE_FRAME_COUNT
   -o      Offset for cropping.  Set to zero to scale instead of crop.  
           Defaults to $OFFSET
   -p      Second picture dimension.  Defaults to $PIP_SIZE.
   -q      Disable progress indication
   -s      Second picture dir, for PIP.  Leave blank for none.  Defaults to blank.
   -t      Dimensions of each tapestry picture.  Defaults to $TAPESTRY_DIM
   -v      Verbose output and preserve the temp output
   -w      Set border between pictures in montage.  Defaults to $MONTAGE_WHITESPACE
   -x      Set web directory.  Defaults to $WEB_ABSOLUTE_DIR
   -z      Frame size.  Defaults to $FRAME_SIZE
   -1      Make the movie
   -2      Make the montage
   -3      Update the web page indexes
   -0      Replace soundtrack on existing movie.  Overrides any of 1, 2, or 3
EOF
}

while getopts a:b:d:e:f:hi:l:m:n:o:p:qs:t:vw:x:z:0123 o
do	
    case "$o" in
	a)      MONTAGE_HEIGHT="$OPTARG";;
	b)	BASE_RELATIVE_DIR="$OPTARG";;
	d)	TARGET_DATE="$OPTARG";;
	e)      MONTAGE_INTERVAL="$OPTARG";;
	f)	FRAMERATE="$OPTARG";;
	h)	usage
		exit 1;;
        i)      MONTAGE_MINIMUM="$OPTARG";;
        m)      MUSIC_DIR="$OPTARG";;
	n)      MONTAGE_FRAME_COUNT="$OPTARG";;
	o)      OFFSET="$OPTARG";;
	p)      PIP_SIZE="$OPTARG";;
        q)	PROGRESS=0;;
	s)      SECOND_PIC_DIR="$OPTARG";;
	t)      TAPESTRY_DIM="$OPTARG";;
        v)      VERBOSE=1;;
        w)      MONTAGE_WHITESPACE="$OPTARG";;
        x)      WEB_ABSOLUTE_DIR="$OPTARG";;
        z)      FRAME_SIZE="$OPTARG";;
        1)      MAKE_MOVIE=1;;
        2)      MAKE_MONTAGE=1;;
        3)      UPDATE_INDEX=1;;
        0)      REPLACE_SOUNDTRACK=1
	        MAKE_MOVIE=0
		MAKE_MONTAGE=0
		UPDATE_INDEX=0;;
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

count=0
if [ ! -z "$MONTAGE_INTERVAL" ]
then
    count=`expr $count + 1`
fi
if [ ! -z "$MONTAGE_FRAME_COUNT" ]
then
    count=`expr $count + 1`
fi
if [ "$count" -ne "1" ]
then
    echo "Either montage interval or montage frame count is required."
    exit 0
fi

PRETTY_DATE=`date -d $TARGET_DATE +%e\ %b\ %Y`
PRETTY_MONTH=`date -d $TARGET_DATE +%b\ %Y`
YEAR=`date -d $TARGET_DATE +%Y`
MONTH=`date -d $TARGET_DATE +%m`
DAY=`date -d $TARGET_DATE +%d`

BASE_ABSOLUTE_DIR=${WEB_ABSOLUTE_DIR}/${BASE_RELATIVE_DIR}
YEAR_ABSOLUTE_DIR=${BASE_ABSOLUTE_DIR}/${YEAR}
YEAR_RELATIVE_DIR=${BASE_RELATIVE_DIR}/${YEAR}
MONTH_ABSOLUTE_DIR=${YEAR_ABSOLUTE_DIR}/${MONTH}
MONTH_RELATIVE_DIR=${YEAR_RELATIVE_DIR}/${MONTH}

DAY_ABSOLUTE_DIR=${MONTH_ABSOLUTE_DIR}/${DAY}
PIP_ABSOLUTE_DIR=${WEB_ABSOLUTE_DIR}/${SECOND_PIC_DIR}/${YEAR}/${MONTH}/${DAY}
DAY_RELATIVE_DIR=${MONTH_RELATIVE_DIR}/${DAY}
MOVIE_NAME=${TARGET_DATE}
MOVIE_LOW_NAME=${TARGET_DATE}_low
MOVIE_ABSOLUTE_PATH=${MONTH_ABSOLUTE_DIR}/${MOVIE_NAME}
MOVIE_RELATIVE_PATH=${MONTH_RELATIVE_DIR}/${MOVIE_NAME}
MOVIE_LOW_ABSOLUTE_PATH=${MONTH_ABSOLUTE_DIR}/${MOVIE_LOW_NAME}
MOVIE_LOW_RELATIVE_PATH=${MONTH_RELATIVE_DIR}/${MOVIE_LOW_NAME}
STRIP_ABSOLUTE_PATH=${MONTH_ABSOLUTE_DIR}/${TARGET_DATE}_strip.jpg
STRIP_RELATIVE_PATH=${MONTH_RELATIVE_DIR}/${TARGET_DATE}_strip.jpg
THUMB_ABSOLUTE_PATH=${MONTH_ABSOLUTE_DIR}/${TARGET_DATE}_thumb.jpg
THUMB_RELATIVE_PATH=${MONTH_RELATIVE_DIR}/${TARGET_DATE}_thumb.jpg
THUMB_DATED_ABSOLUTE_PATH=${MONTH_ABSOLUTE_DIR}/${TARGET_DATE}_thumb_dated.jpg
THUMB_DATED_RELATIVE_PATH=${MONTH_RELATIVE_DIR}/${TARGET_DATE}_thumb_dated.jpg
MONTH_THUMB_ABSOLUTE_PATH=${MONTH_ABSOLUTE_DIR}/${YEAR}-${MONTH}_thumb.jpg
MONTH_THUMB_RELATIVE_PATH=${MONTH_RELATIVE_DIR}/${YEAR}-${MONTH}_thumb.jpg
MONTH_THUMB_DATED_ABSOLUTE_PATH=${MONTH_ABSOLUTE_DIR}/${YEAR}-${MONTH}_thumb_dated.jpg
MONTH_THUMB_DATED_RELATIVE_PATH=${MONTH_RELATIVE_DIR}/${YEAR}-${MONTH}_thumb_dated.jpg

if [ "$MAKE_MOVIE" -eq 1 ]
then
    ######################################################################
    # prepare input files for ffmpeg
    ######################################################################

    #grab a frame and see if conversion is needed
    RANDOM_FRAME=`ls ${DAY_ABSOLUTE_DIR}/??:??:??.jpg|sort -R|head -n1`
    SOURCE_DIMENSION=`identify -verbose ${RANDOM_FRAME} | awk '{ if (/Geometry:/) print gensub(/\+0\+0/, "", "g", $2) }'`
    LINKONLY=`expr "$FRAME_SIZE" == "${SOURCE_DIMENSION}"`

    let "i = 0"
    if [ $PROGRESS -eq 1 ]; then
        max=$(ls ${DAY_ABSOLUTE_DIR}/??:??:??.jpg|wc -l)
    fi
    for file in `ls ${DAY_ABSOLUTE_DIR}/??:??:??.jpg`; do
	output_path=${TEMP_DIR}/`printf %06d $i`.jpg
        if [ -z "$OFFSET" ]; then
	    FORMATED_DATE=`date -d "$(echo $TARGET_DATE|rev|cut -c-10|rev|tr '/' '-') $(echo $file|rev|cut -c5-12|rev)" "+%Y. %b %e. %H:%M"`
            if [ "$LINKONLY" == 1 ]; then
#                ln -s $file ${output_path}
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
		if [ $? != 0 ]
		    then
		    rm ${output_path}
		    continue
		fi
            else
              # error-handle.  If the incoming picture is bad, don't pass on a bad picture
#	      CMD=`convert -scale ${FRAME_SIZE} $file ${output_path}`
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
	      if [ $? != 0 ]
		  then
		  rm ${output_path}
		  continue
	      fi
	    fi
        else
	    CMD=`convert -crop ${FRAME_SIZE}${OFFSET} $file ${output_path}`
	    if [ $? != 0 ]
		then
		rm ${output_path}
		continue
	    fi
        fi
        if [ -e "${PIP_ABSOLUTE_DIR}" ]
        then
            hour=${file:(-12):2}
            minute=${file:(-9):2}
            second=${file:(-6):2}
            #assume closest match for the minute (not second) is good enough
            pip=`ls ${PIP_ABSOLUTE_DIR}/${hour}:${minute}:??.*jpg | sort | tail -n 1`
            if [ -e "$pip" ]
            then
                convert -scale ${PIP_SIZE} $pip ${PIP_RESIZE_PATH}
                composite -gravity southeast ${PIP_RESIZE_PATH} ${output_path} ${output_path}
            fi
        fi
	let "i = $i + 1"
	if [ $PROGRESS -eq 1 ]; then
	    echo -ne "$i/$max $(expr \( $i \* 100 \) / $max)%\r"
	fi
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
    # -fs maximum output file size

    # make the low-def version
    $FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -i $MOVIE_ABSOLUTE_PATH.mp4 -fs 5000k -s 320x240 -acodec copy \
      ${FFMPEG_OUTPUT_OPTIONS_MP4_VID} $MOVIE_LOW_ABSOLUTE_PATH.mp4
    $FFMPEG_PATH -loglevel ${FFMPEG_LOGLEVEL} -y -i $MOVIE_ABSOLUTE_PATH.ogv -fs 5000k -s 320x240 -acodec copy \
      ${FFMPEG_OUTPUT_OPTIONS_OGV_VID} $MOVIE_LOW_ABSOLUTE_PATH.ogv
fi

if [ "$MAKE_MONTAGE" -eq 1 ]
then
    MONTAGE_NO_DATA=0
    MONTAGE_NOT_ENOUGH=0

    ######################################################################
    # make a thumbnail reel for the movie
    ######################################################################

    if [ ! -e "$MOVIE_ABSOLUTE_PATH.mp4" ]
    then
	MONTAGE_NO_DATA=1
    else
	DURATION=`$FFMPEG_PATH -i $MOVIE_ABSOLUTE_PATH.mp4 2>&1 | awk '{ if (/Duration/) {split($2, a, "[:.]"); print (a[1] *60+ a[2])*60 + a[3]} }'`

	if [ "${DURATION}" -lt "${MONTAGE_MINIMUM}" ]
	then
	    MONTAGE_NOT_ENOUGH=1
	else

	    # Duration = interval * frame count.  Calculate the missing one.
	    if [ -z ${MONTAGE_FRAME_COUNT} ]
	    then
		MONTAGE_FRAME_COUNT=`expr $DURATION / $MONTAGE_INTERVAL`
	    else
		MONTAGE_INTERVAL=`echo $DURATION / $MONTAGE_FRAME_COUNT|awk '{print $1 / $3}'`
	    fi

	    i=0
	    while [ "$i" -lt "$MONTAGE_FRAME_COUNT" ]
	    do
		output=${TEMP_DIR}/thumb`printf %04d $i`.png
		offset=`echo $i ${MONTAGE_INTERVAL} | awk '{print $1 * $2}'`
		$FFMPEG_PATH -y -i $MOVIE_ABSOLUTE_PATH.mp4 -ss ${offset} -vframes 1 -s ${TAPESTRY_DIM} -an $output 2>&1 >/dev/null
		let "i = $i + 1"
	    done
	    
	fi
    fi

    # test for error conditions that would make us skip the montage
    if [ "$MONTAGE_NOT_ENOUGH" -eq 0 ] && [ "$MONTAGE_NO_DATA" -eq 0 ]
    then
	# no errors, so make the montage and update the index
	montage ${TEMP_DIR}/thumb*.png -tile `expr ${MONTAGE_FRAME_COUNT}`x1 -geometry ${TAPESTRY_DIM}${MONTAGE_WHITESPACE} $STRIP_ABSOLUTE_PATH
    fi
fi

if [ "$UPDATE_INDEX" -eq 1 ]
then
    ######################################################################
    # update the web index pages
    ######################################################################
    
    if [ -e "$STRIP_ABSOLUTE_PATH" ]
    then

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
	
        #####################################################################
	# rebuild the movie thumbnail for the month
        #####################################################################

	montage -geometry +0+0 -tile 1x`ls ${MONTH_ABSOLUTE_DIR}/*_strip.jpg | wc -l` `ls -r ${MONTH_ABSOLUTE_DIR}/*strip.jpg` $MONTH_THUMB_ABSOLUTE_PATH

	mogrify -resize ${MONTH_THUMB_WIDTH}x $MONTH_THUMB_ABSOLUTE_PATH

	convert $MONTH_THUMB_ABSOLUTE_PATH \
	    -gravity Center \
	    -font ${FONT} \
	    -pointsize ${FONT_SIZE} \
	    -fill gray -annotate +1+1 "${PRETTY_MONTH}" \
	    -fill gray -annotate -1-1 "${PRETTY_MONTH}" \
	    -fill gray -annotate -1+1 "${PRETTY_MONTH}" \
	    -fill black -annotate +1-1 "${PRETTY_MONTH}" \
	    -fill white -annotate +0+0 "${PRETTY_MONTH}" \
	    $MONTH_THUMB_DATED_ABSOLUTE_PATH

    fi
    
fi

if [ "$REPLACE_SOUNDTRACK" -eq 1 ]
then
    # TODO: duplicates previous code; ought to be in a function
    ffmpeg_duration=`$FFMPEG_PATH -i $MOVIE_ABSOLUTE_PATH.mp4 2>&1 | grep Duration`
    minutes=`echo $ffmpeg_duration | grep -o ':[0-9]\{2\}:' | grep -o '[0-9]\{2\}'`
    seconds=`echo $ffmpeg_duration | grep -o ':[0-9]\{2\}\.' | grep -o '[0-9]\{2\}'`
    DURATION=`expr $minutes \* 60 + $seconds`

    # TODO: duplicates previous code; ought to be in a function
    MUSIC_PATH=`find $MUSIC_DIR -name \*mp3 | sort -R | tail -n 1`
    sox "$MUSIC_PATH" $FADE_PATH fade t 0 $DURATION 8
    normalize-audio $FADE_PATH
    $FFMPEG_PATH -y -i $MOVIE_ABSOLUTE_PATH.mp4 -i $FADE_PATH -map 0:0 -map 1:0 \
	-vcodec copy ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD} $TEMP_DIR/hd.mp4
    $FFMPEG_PATH -y -i $MOVIE_ABSOLUTE_PATH.ogv -i $FADE_PATH -map 0:0 -map 1:0 \
	-vcodec copy ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD} $TEMP_DIR/hd.ogv
    mv $TEMP_DIR/hd.mp4 $MOVIE_ABSOLUTE_PATH.mp4
    mv $TEMP_DIR/hd.ogv $MOVIE_ABSOLUTE_PATH.ogv
    $FFMPEG_PATH -y -i $MOVIE_LOW_ABSOLUTE_PATH -i $FADE_PATH -map 0:0 -map 1:0 \
	-vcodec copy ${FFMPEG_OUTPUT_OPTIONS_MP4_AUD} $TEMP_DIR/low.mp4
    $FFMPEG_PATH -y -i $MOVIE_LOW_ABSOLUTE_PATH -i $FADE_PATH -map 0:0 -map 1:0 \
	-vcodec copy ${FFMPEG_OUTPUT_OPTIONS_OGV_AUD} $TEMP_DIR/low.ogv
    mv $TEMP_DIR/low.mp4 $MOVIE_LOW_ABSOLUTE_PATH.mp4
    mv $TEMP_DIR/low.ogv $MOVIE_LOW_ABSOLUTE_PATH.ogv
fi

######################################################################
# clean up
######################################################################

if [ "$VERBOSE" -eq 0 ] 
    then
    rm -rf $TEMP_DIR
fi
