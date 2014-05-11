#!/bin/bash
for i in ??:??:??.jpg; do
  th="`echo $i|cut -b-8`_thumb.jpg"
  if [ -s $th ];then continue; fi
  convert $i -resize 640x360 ${th}
done