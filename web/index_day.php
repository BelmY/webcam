<?php $BASE_DIR='webcam'; 
  $year=$_GET["year"];
  $month=$_GET["month"];
  $day=$_GET["day"];
?>
<html>
<head>
<title><?php include("title.txt") ?> - <?="$year-$month-$day"?></title>
  <link rel="stylesheet" type="text/css" href="basic.css" media="all">
</head>
<body>
<div id="wrap">
<div id="header">
  <div class="titlebar">
    <a class="button left"href="index.php">Up</a>
    <a class="button left" href="index_month.php?<?="year=${year}&month=${month}&day=${day}"?>">Month</a>
    &nbsp;
    <a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}&resolution=_low"?>">Movie</a>
    <a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}"?>">HD Movie</a>
  </div>
</div>
<div id="onecolumn">
    <div style="display:table">
    <?php
    foreach(glob("${BASE_DIR}/${year}/${month}/${day}/*_thumb.jpg") as $index_filename) {
        $files[] = preg_replace('/(.*)_thumb.jpg/', '$1', $index_filename);
    } rsort($files);

    if ($files) {
        foreach ($files as $count=>$name) {
?>
<?php if($count%3==0):?><div style="display:table-row"><?endif?>
	<div style="display:table-cell">
	    <a href="<?=${name}?>.jpg"><img width="100%" src="<?=${name}?>_thumb.jpg"/></a>
	</div>
<?php if($count%3==2):?></div><?endif?>
<?php
        }
    }
?>
    </div>
</div>
<div id="header">
  <div class="titlebar">
    <a class="button left"href="index.php">Up</a>
    <a class="button left" href="index_month.php?<?="year=${year}&month=${month}&day=${day}"?>">Month</a>
    &nbsp;
    <a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}&resolution=_low"?>">Movie</a>
    <a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}"?>">HD Movie</a>
  </div>
</div>
</div>
