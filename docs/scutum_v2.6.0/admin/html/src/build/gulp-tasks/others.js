module.exports = function (gulp, plugins) {
	const modules = {};
	// fonts to base64
	modules.mdiToBase64 = function (done) {
		gulp.src(['node_modules/@mdi/font/fonts/materialdesignicons-webfont.woff2', 'node_modules/@mdi/font/fonts/materialdesignicons-webfont.woff'])
			.pipe(plugins.inlineFonts({ name: 'Material Design Icons' }))
			.pipe(plugins.rename('mdi_fonts.css'))
			.pipe(gulp.dest('assets/css/fonts/'));
		done();
	};
	return modules;
};
