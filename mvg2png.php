<?php
require("header.php");

$upfile = $_FILES['mvgdoc']['tmp_name'];
ob_start();
$filetype = system("file $upfile");
ob_clean();

	
	if (move_uploaded_file($_FILES['mvgdoc']["tmp_name"], $mvgpath)) {
		/*
		$im    = new imagick($mvgpath);
		$image = new Imagick($mvgpath);
		$image->setImageFormat("png"); 
		$image->writeImage($pngpath);
	        */
		system("convert $mvgpath $pngpath");
		echo "<h1>Job Done!</h1><br>";	
		echo 'PNG image has been genereted : <a href="./mvg/' . $rand . '/' .$rand . '.png"  target="_blank">get it!</a>';
	      }
	else {
		echo '<p>Error processing file</p>';
	}
}
else {
	        echo "<p>The given file don't seem to be a mvg, are you trying to hack me ?</p>";
}
?>
<p>
  <br><br>
  <a href="index.php">Homepage</a>
</p>
<?php
require("footer.php");
?>
