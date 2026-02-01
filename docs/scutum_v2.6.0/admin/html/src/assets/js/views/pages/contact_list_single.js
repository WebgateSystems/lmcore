scutum.pages.contactListSingle = {};
scutum.pages.contactListSingle.init = function () {
	// user list
	scutum.require(['listjs'], function () {
		var options = {
			searchClass: 'sc-js-list-search',
			listClass: 'uk-list',
			valueNames: ['sc-js-list-fName', 'sc-js-list-lName', 'sc-js-list-company']
		};
		var list = new List('sc-page-aside', options);
		list.sort('sc-js-list-company', { order: "asc" });
	});
	// address map
	scutum.require(['gmaps'], function () {
		var map = new GMaps({
			el: '#sc-js-address-map',
			lat: 32.67,
			lng: -16.9421801,
			zoom: 12
		});
		map.addMarker({
			lat: 32.6600766,
			lng: -16.9421801,
			title: 'Madeira',
			click: function (e) {
				alert('You clicked in this marker');
			}
		});
	});
};
