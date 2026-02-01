<?php

echo '"login_page",<br/>';
echo '"error_404",<br/>';
echo '"error_500",<br/>';

function rsearch($folder, $pattern) {
	$dir = new RecursiveDirectoryIterator($folder);
	$ite = new RecursiveIteratorIterator($dir);
	$files = new RegexIterator($ite, $pattern, RegexIterator::GET_MATCH);
	$fileList = array();
	foreach($files as $file) {
		$fileList[] = $file[0];
	}
	return $fileList;
}

$files = rsearch("../views","/^.*\.(php)$/");

$i = 4;
foreach($files as $file) {
	$file = str_replace('../views\\', '', $file);
	$filename = dirname($file);
	echo '"' . str_replace('\\', '_', $filename) . '-' . str_replace('.php', '', basename($file)) .'",<br/>';
	$i++;
}
echo $i . ' pages';
