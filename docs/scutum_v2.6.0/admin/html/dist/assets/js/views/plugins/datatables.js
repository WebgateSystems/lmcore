scutum.plugins.dataTables = {};
scutum.plugins.dataTables.init = function () {
	scutum.require(['datatables'], function () {
		// zero configuration
		scutum.plugins.dataTables.basic();
		// vertical scroll
		scutum.plugins.dataTables.scrollV();
		// columns toggle
		scutum.plugins.dataTables.columnsToggle();
		// buttons
		scutum.plugins.dataTables.buttons();
	}, false);
};
scutum.plugins.dataTables.basic = function () {
	$('#sc-dt-basic').DataTable();
};
scutum.plugins.dataTables.scrollV = function () {
	$('#sc-dt-scroll-v').DataTable({
		"scrollY": "200px",
		"scrollCollapse": true,
		"paging": false,
		responsive: {
			details: {
				display: $.fn.dataTable.Responsive.display.modal({
					header: function (row) {
						var data = row.data();
						return 'Details for ' + data[0] + ' ' + data[1];
					}
				}),
				renderer: $.fn.dataTable.Responsive.renderer.tableAll({
					tableClass: 'table'
				})
			}
		}
	});
};
scutum.plugins.dataTables.columnsToggle = function () {
	var table = $('#sc-dt-columns-toggle').DataTable({
		"pagingType": "full_numbers"
	});

	$('.sc-js-dt-column-toggle')
		.on('ifChecked', function () {
			// Get the column API object
			var column = table.column($(this).val());
			// show column
			column.visible(true);
		})
		.on('ifUnchecked', function () {
			// Get the column API object
			var column = table.column($(this).val());
			// show column
			column.visible(false);
		});
};
scutum.plugins.dataTables.buttons = function () {
	// https://datatables.net/extensions/buttons/
	scutum.require(['datatables-buttons'], function () {
		var table = $('#sc-dt-buttons-table').DataTable({
			buttons: [
				{
					extend: "copy",
					className: "sc-button",
					text: 'Copy'
				},
				{
					extend: "csv",
					className: "sc-button",
					text: 'CSV '
				},
				{
					extend: "excel",
					className: "sc-button",
					text: 'Excel '
				},
				{
					extend: "pdf",
					className: "sc-button sc-button-icon",
					text: '<i class="mdi mdi-file-pdf md-color-red-800"></i>'
				},
				{
					extend: "print",
					className: "sc-button sc-button-icon",
					text: '<i class="mdi mdi-printer"></i>',
					title: 'Custom Title',
					messageTop: 'Custom message on the top',
					messageBottom: 'Custom message on the bottom',
					autoPrint: true
				}
			]
		});
		// append buttons to container above datatable
		table.buttons().container().appendTo($('#sc-dt-buttons'));
	}, false);
};
