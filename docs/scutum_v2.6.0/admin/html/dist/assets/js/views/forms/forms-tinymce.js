scutum.forms.tinymce = {};
scutum.forms.tinymce.init = function () {
	if($('#wysiwyg-tinymce').length) {
		var bundles = scutum.helpers.isRTL() ? ['tinymce', 'tinymceRTL'] : ['tinymce']
		scutum.require(bundles, function () {
			tinymce.baseURL = 'assets/js/vendor/tinymce';
			tinymce.suffix = '.min';
			var config = {
				selector: "#wysiwyg-tinymce",
				height: 480,
				plugins: [
					"advlist autolink lists link image charmap print preview anchor",
					"searchreplace visualblocks code fullscreen",
					"insertdatetime media table paste"
				],
				toolbar: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent | link image",
				relative_urls: false,
				remove_script_host: false,
				font_formats: 'Andale Mono=andale mono,times; Arial=arial,helvetica,sans-serif; Arial Black=arial black,avant garde; Book Antiqua=book antiqua,palatino; Comic Sans MS=comic sans ms,sans-serif; Courier New=courier new,courier; Georgia=georgia,palatino; Helvetica=helvetica; Impact=impact,chicago; Symbol=symbol; Roboto=roboto,arial,sans-serif; Symbol=symbol; Tahoma=tahoma,arial,helvetica,sans-serif; Terminal=terminal,monaco; Times New Roman=times new roman,times; Trebuchet MS=trebuchet ms,geneva; Verdana=verdana,geneva; Webdings=webdings; Wingdings=wingdings,zapf dingbats',
			}
			if(scutum.helpers.isRTL()) {
				config.language = 'ar'
				config.directionality = 'rtl'
			}
			tinymce.init(config)
		},
			false
		)
	}
};
