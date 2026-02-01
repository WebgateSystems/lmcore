/*
*  Scutum Admin Template
*  Automated tasks ( gulp 4,  http://gulpjs.com/ )
*/
'use strict';

const gulp = require('gulp');
const plugins = require("gulp-load-plugins")({
	pattern: ['gulp-*', 'gulp.*'],
	replaceString: /\bgulp[-.]/
});
const del = require('del');
const chalk = require('chalk');
const chalk_error = chalk.bold.red;
const browserSync = require('browser-sync').create();
const onError = function (err) {
	console.log(chalk_error(err));
};
const exec = require('child_process').exec;

// gulp tasks
const _sass = require('./build/gulp-tasks/sass.js')(gulp, plugins, onError, browserSync, del);
const _js = require('./build/gulp-tasks/js.js')(gulp, plugins, onError);
const _serve = require('./build/gulp-tasks/serve.js')(gulp, plugins, browserSync);
const _others = require('./build/gulp-tasks/others.js')(gulp, plugins);

/* Available tasks (/build/gulp-tasks/*.js)

	SASS (sass.js)
		gulp sass:main - compile main stylesheet (assets/css/scutum.css|scutum.min.css)
		gulp sass:plugins - compile stylesheets for plugins
		gulp sass:error_page - compile error page stylesheet (error_page.css/error_page.min.css)
		gulp sass:login_page - compile login page stylesheet (login_page.css/login_page.min.css)
		gulp sass:themes - compile themes (assets/css/themes/theme_*.css) and concatenate all themes (themes_combined.min.css)
		gulp sass:style_switcher - compile style switcher stylesheet (style_switcher.css/style_switcher.min.css)
		gulp sass:rtl - custom RTL styles (custom.rtl.css/custom.rtl.min.css)

	JS (js.js)
		gulp js:vendor - common plugins used in Scutum template
		gulp js:uikit - custom build of UIkit components
		gulp js:minify - minify custom/common scripts

	SERVE (serve.js)
		gulp serve - synchronised browser testing - https://www.browsersync.io/docs/

	BUILD (build.js)
		gulp build - build dist folder (minified js/css and HTML files, require PHP and some customization in build/generate_html.php)

 */
// -------------------- SERVE TASKS --------------------
gulp.task('serve', _serve.bs);

// -------------------- SASS TASKS --------------------
// compile main stylesheet (scutum.css/scutum.min.css)
gulp.task('sass:main', _sass.main);
// compile plugins
gulp.task('sass:plugins', _sass.plugins);
// delete plugins
gulp.task('sass:plugins-del', _sass.pluginsClean);
// recreate plugins
const pluginsRecreate = gulp.series('sass:plugins-del', 'sass:plugins');
gulp.task('sass:plugins-recreate', pluginsRecreate, () => {
	return new Promise(function (resolve, reject) {
		pluginsRecreate.on('finish', resolve).on('error', reject)
	})
});
// css for error page
gulp.task('sass:error_page', _sass.error_page);
// css for login page
gulp.task('sass:login_page', _sass.login_page);
// compile themes
gulp.task('sass:themes', _sass.themes);
// css for style switcher
gulp.task('sass:style_switcher', _sass.style_switcher);
// css for style switcher
gulp.task('sass:rtl', _sass.rtl);

// -------------------- JS TASKS --------------------
gulp.task('js:vendor', _js.vendor); // common scripts/plugins used in Scutum template
gulp.task('js:uikit', _js.uikit); // custom build of UIkit components
gulp.task('js:minify', _js.minify); // minify common scripts

// -------------------- OTHERS TASKS --------------------
// mdi font to base64
gulp.task('others:mdiToBase64', _others.mdiToBase64);
// compile material design icons @mdi
gulp.task('others:mdiCSS', _sass.mdi);

// process all other tasks
const othersAll = gulp.parallel(
	'others:mdiToBase64',
	'others:mdiCSS'
);
gulp.task('others:all', othersAll, () => {
	return new Promise(function (resolve, reject) {
		othersAll.on('finish', resolve).on('error', reject)
	})
});

// -------------------- PROCESS ALL JS TASKS --------------------
const jsAll = gulp.series(
	gulp.parallel('js:vendor', 'js:uikit'),
	'js:minify'
);
gulp.task('js:all', jsAll, () => {
	return new Promise(function (resolve, reject) {
		jsAll.on('finish', resolve).on('error', reject)
	})
});

// -------------------- PROCESS ALL SASS TASKS --------------------
const sassAll = gulp.parallel(
	'sass:main',
	'sass:plugins',
	'sass:error_page',
	'sass:login_page',
	'sass:rtl'
);
gulp.task('sass:all', sassAll, () => {
	return new Promise(function (resolve, reject) {
		sassAll.on('finish', resolve).on('error', reject)
	})
});

// -------------------- ALL TASKS --------------------
const all = gulp.parallel(
	'js:all',
	'sass:all',
	'others:all'
);
gulp.task('all', all, () => {
	return new Promise(function (resolve, reject) {
		all.on('finish', resolve).on('error', reject)
	})
});

// -------------------- BUILD TASKS --------------------
const _build = require('./build/gulp-tasks/build.js')(gulp, plugins, onError, del, exec);
gulp.task('build:cleanup', _build.cleanup); // clear dist folder
gulp.task('build:cleanupRTL', _build.cleanupRTL); // clear dist-rtl folder
gulp.task('build:copyFiles', _build.copyFiles); // copy files
gulp.task('build:copyNodeModules', _build.copyNodeModules); // copy files from node_modules (scutum.bundles)
gulp.task('build:generateHTML', _build.generateHTML); // generate HTML pages
gulp.task('build:addInfoToJS', _build.addInfoToJS); // add info to JS files

gulp.task('build', gulp.series(
	gulp.parallel('build:cleanup', 'build:cleanupRTL'),
	gulp.parallel('all', 'build:generateHTML'),
	gulp.parallel('build:copyFiles', 'build:copyNodeModules'),
	'build:addInfoToJS'
));

// -------------------- RELEASE TASKS --------------------
const _release = require('./build/gulp-tasks/release.js')(gulp, plugins, onError, del, exec);
gulp.task('release:cleanup', _release.cleanup); // clear release folder
// HTML
gulp.task('release:copySrcFiles', _release.copySrcFiles); // copy src files
gulp.task('release:copyDistFiles', _release.copyDistFiles); // copy dist files
gulp.task('release:copyDistFilesRTL', _release.copyDistFilesRTL); // copy dist RTL files
// VUE.JS
gulp.task('release:copyVueSrcFiles', _release.copyVueSrcFiles); // copy vuejs src files
gulp.task('release:copyVueSpaFiles', _release.copyVueSpaFiles); // copy vuejs generated app (spa)
gulp.task('release:copyVueSsrFiles', _release.copyVueSsrFiles); // copy vuejs generated app (universal)
gulp.task('release:copyVueSrcFilesRTL', _release.copyVueSrcFilesRTL); // copy vuejs RTL src files
gulp.task('release:copyVueSpaFilesRTL', _release.copyVueSpaFilesRTL); // copy vuejs RTL generated app (spa)
gulp.task('release:copyVueSsrFilesRTL', _release.copyVueSsrFilesRTL); // copy vuejs RTL generated app (universal)
gulp.task('release:copyVueLaravelFiles', _release.copyVueLaravelFiles); // copy vuejs Laravel files
gulp.task('release:copyVueSanctumFiles', _release.copyVueSanctumFiles); // copy vuejs Laravel Sanctum files
// landing page
gulp.task('release:copyLandingPage', _release.copyLandingPage); // copy landing page
gulp.task('release:copyLandingPageRTL', _release.copyLandingPageRTL); // copy landing RTL page
// documentation
gulp.task('release:copyDocumentation', _release.copyDocumentation); // copy documentation

gulp.task('release:generateDemoHTML', _release.generateDemoHTML); // generate HTML files for demo

gulp.task('release', gulp.series(
	//gulp.parallel('build', 'release:cleanup'),
	'release:cleanup',
	gulp.parallel('release:copySrcFiles', 'release:copyDistFiles', 'release:copyDistFilesRTL'),
	gulp.parallel('release:copyVueSrcFiles', 'release:copyVueSpaFiles', 'release:copyVueSsrFiles', 'release:copyVueLaravelFiles', 'release:copyVueSanctumFiles'),
	gulp.parallel('release:copyVueSrcFilesRTL', 'release:copyVueSpaFilesRTL', 'release:copyVueSsrFilesRTL'),
	gulp.parallel('release:copyLandingPage', 'release:copyLandingPageRTL', 'release:copyDocumentation', 'release:generateDemoHTML')
));

// -------------------- DEFAULT TASK --------------------
gulp.task('default', all);
