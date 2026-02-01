scutum.plugins.ajax = {};
scutum.plugins.ajax.init = function () {
	scutum.require(['mockjax', 'intercooler', 'handlebars', 'chancejs'], function () {
		// click to edit example
		scutum.plugins.ajax.clickToEdit();
		// lazy load
		scutum.plugins.ajax.lazyload();
		// click to load example
		scutum.plugins.ajax.clickToLoad();
		// deleting a table row example
		scutum.plugins.ajax.tablerowDelete();
		// save order after sort
		scutum.plugins.ajax.sortableList();
	}, false)
};
scutum.plugins.ajax.clickToEdit = function () {
	var dataStore = (function () {
		var mockUser = {
			"firstName": chance.first(),
			"lastName": chance.last(),
			"email": chance.email(),
			"company": chance.company(),
			"userActive": true
		};
		return {
			findUser: function (id) {
				return mockUser
			}
		}
	})();
	var $container = $('#sc-contact-edit');
	var userDisplaySource = $('#sc-contact-edit-template').html();
	var mockUser = dataStore.findUser("1");
	var template = Handlebars.compile(userDisplaySource);
	var compiledTemplate = template(mockUser);
	// show user data
	$container.html(compiledTemplate);
	// attach intercooler to container
	Intercooler.processNodes($container);

	$.mockjax({
		url: "/contact/1/edit",
		responseTime: 200,
		response: function (settings) {
			var mockUser = dataStore.findUser("1");
			var formSource = $('#sc-contact-edit-form').html();
			var template = Handlebars.compile(formSource);
			// show form
			this.responseText = template(mockUser);
			setTimeout(function () {
				// initialize switches
				scutum.forms.common.switches($('#user-status'));
				// initialize inputs
				scutum.forms.common.inputs($container);
				// attach intercooler to container
				Intercooler.processNodes($container);
			}, 300);
		}
	});
	$.mockjax({
		url: "/contact/1",
		responseTime: 200,
		response: function (settings) {
			var mockUser = dataStore.findUser("1");
			var params = scutum.helpers.parseParams(settings.data);
			if (params['_method'] === 'PUT') {
				mockUser.firstName = params['firstName'];
				mockUser.lastName = params['lastName'];
				mockUser.email = params['email'];
				mockUser.company = params['company'];
				mockUser.userActive = params['userActive'] === 'on';
			}
			// show user data
			this.responseText = template(mockUser);
			// attach intercooler to container
			Intercooler.processNodes($container);
		}
	});
};
scutum.plugins.ajax.lazyload = function () {
	var photos = [ 'alex-guillaume-769172-unsplash', 'avantgarde-concept-763896-unsplash', 'briana-tozour-756151-unsplash', 'casey-horner-768005-unsplash', 'ciaran-o-brien-769402-unsplash', 'daria-kopylova-766667-unsplash', 'eiliv-aceron-765897-unsplash', 'paula-brustur-766878-unsplash', 'pietro-mattia-764559-unsplash', 'rachel-park-366508-unsplash', 'ray-hennessy-763310-unsplash', 'rodion-kutsaev-760882-unsplash', 'san-fermin-pamplona-navarra-768251-unsplash', 'shane-young-768821-unsplash', 'steve-roe-763192-unsplash', 'urban-sanden-768851-unsplash', 'wynand-van-poortvliet-761831-unsplash' ];
	$.mockjax({
		url: "/lazy-load",
		responseTime: 1500,
		response: function (settings) {
			this.responseText = '<img src="assets/img/photos/' + photos[Math.floor(Math.random() * photos.length)] + '_md.jpg" class="sc-round uk-height-medium" alt="">';
		}
	});
};
scutum.plugins.ajax.clickToLoad = function () {
	var dataStore = (function () {
		function generateContact (key) {
			return { key: key + 1, name: chance.name(), email: chance.email(), company: chance.company(), ssn: chance.ssn() }
		}
		return {
			contactsForPage: function (page, key) {
				var vals = [];
				var _key = key;
				for (var i = 0; i < 5; i++) {
					vals.push(generateContact(_key));
					_key++;
				}
				return vals;
			}
		}
	}());
	var $container = $('#sc-table-load');
	var userDisplaySource = $('#sc-table-load-template').html();
	var mockData = dataStore.contactsForPage(1, 0);
	var template = Handlebars.compile(userDisplaySource);
	mockData.forEach(function (item) {
		var compiledTemplate = template(item);
		$container.append(compiledTemplate);
	});
	$container.attr('data-entries', $container.children().length);

	$.mockjax({
		url: /\/contacts.*/,
		responseTime: 800,
		response: function (settings) {
			var queryStr = settings.url.substring(settings.url.lastIndexOf('?'));
			var params = scutum.helpers.parseParams(queryStr);
			var page = parseInt(params['page']);
			var key = parseInt($container.attr('data-entries'));
			var contacts = dataStore.contactsForPage(page, key);
			contacts.forEach(function (item, index) {
				var compiledTemplate = template(item);
				$container.append(compiledTemplate);
			});
			$container.attr('data-entries', $container.children().length)
		}
	});
};
scutum.plugins.ajax.tablerowDelete = function () {
	$('.sc-js-user-delete').on('click', function () {
		var $this = $(this);
		UIkit.modal.confirm('<p class="uk-text-large">Are you sure?</p>', {
			'escClose': false
		}).then(function () {
			$this.trigger('confirmed-by-user');
		}, function () {
			console.log('Rejected.')
		});
	});
	$.mockjax({
		url: /\/users\/.*/,
		headers: {'X-IC-Remove': "300ms"}
	});
};
scutum.plugins.ajax.sortableList = function () {
	$.mockjax({
		url: "/sortable-list",
		responseTime: 750,
		response: function (settings) {
			var params = scutum.helpers.parseParams(settings.data);
			saveOrder(params['sortable-list-items']);
			UIkit.notification('New Order Saved.');
		}
	});
	function saveOrder (items) {
		var _items = [];
		items.forEach(function (item) {
			_items.push(item);
		});
		console.log(_items);
	}
};
