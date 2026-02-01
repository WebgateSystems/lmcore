var $taskBoard = $('#sc-task-board');
var tasks = [];

scutum.pages.taskBoard = {};
scutum.pages.taskBoard.init = function () {
	// lists drag&drop
	scutum.pages.taskBoard.listsDragDrop();
	// cards drag&drop
	scutum.pages.taskBoard.cardsDragDrop();
	// task modal
	scutum.pages.taskBoard.taskModal();
	// list shrink
	scutum.pages.taskBoard.list.shrink();
	// list expand
	scutum.pages.taskBoard.list.expand();
	// commands
	scutum.pages.taskBoard.list.addCard();
};
scutum.pages.taskBoard.cardsDragDrop = function () {
	scutum.require(['dragula'], function () {
		var drake = dragula($('.sc-task-list-cards').toArray());

		var containers = drake.containers;
		var length = containers.length;

		for (var i = 0; i < length; i++) {
			$(containers[i]).addClass('dragula dragula-vertical');
		}

		drake.on('drag', function (el, source) {
			$(el).addClass('sc-mirror-el');
		});
		drake.on('dragend', function (el) {
			$(el).removeClass('sc-mirror-el');
		});

		drake.on('drop', function (el, target, source, sibling) {
			console.log(el);
			console.log(target);
			console.log(source);
		})
	});
};
scutum.pages.taskBoard.listsDragDrop = function () {
	scutum.require(['dragula'], function () {
		var drake = dragula($('.sc-task-board').toArray(), {
			direction: 'horizontal',
			moves: function (el, container, handle) {
				return $(handle).closest('.dragula-handle-el').length;
			}
		});

		var containers = drake.containers;
		var length = containers.length;

		for (var i = 0; i < length; i++) {
			$(containers[i]).addClass('dragula dragula-handle');
		}

		drake.on('drop', function (el, target, source, sibling) {
			console.log(el);
			console.log(target);
			console.log(source);
		})
	});
};
scutum.pages.taskBoard.list = {
	'shrink': function () {
		$taskBoard.on('click', '.sc-js-list-collapse', function (e) {
			e.preventDefault();
			var $list = $(this).closest('.sc-task-list');
			$list.addClass('sc-task-list-collapsed');
			scutum.helpers.hideDuringTransform($list);
		})
	},
	'expand': function () {
		$taskBoard.on('click', '.sc-js-list-expand', function (e) {
			e.preventDefault();
			var $list = $(this).closest('.sc-task-list');
			$list.removeClass('sc-task-list-collapsed');
			scutum.helpers.hideDuringTransform($list);
		})
	}
};
scutum.pages.taskBoard.taskModal = function () {
	scutum.require(['handlebars'], function () {
		var $modal = $('#sc-task-modal');
		var $modal_hb_content = $('#sc-hb-task-modal');
		// init modal component
		var task_modal = UIkit.modal($modal);
		// get tasks
		scutum.helpers.ajax('data/pages/tasks.json', 'GET', 'json').then(function (result) {
			tasks = result;
		}).catch(function (error) { console.log('There has been a error: ' + error.message); throw error; });
		scutum.$body.on('click', '.sc-task-card', function () {
			var task_id = $(this).attr('data-task-id');
			if (task_id) {
				scutum.helpers.findObjectByKey(tasks, 'id', parseInt(task_id)).then(function (response, reject) {
					if (response) {
						// modal content
						$modal_hb_content.one('render.handlebars', function (template, data) {
							task_modal.show();
						}).hbRender('task-modal', {
							title: response.title,
							date: response.date,
							list: response.list_long,
							description: response.description,
							tags: response.tags,
							assignee: response.assignee,
							progress: response.progress
						});
					}
				});
			}
		});
	}, false);
};
scutum.pages.taskBoard.list.addCard = function() {
	scutum.require(['handlebars', 'flatpickr'], function () {
		// add card modal
		var $modal = $('#sc-task-board-card-add-modal');
		var task_modal = UIkit.modal($modal, {
			bgClose: false
		});
		UIkit.util.on('#sc-task-board-card-add-modal', 'shown', function () {
			$('#card-add-title').focus();
			$('#card-add-tags').trigger('change');
			$('#card-add-assignee').trigger('change');
		});
		// datepicker
		flatpickr("#card-add-due-date", {
			dateFormat: "d/m/Y",
			minDate: moment().format('DD/MM/YYYY')
		});
		// multiselect
		$("#card-add-tags").select2({
			placeholder: "Select tags",
			closeOnSelect: false
		});
		$("#card-add-assignee").select2({
			placeholder: "Select assignee",
			closeOnSelect: false
		});

		var $list = null;
		var list_name = null;
		var list_long = '';
		scutum.$body.on('click', '.sc-js-card-add-modal', function () {
			var $this = $(this);
			$list = $this.closest('.sc-task-list');
			list_name = $list.attr('data-list-name');
			switch (list_name) {
				case 'to_do':
					list_long = 'To Do';
					break;
				case 'in_progress':
					list_long = 'In Progress';
					break;
				case 'testing':
					list_long = 'Testing';
					break;
				case 'done':
					list_long = 'Done';
					break;
				default:
					list_long = '';
			}
			task_modal.show()
		});

		scutum.$body.on('click', '#sc-js-card-add', function (e) {
			e.preventDefault();
			var data = {
				id: Math.floor((Math.random() * 1000) + 100),
				list: list_name,
				list_long: list_long,
				title: $('#card-add-title').val(),
				date: $('#card-add-due-date').val(),
				tags: $('#card-add-tags').val(),
				description: $('#card-add-description').val(),
				assignee: $('#card-add-assignee').val()
			};
			$list
				.children('.sc-task-list-cards')
				.one('render.handlebars', function () {
					task_modal.hide();
					tasks.push(data);
					// clear values
					$('#card-add-title').val('');
					$('#card-add-due-date').val('');
					$('#card-add-tags').val(null).trigger('change');
					$('#card-add-description').val('');
					$('#card-add-assignee').val(null).trigger('change');
				})
				.hbRender('task-card-add', {
					id: data.id,
					title: data.title,
					description: data.description,
					date: data.date,
					tags: data.tags,
					assignee: data.assignee,
					list: data.list,
					list_long: data.list_long,
				}, true);
		})
	}, false);
};
