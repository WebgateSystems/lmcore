<?php
define('safe_access',true);
include('php/variables.php');
global $dist_min;
global $isRTL;
global $page;
?>
<!doctype html>
<html lang="en"<?php if(isset($htmlClass)){ echo ' class="'.$htmlClass.'"'; } ?><?php if($isRTL) { echo ' dir="rtl"'; } ?>>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title>Scutum Admin Template</title>
    <meta name="description" content="Scutum Admin Template" />

    <link rel="apple-touch-icon" sizes="180x180" href="assets/img/fav/apple-touch-icon.png">
	<link rel="icon" type="image/png" sizes="32x32" href="assets/img/fav/favicon-32x32.png">
	<link rel="icon" type="image/png" sizes="16x16" href="assets/img/fav/favicon-16x16.png">
	<link rel="mask-icon" href="assets/img/fav/safari-pinned-tab.svg" color="#5bbad5">

	<link rel="manifest" href="manifest.json">
	<meta name="theme-color" content="#00838f">

<?php if (isset($customMeta)) { echo $customMeta; } PHP_EOL; ?>

	<!-- polyfills -->
	<script src="assets/js/vendor/polyfills.min.js"></script>

	<!-- UIKit js -->
    <script src="assets/js/uikit<?php echo $dist_min; ?>.js"></script>

</head>
<body>
<script>
	// prevent FOUC
	var html = document.getElementsByTagName('html')[0];
	html.style.backgroundColor = '#f5f5f5';
	document.body.style.visibility = 'hidden';
	document.body.style.overflow = 'hidden';
	document.body.style.apacity = '0';
	document.body.style.maxHeight = "100%";
</script>

<?php include('php/partials/header.php'); ?>

<?php if($page === 'fancy_toolbar') { ?>
    <?php include('php/partials/fancy_toolbar.php'); ?>
<?php } ?>

<?php if($page !== 'top_menu') { ?>
<?php include('php/partials/sidebar.php'); ?>
<?php } ?>

<?php if( isset($includePage) && file_exists(realpath(__DIR__).'/php/views/' . $includePage) ) {
	global $dt;
	include('php/views/' . $includePage);
} else {
	echo '<div id="sc-page-wrapper"><div id="sc-page-content">';
	echo('<pre>');
	var_dump($includePage);
	echo('</pre>');
	echo '<div class="uk-alert uk-alert-danger">Page not found</div></div></div>';
} ?>

<?php if($page === 'footer') { ?>
	<?php include('php/partials/footer.php'); ?>
<?php } ?>

<?php if($page === 'fancy_footer') { ?>
	<?php include('php/partials/fancy_footer.php'); ?>
<?php } ?>

<!-- async assets-->
<script src="assets/js/vendor/loadjs.min.js"></script>
<script>
	var html = document.getElementsByTagName('html')[0];
	// ----------- CSS
	// md icons
	loadjs('assets/css/materialdesignicons.min.css', {
        preload: true
	});
    // UIkit
    <?php if($isRTL) { ?>
    loadjs('node_modules/uikit/dist/css/uikit-rtl.min.css', {
        preload: true
    });
    <?php } else { ?>
    loadjs('node_modules/uikit/dist/css/uikit.min.css', {
        preload: true
    });
    <?php } ?>
	// themes
	loadjs('assets/css/themes/themes_combined.min.css', {
        preload: true
    });
	// mdi icons (base64) & google fonts (base64)
	loadjs([
	    'assets/css/fonts/mdi_fonts.css',
        'assets/css/fonts/roboto_base64.css',
        'assets/css/fonts/sourceCodePro_base64.css'
    ], {
        preload: true
    });
	// main stylesheet
    <?php if($isRTL) { ?>
    loadjs(['assets/css/main-rtl<?php echo $dist_min; ?>.css'], function() {});
    <?php } else { ?>
    loadjs('assets/css/main<?php echo $dist_min; ?>.css', function() {});
    <?php } ?>
	// vendor
	loadjs('assets/js/vendor<?php echo $dist_min; ?>.js', function () {
        // scutum common functions/helpers
        loadjs('assets/js/scutum_common<?php echo $dist_min; ?>.js', function() {
            scutum.init();
            <?php if(isset($js)) {
                $success = isset($js_success) ? $js_success : '';
                echo 'loadjs(\''.$js.'\', { success: function() { $(function(){'.$success.'}); } })';
            } echo PHP_EOL; ?>
            // show page
            setTimeout(function () {
                // clear styles (FOUC)
                $(html).css({
                    'backgroundColor': '',
                });
                $('body').css({
                    'visibility': '',
                    'overflow': '',
                    'apacity': '',
                    'maxHeight': ''
                });
            }, 100);
            // style switcher
            loadjs([
                'assets/js/style_switcher<?php echo $dist_min; ?>.js',
                'assets/css/plugins/style_switcher.min.css'
            ], {
                success: function() {
                    $(function(){
                        scutum.styleSwitcher();
                    });
                }
            });
        });
	});
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
<?php } ?>

<?php include('php/partials/style_switcher.php'); ?>

</body>
</html>
