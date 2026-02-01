<?php

$files = glob('../../assets/icons/flags/*.svg', GLOB_BRACE);
foreach($files as $file) {
	$dom = new DOMDocument('1.0', 'utf-8');
	$dom->load($file);
	$svg = $dom->documentElement;

	if (!$svg->hasAttribute('viewBox') ) {
		// userspace coordinates
		$pattern = '/^(\d*\.\d+|\d+)(px)?$/';

		$interpretable = preg_match( $pattern, $svg->getAttribute('width'), $width ) &&
						 preg_match( $pattern, $svg->getAttribute('height'), $height );

		if ( $interpretable ) {
			$view_box = implode(' ', [0, 0, $width[0], $height[0]]);
			$svg->setAttribute('viewBox', $view_box);
		} else { // this gets sticky
			throw new Exception("viewBox is dependent on environment");
		}
	}

	$dom->save('fixed/'.preg_replace('/\\.[^.\\s]{3,4}$/', '', $file).'.svg');
}

?>