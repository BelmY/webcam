<?php $BASE_DIR='webcam'; 
  $year=$_GET["year"];
  $month=$_GET["month"]; 
  $day=$_GET["day"];
  $resolution=$_GET["resolution"];
?>
<html>
<head>
<title><?php include("title.txt") ?></title>
  <link rel="stylesheet" type="text/css" href="basic.css" media="all">
</head>
<body>
<div id="wrap">
<div id="header">
  <div class="titlebar">
    <a class="button left"href="index.php">Up</a>
    <a class="button left" href="index_month.php?<?="year=${year}&month=${month}&day=${day}&resolution=${resolution}"?>">Month</a>
    &nbsp;
    <?if (!$resolution):?><a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}&resolution=_low"?>">Movie</a>
                 <?else:?><a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}"?>">HD Movie</a><?endif?>
    <a class="button right" href="index_day.php?<?="year=${year}&month=${month}&day=${day}"?>" title="Click for pictures">All pictures</a>
  </div>
</div>
<div id="onecolumn" class="center">
<video controls="controls" width="100%" autobuffer="autobuffer">
  <source src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}${resolution}"?>.mp4" type="video/mp4"/>
  <source src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}${resolution}"?>.ogv" type='video/ogg; codecs="theora, vorbis"'/>
</video>
</div>
<div id="header">
  <div class="titlebar">
    <a class="button left"href="index.php">Up</a>
    <a class="button left" href="index_month.php?<?="year=${year}&month=${month}&day=${day}&resolution=${resolution}"?>">Month</a>
    &nbsp;
    <?if (!$resolution):?><a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}&resolution=_low"?>">Movie</a>
                 <?else:?><a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}"?>">HD Movie</a><?endif?>
    <a class="button right" href="index_day.php?<?="year=${year}&month=${month}&day=${day}"?>" title="Click for pictures">All pictures</a>
  </div>
</div>
</div>
