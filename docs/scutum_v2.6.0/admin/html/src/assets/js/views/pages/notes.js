var $notes = $('#sc-notes');

scutum.pages.notes = {};
scutum.pages.notes.init = function () {
	scutum.pages.notes.renderAll();
	scutum.pages.notes.preview();
};
scutum.pages.notes.renderAll = function () {
	scutum.require(['handlebars'], function () {
		$.when(scutum.handlebars.getPartial('note'), scutum.handlebars.getPartial('checklist')).done(function (p1, p2) {
			Handlebars.registerPartial('note', p1);
			Handlebars.registerPartial('checklist', p2);
			scutum.helpers.ajax('data/pages/notes.json', 'GET', 'json').then(function (result) {
				$notes
					.one('render.handlebars', function () {
						$notes.find('[data-sc-icheck]').each(function () {
							scutum.forms.common.icheck($(this));
						});
						// inverse colors for dark mode
						$('.sc-notes').find('.uk-card').each(function () {
							var $this = $(this)
							if($this.hasClass('md-bg--50')) {
								$this.removeClass('sc-theme-dark-inverse')
							}
						})
					}).hbRender('notes', {
						notes: result
					});
			});
		});
	}, false);
};
scutum.pages.notes.preview = function () {
	scutum.require(['handlebars'], function () {
		var $modal = $('#sc-note-preview');
		var notes = [];

		// init modal component
		var note_modal = UIkit.modal($modal);

		// get tasks
		scutum.helpers.ajax('data/pages/notes.json', 'GET', 'json').then(function (result) {
			notes = result;
		});

		$notes.on('click', '.sc-js-note-preview', function (e) {
			e.preventDefault();
			if (!$(e.target).closest('.sc-actions').length) {
				var note_id = $(this).attr('data-note-id');
				if (note_id) {
					scutum.helpers.findObjectByKey(notes, 'id', parseInt(note_id)).then(function (response) {
						if (response) {
							// modal content
							$modal.one('render.handlebars', function () {
								$modal.find('[data-sc-icheck]').each(function () {
									scutum.forms.common.icheck($(this));
								});
								note_modal.show();
							}).hbRender('note-modal', {
								title: response.title,
								body: response.body,
								labels: response.labels,
								dueDate: response.dueDate,
								user: response.user,
								checklist: response.checklist,
								folder: response.folder,
								cardColor: response.cardColor
							});
						}
					}).catch(function (error) { console.log('There has been a error: ' + error.message);throw error; });
				}
			}
		});
	});
};
