<?php $BASE_DIR='webcam'; ?>
<html>
<head>
<title><?php include("title.txt") ?></title>
  <link rel="stylesheet" type="text/css" href="basic.css" media="all">
</head>
<body>
<div id="wrap">
  <div id="header">  
    <?php
       $month_directories=glob("${BASE_DIR}/????/??");
       rsort($month_directories);
       $ptr=0;
       // Find last movie, search backward in dir structure until thumbnail is found
       while ($ptr < count($month_directories)) {
         $current_month_day_dirs=glob($month_directories[$ptr]."/????-??-??_thumb.jpg");
         rsort ($current_month_day_dirs);
         if (count($current_month_day_dirs)>0) {
           $fn=preg_replace("#.*(.{4}-.{2}-.{2})_thumb\.jpg#","$1", $current_month_day_dirs[0]);
           $a=split("-", $fn);
           $year=$a[0];
           $month=$a[1];
           $day=$a[2];
           ?>
           <div class="titlebar">
<a class="button right" href="<?="index_day.php?year=${year}&month=${month}&day=${day}"?>" title="Click for pictures">pics</a>
<a class="button right" href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}"?>">HD</a>
<a href="index_day_video.php?<?="year=${year}&month=${month}&day=${day}&resolution=_low"?>">
<img src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb.jpg" onmouseover="this.src='<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb_dated.jpg'" onmouseout="this.src='<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb.jpg'"/>
</a>
<img class="preload" src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}-${day}"?>_thumb_dated.jpg"/><br/>
           </div>
           <?php
           break;
         }
         $ptr++;
       }
    ?>
       
  </div>
  <div id="main">
    <?php
       $month_ptr = 0;
       // Find last image, search backward in dir structure until thumbnail is found
       while ($month_ptr < count($month_directories)) {
         $current_month_day_dirs=glob($month_directories[$month_ptr]."/??");
         rsort ($current_month_day_dirs);
         $day_ptr = 0;
         while ($day_ptr < count($current_month_day_dirs)){
           $current_day_pics=glob($current_month_day_dirs[$day_ptr]."/??:??:??.jpg");
           rsort($current_day_pics);
           if (count($current_day_pics)>0) {
             $fn=str_replace("$BASE_DIR/","", $current_day_pics[0]);
             $fn=str_replace(":","/",$fn);
             $a=split("/", $fn);
             $ts=mktime($a[3],$a[4],$a[5],$a[1],$a[2],$a[0]);
?>
     <div class="candybox">
       <div class="titlebar">
         <span class="name">Webcam</span>
         <span><?=date("r", $ts)?></span>
         <a class="button right" href="index_day.php?year=<?=date('Y', $ts)?>&month=<?=date('m', $ts)?>&day=<?=date('d', $ts)?>">pics</a>
      </div>
      <div>
        <img src="<?=$current_day_pics[0]?>" alt="current picture" width="640">
      </div>
    </div>
<?php
            break 2;
            }
           $day_ptr++;
         }
         $month_ptr++;
       }
?>
     <div class="candybox">
       <div class="titlebar">
         <span class="name">Webcam</span>
         <span>Full</span>
      </div>
      <div>
	<video controls="controls" width="640" height="480" autobuffer="autobuffer">
	  <source src="<?="${BASE_DIR}"?>/full.mp4" type="video/mp4"/>
	  <source src="<?="${BASE_DIR}"?>/full.ogv" type='video/ogg; codecs="theora, vorbis"'/>
	</video>
	</div>
    </div>

  </div>
  <div id="sidebar">
    <?php
       if( count($month_directories) > 0 )  {
          foreach($month_directories as $month_dir) {
            $a = split ("/", $month_dir);
            $year=$a[1];
            $month=$a[2];
            if (!file_exists("${BASE_DIR}/${year}/${month}/${year}-${month}_thumb.jpg")) 
            continue;
          ?>              
            <a href="<?="index_month.php?year=$year&month=${month}"?>">
              <img src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}_thumb.jpg"?>" onmouseover="this.src='<?="${BASE_DIR}/${year}/${month}/${year}-${month}_thumb_dated.jpg"?>'" onmouseout="this.src='<?="${BASE_DIR}/${year}/${month}/${year}-${month}_thumb.jpg"?>'"/></a>
              <img class="preload" src="<?="${BASE_DIR}/${year}/${month}/${year}-${month}_thumb.jpg"?>"/><br/>
          <?php
          }
       }
       else
         print "No history available";
?>
  </div>
</div>

<div class="preload">
</div>

