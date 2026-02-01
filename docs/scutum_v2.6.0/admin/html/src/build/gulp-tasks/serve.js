'use strict';

const config = {
	// http://www.browsersync.io/docs/options/#option-host
	// 'host': process.argv[3] === '--host' ? process.argv[4] : '',
	// http://www.browsersync.io/docs/options/#option-proxy
	// 'proxy': process.argv[5] === '--proxy' ? process.argv[6] : '',
	// https://browsersync.io/docs/options#option-open
	'open': false,
	// Don't show any notifications in the browser.
	'notify': false,
	// http://www.browsersync.io/docs/options/#option-port
	'port': 3101,
	// https://browsersync.io/docs/options#option-ui
	'ui': {
		'port': 3102
	}
};

var proxyIndex = process.argv.indexOf('--proxy')
if (proxyIndex !== -1) {
	config.proxy = process.argv[proxyIndex + 1]
} else {
	config.server = {
		baseDir: './'
	}
}

var hostIndex = process.argv.indexOf('--host')
if (hostIndex !== -1) {
	config.host = process.argv[hostIndex + 1]
}

module.exports = function (gulp, plugins, browserSync) {
	const modules = {};
	modules.bs = function () {
		browserSync.init(config);

		gulp.watch([
			'assets/scss/**/*.scss',
			'!assets/scss/plugins/*.scss',
			'!assets/scss/pages/error_page.scss',
			'!assets/scss/pages/login_page.scss'
		], gulp.series('sass:main'));

		gulp.watch([
			'assets/scss/plugins/*.scss'
		], gulp.series('sass:plugins'));

		gulp.watch([
			'assets/scss/themes/*.scss'
		], gulp.series('sass:themes')).on('change', browserSync.reload);

		gulp.watch([
			'assets/scss/standalone/error_page.scss'
		], gulp.series('sass:error_page'));

		gulp.watch([
			'assets/scss/standalone/login_page.scss'
		], gulp.series('sass:login_page'));

		gulp.watch([
			'assets/css/main.css'
		], gulp.series('sass:rtl'));

		gulp.watch([
			'*.php',
			'*.html',
			'assets/js/**/*.js',
			'!assets/js/**/*.min.js',
			'php/**/*.php',
			'!php/helpers/**/*.php'
		]).on('change', browserSync.reload);
	};
	return modules;
};
