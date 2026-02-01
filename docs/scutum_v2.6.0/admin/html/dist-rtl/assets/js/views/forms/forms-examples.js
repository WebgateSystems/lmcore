scutum.forms.examples = {};
scutum.forms.examples.init = function () {
	// dynamic fields
	scutum.forms.examples.dynamicFields.init();
	// credit cards
	scutum.forms.examples.creditCard();
	// iCheck
	scutum.forms.examples.iCheck();
	// datepicker
	scutum.forms.examples.datePicker();
	// daterangepicker
	scutum.forms.examples.dateRangePicker();
	// chained selects
	scutum.forms.examples.chainedSelects();
	// input masks
	scutum.forms.examples.inputMask();
	// disable form submit on enter
	scutum.forms.common.inputs.disableSubmit($('#sc-booking-form').find('input[type="text"]'));
	// flags (select2 countries)
	scutum.require(['flagsCSS'], function () {});
};

scutum.forms.examples.creditCard = function () {
	// cc validate
	var $el = $("[data-cc-validate]");
	if ($el.length) {
		scutum.require(['creditCardValidator'], function () {
			// credit cards example numbers
			$('.cc-numbers').on('click', 'a', function (e) {
				e.preventDefault();
				var $input = $(this).closest('.cc-validate-wrapper').find('[data-cc-validate]').val('');
				$input.val($(this).text()).trigger('input');
			});
			$el.validateCreditCard(function (result) {
				var icon = $el.closest('.cc-validate-wrapper').children('.cc-icon');
				if (result.valid) {
					if (result.card_type) {
						icon.children('img').attr('src', 'assets/icons/payment-icons/color/' + result.card_type.name + '.png')
					}
				} else {
					icon.children('img').attr('src', 'assets/img/blank.gif')
				}
			});
		})
	}
};
scutum.forms.examples.iCheck = function () {
	// checkout form (payment methods)
	$('[name="f-payment"]').on('ifChecked', function (e) {
		var info = $(e.currentTarget).attr('data-payment-info');
		$('.more-info-section').children().hide();
		if (info !== undefined) {
			$('#' + info).show();
			scutum.$win.resize();
		}
	});
	// medical history form
	$('.sc-js-med-info').on('change', function (e) {
		var $input = $(this).closest('div').find('.sc-js-el-show');
		if (e.currentTarget.checked) {
			$input.show();
		} else {
			$input.hide();
		}
	});
	// registration form
	$('#sc-js-terms-btn').on('click', function (e) {
		e.preventDefault();
		// check input
		$('#sc-js-terms').iCheck('check');
		// close modal
		UIkit.modal($('#sc-terms-modal')).hide();
	})
};
scutum.forms.examples.datePicker = function (wrapper) {
	scutum.require(['flatpickr'], function () {
		// eslint-disable-next-line new-cap
		var confirmDate = new confirmDatePlugin({
			confirmIcon: "<i class='mdi mdi-check'></i>",
			confirmText: ""
		});
		// job application form
		flatpickr("#dp-job-start-date", {
			altFormat: "F j, Y",
			minDate: moment(new Date(), "MM-DD-YYYY")._d
		});
		// car rental form; registration form
		flatpickr("#dp-birthdate", {
			dateFormat: "j F Y"
		});
		// car rental form
		var pickUp = flatpickr("#dp-pick-up-date", {
			enableTime: true,
			time_24hr: true,
			plugins: [confirmDate],
			minDate: moment(new Date(), "MM-DD-YYYY")._d,
			onChange: function (selectedDates, dateStr, instance) {
				dropOff.set('minDate', dateStr);
			}
		});
		var dropOff = flatpickr("#dp-drop-off-date", {
			enableTime: true,
			time_24hr: true,
			plugins: [confirmDate],
			minDate: moment(new Date(), "MM-DD-YYYY")._d,
			onChange: function (selectedDates, dateStr, instance) {
				pickUp.set('maxDate', dateStr);
			}
		});
		// medical history form
		flatpickr("#dp-patient-birthdate", {
			dateFormat: "j F Y"
		});
		// rental application form
		var moveIn = flatpickr(".dp-move-in", {
			onChange: function (selectedDates, dateStr, instance) {
				moveOut.set('minDate', dateStr);
			}
		});
		var moveOut = flatpickr(".dp-move-out", {
			onChange: function (selectedDates, dateStr, instance) {
				moveIn.set('maxDate', dateStr);
			}
		});
	});
};
scutum.forms.examples.dateRangePicker = function () {
	var $drpArivalDeparture = $('#drp-arival-departure');
	if ($drpArivalDeparture.length) {
		scutum.require(['daterangepicker'], function () {
			var $drpArival = $('#drp-arival');
			var $drDeparture = $('#drp-departure');
			$drpArivalDeparture
				.dateRangePicker({
					startOfWeek: 'monday',
					customArrowPrevSymbol: '<i class="mdi mdi-chevron-left"></i>',
					customArrowNextSymbol: '<i class="mdi mdi-chevron-right"></i>',
					inline: true,
					startDate: moment(new Date(), "MM-DD-YYYY").add(1, 'day')._d,
					container: '#drp-arival-departure-container',
					alwaysOpen: true,
					customTopBar: '',
					format: 'dddd MMM Do, YYYY',
					getValue: function () {
						if ($drpArival.val() && $drDeparture.val()) {
							return $drpArival.val() + ' to ' + $drDeparture.val();
						} else {
							return '';
						}
					},
					setValue: function (s, s1, s2) {
						$drpArival.val(s1);
						$drDeparture.val(s2);
					},
					showDateFilter: function (time, date) {
						return '<span class="sc-text-semibold">' + date + '</span>' +
							'<div class="sc-color-secondary uk-margin-mini-top">$' + Math.round(Math.random() * 999) + '</div>';
					}
				})
				.on('datepicker-change', function (event, obj) {
					$drpArival.trigger('change');
					$drDeparture.trigger('change');
				});
		});
	}
};
scutum.forms.examples.chainedSelects = function () {
	scutum.require(['chained'], function () {
		// form examples
		$("#f-car-subtype").chained("#f-car-type");
	})
};
scutum.forms.examples.inputMask = function (input) {
	var $el = (typeof input === 'undefined') ? $("[data-inputmask]") : $(input);
	if ($el.length) {
		scutum.require(['inputmask'], function () {
			$el.each(function (index, item) {
				$(item).inputmask();
			});
		});
	}
};
scutum.forms.examples.dynamicFields = {
	'init': function () {
		// education (job application form)
		scutum.forms.common.dynamicFields($('#sc-js-dynamic-fields-education'), true, false, scutum.forms.examples.dynamicFields.eduCallback, scutum.forms.examples.dynamicFields.eduCallback);
		// notifications
		scutum.$body.on('click', '.sc-js-edu-undo', function () {
			var $this = $(this);
			var $elToUndo = $('#sc-js-dynamic-fields-education').children('tbody').children('tr').eq($this.closest('[data-el-to-undo]').attr('data-el-to-undo'));
			$elToUndo.prev('tr').find('.sc-js-section-remove').trigger('click');
		});
		// employment history (job application form)
		scutum.forms.common.dynamicFields($('#sc-js-dynamic-fields-empl-history'), true, false);
		// rental history (rental application form)
		scutum.forms.common.dynamicFields($('#sc-js-dynamic-fields-rental-history'), true, false);
		// personal references (rental application form)
		scutum.forms.common.dynamicFields($('#sc-js-dynamic-fields-personal-references'), true, false);
	},
	'eduCallback': function (click) {
		var $childrens = $('#sc-js-dynamic-fields-education').children('tbody').children('tr');
		var length = $childrens.length;
		for (var i = 0; i < length; i++) {
			$childrens.eq(i).find('.sc-js-edu-counter').html(i + 1);
		}
		if (click) {
			var margin = scutum.helpers.isRTL() ? 'uk-margin-right' : 'uk-margin-left'
			UIkit.notification({
				message: "<span class='uk-flex uk-flex-middle' data-el-to-undo='" + (length - 1) + "'><span class='uk-flex-1'>New Education added</span><a href='#' class='sc-js-edu-undo md-color-amber-500 " + margin + "'>undo</a></span>",
				timeout: 3000
			});
		}
	}
};
