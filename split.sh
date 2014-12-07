#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script slipts a movie into parts, default is 20 minute parts
but there is an option to change that

OPTIONS:
   -h	Show this message
   -t	The part length in minutes
   -f	File you want to split
EOF
}

PART_LEN=20
FILENAME=
while getopts "ht:f:" OPTION
do
  case $OPTION in
    h)
      usage
      exit 0
      ;;
    t)
      PART_LEN=$OPTARG
      ;;
    f)
      echo "Filename is $OPTARG"
      FILENAME=$OPTARG
      ;;
  esac
done

if [ -z "$FILENAME" ]; then
  #usage
  echo "Filename is not set!"
  usage
  exit 0
fi

EXTENTION="${FILENAME##*.}"
FILENAME_NOEXT="${FILENAME%.*}"

VIDEO_LEN=$(ffmpeg -i star_wars_1.mkv 2>&1 | grep "Duration" | cut -d ' ' -f 4 | sed s/,// | sed 's@\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 60*A[1] + A[2] }')

#echo "File is $VIDEO_LEN minutes long"

NUM_PARTS=$((VIDEO_LEN /  PART_LEN))
REMAINING=$((VIDEO_LEN - (NUM_PARTS * PART_LEN)))

#echo "Will need to be split into $NUM_PARTS $PART_LEN minute parts and one $REMAINING minute part"

PART_LEN_S=$((PART_LEN * 60))

# Split into parts
for (( i=0; i<$NUM_PARTS; i++ ))
do
  ffmpeg -i "$FILENAME" -qscale 0 -ss $((PART_LEN_S * i)) -t $PART_LEN_S "${FILENAME_NOEXT}_${i}.${EXTENTION}"
done

ffmpeg -i "$FILENAME" -qscale 0 -ss $((PART_LEN_S * NUM_PARTS)) -t $((REMAINING * 60)) "${FILENAME_NOEXT}_$((NUM_PARTS)).${EXTENTION}"



