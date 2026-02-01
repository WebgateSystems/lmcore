<?php
define('safe_access',true);
include('php/variables.php');
global $dist_min;
global $isRTL;
global $page;
?>
<!doctype html>
<html lang="en" class="sc-error-page"<?php if($isRTL) { echo ' dir="rtl"'; } ?>>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title>Scutum Admin Template - Error Page</title>

	<link rel="apple-touch-icon" sizes="180x180" href="assets/img/fav/apple-touch-icon.png">
	<link rel="icon" type="image/png" sizes="32x32" href="assets/img/fav/favicon-32x32.png">
	<link rel="icon" type="image/png" sizes="16x16" href="assets/img/fav/favicon-16x16.png">
	<link rel="mask-icon" href="assets/img/fav/safari-pinned-tab.svg" color="#5bbad5">

	<link rel="manifest" href="manifest.json">
	<meta name="theme-color" content="#607D8B">

	<style>
		.appLoading {background:#f5f5f5}
		.appLoading body {visibility:hidden;overflow:hidden;max-height: 100%;}
	</style>
	<script>
		var html = document.getElementsByTagName('html')[0];
		html.className += ' appLoading';
	</script>

	<!-- UIkit js -->
	<script src="assets/js/uikit<?php echo $dist_min; ?>.js"></script>
</head>
<body >

	<h1 class="sc-error-title sc-padding-large">
		<i class="mdi mdi-alert-outline"></i>
		ERROR 500
	</h1>
	<div class="sc-padding-large">
		<p class="sc-text-semibold">Oops! Something went wrong&hellip;</p>
		<p>There was an error. Please try again later.</p>
		<a href="#" onclick="history.go(-1);return false;">Go back to previous page</a>
	</div>

<!-- async assets-->
<script src="assets/js/vendor/loadjs.min.js"></script>
<script>
	var html = document.getElementsByTagName('html')[0];
	// ----------- CSS
	loadjs(['node_modules/uikit/dist/css/uikit<?php echo $dist_min; ?>.css', 'assets/css/error_page<?php echo $dist_min; ?>.css'], {
		success: function () {
			// add id to main stylesheet
			var mainCSS = document.querySelectorAll("link[href='assets/css/error_page<?php echo $dist_min; ?>.css']");
			mainCSS[0].setAttribute('id', 'main-stylesheet');
			// show page
			setTimeout(function () {
				html.className = html.className.replace( /(?:^|\s)appLoading(?!\S)/g , '' );
			}, 100);
			// UIKit & mdi icons CSS
			loadjs('assets/css/materialdesignicons.min.css', {
				before: function (path, scriptEl) {
					if (/(^css!|\.css$)/.test(path)) {
						document.head.insertBefore(scriptEl, mainCSS[0])
					}
					return false;
				}
			});
		},
		async: false
	});
	// mdi icons (base64) & google fonts (base64)
	loadjs(['assets/css/fonts/mdi_fonts.css', 'assets/css/fonts/roboto_base64.css', 'assets/css/fonts/montserrat_base64.css']);
</script>
<?php if(isset($_GET["demo"])) { ?>
    <!-- Global site tag (gtag.js) - Google Analytics -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=UA-136690566-1"></script>
    <script>
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());

        gtag('config', 'UA-136690566-2');
    </script>
<?php }; ?>

</body>
</html>
