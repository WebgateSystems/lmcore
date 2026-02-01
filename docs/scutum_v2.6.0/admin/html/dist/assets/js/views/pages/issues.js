scutum.pages.issues = {};
scutum.pages.issues.init = function () {
	scutum.require(['tablesorter', 'tablesorter-widgets', 'tablesorter-pagecontrols'], function () {

		var $tsIssues = $("#ts-issues");

		// Initialize tablesorter
		$tsIssues.tablesorter({
			theme: 'scutum',
			widthFixed: true,
			widgets: ['zebra', 'filter'],
			headers: {
				0: {
					sorter: false,
					parser: false
				}
			}
		})
		.appendTablesorterPagerControls({
			sizes: [10, 20, 50, 100],
			initialSize: 10,
			classControls: "tablesorter-pager-scutum",
			labelFirst: "<span class='mdi mdi-chevron-double-left'></span>",
			labelPrev: "<span class='mdi mdi-chevron-left'></span>",
			labelNext: "<span class='mdi mdi-chevron-right'></span>",
			labelLast: "<span class='mdi mdi-chevron-double-right'></span>",
			controlsOutput: '<div class="tablesorter-page-nav" dir="ltr">{first}{prev}{display}{next}{last}</div><div>{size}</div>'
		});

		$('.ts-checkAll, .ts-checkbox').iCheck({
			checkboxClass: 'sc-icheckbox',
			radioClass: 'sc-iradio',
			increaseArea: '20%'
		});
		// select/unselect table rows
		$('.ts-checkAll')
			.on('ifChecked',function() {
				$tsIssues
					.find('.ts-checkbox')
					// check all checkboxes in table
					.prop('checked',true)
					.iCheck('update')
					// add highlight to row
					.closest('tr')
					.addClass('sc-row-highlight');
			})
			.on('ifUnchecked',function() {
				$tsIssues
					.find('.ts-checkbox')
					// uncheck all checkboxes in table
					.prop('checked',false)
					.iCheck('update')
					// remove highlight from row
					.closest('tr')
					.removeClass('sc-row-highlight');
			});

		// select/unselect table row
		$tsIssues.find('.ts-checkbox')
			.on('ifUnchecked',function() {
				$(this).closest('tr').removeClass('sc-row-highlight');
				$('.ts-checkAll').prop('checked',false).iCheck('update');
			})
			.on('ifChecked',function() {
				$(this).closest('tr').addClass('sc-row-highlight');
			});

	}, false);
};
