scutum.forms.wizard = {};
scutum.forms.wizard.init = function () {
	// flags (select2 countries)
	scutum.require(['flagsCSS'], function () {});
	// wizard
	scutum.require(['steps', 'parsleyJS'], function () {
		// ==== HORIZONTAL
		var $formH = $("#sc-wizard-h-form");
		var $wizardH = $("#sc-wizard-h");
		// init parsleyJS validation
		$formH.parsley();
		$wizardH.steps({
			headerTag: "h3",
			bodyTag: "section",
			transitionEffect: scutum.helpers.isRTL() ? "fade" : "slideLeft",
			autoFocus: true,
			labels: {
				finish: "Confirm Order"
			},
			onStepChanging: function (event, currentIndex, newIndex) {
				// Always allow previous action even if the current form is not valid!
				if (currentIndex > newIndex) {
					return true;
				}
				// needed in some cases if the user went back (clean up)
				if (currentIndex < newIndex) {
					// remove error styles
					// $formH.find(".body:eq(" + newIndex + ") label.error").remove();
					// $formH.find(".body:eq(" + newIndex + ") .error").removeClass("error");
				}
				var $currentStep = $formH.find('.body.current');
				$currentStep.find('input, textarea, select').each(function () {
					$(this).each(function () {
						var $this = $(this);
						$this.parsley().validate();
						scutum.forms.common.inputs.update($this);
					});
				});
				$wizardH.steps("setHeight", $wizardH, true);
				var isValid = $currentStep.find('.uk-form-danger').length < 1;
				if (!isValid) {
					setTimeout(function () {
						$currentStep.find('.uk-form-danger:first').trigger('focus')
					}, 200);
				}
				return isValid;
			},
			onInit: function (event, currentIndex) {
				function setHeight (click) {
					setTimeout(function () {
						$wizardH.steps("setHeight", $wizardH, click);
					}, 120);
				}
				// dynamic fields
				scutum.forms.common.dynamicFields($('#sc-js-dynamic-fields-billing-address'), false, false, setHeight, setHeight);
				// input mask
				var $imEl = $("[data-inputmask]");
				if ($imEl.length) {
					scutum.require(['inputmask'], function () {
						$imEl.each(function (index, item) {
							$(item).inputmask();
						});
					});
				}
				// payment methods
				$('[name="wiz-payment"]').on('ifChecked', function (e) {
					var info = $(e.currentTarget).attr('data-payment-info');
					if (info !== undefined) {
						$('#' + info).show().siblings().hide();
						scutum.$win.resize();
					}
				});
				// cc validate
				var $ccEl = $("[data-cc-validate]");
				if ($ccEl.length) {
					scutum.require(['creditCardValidator'], function () {
						// credit cards numbers
						$('.cc-numbers').on('click', 'a', function (e) {
							e.preventDefault();
							var $input = $(this).closest('.cc-validate-wrapper').find('[data-cc-validate]');
							$input.val($(this).text()).trigger('input');
						});
						$ccEl.validateCreditCard(function (result) {
							var icon = $ccEl.closest('.cc-validate-wrapper').children('.cc-icon');
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
				scutum.$win.on('resize', scutum.helpers.debounce(setHeight, 200));
			},
			onFinished: function () {
				var form_serialized = JSON.stringify(scutum.helpers.serializeObject($formH), null, 2);
				UIkit.modal.alert('<h5>Wizard data:</h5><pre class="sc-js-highlight"><code>' + form_serialized + '</code></pre>');
				scutum.helpers.codeHighlight();
			}
		});

		// ==== VERTICAL
		$("#sc-wizard-v").steps({
			headerTag: "h3",
			bodyTag: "section",
			transitionEffect: scutum.helpers.isRTL() ? "fade" : "slideLeft",
			stepsOrientation: "vertical",
			enableAllSteps: true
		});
		// MINIMAL
		$("#sc-wizard-h-min").steps({
			headerTag: "h3",
			bodyTag: "section",
			transitionEffect: scutum.helpers.isRTL() ? "fade" : "slideLeft",
			enableAllSteps: true
		});
		$("#sc-wizard-v-min").steps({
			headerTag: "h3",
			bodyTag: "section",
			transitionEffect: scutum.helpers.isRTL() ? "fade" : "slideLeft",
			stepsOrientation: "vertical",
			enableAllSteps: true
		});
	});
};
