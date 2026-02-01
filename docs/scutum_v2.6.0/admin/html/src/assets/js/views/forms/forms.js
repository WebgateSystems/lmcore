scutum.forms.controls = {};
scutum.forms.controls.init = function () {
	// select2 controls
	scutum.forms.controls.select2();
	// colorpicker
	scutum.plugins.colorpicker.init();
	// ionRangeSlider
	scutum.forms.controls.rangeSlider();
	// datepicker/timepicker
	scutum.forms.controls.flatpickr();
	// daterangepicker
	scutum.forms.controls.dateRangePicker();
	// multiselect
	scutum.forms.controls.multiSelect();
	// manual toggle switch
	var $switch = $('#sw-toggle')[0];
	$('#sw-toggle-btn').on('click', function (e) {
		e.preventDefault();
		$switch.checked = !$switch.checked;
		scutum.forms.common.switches.onChange($switch)
	});
};

scutum.forms.controls.select2 = function (input) {
	scutum.require(['select2'], function () {
		// default options
		$.fn.select2.defaults.set('width', '100%');
		// basic
		$("#select-basic")
			.select2({
				placeholder: "Select a state",
				allowClear: true
			})
			.on('select2:open', function (e) {
				$('.select2-dropdown').addClass("uk-animation-slide-top-small");
			});
		// multiple
		$("#select-multiple")
			.select2({
				placeholder: "Select cities...",
				closeOnSelect: false
			})
			.on('select2:open', function (e) {
				$('.select2-dropdown').addClass("uk-animation-slide-top-small");
			})
		;
	});
};
scutum.forms.controls.rangeSlider = function () {
	scutum.require(['rangeSlider'], function () {
		$("#range-01").ionRangeSlider({
			min: 100,
			max: 1000,
			from: 550
		});
		$("#range-02").ionRangeSlider({
			type: "double",
			grid: true,
			min: 0,
			max: 1000,
			from: 200,
			to: 800,
			prefix: "$"
		});
		$("#range-03").ionRangeSlider({
			grid: true,
			from: 5,
			values: [
				"zero", "one",
				"two", "three",
				"four", "five",
				"six", "seven",
				"eight", "nine",
				"ten"
			]
		});
		$("#range-04").ionRangeSlider({
			grid: true,
			min: 18,
			max: 70,
			from: 30,
			prefix: "Age ",
			max_postfix: "+"
		});
		$("#range-05").ionRangeSlider({
			type: "double",
			min: 1000000,
			max: 2000000,
			grid: true,
			force_edges: true
		});
		$("#range-06").ionRangeSlider({
			type: "single",
			min: 0,
			max: 10,
			step: 2.34,
			grid: true,
			grid_snap: true
		});
	});
};
scutum.forms.controls.flatpickr = function (wrapper) {
	scutum.require(['flatpickr'], function () {
		var confirmDate = new confirmDatePlugin({
			confirmIcon: "<i class='mdi mdi-check'></i>",
			confirmText: ""
		});
		// datetime picker
		flatpickr("#dp-time", {
			enableTime: true,
			time_24hr: true,
			plugins: [confirmDate],
			dateFormat: "d/m/Y H:i",
			defaultDate: moment().format('DD/MM/YYYY H:m')
		});
		// multiple dates
		flatpickr("#dp-multiple", {
			mode: "multiple",
			wrap: true,
			plugins: [confirmDate]
		});
		// inline
		flatpickr("#dp-inline", {
			inline: true,
			weekNumbers: scutum.helpers.mq.mediumMin()
		});
		// timepicker
		flatpickr("#dp-timepicker-24", {
			enableTime: true,
			noCalendar: true,
			dateFormat: "H:i",
			time_24hr: true,
			defaultDate: moment().format('HH:mm')
		});
	});
};
scutum.forms.controls.dateRangePicker = function () {
	scutum.require(['daterangepicker'], function () {
		// default
		$('#drp-default').dateRangePicker({
			customArrowPrevSymbol: '<i class="mdi mdi-chevron-left"></i>',
			customArrowNextSymbol: '<i class="mdi mdi-chevron-right"></i>',
			startOfWeek: 'monday',
			separator: ' ~ ',
			customOpenAnimation: function (cb) {
				$(this).css({'transform': 'translateY(-20px)'}).fadeIn(280, cb).css({'transform': 'translateY(0)'});
			},
			customCloseAnimation: function (cb) {
				$(this).fadeOut(140, cb).css({'transform': 'translateY(-20px)'});
			}
		});
		// time enabled
		$('#drp-timeEnabled').dateRangePicker({
			customArrowPrevSymbol: '<i class="mdi mdi-chevron-left"></i>',
			customArrowNextSymbol: '<i class="mdi mdi-chevron-right"></i>',
			startOfWeek: 'monday',
			separator: ' ~ ',
			format: 'DD.MM.YYYY HH:mm',
			autoClose: false,
			time: {
				enabled: true
			},
			customOpenAnimation: function (cb) {
				$(this).css({'transform': 'translateY(-20px)'}).fadeIn(280, cb).css({'transform': 'translateY(0)'});
			},
			customCloseAnimation: function (cb) {
				$(this).fadeOut(140, cb).css({'transform': 'translateY(-20px)'});
			}
		});
		// future date shortcuts
		$('#drp-shortcuts').dateRangePicker({
			customArrowPrevSymbol: '<i class="mdi mdi-chevron-left"></i>',
			customArrowNextSymbol: '<i class="mdi mdi-chevron-right"></i>',
			startOfWeek: 'monday',
			showShortcuts: true,
			separator: ' ~ ',
			shortcuts: {
				'next-days': [3, 5, 7],
				'next': ['week', 'month', 'year']
			},
			customOpenAnimation: function (cb) {
				$(this).css({'transform': 'translateY(-20px)'}).fadeIn(280, cb).css({'transform': 'translateY(0)'});
			},
			customCloseAnimation: function (cb) {
				$(this).fadeOut(140, cb).css({'transform': 'translateY(-20px)'});
			}
		});
		// extra content
		$('#drp-extra-content').dateRangePicker({
			customArrowPrevSymbol: '<i class="mdi mdi-chevron-left"></i>',
			customArrowNextSymbol: '<i class="mdi mdi-chevron-right"></i>',
			startOfWeek: 'monday',
			separator: ' ~ ',
			showDateFilter: function (time, date) {
				return '<span class="sc-text-semibold">' + date + '</span>' +
					'<div class="sc-color-secondary uk-margin-mini-top">$' + Math.round(Math.random() * 999) + '</div>';
			},
			customOpenAnimation: function (cb) {
				$(this).css({'transform': 'translateY(-20px)'}).fadeIn(280, cb).css({'transform': 'translateY(0)'});
			},
			customCloseAnimation: function (cb) {
				$(this).fadeOut(140, cb).css({'transform': 'translateY(-20px)'});
			}
		});
		// style range input
		$('.date-picker-wrapper').find('input[type="range"]').addClass('uk-range');
		// remove &nbsp; in shortcuts
		$('.date-picker-wrapper').find('.footer > .shortcuts').html().replace(/&nbsp;/g, '');
	})
};
scutum.forms.controls.multiSelect = function () {
	scutum.require(['multiSelect', 'quicksearch'], function () {
		// pre-selected options
		$('#ms-pre-selected-options').multiSelect({
			keepOrder: true
		});
		// optgroup
		$('#ms-optgroup').multiSelect({ selectableOptgroup: true });
		// custom headers
		$('#ms-custom-headers').multiSelect({
			cssClass: 'ms-header ms-footer',
			selectableHeader: "<div class='custom-header md-bg-light-blue-800 md-color-white'>Selectable header</div>",
			selectionHeader: "<div class='custom-header md-bg-grey-800 md-color-white'>Selection header</div>",
			selectableFooter: "<div class='custom-footer md-bg-light-blue-800 md-color-white'>Selectable footer</div>",
			selectionFooter: "<div class='custom-footer md-bg-grey-800 md-color-white'>Selection footer</div>"
		});
		// optgroup
		$('#ms-searchable').multiSelect({
			cssClass: 'ms-header',
			selectableHeader: "<div class='custom-header md-bg-grey-200'><input type='text' class='uk-input uk-form-small search-input' autocomplete='off' placeholder='Search...'></div>",
			selectionHeader: "<div class='custom-header md-bg-grey-200'><input type='text' class='uk-input uk-form-small search-input' autocomplete='off' placeholder='Search...'></div>",
			afterInit: function (ms) {
				var that = this;
				var $selectableSearch = that.$selectableUl.prev().children();
				var $selectionSearch = that.$selectionUl.prev().children();
				var selectableSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selectable:not(.ms-selected)';
				var selectionSearchString = '#' + that.$container.attr('id') + ' .ms-elem-selection.ms-selected';
				that.qs1 = $selectableSearch.quicksearch(selectableSearchString)
					.on('keydown', function (e) {
						if (e.which === 40) {
							that.$selectableUl.focus();
							return false;
						}
					});
				that.qs2 = $selectionSearch.quicksearch(selectionSearchString)
					.on('keydown', function (e) {
						if (e.which === 40) {
							that.$selectionUl.focus();
							return false;
						}
					});
			},
			afterSelect: function () {
				this.qs1.cache();
				this.qs2.cache();
			},
			afterDeselect: function () {
				this.qs1.cache();
				this.qs2.cache();
			}
		});
		// public methods
		$('#ms-public-methods').multiSelect();

		$('#ms-select-all').click(function () {
			$('#ms-public-methods').multiSelect('select_all');
			return false;
		});
		$('#ms-deselect-all').click(function () {
			$('#ms-public-methods').multiSelect('deselect_all');
			return false;
		});
		$('#ms-select-10').click(function () {
			$('#ms-public-methods').multiSelect('select', ['elem_0', 'elem_1', 'elem_2', 'elem_3', 'elem_4', 'elem_5', 'elem_6', 'elem_7', 'elem_8', 'elem_9', 'elem_10']);
			return false;
		});
		$('#ms-deselect-10').click(function () {
			$('#ms-public-methods').multiSelect('deselect', ['elem_0', 'elem_1', 'elem_2', 'elem_3', 'elem_4', 'elem_5', 'elem_6', 'elem_7', 'elem_8', 'elem_9', 'elem_10']);
			return false;
		});
		$('#ms-refresh').on('click', function () {
			$('#ms-public-methods').multiSelect('refresh');
			return false;
		});
		$('#ms-add-option').on('click', function () {
			$('#ms-public-methods').multiSelect('addOption', { value: 1, text: 'added 1', index: 0 });
			return false;
		});
	})
};
