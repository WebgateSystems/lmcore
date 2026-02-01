scutum.components = {};
scutum.components.notifications = {
	'init': function () {
		$('.sc-js-notify-default').on('click', function () {
			UIkit.notification('My message');
		});
		$('.sc-js-notify-persistent').on('click', function () {
			UIkit.notification('My persistent message', {
				timeout: false
			});
		});
		$('.sc-js-notify-icon').on('click', function () {
			var margin = scutum.helpers.isRTL() ? 'uk-margin-left' : 'uk-margin-right'
			UIkit.notification('<div class="uk-flex uk-flex-middle"><i class="mdi mdi-check-all ' +  margin + ' md-color-light-green-400"></i>Message</div>');
		});
		$('.sc-js-notify-long').on('click', function () {
			UIkit.notification('Lorem ipsum dolor sit amet, consectetur adipisicing elit. Repellendus, labore laudantium eaque obcaecati');
		});
		$('.sc-js-notify-link').on('click', function () {
			var margin = scutum.helpers.isRTL() ? 'uk-margin-right' : 'uk-margin-left'
			UIkit.notification('<div class="uk-flex uk-flex-middle"><span class="uk-flex-1">Message deleted!</span><a href="#" class="md-color-amber-500 '+ margin + '">undo</a></div>');
		});
		// positions
		$('.sc-js-notify-pos-top-left').on('click', function () {
			UIkit.notification('My message', {
				pos: 'top-left',
				timeout: false
			});
		});
		$('.sc-js-notify-pos-top-center').on('click', function () {
			UIkit.notification('My message', {
				pos: 'top-center',
				timeout: false
			});
		});
		$('.sc-js-notify-pos-top-right').on('click', function () {
			UIkit.notification('My message', {
				pos: 'top-right',
				timeout: false
			});
		});
		$('.sc-js-notify-pos-bottom-left').on('click', function () {
			UIkit.notification('My message', {
				pos: 'bottom-left',
				timeout: false
			});
		});
		$('.sc-js-notify-pos-bottom-center').on('click', function () {
			UIkit.notification('My message', {
				pos: 'bottom-center',
				timeout: false
			});
		});
		$('.sc-js-notify-pos-bottom-right').on('click', function () {
			UIkit.notification('My message', {
				pos: 'bottom-right',
				timeout: false
			});
		});
		// status
		$('.sc-js-notify-status-primary').on('click', function () {
			UIkit.notification('My message', {
				status: 'primary',
				timeout: false
			});
		});
		$('.sc-js-notify-status-success').on('click', function () {
			UIkit.notification('My message', {
				status: 'success',
				timeout: false
			});
		});
		$('.sc-js-notify-status-danger').on('click', function () {
			UIkit.notification('My message', {
				status: 'danger',
				timeout: false
			});
		});
		$('.sc-js-notify-status-warning').on('click', function () {
			UIkit.notification('My message', {
				status: 'warning',
				timeout: false
			});
		});
	}
};
