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
    <?php
    foreach(glob("${BASE_DIR}/${year}/${month}/${day}/*_thumb.jpg") as $index_filename) {
        $files[] = preg_replace('/(.*)_thumb.jpg/', '$1', $index_filename);
    } rsort($files);

    if ($files) {
        foreach ($files as $name) {
?>	<a href="<?=${name}?>.jpg"><img src="<?=${name}?>_thumb.jpg"/></a>
<?php
        }
    }
?>
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
