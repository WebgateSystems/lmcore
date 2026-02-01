scutum.forms.ckeditor = {};
scutum.forms.ckeditor.init = function () {
	if($('#wysiwyg-ckeditor').length) {
		var bundles = scutum.helpers.isRTL() ? ['ckeditor', 'ckeditorRTL'] : ['ckeditor']
		scutum.require(bundles, function () {
			var config = {
				fontColor: {
					colors: [
						{
							color: '#E53935',
							label: 'Red'
						},
						{
							color: '#8E24AA',
							label: 'Purple'
						},
						{
							color: '#1E88E5',
							label: 'Blue'
						},
						{
							color: '#43A047',
							label: 'Green'
						},
						{
							color: '#FFB300',
							label: 'Amber'
						},
						{
							color: '#795548',
							label: 'Brown'
						},
						{
							color: '#00ACC1',
							label: 'Cyan'
						}
					]
				},
				alignment: {
					options: ['left', 'right', 'center']
				},
				toolbar: ['undo', 'redo', '|', 'heading', 'alignment', 'fontColor', 'bold', 'italic', '|', 'bulletedList', 'numberedList', 'blockQuote', 'insertTable', '|', 'link', 'ImageUpload', 'MediaEmbed'],
				heading: {
					options: [
						{model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph'},
						{model: 'heading1', view: 'h1', title: 'Heading 1', class: 'ck-heading_heading1'},
						{model: 'heading2', view: 'h2', title: 'Heading 2', class: 'ck-heading_heading2'},
						{model: 'heading3', view: 'h3', title: 'Heading 3', class: 'ck-heading_heading3'},
						{model: 'heading4', view: 'h4', title: 'Heading 4', class: 'ck-heading_heading4'},
						{model: 'heading5', view: 'h5', title: 'Heading 5', class: 'ck-heading_heading5'}
					]
				},
				image: {
					toolbar: [ 'imageTextAlternative', '|', 'imageStyle:alignLeft', 'imageStyle:full', 'imageStyle:alignRight' ],
					styles: [
						'full',
						'alignLeft',
						'alignRight'
					]
				}
			};
			if(scutum.helpers.isRTL()) {
				config.language = 'ar'
			}
			ClassicEditor
				.create(document.querySelector('#wysiwyg-ckeditor'), config)
				.then(function (editor) {
					// console.log( editor );
					// console.log( Array.from( editor.ui.componentFactory.names() ) );
					$('#wysiwyg-ckeditor-modal')
						.on('beforeshow', function () {
							$('#wysiwyg-ckeditor-data').text(editor.getData())
						}).on('hidden', function () {
						$('#wysiwyg-ckeditor-data').text('');
					});
					$('#wysiwyg-ckeditor-data-show').on('click', function (e) {
						e.preventDefault();
						UIkit.modal('#wysiwyg-ckeditor-modal').show();
					})
				} )
				.catch(function (error) {
					console.error( error );
				});
		});
	}
};
scutum.forms.ckeditor.initEditor = function (config) {

}
