scutum.styleSwitcher = function () {
	var $sSw = $('#sc-style-switcher');
	$sSw.children('.sc-sSw-toggle').on('click', function (e) {
		e.preventDefault();
		$sSw.toggleClass('active');
	});
	// change theme
	$sSw.find('.sc-sSw-theme-switch').on('click', function (e) {
		e.preventDefault();
		$(this).parent('li').addClass('active').siblings().removeClass('active');
		var theme = $(this).attr('data-theme');
		var themes = 'sc-theme-a sc-theme-b sc-theme-c sc-theme-d sc-theme-e sc-theme-f sc-theme-g sc-theme-h sc-theme-dark';
		scutum.$html.removeClass(themes);
		if (theme !== '') {
			scutum.$html.addClass(theme);
		}
	});
	$('#sc-menu-scroll-to-active')
		.on('ifChecked', function () {
			scutum.$sidebarMain.addClass('sc-js-scroll-to-active')
		})
		.on('ifUnchecked', function () {
			scutum.$sidebarMain.removeClass('sc-js-scroll-to-active')
		});
	$('#sc-menu-accordion-mode')
		.on('ifChecked', function () {
			scutum.$sidebarMain.addClass('sc-js-accordion-mode')
		})
		.on('ifUnchecked', function () {
			scutum.$sidebarMain.removeClass('sc-js-accordion-mode')
		});
};
