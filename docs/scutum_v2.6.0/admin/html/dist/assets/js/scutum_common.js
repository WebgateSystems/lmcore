// ----------------------------------------
// VARIABLES
// ----------------------------------------

var scutum = {};
scutum.config = {
	gmapsKey: 'AIzaSyC2FodI8g-iCz1KHRFE7_4r8MFLA7Zbyhk',
	customScrollbar: false,
	hiResImages: true
};
scutum.$body = $('body');
scutum.$html = $('html');
scutum.$doc = $(document);
scutum.$win = $(window);
scutum.$sidebarMain = $('#sc-sidebar-main');
scutum.$offcanvas = $('#sc-offcanvas');
scutum.$toolbar = $('#sc-toolbar');
scutum.$header = $('#sc-header');
scutum.$topBar = $('#sc-page-top-bar');
scutum.$pageContent = $('#sc-page-content');
scutum.$pageWrapper = $('#sc-page-wrapper');
scutum.easingSwiftOut = [0.55, 0, 0.1, 1];
scutum.forms = {};
scutum.pages = {};
scutum.plugins = {};
scutum.components = {};

// ----------------------------------------
// INIT FUNCTIONS
// ----------------------------------------

scutum.init = function () {
	// helpers
	scutum.helpers.init();
	// main sidebar
	scutum.sidebarMain.init();
	// cards
	scutum.cards.init();
	// common form controls
	scutum.forms.common.init();
	// toolbar
	scutum.toolbar.init();
	// main header
	scutum.headerMain.init();
	// offcanvas
	scutum.offcanvas.init();
	// uikit custom functions
	scutum.uikitCustom.init();
	// fix extra spacing in edge
	if (document.documentMode || /Edge/.test(navigator.userAgent)) {
		$('ul.sc-js-edge-fix').each(function () {
			$(this).parent().prepend($(this).detach());
		});
	}
	// fab (speed dial)
	scutum.helpers.fab.speedDial();
	// fab (single sheet)
	scutum.helpers.fab.singleSheet();
	// fancy footer
	scutum.fancyFooter.init();
	// fancy footer
	scutum.fancyToolbar.init();
};

// ----------------------------------------
// LOADJS Config
// ----------------------------------------
scutum.bundles = {
	// =========== CHARTS
	// https://github.com/naver/billboard.js
	'billboard': ['node_modules/billboard.js/dist/billboard.js', 'assets/css/plugins/billboard.min.css'],
	// https://github.com/d3/d3
	'd3': ['node_modules/d3/dist/d3.min.js'],
	// https://github.com/chartjs/Chart.js
	'chartjs': ['node_modules/chart.js/dist/Chart.min.js'],
	// =========== FORMS
	// https://openexchangerates.github.io/accounting.js/
	'accounting': ['assets/js/vendor/accounting.min.js'],
	// https://github.com/jackmoore/autosize
	'autosize': ['assets/js/vendor/autosize.min.js'],
	// https://github.com/tuupola/jquery_chained
	'chained': ['assets/js/vendor/jquery.chained.min.js'],
	// https://github.com/PawelDecowski/jquery-creditcardvalidator
	'creditCardValidator': ['node_modules/jQuery-CreditCardValidator/jquery.creditCardValidator.js'],
	// https://github.com/longbill/jquery-date-range-picker
	'daterangepicker': ['node_modules/jquery-date-range-picker/dist/jquery.daterangepicker.min.js', 'assets/css/plugins/daterangepicker.min.css'],
	// https://github.com/flatpickr/flatpickr
	'flatpickr': ['node_modules/flatpickr/dist/flatpickr.min.js', 'node_modules/flatpickr/dist/plugins/confirmDate/confirmDate.js', 'node_modules/flatpickr/dist/plugins/rangePlugin.js', 'node_modules/flatpickr/dist/flatpickr.min.css', 'assets/css/plugins/flatpickr.min.css'],
	// https://github.com/fronteed/icheck
	'icheck': ['node_modules/icheck/icheck.min.js'],
	// https://github.com/RobinHerbots/Inputmask
	'inputmask': ['node_modules/inputmask/dist/min/jquery.inputmask.bundle.min.js'],
	// https://github.com/lou/multi-select
	'multiSelect': ['assets/js/vendor/jquery.multi-select.min.js', 'assets/css/plugins/multiselect.min.css'],
	// https://github.com/IonDen/ion.rangeSlider
	'rangeSlider': ['node_modules/ion-rangeslider/js/ion.rangeSlider.min.js', 'assets/css/plugins/range_slider.min.css'],
	// https://github.com/guillaumepotier/Parsley.js
	'parsleyJS': ['node_modules/parsleyjs/dist/parsley.min.js'],
	// https://github.com/wbotelhos/raty
	'raty': ['node_modules/raty-js/lib/jquery.raty.js', 'assets/css/plugins/raty.min.css'],
	// https://github.com/select2/select2
	'select2': ['node_modules/select2/dist/js/select2.min.js', 'node_modules/select2/dist/css/select2.min.css', 'assets/css/plugins/select2.min.css'],
	// https://github.com/rstaib/jquery-steps
	'steps': ['assets/js/vendor/jquery.steps.min.js', 'assets/css/plugins/steps.min.css'],
	// https://github.com/abpetkov/switchery
	'switchery': ['node_modules/switchery/dist/switchery.min.js', 'assets/css/plugins/switchery.min.css'],
	// =========== WYSIWYG
	// https://www.tiny.cloud/
	'tinymce': ['assets/js/vendor/tinymce/tinymce.min.js'],
	'tinymceRTL': ['assets/js/vendor/tinymce/langs/ar.js'],
	// https://ckeditor.com/ckeditor-5/
	'ckeditor': ['assets/js/vendor/ckeditor/ckeditor.js'],
	'ckeditorRTL': ['assets/js/vendor/ckeditor/translations/ar.js'],
	// =========== OTHER PLUGINS
	// http://backbonejs.org/
	'backbone': ['node_modules/backbone/backbone-min.js'],
	// https://chancejs.com/index.html
	'chancejs': ['assets/js/vendor/chance.min.js'],
	// https://github.com/zenorocha/clipboard.js
	'clipboard': ['node_modules/clipboard/dist/clipboard.min.js'],
	// https://codemirror.net/
	'codemirror': ['node_modules/codemirror/lib/codemirror.js', 'node_modules/codemirror/lib/codemirror.css', 'assets/css/plugins/codemirror.min.css', 'node_modules/codemirror/theme/material.css'],
	'codemirror-modes': ['node_modules/codemirror/mode/htmlmixed/htmlmixed.js', 'node_modules/codemirror/mode/xml/xml.js', 'node_modules/codemirror/mode/php/php.js', 'node_modules/codemirror/mode/clike/clike.js', 'node_modules/codemirror/mode/javascript/javascript.js'],
	'codemirror-addons': ['node_modules/codemirror/addon/display/fullscreen.js', 'node_modules/codemirror/addon/edit/matchbrackets.js', 'node_modules/codemirror/addon/edit/matchtags.js', 'node_modules/codemirror/addon/fold/xml-fold.js', 'node_modules/codemirror/addon/scroll/simplescrollbars.js', 'node_modules/codemirror/addon/scroll/simplescrollbars.css'],
	// https://github.com/fengyuanchen/cropper
	'cropper': ['node_modules/cropper/dist/cropper.min.js', 'assets/css/plugins/cropper.min.css'],
	// https://datatables.net/
	'datatables': ['node_modules/datatables.net/js/jquery.dataTables.min.js', 'node_modules/datatables.net-responsive/js/dataTables.responsive.min.js', 'assets/js/vendor/datatables/responsive.uikit.min.js', 'assets/js/vendor/datatables/dataTables.uikit.min.js', 'assets/css/plugins/datatables.min.css'],
	'datatables-buttons': ['assets/js/vendor/pdfmake.min.js', 'assets/js/vendor/vfs_fonts.js', 'assets/js/vendor/jszip.min.js', 'node_modules/datatables.net-buttons/js/dataTables.buttons.min.js', 'node_modules/datatables.net-buttons/js/buttons.html5.min.js', 'node_modules/datatables.net-buttons/js/buttons.print.min.js'],
	'datatables-scroller': ['node_modules/datatables.net-scroller/js/dataTables.scroller.min.js'],
	// https://github.com/kpdecker/jsdiff
	'diff-tool': ['node_modules/diff/dist/diff.min.js'],
	// https://github.com/kamranahmedse/driver.js
	'driver': ['node_modules/driver.js/dist/driver.min.js', 'assets/css/plugins/driver.min.css'],
	// https://github.com/bevacqua/dragula
	'dragula': ['node_modules/dragula/dist/dragula.min.js', 'assets/css/plugins/dragula.min.css'],
	// https://github.com/mar10/fancytree
	'fancytree': ['node_modules/jquery.fancytree/dist/jquery.fancytree-all-deps.min.js', 'assets/js/vendor/jquery.fancytree.glyphMap.min.js', 'node_modules/jquery.fancytree/dist/skin-material/ui.fancytree.min.css', 'assets/css/plugins/fancytree.min.css'],
	// http://jasny.github.com/bootstrap/javascript/#fileinput
	'fileinput': ['assets/js/vendor/uikit.fileinput.min.js'],
	// https://github.com/thegrubbsian/jquery.ganttView
	'gantt-chart': ['assets/js/vendor/jquery.gantt-chart.js', 'assets/css/plugins/gantt_chart.min.css'],
	// google maps
	'gmaps': ['https://maps.google.com/maps/api/js?key=' + scutum.config.gmapsKey, 'assets/js/vendor/gmaps.min.js'],
	// https://github.com/wycats/handlebars.js
	'handlebars': ['node_modules/handlebars/dist/handlebars.min.js', 'handlebars/handlebars_helpers.js', 'node_modules/handlebars-intl/dist/handlebars-intl.min.js', 'node_modules/handlebars-intl/dist/locale-data/fr.js'],
	// https://github.com/thorst/jquery-idletimer
	'idle-timeout': ['assets/js/vendor/idle-timer.min.js'],
	// https://github.com/desandro/imagesloaded
	'imagesLoaded': ['node_modules/imagesloaded/imagesloaded.pkgd.min.js'],
	// http://intercoolerjs.org/
	'intercooler': ['assets/js/vendor/intercooler.min.js'],
	// https://jqueryui.com/
	'jquery-ui': ['assets/js/vendor/jquery-ui.min.js'],
	// https://github.com/10bestdesign/jqvmap
	'jqvmap': ['assets/js/vendor/jqvmap/jquery.vmap.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.world.min.js', 'assets/css/plugins/jqvmap.min.css'],
	'jqvmap-maps': ['assets/js/vendor/jqvmap/maps/jquery.vmap.algeria.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.argentina.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.australia.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.brazil.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.canada.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.china.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.europe.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.france.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.germany.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.greece.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.india.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.iran.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.iraq.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.poland.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.russia.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.south_america.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.tunisia.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.turkey.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.usa.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.africa.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.asia.min.js', 'assets/js/vendor/jqvmap/maps/jquery.vmap.north_america.min.js'],
	// https://github.com/highlightjs/highlight.js
	'highlightJS': ['assets/js/vendor/highlight.js/highlight.pack.min.js', 'assets/js/vendor/highlight.js/styles/github.css'],
	// https://github.com/davetayls/jquery.kinetic
	'kinetic': ['assets/js/vendor/jquery.kinetic.min.js'],
	// https://github.com/javve/list.js
	'listjs': ['node_modules/list.js/dist/list.min.js'],
	// https://github.com/esteinborn/jquery-listnav
	'listnav': ['assets/js/vendor/jquery-listnav.min.js', 'assets/css/plugins/listnav.min.css'],
	// https://github.com/jakerella/jquery-mockjax
	'mockjax': ['node_modules/jquery-mockjax/dist/jquery.mockjax.min.js'],
	// https://github.com/unite-cms/uikit3-nestable
	'nestable': ['assets/js/vendor/uikit.nestable.min.js', 'assets/css/plugins/nestable.min.css'],
	// https://github.com/VincentGarreau/particles.js/
	'particlesJS': ['assets/js/vendor/particles.min.js'],
	// https://github.com/mdbootstrap/perfect-scrollbar
	'perfect-scrollbar': ['node_modules/perfect-scrollbar/css/perfect-scrollbar.css', 'node_modules/perfect-scrollbar/dist/perfect-scrollbar.min.js'],
	// https://github.com/Nickersoft/push.js
	'pushJS': ['node_modules/push.js/bin/push.min.js'],
	// https://github.com/leafo/sticky-kit
	'stickyKit': ['assets/js/vendor/sticky-kit.min.js'],
	// https://github.com/sindresorhus/screenfull.js
	'screenfull': ['node_modules/screenfull/dist/screenfull.js'],
	// https://github.com/atmist/snazzy-info-window
	'snazzy-infowindow': ['node_modules/snazzy-info-window/dist/snazzy-info-window.min.js', 'assets/css/plugins/snazzy_infowindow.min.css'],
	// tablesorter
	'tablesorter': ['node_modules/tablesorter/dist/js/jquery.tablesorter.min.js', 'node_modules/tablesorter/dist/js/extras/jquery.tablesorter.pager.min.js', 'node_modules/tablesorter/dist/js/jquery.tablesorter.widgets.min.js', 'assets/css/plugins/tablesorter.min.css'],
	'tablesorter-widgets': ['node_modules/tablesorter/dist/js/widgets/widget-print.min.js'],
	'tablesorter-pagecontrols': ['node_modules/tablesorter-pagercontrols/dist/js/jquery.tablesorter.pager.appendcontrols.english.min.js','node_modules/tablesorter-pagercontrols/dist/css/jquery.tablesorter.pager.appendcontrols.css'],
	// https://github.com/nhnent/tui-calendar
	'tui-calendar': ['node_modules/tui-calendar/dist/tui-calendar.min.js', 'node_modules/tui-calendar/dist/tui-calendar.min.css', 'assets/css/plugins/calendar.min.css'],
	// https://github.com/nhnent/tui.date-picker
	'tui-datepicker': ['node_modules/tui-date-picker/dist/tui-date-picker.min.js', 'node_modules/tui-date-picker/dist/tui-date-picker.css'],
	// https://github.com/nhnent/tui.grid
	'tui-grid': ['node_modules/tui-grid/dist/tui-grid.min.js', 'node_modules/tui-grid/dist/tui-grid.min.css', 'assets/css/plugins/data_grid.min.css'],
	// https://github.com/nhnent/tui.pagination
	'tui-pagination': ['node_modules/tui-pagination/dist/tui-pagination.min.js'],
	// https://github.com/nhnent/tui.code-snippet
	'tui-snippets': ['assets/js/vendor/tui-code-snippet.min.js'],
	// https://github.com/nhnent/tui.time-picker
	'tui-timepicker': ['node_modules/tui-time-picker/dist/tui-time-picker.min.js', 'node_modules/tui-time-picker/dist/tui-time-picker.css'],
	// https://github.com/DeuxHuitHuit/quicksearch
	'quicksearch': ['assets/js/vendor/jquery.quicksearch.min.js'],
	// https://www.npmjs.com/package/xhr-mock
	'xhr-mock': ['assets/js/vendor/xhr-mock.js'],
	// =========== OTHER ASSETS
	'flagsCSS': ['assets/icons/flags/flags.css'],
	'uikitCSS': ['node_modules/uikit/dist/css/uikit.min.css'],
	'uikitCSSRTL': ['node_modules/uikit/dist/css/uikit-rtl.min.css'],
	'hammerJS': ['assets/js/vendor/hammer.min.js'],
	'printThis': ['assets/js/vendor/printThis.min.js'],
	'swiped': ['assets/js/vendor/swiped.js', 'assets/css/plugins/swiped_list.min.css'],
	'swiper': ['node_modules/swiper/swiper-bundle.js', 'node_modules/swiper/swiper-bundle.min.css'],
	'clndr': ['assets/js/vendor/clndr/clndr.min.js', 'assets/css/plugins/clndr.min.css']
};
scutum.getBundlesFiles = function (nodeModules) {
	// get all files from scutum.bundles
	var _files = [];
	Object.keys(scutum.bundles).forEach(function (key) {
		scutum.bundles[key].forEach(function (element) {
			_files.push(element);
		});
	});
	// filter node_modules
	if (nodeModules) {
		_files = _files.filter(function (file) {
			return file.indexOf('node_modules') !== -1;
		});
	}
	// add all tinymce assets
	_files.push('node_modules/tinymce/**/*');
	return _files;
};
// console.log(scutum.getBundlesFiles(true))

/**
 * Require-like dependency manager
 * @param {array} 		bundleIds	bundle names (defined in scutum.bundles)
 * @param {function} 	successFn	function to run after all assets has been successfully loaded
 * @param {boolean} 	async		load files synchronously or asynchronously
 */
scutum.require = function (bundleIds, successFn, async) {
	bundleIds.forEach(function (bundleId) {
		if (!(bundleId in scutum.bundles)) {
			// eslint-disable-next-line no-console
			console.log('Bundle not defined: ' + bundleId);
		} else {
			if (!loadjs.isDefined(bundleId)) {
				loadjs(scutum.bundles[bundleId], bundleId, {
					async: typeof async === 'undefined'
				});
			}
		}
	});
	loadjs.ready(bundleIds, successFn);
};

// ----------------------------------------
// UIKIT CUSTOM FUNCTIONS
// ----------------------------------------
scutum.uikitCustom = {}
scutum.uikitCustom.init = function () {
	// hide dropdown on children click
	scutum.$body.on('click', '.sc-uk-dropdown-close', function(e) {
		UIkit.dropdown($(e.target).closest('.uk-dropdown')).hide();
	});
}


// ----------------------------------------
// HELPERS
// ----------------------------------------

scutum.helpers = {};
scutum.helpers.init = function () {
	// detect touch
	scutum.helpers.touchDetect();
	// code highlight
	scutum.helpers.codeHighlight();
	// live search
	// scutum.helpers.listjs();
	// prevent default behaviour of hashed anchor tag
	scutum.helpers.preventLinkClick();
	// ripple effect
	scutum.helpers.waves();
	// iCheck toggle list items
	scutum.helpers.iCheck.toggleListItems();
	// iCheck toggle single item
	scutum.helpers.iCheck.toggleSingleItem();
	// sequence show
	scutum.helpers.sequenceShow.init();
	// toggle column visibility
	scutum.helpers.column.toggle();
	// sticky
	scutum.helpers.sticky();
	// styled scrollbar
	scutum.helpers.scrollbar.custom();
	// parsleyJS config
	scutum.helpers.validation.parsleyJS();
	// background gradient
	scutum.helpers.bgGradient();
	// HiRes Images
	scutum.helpers.hiResImages();
	// disable double click on touch devices
	// scutum.helpers.disableDoubleClick();
};
scutum.helpers.touchDetect = function () {
	window.addEventListener('touchstart', function onFirstTouch () {
		document.body.classList.add('sc-touch-device');
		window.TOUCH_DETECTED = true;
		// scutum.$body.dispatchEvent('touch-detected', true);
		window.removeEventListener('touchstart', onFirstTouch, false);
	}, false);
};

/**
 * Highlight code in pre block
 */
scutum.helpers.codeHighlight = function () {
	var $el = $('pre.sc-js-highlight');
	if ($el.length) {
		scutum.require(['highlightJS'], function () {
			$el.not('.highlighted').each(function (i, block) {
				hljs.highlightBlock(block);
				$(this).addClass('highlighted');
			});
		});
	}
};
/**
 * Generate unique ID
 * @returns {string}
 */
scutum.helpers.uniqueID = function () {
	var text = "";
	var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	for (var i = 0; i < 6; i++) {
		text += possible.charAt(Math.floor(Math.random() * possible.length));
	}
	return text;
};
/**
 * Check if device has hi-res display
 * @returns {boolean}
 */
scutum.helpers.isHiRes = (function () {
	var mediaQuery = "(-webkit-min-device-pixel-ratio: 1.5),(min--moz-device-pixel-ratio: 1.5),(-o-min-device-pixel-ratio: 3/2),(min-resolution: 1.5dppx)";
	if (window.devicePixelRatio > 1) {
		return true;
	}
	return window.matchMedia && window.matchMedia(mediaQuery).matches;
}());
/**
 * Extend object
 * @param   {object} defaults
 * @param   {object} options
 * @returns {object} extended object
 */
scutum.helpers.extend = function (defaults, options) {
	var extended = {};
	var prop;
	for (prop in defaults) {
		if (Object.prototype.hasOwnProperty.call(defaults, prop)) {
			extended[prop] = defaults[prop];
		}
	}
	for (prop in options) {
		if (Object.prototype.hasOwnProperty.call(options, prop)) {
			extended[prop] = options[prop];
		}
	}
	return extended;
};
/**
 * Prevent Default Behaviour of Hashed Anchor Tag
 */
scutum.helpers.preventLinkClick = function () {
	scutum.$body.on('click', 'a[href="#"]', function (e) {
		e.preventDefault();
	});
};
/**
 * Sequence animation
 */
scutum.helpers.sequenceShow = {
	'settings': {
		animation: 'uk-animation-scale-up', // animation class
		duration: '320', // animation duration
		delay: 0.25, // animation delay
		target: '' // animated element
	},
	'init': function (wrapper, manual) {
		var $wrapper = wrapper ? $(wrapper) : $('[data-sc-sequence-show]');
		if ($wrapper.length) {
			$wrapper.each(function () {
				var $this = $(this);
				var thisOffset = $this.offset();
				if ($this.hasClass('sc-sequence-show-processed') || !$this.children().length) {
					return;
				}
				var settings = JSON.parse(JSON.stringify(scutum.helpers.sequenceShow.settings));
				if ($this.attr('data-sc-sequence-show') !== '') {
					settings = $.extend(settings, jQuery.parseJSON($this.attr('data-sc-sequence-show')));
				}
				var $target = (settings.target === '') ? $this.children() : $this.find(settings.target);
				$target.addClass('sc-sequence-show');
				setTimeout(function () {
					$target.each(function (index) {
						var $el = $(this);
						var elementPosition = $el.position();
						var hOffset = scutum.helpers.isRTL() ? $wrapper.outerWidth() - (elementPosition.left + $el.outerWidth()) : elementPosition.left;
						var calculatedOffset = hOffset * 0.8 + (elementPosition.top - thisOffset.top);
						var delay = parseFloat(calculatedOffset * settings.delay).toFixed(0);
						// console.log(parseFloat(calculatedOffset * 0.32).toFixed(0));
						// var delay = (duration * 0.32) * (index + 1);
						$el
							.css('-webkit-animation-delay', delay + 'ms').css('animation-delay', delay + 'ms')
							.css('-webkit-animation-duration', settings.duration + 'ms').css('animation-duration', settings.duration + 'ms');
						if (!$this.hasClass('sc-sequence-show-manual')) {
							$this.on('inview', function () {
								scutum.helpers.sequenceShow.activate($el, settings.animation);
							});
						}
						if (manual) {
							scutum.helpers.sequenceShow.activate($el, settings.animation);
						}
					});
					// show items when they are in view
					if (!$this.hasClass('sc-sequence-show-manual')) {
						if (typeof UIkit.scrollspy === 'function') {
							UIkit.scrollspy($this);
						}
					}
					$this.addClass('sc-sequence-show-processed');
				}, 500);
			});
		}
	},
	'activate': function ($el, animation, callback) {
		var $parent = $el.closest('.sc-sequence-show');
		var _animation = animation || $parent.attr('data-sequence-animation') || scutum.helpers.sequenceShow.settings.animation;
		$parent.addClass('sc-sequence-show-animate ' + _animation);
		$parent.one('webkitAnimationEnd animationend', function () {
			$(this)
				.css({
					'-webkit-animation-delay': '',
					'-webkit-animation-duration': '',
					'animation-duration': '',
					'animation-delay': ''
				})
				.removeClass('sc-sequence-show sc-sequence-show-animate')
				.removeClass(_animation);
		});
		if (typeof callback === "function") {
			$parent.last().one('webkitAnimationEnd animationend', function () {
				callback();
			})
		}
	}
};
scutum.helpers.scrollbar = {
	/**
	 * Get scrollbar width
	 */
	'width': function (width) {
		/*!
		 * jQuery scrollbarWidth - v0.2 - 2/11/2009
		 * http://benalman.com/projects/jquery-misc-plugins/
		 */
		var parent, child;
		if (width === undefined) {
			parent = $('<div style="width:50px;height:50px;overflow:auto"></div>').appendTo('body');
			child = parent.children();
			width = child.innerWidth() - child.height(99).innerWidth();
			parent.remove();
		}
		return width;
	},
	/**
	 * Disable scrollbar
	 */
	'disable': function (height) {
		scutum.$html.css({'overflow': 'hidden'});
		scutum.$body.css({'overflow-y': 'scroll'});
		scutum.$header.css({'margin-right': scutum.helpers.scrollbar.width()});
		if (height) {
			scutum.$body.css({'height': '100%'});
		}
	},
	/**
	 * Enable scrollbar
	 */
	'enable': function (height) {
		scutum.$html.css({'overflow': ''});
		scutum.$body.css({'overflow-y': ''});
		scutum.$header.css({'margin-right': ''});
		if (height) {
			scutum.$body.css({'height': ''});
		}
	},
	/**
	 * Custom scrollbar
	 * (must be activated in scutum.config)
	 */
	'custom': function (el) {
		if (scutum.config.customScrollbar && scutum.helpers.mq.mediumMin()) {
			var $el = (el !== undefined) ? $(el) : $("[data-sc-scrollbar]");
			if ($el.length) {
				scutum.require(['perfect-scrollbar'], function () {
					$el.each(function () {
						var $this = $(this);
						var ps = new PerfectScrollbar($this[0]);
						$this.addClass('uk-position-relative').data('ps', ps);
						if ($this.attr('data-sc-scrollbar') === 'visible-y') {
							$this.addClass('ps--active-y ps--focus');
						}
						if ($this.attr('data-sc-scrollbar') === 'visible-x') {
							$this.addClass('ps--active-x ps--focus');
						}
					})
				});
			}
		}
	}
};
/**
 * Custom colors (used in eg. charts)
 */
scutum.helpers.colors = {
	'multi': ['#0288D1', '#FB8C00', '#689F38', '#7B1FA2', '#D32F2F', '#00796B'],
	'blue': ['#01579B', '#0288D1', '#03A9F4', '#4FC3F7', '#B3E5FC'],
	'green': ['#558B2F', '#689F38', '#7CB342', '#8BC34A', '#9CCC65'],
	'chart_a': ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf']
};
/**
 * Convert Hex to RGBA
 * @param   {string} hex        color in hex
 * @param   {number} opacity    opacity value
 * @returns {string}            color in rgba
 */
scutum.helpers.hex2rgba = function (hex, opacity) {
	var _opacity = opacity || 100;
	var _hex = hex.replace('#', '');
	var r = parseInt(_hex.substring(0, 2), 16);
	var g = parseInt(_hex.substring(2, 4), 16);
	var b = parseInt(_hex.substring(4, 6), 16);
	return 'rgba(' + r + ',' + g + ',' + b + ',' + _opacity / 100 + ')';
};
/**
 * Convert Hex to RGB
 * @param   {string} hex    color in hex
 * @returns {string} rgb    color in rgb
 */
scutum.helpers.hex2rgb = function (hex) {
	hex = hex.replace('#', '');
	var r = parseInt(hex.substring(0, 2), 16);
	var g = parseInt(hex.substring(2, 4), 16);
	var b = parseInt(hex.substring(4, 6), 16);

	return 'rgba(' + r + ',' + g + ',' + b + ')';
};
/**
 * Wave effect
 */
scutum.helpers.waves = function () {
	if (typeof Waves.init === 'function' && $('.sc-js-button-wave,.sc-js-button-light-wave,.sc-js-block-wave,.sc-js-block-light-wave').length) {
		Waves.attach('.sc-js-button-wave,.sc-card-actions-icon', ['waves-button']);
		Waves.attach('.sc-js-button-wave-light', ['waves-button', 'waves-light']);
		Waves.attach('.sc-js-button-wave-primary', ['waves-button', 'waves-primary']);
		Waves.attach('.sc-js-button-wave-md', ['waves-button', 'waves-md']);
		Waves.attach('.sc-js-button-wave-warning', ['waves-button', 'waves-warning']);
		Waves.attach('.sc-js-button-wave-success', ['waves-button', 'waves-success']);
		Waves.attach('.sc-js-button-wave-danger', ['waves-button', 'waves-danger']);
		Waves.attach('.sc-js-block-wave', ['waves-block']);
		Waves.attach('.sc-js-block-wave-light', ['waves-block', 'waves-light']);
		Waves.init();
	}
};
scutum.helpers.iCheck = {
	/**
	 * Toggle all checkboxes
	 */
	'toggleListItems': function () {
		var $mainCheckbox = $('.sc-main-checkbox');
		if ($mainCheckbox.length) {
			$mainCheckbox.each(function () {
				var $this = $(this);
				var thisGroup = $this.attr('data-group');
				$this
					.on('ifChecked', function () {
						scutum.$body.find(thisGroup).iCheck('check');
					})
					.on('ifUnchecked', function () {
						scutum.$body.find(thisGroup).iCheck('uncheck');
					});
				scutum.$body.on('ifChanged', thisGroup, function () {
					var isAllChecked = true;
					scutum.$body.find(thisGroup).each(function () {
						if (!$(this).is(':checked')) {
							isAllChecked = false;
						}
					});
					$this.prop('checked', isAllChecked).iCheck('update');
				});
			})
		}
	},
	/**
	 * Toggle <tr>,<li> element on checkbox change
	 */
	'toggleSingleItem': function () {
		var $el = $('.sc-js-item-check');
		if ($el.length) {
			$el.each(function () {
				$(this).on('ifChecked', function () {
					$(this).closest('li,tr').addClass('sc-item-checked');
				});
				$(this).on('ifUnchecked', function () {
					$(this).closest('li,tr').removeClass('sc-item-checked');
				});
			})
		}
	}
};
scutum.helpers.overlay = {
	/**
	 * Add overlay to container
	 * @param {string}  parent      container class or id
	 * @param {boolean} animate     fadeIn effect
	 * @param {number}  offset      top offset
	 */
	'add': function (parent, animate, offset) {
		var $parent = parent ? $(parent) : scutum.$body;
		var offsetTop = offset ? 'style="top:' + offset + 'px"' : '';

		if (animate) {
			$parent.append('<div class="sc-overlay" ' + offsetTop + '></div>');
			setTimeout(function () {
				$parent.find('.sc-overlay').addClass('dimmed');
			}, 10);
		} else {
			$parent.append('<div class="sc-overlay dimmed" ' + offsetTop + '></div>');
		}
	},
	/**
	 * Remove overlay
	 * @param {string}  parent      container class or id
	 * @param {boolean} animate     fadeOut effect
	 */
	'remove': function (parent, animate) {
		var $parent = parent ? $(parent) : scutum.$body;
		var $overlay = $parent.find('.sc-overlay');

		if (animate) {
			$overlay.removeClass('dimmed');
			setTimeout(function () {
				$overlay.remove();
			}, 280);
		} else {
			$overlay.remove();
		}
	}
};
scutum.helpers.validation = {
	/**
	 * ParsleyJS configuration
	 */
	'parsleyJS': function () {
		window.ParsleyConfig = {
			excluded: 'input[type=button], input[type=submit], input[type=reset], input[type=hidden], input.sc-validation-exclude',
			trigger: 'change',
			errorsWrapper: '<div class="sc-form-errors-list"></div>',
			errorTemplate: '<span></span>',
			errorClass: 'uk-form-danger',
			successClass: 'uk-form-success',
			errorsContainer: function (ParsleyField) {
				var element = ParsleyField.$element;
				var $container = element.closest('.sc-validation-wrapper');
				if (element.closest('.sc-input-wrapper').length) {
					$container = element.closest('.sc-input-wrapper').parent()
				}
				return $container;
			},
			classHandler: function (ParsleyField) {
				var element = ParsleyField.$element;
				if (element.is(':checkbox') || element.is(':radio') || element.parent().is('label') || $(element).is('[data-sc-select2]')) {
					return element.closest('.sc-validation-wrapper,.sc-input-wrapper');
				}
			}
		};
	},
	/**
	 * Email address validation
	 * @param   {string} email
	 * @returns {boolean}
	 */
	'emailAddress': function (email) {
		var pattern = new RegExp(/^(("[\w-+\s]+")|([\w-+]+(?:\.[\w-+]+)*)|("[\w-+\s]+")([\w-+]+(?:\.[\w-+]+)*))(@((?:[\w-+]+\.)*\w[\w-+]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$)|(@\[?(25[0-5]\.|2[0-4][\d]\.|1[\d]{2}\.|[\d]{1,2}\.)((25[0-5]|2[0-4][\d]|1[\d]{2}|[\d]{1,2})\.){2}(25[0-5]|2[0-4][\d]|1[\d]{2}|[\d]{1,2})\]?$)/i);
		return pattern.test(email);
	}
};
scutum.helpers.button = {
	/**
	 * Replace button content
	 * @param {string}  el          element class or id
	 * @param {string}  html        replaced content
	 * @param {boolean} animate     scale animation
	 * @param {string}  classToAdd  class to add to button
	 */
	'replaceContent': function (el, html, animate, classToAdd) {
		var $el = $(el).addClass('uk-transform-origin-center');
		var _html = $el.html();
		var $_html = $('<span class="uk-invisible">' + _html + '</span>');

		$el.html($_html);
		var $html = $el.children();

		if (animate) {
			$el.velocity({
				scale: 0.1,
				opacity: 0
			}, {
				duration: 140,
				easing: scutum.easingSwiftOut,
				complete: function () {
					$el.velocity('reverse', {delay: 150});
					if (classToAdd) {
						$el.addClass(classToAdd);
					}
					setTimeout(function () {
						$html.html(html).removeClass('uk-invisible');
					}, 200)
				}
			});
		} else {
			$(el).html(html);
		}
	},
	/**
	 * Show loading indicator
	 * @param {string} el       element class or id
	 * @param {string} mode     spinner color
	 */
	'showLoading': function (el, mode) {
		var $el = $(el);
		if (!$el.children('.sc-js-el-hide').length) {
			var $_html = $('<span class="uk-invisible">' + $el.html() + '</span>');
			var style = mode || $el.attr('data-button-mode') ? 'style="border-color: rgba(0,0,0,.2);border-top-color: rgba(255,255,255,.9)"' : '';
			var $spinner = $('<span class="sc-spinner sc-spinner-small uk-hidden"' + style + '></span>');
			$el.html($_html).append($spinner);
		}
		var $wrapper = $('<div>', {
			'class': 'sc-button-wrapper',
			'css': {
				'width': $el.outerWidth()
			}
		});
		$el.wrap($wrapper);
		$el.velocity({
			width: $el.outerHeight(),
			minWidth: $el.outerHeight()
		}, {
			duration: 140,
			easing: scutum.easingSwiftOut,
			complete: function () {
				$el.addClass('sc-button-round sc-button-flex uk-flex-center');
				$el.children('.sc-spinner').removeClass('uk-hidden');
				$el.children('.uk-invisible').toggleClass('uk-hidden uk-invisible');
			}
		})
	},
	/**
	 * Hide loading indicator
	 * @param {string} el       element class or id
	 */
	'hideLoading': function (el) {
		var $el = $(el);
		var $wrapper = $el.closest('.sc-button-wrapper');
		$.Velocity.hook($el, "transition", 'none');
		$el.velocity({
			width: $wrapper.width(),
			minWidth: $wrapper.width()
		}, {
			duration: 140,
			easing: scutum.easingSwiftOut,
			begin: function () {
				$el.children('.sc-spinner').remove();
				$el.removeClass('sc-button-round sc-button-flex uk-flex-center');
			},
			complete: function () {
				var $children = $el.children();
				$el.unwrap($wrapper);
				$.Velocity.hook($el, "transition", '');
				setTimeout(function () {
					$children.replaceWith($children[0].childNodes);
					// cleanup
					$.Velocity.hook($el, "width", '');
					$.Velocity.hook($el, "min-width", '');
				}, 150);
			}
		});
	}
};
/**
 * Hide content during transform (eg. collapse animation)
 * @param {string} el           element class or id
 * @param {number} delay        show content delay
 * @param {string} elExcluded   elements excluded from hiding
 */
scutum.helpers.hideDuringTransform = function (el, delay, elExcluded) {
	$(el).addClass('sc-js-el-transform');
	if (elExcluded) {
		$(el).find(elExcluded).addClass('sc-js-el-transform-visible');
	}
	setTimeout(function () {
		$(el).removeClass('sc-js-el-transform');
		if (elExcluded) {
			$(el).find(elExcluded).removeClass('sc-js-el-transform-visible');
		}
	}, delay || 280)
};
scutum.helpers.preloader = {
	/**
	 * Show preloader
	 * @param {string} el       element class or id
	 * @param {number} ratio    preloader size
	 * @param {number} color    preloader color
	 */
	'show': function (el, ratio, color) {
		$(el).html('<div class="' + (color || 'md-color-light-blue-500') + ' uk-flex uk-flex-center uk-flex-middle uk-height-1-1 uk-animation-fade sc-js-preloader uk-width-1-1" data-uk-spinner="ratio: ' + (ratio || 2) + '"></div>');
	},
	/**
	 * Show preloader (on top)
	 * @param {boolean} css     css/uikit preloader
	 * @param {string}  el      element class or id
	 * @param {number}  ratio   preloader size
	 * @param {string}  color   preloader color
	 */
	'overlayShow': function (css, el, ratio, color) {
		var _el = el || scutum.$body;
		var spinner = css ? '<div class="sc-spinner"></div>' : '<div class="' + (color || 'md-color-light-blue-500') + '" uk-spinner="ratio: ' + (ratio || 1) + '"></div>';
		var fixed = (_el === scutum.$body) ? ' fixed' : '';
		$(_el).append('<div class="sc-spinner-overlay' + fixed + '">' + spinner + '</div>');
		setTimeout(function () {
			$('.sc-spinner-overlay').addClass('enter');
		}, 50)
	},
	/**
	 * Hide preloader
	 */
	'overlayHide': function () {
		var $spinner = $('.sc-spinner-overlay');
		$spinner.removeClass('enter');
		setTimeout(function () {
			$spinner.remove();
		}, 300)
	}
};
scutum.helpers.column = {
	/**
	 * Toggle column
	 */
	'toggle': function () {
		var $el = $('.sc-js-column');
		if ($el.length) {
			$el.each(function () {
				var $this = $(this);
				$this.find('.sc-js-column-collapse').on('click', function (e) {
					e.preventDefault();
					scutum.helpers.hideDuringTransform($this);
					$this.addClass('sc-column-collapsed');
					var _that = $(this);
					setTimeout(function () {
						_that.trigger('collapse');
					}, 300)
				});
				$this.find('.sc-js-column-expand').on('click', function (e) {
					e.preventDefault();
					scutum.helpers.hideDuringTransform($this);
					$this.removeClass('sc-column-collapsed');
					var _that = $(this);
					setTimeout(function () {
						_that.trigger('expand');
					}, 300)
				});
			})
		}
	}
};
/**
 * Find object by key
 * @param   {array}           array
 * @param   {string}          key     object key
 * @param   {string|number}   value   object value
 * @returns {Promise<any>}
 */
scutum.helpers.findObjectByKey = function (array, key, value) {
	var object = function () {
		for (var i = 0; i < array.length; i++) {
			if (array[i][key] === value) {
				return array[i];
			}
		}
		return null;
	};
	return Promise.resolve(object()).catch(function (error) {
		console.log('There has been a error: ' + error.message);
		throw error;
	});
};
/**
 * Ajax helper function
 * @param   {string}        url
 * @param   {string}        method
 * @param   {string}        type
 * @param   {object}        data
 * @returns {Promise<any>}
 */
scutum.helpers.ajax = function (url, method, type, data) {
	return new Promise(function (resolve, reject) {
		var request = new XMLHttpRequest();
		request.onreadystatechange = function () {
			if (request.readyState === XMLHttpRequest.DONE) {
				if (request.status === 200) {
					if (type && type === 'json') {
						resolve(JSON.parse(request.responseText));
					} else {
						resolve(request.responseText);
					}
				} else {
					reject(Error(request.statusText));
				}
			}
		};
		request.onerror = function () {
			reject(Error("Network Error"));
		};
		request.open(method, url, true);
		request.responseType = 'text';
		request.send(data);
	}).catch(function (error) {
		console.log('There has been a error: ' + error.message);
		throw error;
	});
};
/**
 * Escape html
 * @param   {string} string
 * @returns {string}
 */
scutum.helpers.escapeHTML = function (string) {
	var entityMap = {
		'&': '&amp;',
		'<': '&lt;',
		'>': '&gt;',
		'"': '&quot;',
		"'": '&#39;',
		'/': '&#x2F;',
		'`': '&#x60;',
		'=': '&#x3D;'
	};
	return String(string).replace(/[&<>"'/]/g, function (s) {
		return entityMap[s];
	});
};
/**
 * Remove element from HTML
 * @param {string} el       element class or id
 * @param {number} delay    remove delay
 */
scutum.helpers.element = {
	'remove': function (el, delay) {
		if (delay) {
			setTimeout(function () {
				$(el).remove();
			}, delay)
		} else {
			$(el).remove();
		}
	}
};
/**
 * Sticky elements
 * based on Sticky-kit plugin
 */
scutum.helpers.sticky = function () {
	var $el = $('[data-sc-sticky]');
	if ($el.length) {
		scutum.require(['stickyKit'], function () {
			$el.each(function (el) {
				var $this = $(this);
				var config = {};
				var data = $this.attr('data-sc-sticky');
				var timeout = null;
				if (data !== '') {
					var userConfig = jQuery.parseJSON($this.attr('data-sc-sticky'));
					$.each(userConfig, function (k, v) {
						config[k] = v;
					});
				}
				if (scutum.$header.length && config.offset_top !== 'inPlace') {
					config.offset_top = scutum.$header.outerHeight();
				}
				if (config.offset_top === 'inPlace') {
					config.offset_top = $(this).offset().top;
				}
				if (typeof config.media !== 'undefined') {
					if (!scutum.helpers.mq[config.media]()) {
						return;
					}
				}
				if (config.delay) {
					timeout = config.delay;
					delete config['delay'];
					setTimeout(function () {
						$this.stick_in_parent(config);
					}, timeout);
				} else {
					$this.stick_in_parent(config);
				}
			});
		});
	}
};
/**
 * Function to limit your JavaScript function execution rate
 * @param {function} func
 * @param {number} wait
 * @param {boolean} immediate
 * @returns {Function}
 */
scutum.helpers.debounce = function (func, wait, immediate) {
	var timeout;
	return function () {
		var context = this;
		var args = arguments;
		var later = function () {
			timeout = null;
			if (!immediate) func.apply(context, args);
		};
		var callNow = immediate && !timeout;
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (callNow) func.apply(context, args);
	};
};
/**
 * Serialize form
 * @param {string} form form class or id
 */
scutum.helpers.serializeObject = function (form) {
	var o = {};
	var a = $(form).serializeArray();
	$.each(a, function () {
		if (o[this.name] !== undefined) {
			if (!o[this.name].push) {
				o[this.name] = [o[this.name]];
			}
			o[this.name].push(this.value || '');
		} else {
			o[this.name] = this.value || '';
		}
	});
	return o;
};
/**
 * Check if RTL mode is active
 * @returns {boolean}
 */
scutum.helpers.isRTL = function () {
	var getComputedStyle = window.getComputedStyle || function (element) {
		return element.currentStyle;
	};
	var style = getComputedStyle(scutum.$html[0]);
	return style.direction === 'rtl';
};
/**
 * Add gradient to element
 */
scutum.helpers.bgGradient = function () {
	var $el = $('[data-sc-bg-gradient]');
	if ($el.length) {
		$el.each(function () {
			var $this = $(this);
			var colors = $this.attr('data-sc-bg-gradient').split(',');
			$this.css({
				'background-color': colors[1],
				'background-image': 'linear-gradient( 135deg, ' + colors[0] + ' 10%, ' + colors[1] + ' 100%)'
			})
		})
	}
};
/**
 * Parse url params
 * @param   {string} query
 * @returns {object}
 */
// https://gist.github.com/kares/956897#gistcomment-29660
// Add an URL parser to JQuery that returns an object
// This function is meant to be used with an URL like the window.location
// Use: $.parseParams('http://mysite.com/?var=string') or $.parseParams() to parse the window.location
// Simple variable:  ?var=abc                        returns {var: "abc"}
// Simple object:    ?var.length=2&var.scope=123     returns {var: {length: "2", scope: "123"}}
// Simple array:     ?var[]=0&var[]=9                returns {var: ["0", "9"]}
// Array with index: ?var[0]=0&var[1]=9              returns {var: ["0", "9"]}
// Nested objects:   ?my.var.is.here=5               returns {my: {var: {is: {here: "5"}}}}
// All together:     ?var=a&my.var[]=b&my.cookie=no  returns {var: "a", my: {var: ["b"], cookie: "no"}}
// You just cant have an object in an array, ?var[1].test=abc DOES NOT WORK
scutum.helpers.parseParams = function (query) {
	var re = /([^&=]+)=?([^&]*)/g;
	var decode = function (str) {
		return decodeURIComponent(str.replace(/\+/g, ' '));
	};
	// recursive function to construct the result object
	function createElement (params, key, value) {
		key = key + '';
		// if the key is a property
		if (key.indexOf('.') !== -1) {
			// extract the first part with the name of the object
			var list = key.split('.');
			// the rest of the key
			var new_key = key.split(/\.(.+)?/)[1];
			// create the object if it doesnt exist
			if (!params[list[0]]) params[list[0]] = {};
			// if the key is not empty, create it in the object
			if (new_key !== '') {
				createElement(params[list[0]], new_key, value);
			} else console.warn('parseParams :: empty property in key "' + key + '"');
		} else
		// if the key is an array
		if (key.indexOf('[') !== -1) {
			// extract the array name
			var list = key.split('[');
			key = list[0];
			// extract the index of the array
			var _list = list[1].split(']');
			var index = _list[0];
			// if index is empty, just push the value at the end of the array
			if (index === '') {
				if (!params) params = {};
				if (!params[key] || !$.isArray(params[key])) params[key] = [];
				params[key].push(value);
			} else {
			// add the value at the index (must be an integer)
				if (!params) params = {};
				if (!params[key] || !$.isArray(params[key])) params[key] = [];
				params[key][parseInt(index)] = value;
			}
		} else {
		// just normal key
			if (!params) params = {};
			params[key] = value;
		}
	}
	// be sure the query is a string
	query = query + '';
	if (query === '') query = window.location + '';
	var params = {};
	var e;
	if (query) {
		// remove # from end of query
		if (query.indexOf('#') !== -1) {
			query = query.substr(0, query.indexOf('#'));
		}
		// remove ? at the begining of the query
		if (query.indexOf('?') !== -1) {
			query = query.substr(query.indexOf('?') + 1, query.length);
		}
		// empty parameters
		if (query === '') return {};
		// execute a createElement on every key and value
		while (e = re.exec(query)) {
			var key = decode(e[1]);
			var value = decode(e[2]);
			createElement(params, key, value);
		}
	}
	return params;
};
/**
 * Media queries
 */
scutum.helpers.mq = {
	'smallMax': function () {
		return window.matchMedia('(max-width: 959px)').matches
	},
	'mediumMin': function () {
		return window.matchMedia('(min-width: 960px)').matches
	},
	'mediumMax': function () {
		return window.matchMedia('(max-width: 1199px)').matches
	},
	'largeMin': function () {
		return window.matchMedia('(min-width: 1200px)').matches
	},
	'largeMax': function () {
		return window.matchMedia('(max-width: 1599px)').matches
	},
	'xlargeMin': function () {
		return window.matchMedia('(min-width: 1600px)').matches
	}
};
/**
 * Serve HiRes images
 */
scutum.helpers.hiResImages = function () {
	if (scutum.config.hiResImages && scutum.helpers.isHiRes) {
		loadjs('assets/js/vendor/retina.min.js', {
			success: function () {
				$('img').attr('data-rjs', 2);
				retinajs();
			}
		})
	} else {
		return false;
	}
};
scutum.helpers.hiResImagesProcess = function () {
	if (scutum.config.hiResImages && scutum.helpers.isHiRes) {
		$('img').attr('data-rjs', 2);
		retinajs();
	} else {
		return false;
	}
};
// scutum.helpers.disableDoubleClick = function () {
// 	var doubleTouchStartTimestamp = 0;
// 	document.addEventListener("touchstart", function (event) {
// 		var now = +(new Date());
// 		if (doubleTouchStartTimestamp + 500 > now) {
// 			event.preventDefault();
// 		}
// 		doubleTouchStartTimestamp = now;
// 	});
// };
scutum.helpers.fab = []
scutum.helpers.fab.speedDial = function () {
	var animDuration = 100;
	var $fab = $('[data-sc-fab]');
	function animationDelay (fabs, reverse) {
		var length = fabs.length - 1;
		fabs.each(function (i) {
			var delay = reverse ? (length - i) * (animDuration/2.2) : i * (animDuration/2.2);
			$(this).css({
				'animation-delay': delay + 'ms'
			})
		})
	}
	function animIn (speedDial) {
		speedDial.removeClass('animOut');
		speedDial.addClass('sc-fab-speed-dial-active animIn')
	}
	function animOut (speedDial, fabLength) {
		speedDial.removeClass('animIn');
		speedDial.addClass('animOut');
		setTimeout(function () {
			speedDial.removeClass('sc-fab-speed-dial-active animOut')
		}, animDuration * fabLength)
	}
	$fab.each(function () {
		var speedDialLeave;
		var $this = $(this);
		var $speedDial = $this.closest('.sc-fab-speed-dial');
		var $fabs = $speedDial.children('.sc-fab-wrapper-inner').children();
		var _data = $this.attr('data-sc-fab');
		if (_data !== '' && typeof _data !== 'undefined') {
			var data = jQuery.parseJSON(_data);
			if(data.horizontal) {
				$this.addClass('sc-fab-speed-dial-horizontal')
			}
			if(data.hover) {
				$this.addClass('sc-fab-speed-dial-hover');
				$this
					.on('mouseenter', function () {
						animationDelay($fabs);
						clearTimeout(speedDialLeave);
						$speedDial.removeClass('animOut');
						$speedDial.addClass('sc-fab-speed-dial-active animIn')
					})
					.on('mouseleave', function () {
						animationDelay($fabs, true);
						$speedDial.removeClass('animIn');
						$speedDial.addClass('animOut');
						speedDialLeave = setTimeout(function () {
							$speedDial.removeClass('sc-fab-speed-dial-active animOut')
						}, animDuration * $fabs.length)
					})
			} else {
				$this.on('click', function () {
					animationDelay($fabs, $speedDial.hasClass('sc-fab-speed-dial-active'));
					if($speedDial.hasClass('sc-fab-speed-dial-active')) {
						animOut($speedDial, $fabs.length)
					} else {
						animIn($speedDial)
					}
				})
			}
		} else {
			$this.on('click', function () {
				animationDelay($fabs, $speedDial.hasClass('sc-fab-speed-dial-active'));
				if($speedDial.hasClass('sc-fab-speed-dial-active')) {
					animOut($speedDial, $fabs.length)
				} else {
					animIn($speedDial)
				}
			})
		}
	})
};
scutum.helpers.fab.singleSheet = function () {
	var $fabSheet = $('.sc-fab-sheet');
	$fabSheet.each(function() {
		var $this = $(this);
		var $trigger = $this.children('.sc-fab-sheet-trigger');
		var isActive = $this.hasClass('sc-fab-active')
		$trigger.on('click', function () {
			var sheetItems = $this.children('.sc-fab-sheet-actions').children('a').length;
			$this.addClass('sc-fab-animated');
			setTimeout(function() {
				$this
						.width('240px')
						.height(sheetItems*40 + 8);
			},140);
			setTimeout(function() {
				$this.addClass('sc-fab-active');
			},280);
		})
		scutum.$win.on('click scroll', function (e) {
			if (!$(e.target).closest($fabSheet).length) {
				$this
						.css({
							'height':'',
							'width':''
						})
						.removeClass('sc-fab-active');

				setTimeout(function() {
					$this.removeClass('sc-fab-animated');
				},140);
			}
		})
	})
}

// ----------------------------------------
// HANDLEBARS
// ----------------------------------------
scutum.handlebars = {};
scutum.handlebars.getPartial = function (name, data) {
	return new Promise(function (resolve, reject) {
		var request = new XMLHttpRequest();
		request.onreadystatechange = function () {
			if (request.readyState === XMLHttpRequest.DONE) {
				if (request.status === 200) {
					resolve(request.responseText);
				} else {
					reject(Error(request.statusText));
				}
			}
		};
		request.onerror = function () {
			reject(Error("Network Error"));
		};
		request.open('GET', 'handlebars/templates/' + name + '.hbs', true);
		request.responseType = 'text';
		request.send(data);
	}).catch(function (error) {console.log('There has been a error: ' + error.message);throw error; });;
};

// ----------------------------------------
// PARTIALS
// ----------------------------------------

// ----- TOOLBAR
scutum.toolbar = {};
scutum.toolbar.init = function () {
	scutum.toolbar.sticky();
};
scutum.toolbar.sticky = function () {
	var offset = (scutum.$topBar.length || scutum.$header) ? (scutum.$topBar.height() + scutum.$header.height() + 25) : 0;
	UIkit.sticky(scutum.$toolbar, {
		offset: offset
	});
};

// ----- MAIN HEADER
scutum.headerMain = {};
scutum.headerMain.init = function () {
	// header full screen toggle
	scutum.headerMain.fullscreen();
	// sticky header
	scutum.headerMain.sticky();
	// clear alerts in header
	scutum.headerMain.clearAlerts();
	// top menu
	scutum.headerMain.topMenu();
};
scutum.headerMain.fullscreen = function () {
	var $el = $('#sc-js-fullscreen-toggle');
	if ($el.length) {
		scutum.require(['screenfull'], function () {
			$el.on('click', function (e) {
				e.preventDefault();
				if (screenfull.isEnabled) {
					screenfull.request();
					$el.find('.sc-js-el-show').show();
					$el.find('.sc-js-el-hide').hide();
					if (screenfull.isFullscreen) {
						screenfull.exit();
						$el.find('.sc-js-el-hide').show();
						$el.find('.sc-js-el-show').hide();
					}
				}
				scutum.$win.resize();
			});
		});
	}
};
scutum.headerMain.clearAlerts = function () {
	var $clearBtn = $('.sc-js-clear-alerts');
	$clearBtn.on('click', function (e) {
		e.preventDefault();
		var $list = $('#sc-header-alerts');
		$list.children('li').not('.sc-js-empty-message')
			.velocity("transition.slideRightOut", {
				stagger: 70,
				duration: 140,
				complete: function () {
					$clearBtn.parent().hide();
					$clearBtn.closest('li').find('.sc-indicator').hide();
					$clearBtn.closest('li').find('.sc-js-empty-message').show();
				}
			})
	});
};
scutum.headerMain.sticky = function () {
	var options = scutum.helpers.mq.smallMax() ? {
		// showOnUp: true,
		// animation: "uk-animation-slide-top"
	} : {};
	setTimeout(function () {
		UIkit.sticky(scutum.$header, options);
	}, 500);
};
scutum.headerMain.topMenu = function () {
	var $topMenu = $('.sc-top-menu');
	if($topMenu.length) {
		$topMenu.find('li').each(function () {
			var $_li = $(this);
			var $_ul= $(this).children('ul');
			var enterInterval;
			var leaveInterval;
			if($_ul.length) {
				$_li
					.addClass('sc-has-submenu')
					.on('mouseenter', function () {
						clearInterval(enterInterval);
						$_ul.show();
						enterInterval = setTimeout(function () {
							$_li.addClass('sc-js-active');
						}, 50);
					})
					.on('mouseleave', function () {
						clearInterval(leaveInterval);
						$_li.removeClass('sc-js-active');
						leaveInterval = setTimeout(function () {
							$_ul.hide();
						}, 220);
					})
			}
		});
	}
};

// ----- MAIN SIDEBAR
scutum.sidebarMain = {};
scutum.sidebarMain.init = function () {
	// sidebar navigation
	scutum.sidebarMain.navigation();
	// sidebar toggle
	scutum.sidebarMain.toggle();
	// sidebar touch gestures
	scutum.sidebarMain.touchGestures();
	// sidebar events
	scutum.sidebarMain.events();
	// mini sidebar
	scutum.sidebarMain.mini();
};
scutum.sidebarMain.navigation = function () {
	// check for submenu
	scutum.$sidebarMain.find('.sc-sidebar-menu').find('li').not('.sc-sidebar-submenu-expanded').each(function () {
		if ($(this).children('ul').length) {
			$(this).addClass('sc-js-submenu-trigger sc-has-submenu');
			$(this).find('ul').hide();
		}
	});
	// toggle sections
	$('.sc-js-submenu-trigger > a').on('click ', function (e) {
		e.preventDefault();
		var $this = $(this);
		var slideToogle = $this.next('ul').is(':visible') ? 'slideUp' : 'slideDown';
		// accordion mode
		var accordionMode = scutum.$sidebarMain.hasClass('sc-js-accordion-mode');
		$this.next('ul')
			.velocity(slideToogle, {
				duration: 280,
				easing: scutum.easingSwiftOut,
				begin: function () {
					if (slideToogle === 'slideUp') {
						$(this).closest('.sc-js-submenu-trigger').removeClass('sc-section-active')
					} else {
						if (accordionMode) {
							$this.closest('li').siblings('.sc-js-submenu-trigger').each(function () {
								$(this).children('ul').velocity('slideUp', {
									duration: 300,
									easing: scutum.easingSwiftOut,
									begin: function () {
										$(this).closest('.sc-js-submenu-trigger').removeClass('sc-section-active')
									}
								})
							})
						}
						$(this).closest('.sc-js-submenu-trigger').addClass('sc-section-active')
					}
				},
				complete: function () {
					if (slideToogle !== 'slideUp') {
						if (scutum.$sidebarMain.hasClass('sc-js-scroll-to-active')) {
							$this.closest('.sc-section-active').velocity("scroll", {
								duration: 400,
								easing: scutum.easingSwiftOut,
								container: scutum.$sidebarMain.find(".sc-sidebar-main-scrollable"),
								offset: 1
							});
						}
					}
					if (scutum.helpers.mq.mediumMax()) {
						UIkit.offcanvas(scutum.$sidebarMain).show();
					}
					// update custom scrollbar
					if (scutum.config.customScrollbar) {
						scutum.$sidebarMain.find('[data-sc-scrollbar]').data('ps').update();
					}
				}
			});
	});
	// open section/add classes if children has class .page-active
	scutum.$sidebarMain.find('.sc-page-active').each(function () {
		var $this = $(this);
		// all parents
		$this.parents('.sc-js-submenu-trigger').addClass('sc-section-active');
		$this.parents('ul').css({
			'display': 'block'
		});
	});
};
scutum.sidebarMain.toggle = function () {
	// var sidebarToggleTimeout;
	if (scutum.helpers.mq.smallMax() || scutum.$html.hasClass('sc-sidebar-offcanvas')) {
		UIkit.offcanvas(scutum.$sidebarMain, {
			overlay: true
		});
		scutum.$sidebarMain
			.on('show', function () {
				scutum.$html.addClass('sc-sidebar-main-visible');
			})
			.on('hide', function () {
				scutum.$html.removeClass('sc-sidebar-main-visible');
			});
	}
	// trigger custom event/window resize on sidebar toggle
	if (scutum.helpers.mq.mediumMin()) {
		scutum.$pageWrapper.off('transitionend.scSidebar');
		scutum.$pageWrapper.on('transitionend.scSidebar', function (e) {
			if ($(e.target).is('#sc-page-wrapper')) {
				scutum.$doc.trigger('sc-sidebar:toggle');
				scutum.$win.trigger('resize');
			}
		});
	}
	$('#sc-sidebar-main-toggle').on('click', function (e) {
		e.preventDefault();
		if (scutum.helpers.mq.mediumMin() && !scutum.$html.hasClass('sc-sidebar-offcanvas')) {
			// clearTimeout(sidebarToggleTimeout);
			if (scutum.$html.hasClass('sc-sidebar-main-slide')) {
				scutum.$html.removeClass('sc-sidebar-main-slide')
			} else {
				scutum.$html.addClass('sc-sidebar-main-slide')
			}
			// sidebarToggleTimeout = setTimeout(function () {
			// 	// trigger custom event
			// 	scutum.$doc.trigger('sc-sidebar:toggle');
			// 	scutum.$win.trigger('resize');
			// }, 150);
		} else {
			if (scutum.$html.hasClass('sc-sidebar-main-visible')) {
				UIkit.offcanvas(scutum.$sidebarMain).hide();
			} else {
				UIkit.offcanvas(scutum.$sidebarMain).show();
			}
		}
	})
};
scutum.sidebarMain.touchGestures = function () {
	if (scutum.$sidebarMain[0] && (scutum.helpers.mq.mediumMax() || scutum.$html.hasClass('sc-sidebar-offcanvas'))) {
		scutum.require(['hammerJS'], function () {
			if (scutum.$sidebarMain[0]) {
				var sidebarHammer = new Hammer(scutum.$sidebarMain[0]);
				sidebarHammer.get('pan').set({ direction: Hammer.DIRECTION_ALL, threshold: 400  });
				sidebarHammer.on(scutum.helpers.isRTL() ? "panright" : "panleft", function(ev) {
					if (scutum.$html.hasClass('sc-sidebar-main-visible')) {
						UIkit.offcanvas(scutum.$sidebarMain).hide();
					}
				});
			}
			// swipe right to open sidebar
			// var bodyHammer = new Hammer(scutum.$body[0]);
			// bodyHammer.on("panright", function(ev) {
			// 	if (!scutum.$html.hasClass('sc-sidebar-main-visible')) {
			// 		UIkit.offcanvas(scutum.$sidebarMain).show();
			// 	}
			// });
		})
	}
}
scutum.sidebarMain.events = function () {
	var offCanvasActivated = false;
	scutum.$win.on('resize', function () {
		if (scutum.helpers.mq.smallMax()) {
			scutum.$html.removeClass('sc-sidebar-main-slide');
			if(!offCanvasActivated) {
				UIkit.offcanvas(scutum.$sidebarMain, {
					overlay: true
				});
				scutum.$sidebarMain
					.on('show', function () {
						scutum.$html.addClass('sc-sidebar-main-visible');
					})
					.on('hide', function () {
						scutum.$html.removeClass('sc-sidebar-main-visible');
					});
				offCanvasActivated = true;
			}
		}
	})
};
scutum.sidebarMain.mini = function () {
	var isMini = scutum.$html.hasClass('sc-sidebar-mini');
	if (scutum.helpers.mq.smallMax() && isMini) {
		scutum.$html.removeClass('sc-sidebar-mini')
	}
	scutum.$win.on('resize', function () {
		if (scutum.helpers.mq.smallMax()) {
			scutum.$html.removeClass('sc-sidebar-mini')
		} else if(isMini) {
			scutum.$html.removeClass('sc-sidebar-main-visible');
			scutum.$html.addClass('sc-sidebar-mini');
		}
	})
};

// ----- OFFCANVAS
scutum.offcanvas = {};
scutum.offcanvas.init = function () {
	if (scutum.$offcanvas.length && scutum.helpers.mq.mediumMax()) {
		var $offcanvasToggle = $('.sc-js-offcanvas-toggle');
		setTimeout(function () {
			$offcanvasToggle.show();
		},500);
		$offcanvasToggle.on('click', function (e) {
			e.preventDefault();
			if (scutum.$html.hasClass('sc-offcanvas-visible')) {
				UIkit.offcanvas(scutum.$offcanvas).hide();
			} else {
				UIkit.offcanvas(scutum.$offcanvas).show();
			}
		});
		scutum.$offcanvas
			.on('shown', function () {
				scutum.$html.addClass('sc-offcanvas-visible');
			})
			.on('hidden', function () {
				scutum.$html.removeClass('sc-offcanvas-visible');
			});
	}
};

// ---- FANCY FOOTER
scutum.fancyFooter = {}
scutum.fancyFooter.init = function () {
	var $footer = $('#sc-fancy-footer');
	if($footer.length) {
		var $list = $footer.find('.sc-ff-list');
		var $item = $list.children("li");
		// set first item active
		var activeEl = $item.closest('.active')
		if (activeEl.length) {
			setTimeout(function () {
				scutum.fancyFooter.makeItemActive($(activeEl[0]))
			}, 200)
		}
		scutum.fancyFooter.events($list)
	}
}
scutum.fancyFooter.events = function (list) {
	var $link = list.find('a')
	$link.on('click', function () {
		var $this = $(this)
		var $li = $this.parent('li')
		if($li.hasClass('active')) {
			return
		}
		scutum.fancyFooter.makeItemActive($li)
	})
	// switcher
	UIkit.util.on(document, 'show', '.sc-ff-switcher', function(el) {
		var el = list.children("li").eq($(el.target).index())
		if(!el.hasClass('active')) {
			scutum.fancyFooter.makeItemActive(el)
		}
	});
	scutum.$win.on('resize', function () {
		setTimeout(function () {
			scutum.fancyFooter.alignWave(list.children("li.uk-active"))
		}, 400)
	})
	window.matchMedia('(orientation: portrait)').addEventListener( "change", (e) => {
		if (e.matches) {
			setTimeout(function () {
				scutum.fancyFooter.alignWave(list.children("li.uk-active"))
			}, 400)
		}
	})
	window.matchMedia('(orientation: landscape)').addEventListener( "change", (e) => {
		if (e.matches) {
			setTimeout(function () {
				scutum.fancyFooter.alignWave(list.children("li.uk-active"))
			}, 400)
		}
	})
}
scutum.fancyFooter.makeItemActive = function (item) {
	// add active class to the new item
	$(".sc-ff-list li").removeClass("active");
	item.delay(100).queue(function() {
		item.addClass('active').dequeue();
	});
	scutum.fancyFooter.alignWave(item)
}
scutum.fancyFooter.alignWave = function (item) {
	// move the wave
	var itemWidth = $(item).width()
	var itemPosLeft = $(item).position().left
	$(".sc-ff-wave").css('left', itemPosLeft.toFixed(2) - itemWidth/2 - 6);
}

// ---- FANCY TOOLBAR
scutum.fancyToolbar = {}
scutum.fancyToolbar.init = function () {
	var $toolbar = $('#sc-fancy-toolbar');
	if($toolbar.length) {
		var $list = $toolbar.find('.sc-ft-list');
		var $item = $list.children("li");
		// set first item active
		var activeEl = $item.closest('.active')
		if (activeEl.length) {
			setTimeout(function () {
				scutum.fancyToolbar.makeItemActive($(activeEl[0]))
			}, 200)
		}
		scutum.fancyToolbar.events($list)
	}
}
scutum.fancyToolbar.events = function (list) {
	var $link = list.find('a')
	$link.on('click', function () {
		var $this = $(this)
		var $li = $this.parent('li')
		if($li.hasClass('active')) {
			return
		}
		scutum.fancyToolbar.makeItemActive($li)
	})
	// switcher
	UIkit.util.on(document, 'show', '.sc-ff-switcher', function(el) {
		var el = list.children("li").eq($(el.target).index())
		if(!el.hasClass('active')) {
			scutum.fancyToolbar.makeItemActive(el)
		}
	});
	scutum.$win.on('resize', function () {
		setTimeout(function () {
			scutum.fancyToolbar.alignWave(list.children("li.uk-active"))
		}, 400)
	})
	window.matchMedia('(orientation: portrait)').addEventListener( "change", (e) => {
		if (e.matches) {
			setTimeout(function () {
				scutum.fancyToolbar.alignWave(list.children("li.uk-active"))
			}, 400)
		}
	})
	window.matchMedia('(orientation: landscape)').addEventListener( "change", (e) => {
		if (e.matches) {
			setTimeout(function () {
				scutum.fancyToolbar.alignWave(list.children("li.uk-active"))
			}, 400)
		}
	})
}
scutum.fancyToolbar.makeItemActive = function (item) {
	// add active class to the new item
	$(".sc-ft-list li").removeClass("active");
	item.delay(100).queue(function() {
		item.addClass('active').dequeue();
	});
	scutum.fancyToolbar.alignWave(item)
}
scutum.fancyToolbar.alignWave = function (item) {
	// move the wave
	var itemWidth = $(item).width()
	var itemPosLeft = $(item).position().left
	$(".sc-ft-wave").css('left', itemPosLeft.toFixed(2) - itemWidth/2 - 4);
}



// ----------------------------------------
// CARDS
// ----------------------------------------

scutum.cards = {};
scutum.cards.init = function () {
	scutum.cards.fullscreen();
	scutum.cards.toggle();
	scutum.cards.close();
};
scutum.cards.hideContent = function (el, preloader, callback) {
	var $this = $(el);
	var $card = $this.closest('.uk-card');

	if (!$card.hasClass('sc-card-hidden')) {
		$card.addClass('sc-card-hidden');
		if (preloader) {
			$card.append('<div data-uk-spinner="ratio: 2"></div>');
		}
		if (typeof callback !== 'undefined' && typeof callback === 'function') {
			setTimeout(function () {
				callback();
			}, 320)
		}
	}
};
scutum.cards.showContent = function (el, preloader, callback) {
	var $this = $(el);
	var $card = $this.closest('.uk-card');

	if ($card.hasClass('sc-card-hidden')) {
		$card.removeClass('sc-card-hidden');
		if (preloader) {
			$card.find('.uk-spinner').remove();
		}
		if (typeof callback !== 'undefined' && typeof callback === 'function') {
			callback();
		}
	}
};
scutum.cards.fullscreen = function () {
	var $el = $('.sc-js-card-fullscreen');

	$el.each(function () {
		$(this).on('click', function (e) {
			e.preventDefault();
			var $this = $(this);
			var $card = $this.closest('.uk-card');
			var card = {};

			card.width = $card.width();
			card.height = $card.height();
			card.offset = $card.offset();
			card.position = $card.position();

			if (!$card.hasClass('sc-card-fs-active')) {
				var scrollTop = scutum.$win.scrollTop();

				scutum.helpers.scrollbar.disable();

				$card
					.addClass('sc-card-fs-active sc-card-fs-animate')
					.css({
						'width': card.width,
						'height': card.height,
						'left': card.offset.left,
						'top': card.offset.top - scrollTop
					});

				$('<div class="sc-card-fs-placeholder" style="height:' + $card.height() + 'px">').insertBefore($card);

				$card.velocity({
					top: 0,
					left: 0,
					width: '100%',
					height: '100%'
				}, {
					delay: 280,
					duration: 560,
					easing: scutum.easingSwiftOut,
					begin: function () {
						if($this.hasClass('mdi-fullscreen') || $this.hasClass('mdi-fullscreen-exit')) {
							$this.toggleClass('mdi-fullscreen mdi-fullscreen-exit');
						}
					},
					complete: function () {
						$card.removeClass('sc-card-fs-animate');
					}
				});
			} else {
				var $placeholder = $('.sc-card-fs-placeholder');
				var placeholder = {};

				placeholder.width = $placeholder.width();
				placeholder.height = $placeholder.height();
				placeholder.offset = $placeholder.offset();

				$card.addClass('sc-card-fs-animate');

				$card.velocity({
					top: placeholder.offset.top - scutum.$win.scrollTop(),
					left: placeholder.offset.left,
					height: placeholder.height,
					width: placeholder.width
				}, {
					delay: 280,
					duration: 560,
					easing: scutum.easingSwiftOut,
					complete: function () {
						$card.removeClass('sc-card-fs-active sc-card-fs-animate');
						if($this.hasClass('mdi-fullscreen') || $this.hasClass('mdi-fullscreen-exit')) {
							$this.toggleClass('mdi-fullscreen mdi-fullscreen-exit');
						}
						$placeholder.remove();
						scutum.helpers.scrollbar.enable();
						// cleanup & trigger resize components
						$.Velocity.hook($card, "top", '');
						$.Velocity.hook($card, "left", '');
						$.Velocity.hook($card, "width", '');
						$.Velocity.hook($card, "height", '');
						scutum.$win.resize();
					}
				});
			}
		});
	})
};
scutum.cards.toggle = function () {
	var $el = $('.sc-js-card-toggle');
	$el.on('click', function (e) {
		e.preventDefault();
		var $this = $(this);
		var $card = $this.closest('.uk-card');
		var $cardContent = $card.find('.sc-card-content');

		if (!$card.hasClass('sc-card-minimized')) {
			$cardContent
				.height($cardContent.height())
				.css({ 'transition': 'none' })
				.velocity('slideUp', {
					duration: 280,
					easing: scutum.easingSwiftOut,
					begin: function () {
						$card.addClass('sc-card-minimized');
						$this.toggleClass('mdi-window-minimize mdi-window-maximize');
					},
					complete: function () {
						$cardContent.css({
							'transition': ''
						});
					}
				})
		} else {
			$cardContent.velocity('slideDown', {
				duration: 280,
				easing: scutum.easingSwiftOut,
				begin: function () {
					$cardContent.css({ 'transition': 'none' });
					$card.removeClass('sc-card-minimized');
					$this.toggleClass('mdi-window-minimize mdi-window-maximize');
				},
				complete: function () {
					$cardContent.css({
						'height': '',
						'transition': ''
					});
				}
			})
		}
	});
	// minimized on page load
	$('.sc-card-minimized').each(function() {
		var $card = $(this);
		var $cardToggle = $card.find('.sc-js-card-toggle');
		var $cardContent = $card.find('.sc-card-content');

		$cardContent.hide()
		$cardToggle.toggleClass('mdi-window-minimize mdi-window-maximize');
	})
};
scutum.cards.close = function () {
	scutum.$body.on('click', '.sc-js-card-close', function (e) {
		e.preventDefault();
		var $this = $(this);
		var $card = $this.closest('.uk-card');
		var $toRemove = $this.attr('data-card-close-remove') !== '' ? $this.closest($this.attr('data-card-close-remove')) : $card;

		$card.addClass('uk-animation-scale-up uk-animation-reverse');

		$card.one('webkitAnimationEnd animationend', function () {
			scutum.helpers.element.remove($toRemove, 100);
		});
	});
};

// ----------------------------------------
// PLUGINS
// ----------------------------------------

/**
 * Colorpicker
 * @param {string} input
 * @param {array} palette
 * @param {boolean} inline
 * @param {string} size
 * @param {function} callback
 * @type {{init: scutum.plugins.colorpicker.init}}
 */
scutum.plugins.colorpicker = {
	'init': function (input, palette, inline, callback) {
		var $input = input ? $(input) : $('[data-sc-colorpicker]');
		if ($input.length) {
			$input.each(function () {
				var config = {
					inline: inline || false,
					palette: ['#e53935', '#d81b60', '#8e24aa', '#5e35b1', '#3949ab', '#1e88e5', '#039be5', '#0097a7', '#00897b', '#43a047', '#689f38', '#ef6c00', '#f4511e', '#6d4c41', '#757575', '#546e7a']
				};
				var $this = $(this);
				var cpID = scutum.helpers.uniqueID();

				var cpPalette = palette || config.palette;
				var data = $this.attr('data-sc-colorpicker');
				if (data !== '' && typeof data !== 'undefined') {
					if (data.startsWith('{')) {
						var userConfig = jQuery.parseJSON(data);
						if (typeof userConfig.palette !== 'undefined') {
							cpPalette = userConfig.palette.toString().split(',');
						}
						if (typeof userConfig.inline !== 'undefined') {
							config.inline = true;
						}
					}
				}
				var cpWrapper = $('<div class="sc-colorpicker" id="' + cpID + '"/>');
				var cpDropdown = $('<div class="sc-colorpicker-dropdown"/>');
				var cpInline = $('<div class="sc-colorpicker-colors"/>');
				var cpPicker = $('<div class="sc-colorpicker-picker"/>');

				for (var $i = 0; $i < cpPalette.length; $i++) {
					var $span = $('<span data-color=' + cpPalette[$i] + ' style="background-color:' + cpPalette[$i] + '"></span>');
					if ($this.val() !== '' && $this.val() === cpPalette[$i]) {
						$span.addClass('sc-color-active')
					}
					if (config.inline) {
						cpInline.append($span);
					} else {
						cpDropdown.append($span);
					}
				}

				$this.wrap(cpWrapper);
				if (config.inline) {
					$this.closest('.sc-colorpicker').addClass('sc-colorpicker-inline').prepend(cpInline).prepend(cpPicker);
				} else {
					if (cpPalette.length > 8) {
						cpDropdown.css({
							width: ((cpPalette.length * 28) / 2) + 'px'
						});
					} else {
						cpDropdown.css({
							width: (cpPalette.length * 28) + 'px'
						})
					}
					$this.closest('.sc-colorpicker').prepend(cpDropdown).prepend(cpPicker);
				}
				if ($this.val() !== '') {
					$(this).closest('.sc-colorpicker').find('.sc-colorpicker-picker').css({
						'background-color': $this.val()
					});
				}

				// adjust dropdown position
				var $colorPicker = $this.closest('.sc-colorpicker')
				var $colorPickerDropdown = $colorPicker.find('.sc-colorpicker-dropdown');
				var dpWidth = $colorPickerDropdown.actual('width');
				if ($colorPickerDropdown) {
					if($colorPicker.offset().left + dpWidth > scutum.$win.width()) {
						$this.closest('.sc-colorpicker').addClass('sc-colorpicker-right')
					}
				}

				scutum.$body
					.on('click', '#' + cpID + ' span', function () {
						var $colorPicker = $(this).closest('.sc-colorpicker');
						$(this)
							.addClass('sc-color-active')
							.siblings().removeClass('sc-color-active');
						$colorPicker.closest('.sc-colorpicker').find('input').val($(this).attr('data-color'));
						$colorPicker.closest('.sc-colorpicker').find('.sc-colorpicker-picker').css({
							'background-color': $(this).attr('data-color')
						});
						$colorPicker.closest('.sc-colorpicker').removeClass('sc-colorpicker-active');
						if (typeof callback === 'function') {
							callback.call(this);
						}
					});
				scutum.$body.on('click', '#' + cpID + ' .sc-colorpicker-picker', function () {
					var $colorPicker = $(this).closest('.sc-colorpicker');
					var activeColorpicker = scutum.$body.find('.sc-colorpicker-active').not($(this).closest('.sc-colorpicker'));
					if (activeColorpicker.length) {
						activeColorpicker.removeClass('sc-colorpicker-active');
					}
					$colorPicker.toggleClass('sc-colorpicker-active');
				});
				// update active color when value changes
				$this.on('change', function () {
					var $cp = $this.closest('.sc-colorpicker');
					var color = $this.val();
					$cp.find('.sc-colorpicker-picker').css({
						'background-color': color
					});
					$cp.find('.sc-colorpicker-dropdown').find('[data-color]').removeClass('sc-color-active')
					var $dropdownItem = $cp.find('.sc-colorpicker-dropdown').find('[data-color="'+ color +'"]')
					if($dropdownItem.length) {
						$dropdownItem.addClass('sc-color-active')
					}
				})
			});
			scutum.$body.on('click', function (e) {
				if (!$(event.target).closest('.sc-colorpicker-dropdown').length && !$(event.target).closest('.sc-colorpicker-picker').length) {
					var activeColorpicker = scutum.$body.find('.sc-colorpicker-active');
					if (activeColorpicker.length) {
						activeColorpicker.removeClass('sc-colorpicker-active')
					}
				}
			});
		}
	}
};

// ----------------------------------------
// FORMS
// ----------------------------------------

// common form controls
scutum.forms.common = {};
scutum.forms.common.init = function () {
	// md inputs
	scutum.forms.common.inputs();
	// autosize
	scutum.forms.common.inputs.autosize();
	// icheck
	scutum.forms.common.icheck();
	// select 2
	scutum.forms.common.select2();
	// ratings
	scutum.forms.common.rating();
	// switchery switches
	scutum.forms.common.switches();
	// datepicker
	scutum.forms.common.datePicker();
	// input masks
	scutum.forms.common.inputMask();
	// clear input
	scutum.forms.common.clearInput();
};
scutum.forms.common.inputs = function (parent) {
	var $el = (typeof parent === 'undefined') ? $('[data-sc-input]') : $(parent).find('[data-sc-input]');
	$el.each(function () {
		if (!$(this).closest('.sc-input-wrapper').length) {
			var $this = $(this);
			if ($this.attr('data-sc-input') === 'outline') {
				if ($this.is('input')) {
					$this.addClass('sc-input-outline');
				}
				if ($this.is('textarea')) {
					$this.addClass('sc-textarea-outline');
				}
			}
			var $label = $this.siblings('label');
			var $formIcon = $this.siblings('.uk-form-icon');
			var $helpInline = $this.next('.uk-form-help-inline');

			$this.wrap('<div class="sc-input-wrapper"></div>');

			if ($label.length) {
				$this.closest('.sc-input-wrapper').prepend($label)
			}
			if ($formIcon.length) {
				$this.closest('.sc-input-wrapper').prepend($formIcon);
				$formIcon.each(function () {
					var $that = $(this);
					if ($that.hasClass('sc-js-input-clear')) {
						$that.on('click', function () {
							$this.val('').trigger('keyup');
						});
					}
				})
			}
			if ($this.hasClass('sc-input-outline') || $this.hasClass('sc-textarea-outline')) {
				$this.closest('.sc-input-wrapper').addClass('sc-input-wrapper-outline');
			} else {
				$this.closest('.sc-input-wrapper').append('<span class="sc-input-bar"></span>');
			}
			if (scutum.helpers.mq.mediumMin()) {
				if ($helpInline.length) {
					$helpInline.insertAfter($this.next('.sc-input-bar'));
				}
			}

			scutum.forms.common.inputs.update($(this));
		}
		scutum.$body
			.on('focus', '[data-sc-input]', function () {
				$(this).closest('.sc-input-wrapper').addClass('sc-input-focus');
			})
			.on('blur', '[data-sc-input]', function () {
				$(this).closest('.sc-input-wrapper').removeClass('sc-input-focus');
				if (!$(this).hasClass('sc-label-fixed')) {
					if ($(this).val() !== '') {
						$(this).closest('.sc-input-wrapper').addClass('sc-input-filled')
					} else {
						$(this).closest('.sc-input-wrapper').removeClass('sc-input-filled')
					}
				}
			})
			.on('keyup change input', '[data-sc-input]', function () {
				if (!$(this).hasClass('sc-label-fixed')) {
					if ($(this).val() !== '') {
						$(this).closest('.sc-input-wrapper').addClass('sc-input-filled')
					} else {
						$(this).closest('.sc-input-wrapper').removeClass('sc-input-filled')
					}
				}
			})
			.on('change', '[data-sc-input]', function () {
				scutum.forms.common.inputs.update($(this));
			})
			.on('validationClassChanged', '[data-sc-input]', function () {
				if ($(this).hasClass('uk-form-danger')) {
					$(this).closest('.sc-input-wrapper').addClass('sc-input-wrapper-danger')
				}
			});
	})
};
scutum.forms.common.inputs.update = function (el) {
	$(el).each(function () {
		var $el = $(this);
		// clear wrapper classes
		$el.closest('.uk-input-group').removeClass('uk-input-group-danger uk-input-group-success');
		$el.closest('.sc-input-wrapper').removeClass('sc-input-wrapper-danger sc-input-wrapper-success sc-input-wrapper-disabled');

		if ($el.hasClass('uk-form-danger')) {
			if ($el.closest('.uk-input-group').length) {
				$el.closest('.uk-input-group').addClass('sc-input-group-danger')
			}
			$el.closest('.sc-input-wrapper').addClass('sc-input-wrapper-danger')
		}
		if ($el.hasClass('uk-form-success')) {
			if ($el.closest('.uk-input-group').length) {
				$el.closest('.uk-input-group').addClass('sc-input-group-success')
			}
			$el.closest('.sc-input-wrapper').addClass('sc-input-wrapper-success')
		}
		if ($el.prop('disabled')) {
			$el.closest('.sc-input-wrapper').addClass('md-input-wrapper-disabled')
		}
		if ($el.val() !== '') {
			$el.closest('.sc-input-wrapper').addClass('sc-input-filled')
		} else {
			$el.closest('.sc-input-wrapper').removeClass('sc-input-filled')
		}
		if ($el.hasClass('label-fixed')) {
			$el.closest('.sc-input-wrapper').addClass('sc-input-filled')
		}
	})
};
scutum.forms.common.inputs.disableSubmit = function (input) {
	$(input).each(function () {
		$(this).on('keyup keypress', function (e) {
			var keyCode = e.keyCode || e.which;
			if (keyCode === 13) {
				e.preventDefault();
				return false;
			}
		});
	})
};
scutum.forms.common.inputs.autosize = function () {
	var $textarea = $('textarea.sc-js-autosize');
	if ($textarea.length) {
		scutum.require(['autosize'], function () {
			$textarea.on('autosize.change', function () {
				autosize.update($textarea)
			});
			autosize($textarea);
		});
	}
};
scutum.forms.common.icheck = function (input) {
	var iInput = (input === undefined) ? $("[data-sc-icheck]") : $(input);
	if (iInput.length) {
		scutum.require(['icheck'], function () {
			iInput.each(function () {
				if (!$(this).next('.iCheck-helper').length) {
					$(this)
						.iCheck({
							checkboxClass: 'sc-icheckbox',
							radioClass: 'sc-iradio',
							increaseArea: '20%'
						})
						// validate inputs on change (parsley)
						.on('ifChanged', function (event) {
							if (typeof $(this).data('parsleyMultiple') !== 'undefined') {
								$(this).parsley().validate();
							}
						});
					if (typeof $(this).attr('data-color') !== 'undefined') {
						$(this).closest('div').addClass('sc-icheck-custom').attr('style', '--color:' + $(this).attr('data-color'));
					}
				}
			});
		});
	}
};
scutum.forms.common.select2 = function (parent) {
	var $el = parent ? $(parent).find('select').not('.sc-regular-select') : $('[data-sc-select2]');
	if ($el.length) {
		scutum.require(['select2'], function () {
			// default options
			$.fn.select2.defaults.set('width', '100%');
			// convert each $el to select2 control
			$el.each(function () {
				var $this = $(this);
				if (!$this.data('select2')) {
					var data = $this.attr('data-sc-select2');
					if (data !== '' && typeof data !== 'undefined') {
						if (data.startsWith('{')) {
							var userConfig = jQuery.parseJSON(data);
						}
					}
					var config = {
						closeOnSelect: !$this.prop('multiple')
					};
					$.each(userConfig, function (k, v) {
						// restrict tags to email adresses
						if (k === 'createTag' && v === 'tag_emailAddress') {
							v = function (params) { return !scutum.helpers.validation.emailAddress(params.term) ? null : { id: params.term, text: params.term } };
						}
						// country flags
						if (k === 'templateResult' && v === 'formatCountryResult') {
							v = function (country) {
								if (!country.id) { return country.text; }
								return $('<span class="select2-search__flags"><span class="flag flag-' + country.id.toLowerCase() + '"></span><span>' + country.text + '</span>');
							}
						}
						if (k === 'templateSelection' && v === 'formatCountrySelection') {
							v = function (data, container) {
								if (!data.id) { return data.text; }
								return $('<span class="select2-selection__flag"><span class="flag flag-' + data.id.toLowerCase() + '"></span><span>' + data.text + '</span>');
							}
						}
						config[k] = v;
					});
					$this.select2(config);
					$this.on('select2:open', function (e) {
						scutum.forms.common.select2.addAnimation()
					});
					$this.on('change.select2', function (e) {
						if (typeof $(e.target).data('parsleyId') !== 'undefined') {
							$this.parsley().validate();
						}
					});
				}
			});
		})
	}
};
scutum.forms.common.select2.addAnimation = function () {
	var $dropdown = $('.select2-dropdown');
	if ($dropdown.hasClass('select2-dropdown--above')) {
		$dropdown.removeClass('uk-animation-slide-top-small').addClass("uk-animation-slide-bottom-small");
	} else {
		$dropdown.removeClass('uk-animation-slide-bottom-small').addClass("uk-animation-slide-top-small");
	}
};
scutum.forms.common.rating = function (input) {
	var $el = (input === undefined) ? $("[data-sc-raty]") : $(input);
	if ($el.length) {
		scutum.require(['raty'], function () {
			$el.each(function (index, item) {
				var $element = $(item);
				var options = {
					starType: 'span',
					scoreName: 'score',
					number: 5
				};
				var userOptions = JSON.parse(JSON.stringify($element.data('sc-raty')));
				if (userOptions !== '') {
					options = $.extend(options, userOptions);
				}
				$element.raty(options);
			});
		});
	}
};
scutum.forms.common.datePicker = function (wrapper) {
	var $el = (wrapper === undefined) ? $("[data-sc-flatpickr]") : $(wrapper).find('[data-sc-flatpickr]');
	if ($el.length) {
		scutum.require(['flatpickr'], function () {
			$el.each(function (index, input) {
				var options = {};
				var userOptions = JSON.parse(JSON.stringify($(this).data('sc-flatpickr')));
				if (userOptions !== '') {
					options = $.extend(options, userOptions);
				}
				$(this).flatpickr(options);
			}, true)
		})
	}
};
scutum.forms.common.switches = function (input) {
	var $el = input ? $(input) : $("[data-sc-switchery]");
	if ($el.length) {
		scutum.require(['switchery'], function () {
			$el.each(function (index, el) {
				var $switch = $(el);
				if (!$switch.data('objSwitchery')) {
					var sw_size = $switch.attr('data-switchery-size');
					var sw_color = $switch.attr('data-switchery-color');
					var sw_secondary_color = $switch.attr('data-switchery-secondary-color');
					var sw_disabled = $switch.attr('data-switchery-disabled') || $switch.attr('disabled');
					var switchery = new Switchery($switch[0], {
						color: (typeof sw_color !== 'undefined') ? scutum.helpers.hex2rgba(sw_color, 50) : scutum.helpers.hex2rgba('#90caf9', 100),
						secondaryColor: (typeof sw_secondary_color !== 'undefined') ? scutum.helpers.hex2rgba(sw_secondary_color, 50) : 'rgba(0, 0, 0,0.26)',
						jackColor: (typeof sw_color !== 'undefined') ? scutum.helpers.hex2rgba(sw_color, 100) : scutum.helpers.hex2rgba('#1976d2', 100),
						jackSecondaryColor: (typeof sw_secondary_color !== 'undefined') ? scutum.helpers.hex2rgba(sw_secondary_color, 100) : '#fafafa',
						size: (typeof sw_size !== 'undefined') ? sw_size : 'default',
						disabled: sw_disabled ? $switch.attr('data-switchery-disabled') : 'false'
					});
					$switch.data('objSwitchery', switchery);
				}
			});
		})
	}
};
scutum.forms.common.switches.onChange = function (el) {
	if (typeof Event === 'function' || !document.fireEvent) {
		var event = document.createEvent('HTMLEvents');
		event.initEvent('change', true, true);
		el.dispatchEvent(event);
	} else {
		el.fireEvent('onchange');
	}
};
scutum.forms.common.dynamicFields = function (parent, resize, hideFieldsOnLoad, addCallback, removeCallback) {
	var $dynamic_fields = parent ? $(parent).find('[data-sc-dynamic-fields]') : $('[data-sc-dynamic-fields]');
	if ($dynamic_fields.length) {
		scutum.require(['handlebars'], function () {
			var $this = $dynamic_fields;
			var counter = $this.attr('data-sc-dynamic-fields-counter');
			if (typeof counter === 'undefined') {
				$this.attr('data-sc-dynamic-fields-counter', 0);
			}
			var index = (typeof counter !== 'undefined') ? counter : 0;
			var this_template = $this.data('scDynamicFields');
			if (!hideFieldsOnLoad) {
				scutum.forms.common.dynamicFields.add_fields($this, this_template, index);
				if (typeof addCallback !== 'undefined' && typeof addCallback === 'function') {
					addCallback();
				}
				if (resize) {
					scutum.$win.resize();
				}
			}
			$this
				// add fields
				.on('click', '.sc-js-section-clone', function (e) {
					e.preventDefault();
					$(this)
						.toggleClass('sc-js-section-clone sc-js-section-remove')
						.children().toggle();
					var index = parseInt($this.attr('data-sc-dynamic-fields-counter')) + 1;
					$this.attr('data-sc-dynamic-fields-counter', index);
					scutum.forms.common.dynamicFields.add_fields($this, this_template, index);
					if (typeof addCallback !== 'undefined' && typeof addCallback === 'function') {
						addCallback(true);
					}
					if (resize) {
						scutum.$win.resize();
					}
				})
				// remove fields
				.on('click', '.sc-js-section-remove', function (e) {
					e.preventDefault();
					$(this).closest('.sc-form-section').next('hr').remove().end().remove();
					if (typeof removeCallback !== 'undefined' && typeof removeCallback === 'function') {
						removeCallback();
					}
					if (resize) {
						scutum.$win.resize();
					}
				});
		}, false)
	}
};
scutum.forms.common.dynamicFields.add_fields = function ($wrapper, template, index) {
	var source = $("#" + template).html();
	var tmpl = Handlebars.compile(source);
	var theCompiledHtml = tmpl({
		index: index || 0,
		counter: index ? '__' + index : '__' + 0
	});
	// append fields
	$wrapper.append(theCompiledHtml);
	var $lastChild = $wrapper.children().last();
	// initialize inputs
	scutum.forms.common.inputs($lastChild);
	// initialize checkboxes
	scutum.forms.common.icheck($lastChild.find('[data-sc-icheck]'));
	// initialize switches
	scutum.forms.common.switches($lastChild.find('[data-sc-switchery]'));
	// initialize select2
	scutum.forms.common.select2($lastChild);
	// initialize datepicker
	scutum.forms.common.datePicker($lastChild);
};
scutum.forms.common.inputMask = function (input) {
	var $el = (typeof input === 'undefined') ? $("[data-inputmask]") : $(input);
	if ($el.length) {
		scutum.require(['inputmask'], function () {
			$el.each(function (index, item) {
				$(item).inputmask();
			});
		});
	}
};
scutum.forms.common.clearInput = function (input) {
	var $el = $("[data-sc-clear-input]");
	$el.each(function () {
		var $this = $(this)
		var $input = $this.siblings('input')
		$this.hide().on('click', function () {
			$input.val('').focus();
			$this.hide();
		})
		$input.on('propertychange change click keyup input paste', function () {
			if($(this).val() !== '') {
				$this.show();
			} else {
				$this.hide();
			}
		})
	})
};
