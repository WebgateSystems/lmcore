// -------------------- RELEASE (generate package for themeforest) --------------------------

// get scutum version
const pjson = require('../../package.json');
const version = pjson.version;

// directories
const releaseDir = '../../../_release/' + version + '/';
const releaseSrcDir = releaseDir + '/scutum_v' + version + '/admin/html/src/';
const releaseDistDir = releaseDir + '/scutum_v' + version + '/admin/html/dist/';
const releaseDistRTLDir = releaseDir + '/scutum_v' + version + '/admin/html/dist-rtl/';
const releaseVuejsSrcDir = releaseDir + '/scutum_v' + version + '/admin/vuejs/';
const releaseDocDir = releaseDir + '/scutum_v' + version + '/documentation/';
const releaseLandingPageDir = releaseDir + '/scutum_v' + version + '/landing_page/';
const releaseLandingPageDirRTL = releaseDir + '/scutum_v' + version + '/landing_page_rtl/';
const releaseDemoDir = releaseDir + '/demo/';
const vuejsDir = '../../vuejs/';

module.exports = function (gulp, plugins, onError, del, exec) {
	const modules = {};
	modules.cleanup = function () {
		return del(
			[
				releaseDir + '**',
				releaseDemoDir + '**'
			],
			{ force: true }
		)
	};
	modules.copySrcFiles = function (done) {
		gulp.src([
			'**/*',
			'.*',
			'!{.idea, .idea/**}',
			'!{node_modules,node_modules/**}'
		], {base: './'})
			.pipe(gulp.dest(releaseSrcDir));
		done();
	};
	modules.copyDistFiles = function (done) {
		gulp.src([
			'**/*'
		], {cwd: '../dist'})
			.pipe(gulp.dest(releaseDistDir))
			.pipe(gulp.dest(releaseDemoDir + 'html/dist/'));
		done();
	};
	modules.copyDistFilesRTL = function (done) {
		gulp.src([
			'**/*'
		], {cwd: '../dist-rtl'})
			.pipe(gulp.dest(releaseDistRTLDir))
			.pipe(gulp.dest(releaseDemoDir + 'html/dist-rtl'));
		done();
	};
	modules.copyVueSrcFiles = function (done) {
		gulp.src([
			'**/*',
			'.*',
			'!{node_modules,node_modules/**}',
			'!{scutum-spa,scutum-spa/**}',
			'!{scutum-universal,scutum-universal/**}',
			'!{.idea, .idea/**}',
			'!{.nuxt, .nuxt/**}',
			'!{.https, .https/**}',
			'!package-lock.json',
			'!yarn.lock',
		], {cwd: vuejsDir + '/src'})
			.pipe(gulp.dest(releaseVuejsSrcDir + 'src/'))
		done();
	};
	modules.copyVueSrcFilesRTL = function (done) {
		gulp.src([
			'**/*',
			'.*',
			'!{node_modules,node_modules/**}',
			'!{scutum-spa,scutum-spa/**}',
			'!{scutum-universal,scutum-universal/**}',
			'!{.idea, .idea/**}',
			'!{.nuxt, .nuxt/**}',
			'!{.https, .https/**}',
			'!package-lock.json',
			'!yarn.lock',
		], {cwd: vuejsDir + '/src-rtl'})
			.pipe(gulp.dest(releaseVuejsSrcDir + 'src-rtl/'));
		done();
	};
	modules.copyVueSsrFiles = function (done) {
		gulp.src([
			'**/*',
			'.*'
		], {cwd: vuejsDir + 'src/scutum-universal/'})
			.pipe(gulp.dest(releaseDemoDir + 'scutum-universal/'));
		done();
	};
	modules.copyVueSpaFiles = function (done) {
		gulp.src([
			'**/*',
			'.*'
		], {cwd: vuejsDir + 'src/scutum-spa/'})
			.pipe(gulp.dest(releaseDemoDir + 'scutum-spa/'));
		done();
	};
	modules.copyVueSsrFilesRTL = function (done) {
		gulp.src([
			'**/*',
			'.*'
		], {cwd: vuejsDir + 'src-rtl/scutum-universal/'})
			.pipe(gulp.dest(releaseDemoDir + 'scutum-universal-rtl/'));
		done();
	};
	modules.copyVueSpaFilesRTL = function (done) {
		gulp.src([
			'**/*',
			'.*'
		], {cwd: vuejsDir + 'src-rtl/scutum-spa/'})
			.pipe(gulp.dest(releaseDemoDir + 'scutum-spa-rtl/'));
		done();
	};
	modules.copyVueLaravelFiles = function (done) {
		gulp.src([
			'**/*',
			'.*',
			'!{.idea, .idea/**}',
		], {cwd: vuejsDir + 'laravel-nuxt/'})
			.pipe(gulp.dest(releaseVuejsSrcDir + 'laravel-nuxt/'));
		done();
	};
	modules.copyVueSanctumFiles = function (done) {
		gulp.src([
			'**/*',
			'.*',
			'!{.idea, .idea/**}',
		], {cwd: vuejsDir + 'sanctum-nuxt/'})
			.pipe(gulp.dest(releaseVuejsSrcDir + 'sanctum-nuxt/'));
		done();
	};
	modules.copyLandingPage = function (done) {
		gulp.src([
			'index.html',
			'favicon.ico',
			'{assets,assets/**}',
			'!{node_modules,node_modules/**}',
			'!{.idea, .idea/**}',
		], {cwd: '../../../landing_page/'})
			.pipe(gulp.dest(releaseDemoDir + 'landing-page/'))
			.pipe(gulp.dest(releaseLandingPageDir));
		done();
	};
	modules.copyLandingPageRTL = function (done) {
		gulp.src([
			'index.html',
			'favicon.ico',
			'{assets,assets/**}',
			'!{node_modules,node_modules/**}',
			'!{.idea, .idea/**}',
		], {cwd: '../../../landing_page_rtl/'})
			.pipe(gulp.dest(releaseDemoDir + 'landing-page-rtl/'))
			.pipe(gulp.dest(releaseLandingPageDirRTL));
		done();
	};
	modules.copyDocumentation = function (done) {
		gulp.src([
			'**/*'
		], {cwd: '../../../documentation/'})
			.pipe(gulp.dest(releaseDocDir));
		done();
	};
	modules.generateDemoHTML = function (cb) {
		// exec('php build/generate_html_demo.php', cb);
		var spawn = require('child_process').spawn
		var command = spawn('php', ['build/generate_html_demo.php'])
		command.stdout.on('data', function (data) {
			console.log('stdout: ' + data.toString());
		});
		command.stderr.on('data', function (data) {
			console.log('stderr: ' + data.toString());
		});
		command.on('exit', function (code) {
			console.log('child process exited with code ' + code.toString());
		});
		cb()
	};
	return modules;
};
