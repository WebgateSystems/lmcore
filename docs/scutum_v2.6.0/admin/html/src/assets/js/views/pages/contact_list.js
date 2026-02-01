scutum.pages.contactList = {};
scutum.pages.contactList.init = function () {
	var $list = $("#sc-contact-list");
	scutum.require(['listnav'], function () {
		$list.listnav({
			noMatchText: 'No matching contacts',
			filterSelector: '.sc-js-contact-name',
			onAfterFilter: function (letter) {
				console.log('Letter changed to ' + letter);
			}
		});
	});
};
