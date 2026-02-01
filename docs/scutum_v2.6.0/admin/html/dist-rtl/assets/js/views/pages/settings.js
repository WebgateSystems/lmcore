scutum.pages.settings = {};
scutum.pages.settings.init = function () {
	// flags (select2 countries)
	scutum.require(['flagsCSS'], function () {});
	// colorpicker
	scutum.plugins.colorpicker.init();
};
