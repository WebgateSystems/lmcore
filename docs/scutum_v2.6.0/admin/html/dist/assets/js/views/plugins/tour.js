scutum.plugins.tour = {};
scutum.plugins.tour.init = function () {
	scutum.require(['driver'], function () {
		// whole page tour
		scutum.plugins.tour.page();
		// single element without popover
		scutum.plugins.tour.singleELNoPopover();
		// single element with popover
		scutum.plugins.tour.singleELPopover();
		// positioning
		scutum.plugins.tour.popoverPositioning();
	});
};
scutum.plugins.tour.page = function () {
	var driver = new Driver({
		opacity: 0.6,
		padding: 0,
		allowClose: false,
		closeBtnText: '',
		nextBtnText: 'Next',
		prevBtnText: 'Previous',
		animate: scutum.helpers.mq.mediumMin()
	});
	// driver.window.removeEventListener('touchstart', driver.onClick, false);
	// define the steps
	var steps = scutum.helpers.mq.mediumMax()
		? [
			{
				element: '#sc-header',
				popover: {
					title: 'Main Header',
					description: 'Here is the main header.',
					position: 'bottom-center',
					offset: 0
				}
			},
			{
				element: '#sc-sidebar-main-toggle',
				popover: {
					title: 'Main Sidebar',
					description: 'Here you can toggle main sidebar.',
					position: scutum.helpers.isRTL() ? 'bottom-right' : 'bottom-left',
					offset: -8
				}
			},
			{
				element: '#sc-search-main-toggle-mobile',
				popover: {
					title: 'Main Search',
					description: 'Here you can toggle search form.',
					position: scutum.helpers.isRTL() ? 'bottom-left' : 'bottom-right',
					offset: 0
				}
			},
			{
				element: '#sc-tour-restart',
				popover: {
					title: 'Restart tour',
					description: 'Here you can restart tour.',
					position: scutum.helpers.isRTL() ? 'bottom-right' : 'bottom-left',
					offset: 0
				}
			}
		]
		: [
			{
				element: '#sc-header',
				popover: {
					title: 'Main Header',
					description: 'Here is the main header.',
					position: 'bottom-center',
					offset: 16
				}
			},
			{
				element: '#sc-sidebar-main',
				popover: {
					title: 'Main Sidebar',
					description: 'Here is the main sidebar with the main menu.',
					position: scutum.helpers.isRTL() ? 'left' : 'right',
					offset: 8
				}
			},
			{
				element: '#sc-js-fullscreen-toggle',
				popover: {
					title: 'Fullscreen toggle',
					description: 'Here you can toggle fullscreen mode.',
					position: scutum.helpers.isRTL() ? 'bottom-left' : 'bottom-right',
					offset: 8
				}
			},
			{
				element: '#sc-tour-restart',
				popover: {
					title: 'Restart tour',
					description: 'Here you can restart tour.',
					position: scutum.helpers.isRTL() ? 'bottom-right' : 'bottom-left',
					offset: 8
				}
			}
		];
	driver.defineSteps(steps);
	setTimeout(function () {
		// start the tour
		driver.start();
	}, 200);
	// restart the tour
	$('#sc-tour-restart').on('click', function () {
		setTimeout(function () {
			driver.start(0);
		}, 200)
	})
};
scutum.plugins.tour.singleELNoPopover = function () {
	var highlightDriver = new Driver({
		closeBtnText: '',
		opacity: 0.6
	});
	$('#sc-tour-singleEl-noPopover button').on('click', function (e) {
		e.preventDefault();
		highlightDriver.highlight('#sc-tour-singleEl-noPopover');
	});
	var focusDriver = new Driver({
		closeBtnText: '',
		opacity: 0.6
	});
	// Highlight the section on focus
	$('.sc-tour-singleEl-noPopover-focus input').on('focus', function () {
		focusDriver.highlight($(this).closest('.sc-tour-singleEl-noPopover-focus')[0]);
	})
};
scutum.plugins.tour.singleELPopover = function () {
	var highlightDriver = new Driver({
		closeBtnText: '',
		opacity: 0.6
	});
	$('#sc-tour-singleEl-Popover button').on('click', function (e) {
		e.preventDefault();
		highlightDriver.highlight({
			element: '#sc-tour-singleEl-Popover',
			popover: {
				title: 'Title for the Popover',
				description: 'Description for highlighted element',
				position: 'top'
			}
		});
	});
};
scutum.plugins.tour.popoverPositioning = function () {
	var driver = new Driver({
		closeBtnText: '',
		opacity: 0.6,
		padding: 0
	});
	$('.sc-tour-position button').on('click', function () {
		var $this = $(this);
		driver.highlight({
			element: $this.closest('div')[0],
			popover: {
				title: 'Title for the Popover',
				description: 'Description for popover.',
				position: $this.closest('div').attr('data-position')
			}
		});
	})
};
