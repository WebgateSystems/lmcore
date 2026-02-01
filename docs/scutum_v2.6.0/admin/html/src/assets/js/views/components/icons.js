scutum.components = {};
scutum.components.icons = {
	'init': function () {
		var $mdIcons = $('#sc-js-mdi-dynamic-load');
		scutum.helpers.preloader.show($mdIcons);
		scutum.require(['handlebars', 'clipboard', 'quicksearch'], function () {
			scutum.helpers.ajax('data/pages/mdicons.json', 'GET', 'json').then(function (response) {
				var source = $('#mdiTemplate').html();
				var tmpl = Handlebars.compile(source);
				var theCompiledHtml = tmpl({
					icons: response
				});
				setTimeout(function () {
					$mdIcons.addClass('uk-animation-slide-bottom-medium');
					// append icons
					$mdIcons.html(theCompiledHtml);
					// copy mdi icons to clipboard
					var clipboardMdi = new ClipboardJS('.sc-js-mdi-code', {
						text: function (trigger) {
							var icon = $(trigger).html();
							return icon.trim();
						}
					});
					clipboardMdi.on('success', function (e) {
						var margin = scutum.helpers.isRTL() ? 'uk-margin-left' : 'uk-margin-right'
						UIkit.notification({
							message: '<div class="uk-flex uk-flex-middle"><span class="'+ margin + '">' + e.text + '</span><span class="uk-flex-1 uk-text-center">copied to clipboard</span></div>',
							timeout: 3000
						});
					});
					// quicksearch
					$('input#sc-js-icons-search').quicksearch('.sc-js-search-list > div', {
						minValLength: 3,
						testQuery: function (query, txt, _row) {
							txt = $(_row).attr('data-icon-name');
							txt = txt.toLowerCase();
							for (var i = 0; i < query.length; i += 1) {
								if (txt.indexOf(query[i]) === -1) {
									return false;
								}
							}
							return true;
						}
					});
					// copy uikit icons to clipboard
					var clipboardUIKit = new ClipboardJS('.sc-js-uikit-code', {
						text: function (trigger) {
							var data_ = $(trigger).children().attr('data-uk-icon');
							var data = data_.replace('; ratio: 1.4', '');
							return '<span data-uk-icon="' + data + '"></span>';
						}
					});
					clipboardUIKit.on('success', function (e) {
						var margin = scutum.helpers.isRTL() ? 'uk-margin-left' : 'uk-margin-right'
						UIkit.notification({
							message: '<div class="uk-flex uk-flex-middle"><span class="' + margin + '">' + e.text + '</span><span class="uk-flex-1 uk-text-center">copied to clipboard</span></div>',
							timeout: 3000
						});
					});
				}, 1000);
			})
		}, false)
	}
};
