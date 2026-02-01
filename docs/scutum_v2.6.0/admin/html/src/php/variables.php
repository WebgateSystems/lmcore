<?php defined('safe_access') or die('Restricted access!'); ?>
<?php
require_once realpath(__DIR__).'/helpers/vendor/autoload.php';

// PHP library that generates fake data
$faker = Faker\Factory::create();

use Carbon\Carbon;
function _carbon() {
	return new Carbon();
}

// variables
$app_info = json_decode(file_get_contents('./package.json'),true);
$app_version = 'v'.$app_info['version'];
$vendor = 'node_modules/';
$images = 'assets/img';

// check if dev/dist
$dist_min = isset($_GET["generate"]) ? '.min' : '';

// RTL
$enableRTL = false;
$isRTL = isset($_GET["rtl"]) || $enableRTL;


function avatar($number,$alt = '',$size = '_sm',$extraClass = null) {
	$faker = Faker\Factory::create();
	$name = $alt != '' ? $alt : $faker->userName;
	echo '<img src="assets/img/avatars/avatar_0'. $number . $size .'.png" class="sc-avatar' . ' ' . $extraClass . '" alt="'. $name .'"/>';
};
function avatarInitials($initials,$bg = 'md-bg-grey-100',$alt = '',$size = '') {
	$faker = Faker\Factory::create();
	$name = $alt != '' ? $alt : $faker->userName;
	$background = $bg != '' ? ' '.$bg : ' md-bg-grey-100';
	$_size = $size != '' ? ' sc-avatar-initials-'.$size : '';
	echo '<span class="sc-avatar-initials'.$background.''.$_size.'" title="'. $name .'">'.$initials.'</span>';
};
function getphoto($index) {
	$photos = [ 'alex-guillaume-769172-unsplash', 'avantgarde-concept-763896-unsplash', 'briana-tozour-756151-unsplash', 'casey-horner-768005-unsplash', 'ciaran-o-brien-769402-unsplash', 'daria-kopylova-766667-unsplash', 'eiliv-aceron-765897-unsplash', 'paula-brustur-766878-unsplash', 'pietro-mattia-764559-unsplash', 'rachel-park-366508-unsplash', 'ray-hennessy-763310-unsplash', 'rodion-kutsaev-760882-unsplash', 'san-fermin-pamplona-navarra-768251-unsplash', 'shane-young-768821-unsplash', 'steve-roe-763192-unsplash', 'urban-sanden-768851-unsplash', 'wynand-van-poortvliet-761831-unsplash' ];
	return 	$photos[$index];
};
function photo($index = 0,$size = '',$classes = '',$cover = false) {
	$ukCover = $cover ? 'data-uk-cover' : '';
	echo '<img src="assets/img/photos/'. getphoto($index) . $size .'.jpg" class="' . $classes . '" alt="' . getphoto($index) . '"' . $ukCover . '/>';
};
function float_rand($Min, $Max, $round=0){
	if ($Min > $Max) {
		$min = $Max; $max = $Min;
	} else {
		$min = $Min; $max=$Max;
	}
	$randomfloat = $min + mt_rand() / mt_getrandmax() * ($max - $min);
	if($round > 0) {
		$randomfloat = round($randomfloat,$round);
	}
	return $randomfloat;
}
function generateRandomString($length = 10) {
	return substr(str_shuffle(str_repeat($x='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil($length/strlen($x)) )),1,$length);
}

function rtlReplace($ltr, $rtl) {
    echo $GLOBALS['isRTL'] ? $rtl : $ltr;
}

// get page/directories
if(!isset($_GET['page']) || $_GET['page'] == 'index') {
	$page = 'v1';
	// DASHBOARD -----------------------------------------------------------
	$includePage = 'dashboard/v1.php';
	$css = '';
	$js = 'assets/js/views/dashboard/dashboard_v1'.$dist_min.'.js';
	$js_success = 'scutum.dashboard.init()';
} else {
	// OTHER PAGES ---------------------------------------------------------
	$url = explode("-", $_GET['page']);
	$page = $url[1];
	$subpageDir = explode("_", $url[0]);
	$dir_length = count($subpageDir);

	if($dir_length > 0) {
		$subdir = '';
		foreach ($subpageDir as $dir) {
			$subdir .=  $dir.'/';
		}
		$includePage = $subdir . $page . '.php';
	} else {
		$includePage = $subpageDir[0] . '/' . $page . '.php';
	}
	// DASHBOARDS
	if($url[0] == 'dashboard' && $page == 'v1') {
		$js = 'assets/js/views/dashboard/dashboard_v1'.$dist_min.'.js';
		$js_success = 'scutum.dashboard.init()';
	}
	if($url[0] == 'dashboard' && $page == 'v2') {
		$js = 'assets/js/views/dashboard/dashboard_v2'.$dist_min.'.js';
		$js_success = 'scutum.dashboard.init()';
	}
	// PAGES
	if($page == 'blank_header_expanded') {
		$htmlClass = 'sc-card-fixed sc-header-expanded';
	}
	if($page == 'chat') {
		$htmlClass = 'sc-card-fixed sc-header-expanded';
		$js = 'assets/js/views/pages/chat'.$dist_min.'.js';
		$js_success = 'scutum.pages.chat.init()';
	}
	if($page == 'contact_list') {
		$js = 'assets/js/views/pages/contact_list'.$dist_min.'.js';
		$js_success = 'scutum.pages.contactList.init()';
	}
    if($page == 'data_visualization') {
        $js = 'assets/js/views/pages/data_visualization'.$dist_min.'.js';
        $js_success = 'scutum.pages.data_visualization.init()';
    }
	if($page == 'gallery') {
		$js = 'assets/js/views/pages/gallery'.$dist_min.'.js';
		$js_success = 'scutum.pages.gallery.init()';
	}
	if($page == 'invoices') {
		$htmlClass = 'sc-card-fixed sc-header-expanded';
		$js = 'assets/js/views/pages/invoices'.$dist_min.'.js';
		$js_success = 'scutum.pages.invoices.init()';
	}
    if($page == 'invoice_create') {
        $htmlClass = 'sc-card-fixed sc-header-expanded';
        $js = 'assets/js/views/pages/invoice_create'.$dist_min.'.js';
        $js_success = 'scutum.pages.invoiceCreate.init()';
    }
	if($page == 'mailbox') {
		$htmlClass = 'sc-page-fixed';
		$js = 'assets/js/views/pages/mailbox'.$dist_min.'.js';
		$js_success = 'scutum.pages.mailbox.init()';
	}
	if($page == 'task_board') {
		$htmlClass = 'sc-page-fixed';
		$js = 'assets/js/views/pages/task-board'.$dist_min.'.js';
		$js_success = 'scutum.pages.taskBoard.init()';
	}
	if($page == 'contact_list_single') {
		$htmlClass = 'sc-page-fixed';
		$js = 'assets/js/views/pages/contact_list_single'.$dist_min.'.js';
		$js_success = 'scutum.pages.contactListSingle.init()';
	}
	if($page == 'notes') {
		$js = 'assets/js/views/pages/notes'.$dist_min.'.js';
		$js_success = 'scutum.pages.notes.init()';
	}
	if($page == 'poi_listing') {
		$htmlClass = 'sc-page-fixed';
		$js = 'assets/js/views/pages/poi-listing'.$dist_min.'.js';
		$js_success = 'scutum.pages.poiListing.init()';
	}
	if($page == 'settings') {
		$js = 'assets/js/views/pages/settings'.$dist_min.'.js';
		$js_success = 'scutum.pages.settings.init()';
	}
    if($page == 'user_profile') {
        $js = 'assets/js/views/pages/user-profile'.$dist_min.'.js';
        $js_success = 'scutum.pages.user_profile.init()';
    }
	if($page == 'issues_list') {
		$js = 'assets/js/views/pages/issues'.$dist_min.'.js';
		$js_success = 'scutum.pages.issues.init()';
	}

	// PLUGINS
	if($page == 'ajax') {
	    $customMeta = '<meta name="intercoolerjs:use-data-prefix" content="true"/>';
		$js = 'assets/js/views/plugins/ajax'.$dist_min.'.js';
		$js_success = 'scutum.plugins.ajax.init()';
	}
	if($page == 'calendar') {
		$js = 'assets/js/views/plugins/calendar'.$dist_min.'.js';
		$js_success = 'scutum.plugins.calendar.init()';
	}
    if($page == 'calendar_events') {
        $js = 'assets/js/views/plugins/calendar_events'.$dist_min.'.js';
        $js_success = 'scutum.plugins.calendar_events.init()';
    }
	if($page == 'charts') {
		$js = 'assets/js/views/plugins/charts'.$dist_min.'.js';
		$js_success = 'scutum.plugins.charts.init()';
	}
	if($page == 'code_editor') {
		$htmlClass = 'sc-card-fixed sc-header-expanded';
		$js = 'assets/js/views/plugins/code_editor'.$dist_min.'.js';
		$js_success = 'scutum.plugins.codeEditor.init()';
	}
	if($page == 'data_grid') {
		$js = 'assets/js/views/plugins/data_grid'.$dist_min.'.js';
		$js_success = 'scutum.plugins.dataGrid.init()';
	}
	if($page == 'datatables') {
		$js = 'assets/js/views/plugins/datatables'.$dist_min.'.js';
		$js_success = 'scutum.plugins.dataTables.init()';
	}
	if($page == 'diff_tool') {
		$js = 'assets/js/views/plugins/diff_tool'.$dist_min.'.js';
		$js_success = 'scutum.plugins.diffTool.init()';
	}
	if($page == 'gantt_chart') {
		$js = 'assets/js/views/plugins/gantt_chart'.$dist_min.'.js';
		$js_success = 'scutum.plugins.ganttChart.init()';
	}
	if($page == 'google_maps') {
		$js = 'assets/js/views/plugins/google_maps'.$dist_min.'.js';
		$js_success = 'scutum.plugins.gmaps.init()';
	}
	if($page == 'idle_timeout') {
		$js = 'assets/js/views/plugins/idle_timeout'.$dist_min.'.js';
		$js_success = 'scutum.plugins.idleTimeout.init()';
	}
	if($page == 'image_cropper') {
		$js = 'assets/js/views/plugins/image_cropper'.$dist_min.'.js';
		$js_success = 'scutum.plugins.cropper.init()';
	}
	if($page == 'push_notifications') {
		$js = 'assets/js/views/plugins/push_notifications'.$dist_min.'.js';
		$js_success = 'scutum.plugins.pushNotifications.init()';
	}
    if($page == 'swipe_calendar') {
        $js = 'assets/js/views/plugins/swipe_calendar'.$dist_min.'.js';
        $js_success = 'scutum.plugins.swipe_calendar.init()';
    }
	if($page == 'tour') {
		$js = 'assets/js/views/plugins/tour'.$dist_min.'.js';
		$js_success = 'scutum.plugins.tour.init()';
	}
	if($page == 'tree') {
		$js = 'assets/js/views/plugins/tree'.$dist_min.'.js';
		$js_success = 'scutum.plugins.tree.init()';
	}
	if($page == 'vector_maps') {
		$js = 'assets/js/views/plugins/vector_maps'.$dist_min.'.js';
		$js_success = 'scutum.plugins.vectorMaps.init()';
	}


	// FORMS
	if($page == 'regular_elements') {
		$js = 'assets/js/views/forms/forms-regular'.$dist_min.'.js';
		$js_success = 'scutum.forms.regular.init()';
	}
	if($page == 'advanced_elements') {
		$js = 'assets/js/views/forms/forms'.$dist_min.'.js';
		$js_success = 'scutum.forms.controls.init()';
	}
	if($page == 'dynamic_fields') {
		$js = 'assets/js/views/forms/dynamic-fields'.$dist_min.'.js';
		$js_success = 'scutum.dynamicFields.init()';
	}
	if($page == 'validation') {
		$js = 'assets/js/views/forms/forms-validation'.$dist_min.'.js';
		$js_success = 'scutum.forms.validation.init()';
	}
	if($page == 'ckeditor') {
		$js = 'assets/js/views/forms/forms-ckeditor'.$dist_min.'.js';
		$js_success = 'scutum.forms.ckeditor.init()';
	}
	if($page == 'tinymce') {
		$js = 'assets/js/views/forms/forms-tinymce'.$dist_min.'.js';
		$js_success = 'scutum.forms.tinymce.init()';
	}
	$form_examples = [
		'advertising_evaluation_form',
		'booking_form',
		'checkout_form',
		'job_application_form',
		'medical_history_form',
		'registration_form',
		'transaction_feedback_form',
		'rental_application_form',
	];
	if(in_array($page,$form_examples)) {
		$js = 'assets/js/views/forms/forms-examples'.$dist_min.'.js';
		$js_success = 'scutum.forms.examples.init()';
	}
	if($page == 'car_rental_form') {
		$htmlClass = 'sc-card-fixed sc-header-expanded';
		$js = 'assets/js/views/forms/forms-examples'.$dist_min.'.js';
		$js_success = 'scutum.forms.examples.init()';
	}
	$form_wizard = [
		'horizontal',
		'horizontal_minimal',
		'vertical',
		'vertical_minimal'
	];
	if(in_array($page,$form_wizard)) {
		$js = 'assets/js/views/forms/forms-wizard'.$dist_min.'.js';
		$js_success = 'scutum.forms.wizard.init()';
	}
	// COMPONENTS
	if($page == 'animations') {
		$js = 'assets/js/views/components/animations'.$dist_min.'.js';
		$js_success = 'scutum.components.animations.init()';
	}
	if($page == 'buttons') {
		$js = 'assets/js/views/components/buttons'.$dist_min.'.js';
		$js_success = 'scutum.components.buttons()';
	}
	if($page == 'cards') {
		$js = 'assets/js/views/components/cards'.$dist_min.'.js';
		$js_success = 'scutum.components.cards.init()';
	}
    if($page == 'footer') {
        $htmlClass = 'sc-footer-active';
    }
    if($page == 'fancy_toolbar') {
        $htmlClass = 'sc-fancy-toolbar-active';
    }
	if($page == 'icons') {
		$js = 'assets/js/views/components/icons'.$dist_min.'.js';
		$js_success = 'scutum.components.icons.init()';
	}
	if ($page == 'modals_dialogs') {
		$js = 'assets/js/views/components/modals_dialogs' . $dist_min . '.js';
		$js_success = 'scutum.components.modalsDialogs.init()';
	}
	if ($page == 'notifications') {
		$js = 'assets/js/views/components/notifications' . $dist_min . '.js';
		$js_success = 'scutum.components.notifications.init()';
	}
    if ($page == 'overlay') {
        $js = 'assets/js/views/components/overlay' . $dist_min . '.js';
        $js_success = 'scutum.components.overlay.init()';
    }
	if ($page == 'progress_spinners') {
		$js = 'assets/js/views/components/progress_spinners' . $dist_min . '.js';
		$js_success = 'scutum.components.progressSpinners.init()';
	}
	if($page == 'scrollable') {
		$js = 'assets/js/views/components/scrollable'.$dist_min.'.js';
		$js_success = 'scutum.components.scrollable.init()';
	}
    if($page == 'swiped_list') {
        $js = 'assets/js/views/components/swiped_list'.$dist_min.'.js';
        $js_success = 'scutum.components.swiped_list.init()';
    }
	// LAYOUT
    if($page == 'boxed') {
        $htmlClass = 'sc-layout-boxed';
    }
    if($page == 'mini_sidebar') {
		$htmlClass = 'sc-sidebar-mini';
	}
    if($page == 'offcanvas_sidebar') {
        $htmlClass = 'sc-sidebar-offcanvas';
    }
	if($page == 'top_menu') {
		$htmlClass = 'sc-sidebar-disabled';
	}
}
