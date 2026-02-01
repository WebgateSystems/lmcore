<?php

	// server name or ip
    $server = 'http://scutum-html.local/';
    $folder = '../dist/';
    $folderRTL = '../dist-rtl/';

    function curl_html($url,$out) {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $result = curl_exec($ch);
        file_put_contents($out, $result);
        if (curl_errno($ch)) {
            echo 'Error:' . curl_error($ch);
        }
        curl_close($ch);
    }

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

	if (is_dir($folder)) {
	    array_map('unlink', glob($folder."*.html"));
    } else {
	    mkdir($folder, 0775, true);
    }
    if (is_dir($folderRTL)) {
        array_map('unlink', glob($folderRTL."*.html"));
    } else {
        mkdir($folderRTL, 0775, true);
    }

    $files = rsearch("./php/views","/^.*\.(php)$/");

    foreach($files as $file) {
	    $file = str_replace('./php/views', '', $file);
	    $filename = substr(dirname($file), 1);
	    $_file = str_replace(DIRECTORY_SEPARATOR, '_', $filename) . '-' . str_replace('.php', '', basename($file));
	    curl_html($server."index.php?generate&page=".$_file, $folder.$_file.".html");
	    curl_html($server."index.php?generate&rtl&page=".$_file, $folderRTL.$_file.".html");
	    if($_file === 'dashboard-v1') {
            curl_html($server."index.php?generate&page=".$_file, $folder."index.html");
            curl_html($server."index.php?generate&rtl&page=".$_file, $folderRTL."index.html");
        }
    }

    curl_html($server."login_page.php?generate",$folder."login_page.html");
    curl_html($server."error_404.php?generate",$folder."error_404.html");
    curl_html($server."error_500.php?generate",$folder."error_500.html");
    curl_html($server."login_page.php?generate&rtl",$folderRTL."login_page.html");
    curl_html($server."error_404.php?generate&rtl",$folderRTL."error_404.html");
    curl_html($server."error_500.php?generate&rtl",$folderRTL."error_500.html");
