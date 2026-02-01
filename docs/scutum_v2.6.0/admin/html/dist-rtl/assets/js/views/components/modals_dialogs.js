scutum.components = {};
scutum.components.modalsDialogs = {
	'init': function () {
		$('#sc-js-modal-dialog').on('click', function (e) {
			e.preventDefault();
			UIkit.modal.dialog('<p class="uk-modal-body">Lorem ipsum dolor, sit amet consectetur adipisicing elit. Cupiditate enim consequuntur, saepe mollitia aliquam quia, delectus cum, nobis quisquam ipsam rerum excepturi repellendus explicabo perspiciatis dolor accusantium! Voluptates, asperiores rerum.</p>');
		})
		$('#sc-js-modal-alert').on('click', function (e) {
			UIkit.modal.alert('UIkit alert!').then(function () {
				console.log('Alert closed.')
			})
		})
		$('#sc-js-modal-confirm').on('click', function (e) {
			UIkit.modal.confirm('UIkit confirm!').then(function () {
				console.log('Confirmed.')
			}, function () {
				console.log('Rejected.')
			})
		})
		$('#sc-js-modal-prompt').on('click', function (e) {
			UIkit.modal.prompt('Name:', '').then(function (name) {
				console.log('Prompted: ', name)
			})
		})
	}
};
