<?php $BASE_DIR='webcam'; 
  $year=$_GET["year"];
  $month=$_GET["month"];
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
    &nbsp;
    <?if (!$resolution):?><a class="button right" href="index_month.php?<?="year=${year}&month=${month}&resolution=_low"?>">Movie</a>
                 <?else:?><a class="button right" href="index_month.php?<?="year=${year}&month=${month}"?>">HD Movie</a><?endif?>
  </div>
</div>
<div id="onecolumn" class="center">
    <?php
    foreach(glob("$BASE_DIR/$year/$month/??") as $day_directory) {
        $day_directories[] = $day_directory;
    } 
    rsort($day_directories);

    foreach ($day_directories as $name) {
	$day = str_replace ("$BASE_DIR/$year/$month/", "", $name);
?>    
<a href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}&resolution=${resolution}"?>"><img src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb.jpg" onmouseover="this.src='<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb_dated.jpg'" onmouseout="this.src='<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb.jpg'"/></a>
<img class="preload" src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb_dated.jpg"/><br/>
<?
    }
?>
<video controls="controls" width="100%"?>">
  <source src="<?="${BASE_DIR}/${year}/${year}-${month}${resolution}"?>.mp4" type='video/mp4'/>
  <source src="<?="${BASE_DIR}/${year}/${year}-${month}${resolution}"?>.ogv" type='video/ogg'/>
</video>
</div>
<div id="header">
  <div class="titlebar">
    <a class="button left"href="index.php">Up</a>
    &nbsp;
    <?if (!$resolution):?><a class="button right" href="index_month.php?<?="year=${year}&month=${month}&resolution=_low"?>">Movie</a>
                 <?else:?><a class="button right" href="index_month.php?<?="year=${year}&month=${month}"?>">HD Movie</a><?endif?>
  </div>
</div>
</div>
