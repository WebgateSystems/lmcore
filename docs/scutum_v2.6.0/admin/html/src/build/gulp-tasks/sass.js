'use strict';
module.exports = function (gulp, plugins, onError, browserSync, del) {
	const modules = {};
	const path = {
		src: './assets/scss/',
		dest: './assets/css/'
	};
	modules.main = function (done) {
		gulp.src(path.src + 'main.scss')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.sourcemaps.init())
			.pipe(plugins.sass())
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(plugins.sourcemaps.write())
			.pipe(gulp.dest(path.dest))
			.pipe(browserSync.stream())
			.pipe(plugins.cleanCss({
				level: {1: {specialComments: 0}}
			}))
			.pipe(plugins.rename('main.min.css'))
			.pipe(gulp.dest(path.dest));
		done();
	};
	modules.plugins = function (done) {
		gulp.src(path.src + 'plugins/*.scss')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.changed(path.dest + 'plugins', {extension: '.css'}))
			// .pipe(plugins.debug())
			.pipe(plugins.sass())
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(gulp.dest(path.dest + 'plugins'))
			.pipe(plugins.cleanCss({
				level: {1: {specialComments: 0}}
			}))
			.pipe(plugins.rename(function (path) {
				path.extname = ".min.css"
			}))
			.pipe(gulp.dest(path.dest + 'plugins'))
			.pipe(browserSync.reload({stream: true}));
		done();
	};
	modules.pluginsClean = function () {
		return del(path.dest + 'plugins/*.css')
	};
	modules.mdi = function (done) {
		gulp.src(path.src + 'components/mdi.scss')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.sass())
			.pipe(plugins.rename('materialdesignicons.css'))
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(gulp.dest(path.dest))
			.pipe(plugins.cleanCss({
				level: {
					1: {
						specialComments: 0
					}
				}
			}))
			.pipe(plugins.rename('materialdesignicons.min.css'))
			.pipe(gulp.dest(path.dest));
		done();
	};
	modules.error_page = function (done) {
		gulp.src(path.src + 'standalone/error_page.scss')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.sass())
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(gulp.dest(path.dest))
			.pipe(browserSync.stream())
			.pipe(plugins.cleanCss({
				level: {1: {specialComments: 0}}
			}))
			.pipe(plugins.rename('error_page.min.css'))
			.pipe(gulp.dest(path.dest));
		done();
	};
	modules.login_page = function (done) {
		let stream = gulp.src(path.src + 'standalone/login_page.scss')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.sass())
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(gulp.dest(path.dest))
			.pipe(browserSync.stream())
			.pipe(plugins.cleanCss({
				level: {1: {specialComments: 0}}
			}))
			.pipe(plugins.rename('login_page.min.css'))
			.pipe(gulp.dest(path.dest));
		done();
	};
	modules.themes = function (done) {
		gulp.src(path.src + 'themes/theme_*.scss')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.sass())
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(gulp.dest(path.dest + 'themes/'))
			.pipe(plugins.cleanCss({
				level: {
					1: {
						specialComments: 0
					}
				}
			}))
			.pipe(plugins.rename(function (path) {
				path.extname = ".min.css"
			}))
			.pipe(gulp.dest(path.dest + 'themes/'))
			.pipe(plugins.concat('themes_combined.min.css'))
			.pipe(gulp.dest(path.dest + 'themes/'));
		done();
	};
	modules.style_switcher = function (done) {
		gulp.src(path.src + 'plugins/style_switcher.scss')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.sass())
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(plugins.rename('plugins/style_switcher.css'))
			.pipe(gulp.dest(path.dest))
			.pipe(plugins.cleanCss({
				level: {
					1: {
						specialComments: 0
					}
				}
			}))
			.pipe(plugins.rename('plugins/style_switcher.min.css'))
			.pipe(gulp.dest(path.dest));
		done();
	};
	modules.rtl = function (done) {
		gulp.src(path.dest + 'main.css')
			.pipe(plugins.plumber({
				errorHandler: onError
			}))
			.pipe(plugins.sourcemaps.init())
			.pipe(plugins.sass())
			.pipe(plugins.autoprefixer({
				cascade: false
			}))
			.pipe(plugins.sourcemaps.write())
			.pipe(plugins.rtlcss())
			.pipe(plugins.rename({ suffix: '-rtl' }))
			.pipe(gulp.dest(path.dest))
			.pipe(browserSync.stream())
			.pipe(plugins.cleanCss({
				level: {1: {specialComments: 0}}
			}))
			.pipe(plugins.rename({ suffix: '.min' }))
			.pipe(gulp.dest(path.dest))
			.pipe(browserSync.stream())
		done();
	};
	return modules;
};
