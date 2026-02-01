scutum.forms.validation = {};
scutum.forms.validation.init = function () {
	var $form = $('#sc-js-form');
	scutum.require(['parsleyJS'], function () {
		$form.parsley().on('form:validated', function (ParsleyForm) {
			$form.find('[data-sc-input]').trigger('validationClassChanged');
		});
	})
};
