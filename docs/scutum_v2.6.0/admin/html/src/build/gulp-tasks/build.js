//  -------------------- BUILD --------------------------
'use strict';

const pjson = require('../../package.json');
const nodeModules = require('../node_modules.json');
const nodeModulesFiles = nodeModules.files;
const buildDir = '../dist/';
const buildDirRTL = '../dist-rtl/';

function toTitleCase(str) {
	return str.replace(/\w\S*/g, function (txt) {
		return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
	});
}

module.exports = function (gulp, plugins, onError, del, exec) {
	const modules = {};
	modules.cleanup = function () {
		return del(
			[ buildDir + '**' ],
			{ force: true }
		)
	};
	modules.cleanupRTL = function () {
		return del(
			[ buildDirRTL + '**' ],
			{ force: true }
		)
	};
	modules.copyFiles = function (done) {
		gulp.src([
			'assets/**/*',
			'!assets/scss/**/*',
			'!assets/scss/**',
			'data/**/*',
			'handlebars/**/*',
			'favicon.ico',
			'manifest.json'
		], {base: './'})
			.pipe(gulp.dest(buildDir))
			.pipe(gulp.dest(buildDirRTL));
		done();
	};
	modules.copyNodeModules = function (done) {
		gulp.src(nodeModulesFiles, {base: './'})
			.pipe(gulp.dest(buildDir))
			.pipe(gulp.dest(buildDirRTL));
		done();
	};
	modules.addInfoToJS = function (done) {
		gulp.src([
			'assets/js/views/**/*.js',
			'!assets/js/views/**/*.min.js'
		], {cwd: buildDir})
			.pipe(plugins.wrapper({
				header: function (file) {
					const pName = toTitleCase(pjson.name.replace("_", " "));
					const fileName = file.path.replace(file.base, '');
					let fileNameHtml = fileName.replace('.js', '.html').replace(/\//g, '-').substring(1);

					if (fileName === 'dashboard_v1.js') {
						fileNameHtml = 'dashboard_v1.html';
					} else if (fileName === 'dashboard_v2.js') {
						fileNameHtml = 'dashboard_v2.html';
					}

					return '/*\n' +
						'*  ' + pName + '\n' +
						'*  @version v' + pjson.version + '\n' +
						'*  @author ' + pjson.author + '\n' +
						'*  @license ' + pjson.license + '\n' +
						'\n' +
						'*  used in: ' + fileNameHtml + '\n' +
						'*/\n' +
						'\n'
				}
			}))
			.pipe(gulp.dest(buildDir + 'assets/js/views/'))
			.pipe(gulp.dest(buildDirRTL + 'assets/js/views/'));
		done();
	};
	modules.generateHTML = function (cb) {
		// var exec = require('child_process').exec
		// exec('php build/generate_html.php')
		var spawn = require('child_process').spawn
		var command = spawn('php', ['build/generate_html.php'])
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
