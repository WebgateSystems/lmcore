'use strict';
const src = {
	'vendor': [
		// jquery
		"node_modules/jquery/dist/jquery.js",
		// moment
		"node_modules/moment/moment.js",
		// jquery.debouncedresize
		// "assets/js/custom/jquery.debouncedresize.js",
		// Accelerated JavaScript animation (velocity)
		"node_modules/velocity-animate/velocity.js",
		"node_modules/velocity-animate/velocity.ui.js",
		// ripple effect
		"node_modules/node-waves/dist/waves.js",
		// actual dimensions
		"node_modules/jquery.actual/jquery.actual.min.js"
	],
	'uikit': [
		// uikit core
		"node_modules/uikit/dist/js/uikit.js",
		// uikit icons
		"node_modules/uikit/dist/js/uikit-icons.js",
		// uikit components
		// "node_modules/uikit/dist/js/components/countdown.js",
		// "node_modules/uikit/dist/js/components/filter.js",
		// "node_modules/uikit/dist/js/components/lightbox.js",
		// "node_modules/uikit/dist/js/components/notification.js",
		// "node_modules/uikit/dist/js/components/slider.js",
		// "node_modules/uikit/dist/js/components/sortable.js",
		// "node_modules/uikit/dist/js/components/tooltip.js",
		// "node_modules/uikit/dist/js/components/upload.js",
		// uikit customizations
		"assets/js/vendor/uikit-custom.js"
	]
};

module.exports = function (gulp, plugins, onError) {
	const modules = {};
	modules.vendor = function (done) {
		gulp.src(src.vendor)
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.concat('vendor.js'))
			.pipe(gulp.dest('assets/js/'))
			.pipe(plugins.uglify({
				mangle: true
			}))
			.pipe(plugins.rename('vendor.min.js'))
			.pipe(plugins.size({
				showFiles: true
			}))
			.pipe(gulp.dest('assets/js/'));
		done();
	};
	modules.uikit = function (done) {
		let stream = gulp.src(src.uikit)
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.concat('uikit.js'))
			.pipe(gulp.dest('assets/js/'))
			.pipe(plugins.uglify({
				mangle: true
			}))
			.pipe(plugins.rename('uikit.min.js'))
			.pipe(plugins.size({
				showFiles: true
			}))
			.pipe(gulp.dest('assets/js/'));
		done();
	};
	modules.minify = function (done) {
		gulp.src([
			'assets/js/**/*.js',
			'handlebars/*.js',
			'!assets/js/**/*.min.js',
			'!assets/js/uikit.js',
			'!assets/js/vendor.js',
			'!assets/js/vendor/ckeditor/**/*.js'
		])
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.uglify({
				mangle: true
			}))
			.pipe(plugins.rename({
				extname: ".min.js"
			}))
			.pipe(gulp.dest(function (file) {
				return file.base;
			}));
		done();
	};
	return modules;
};
