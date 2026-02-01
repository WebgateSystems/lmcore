scutum.dashboard = {};
scutum.dashboard.init = function () {
	scutum.require(['d3', 'billboard'], function () {
		scutum.dashboard.charts.revenue();
		scutum.dashboard.charts.emailSubscribers();
		scutum.dashboard.charts.returns();
		scutum.dashboard.charts.salesReport();
		scutum.dashboard.charts.referrals();
	}, false);
};
scutum.dashboard.charts = {};
scutum.dashboard.charts.revenue = function () {
	var $el = $('#sc-js-chart-revenue');
	if ($el.length) {
		var revenue = bb.generate({
			data: {
				x: "x",
				columns: [
					["x", "2019-01-01", "2019-02-01", "2019-03-01", "2019-04-01", "2019-05-01", "2019-06-01"],
					["data1", 42543, 65240, 52638, 73460, 46320, 52800]
				],
				types: {
					data1: "spline"
				},
				colors: {
					data1: scutum.helpers.colors.multi[0]
				}
			},
			axis: {
				x: {
					type: "timeseries",
					tick: {
						fit: true,
						format: "%b"
					}
				},
				y: {
					show: false
				}
			},
			grid: {
				x: {
					show: false
				},
				y: {
					show: false,
					lines: [
						{
							value: 54000,
							text: "Target"
						}
					]
				}
			},
			tooltip: {
				format: {
					title: function (d) {
						return moment(d).format('MMMM');
					},
					value: function (value, ratio, id) {
						if (id === 'data1') {
							return '$' + d3.format(',')(value);
						}
					}
				}
			},
			transition: {
				duration: 0
			},
			legend: {
				show: false
			},
			bindto: $el[0]
		});
		// trigger resize on sidebar toggle
		// scutum.$doc.on('sc-sidebar:toggle', function () {
		// 	revenue.resize();
		// });
	}
};
scutum.dashboard.charts.emailSubscribers = function () {
	var $el = $('#sc-js-chart-email-subscribers');
	if ($el.length) {
		var subscribers = bb.generate({
			data: {
				x: "x",
				columns: [
					["x", "2019-01-01", "2019-02-01", "2019-03-01", "2019-04-01", "2019-05-01", "2019-06-01"],
					["data1", 120, 72, 245, 181, 42, 212]
				],
				types: {
					data1: "bar"
				},
				colors: {
					data1: scutum.helpers.colors.multi[3]
				}
			},
			axis: {
				x: {
					type: "timeseries",
					tick: {
						fit: true,
						format: "%b"
					}
				},
				y: {
					show: false
				}
			},
			grid: {
				x: {
					show: false,
					lines: [
						{
							value: "2019-04-18",
							text: "New Campaign"
						}
					]
				},
				y: {
					show: false
				}
			},
			tooltip: {
				format: {
					title: function (d) {
						return moment(d).format('MMMM');
					}
				}
			},
			transition: {
				duration: 0
			},
			legend: {
				show: false
			},
			bindto: $el[0]
		});
		// trigger resize on sidebar toggle
		// scutum.$doc.on('sc-sidebar:toggle', function () {
		// 	subscribers.resize();
		// });
	}
};
scutum.dashboard.charts.returns = function () {
	var $el = $('#sc-js-chart-returns');
	if ($el.length) {
		var returns = bb.generate({
			data: {
				x: "x",
				columns: [
					["x", "2019-01-01", "2019-02-01", "2019-03-01", "2019-04-01", "2019-05-01", "2019-06-01"],
					["data1", 41, 18, 30, 21, 35, 22]
				],
				types: {
					data1: "line"
				},
				colors: {
					data1: scutum.helpers.colors.multi[1]
				}
			},
			axis: {
				x: {
					type: "timeseries",
					tick: {
						fit: true,
						format: "%b"
					}
				},
				y: {
					show: false
				}
			},
			grid: {
				x: {
					show: false
				},
				y: {
					show: false,
					lines: [
						{
							value: 24,
							text: "Target"
						}
					]
				}
			},
			tooltip: {
				format: {
					title: function (d) {
						return moment(d).format('MMMM');
					}
				}
			},
			transition: {
				duration: 0
			},
			legend: {
				show: false
			},
			bindto: $el[0]
		});
		// trigger resize on sidebar toggle
		// scutum.$doc.on('sc-sidebar:toggle', function () {
		// 	returns.resize();
		// });
	}
};
scutum.dashboard.charts.salesReport = function () {
	var salesReport;
	function generateChart (view, destroy) {
		if (destroy) {
			salesReport.destroy();
		}
		salesReport = bb.generate({
			data: {
				x: "x",
				xFormat: chartsData[view].xFormat,
				columns: [
					chartsData[view].x,
					chartsData[view].data
				],
				names: {
					data1: "Sale"
				},
				types: {
					data1: "bar"
				},
				colors: {
					data1: chartsData[view].color
				}
			},
			axis: {
				x: {
					type: "timeseries",
					tick: {
						fit: true,
						culling: chartsData[view].axis.x.culling,
						format: chartsData[view].axis.x.tick.format
					}
				},
				y: {
					show: true,
					tick: {
						format: function (x) { return d3.format("$,")(x); }
					}
				}
			},
			grid: {
				x: {
					show: false
				},
				y: {
					show: false
				}
			},
			bar: {
				width: chartsData[view].bar.width
			},
			transition: {
				duration: 0
			},
			tooltip: {
				format: {
					title: function (d) {
						return moment(d).format(chartsData[view].tooltip.title.format);
					},
					value: function (value, ratio, id) {
						if (id === 'data1') {
							return '$' + d3.format(',')(value);
						}
					}
				}
			},
			legend: {
				show: false
			},
			bindto: $el[0]
		});
		setTimeout(function () {
			salesReport.export("image/png", function (dataUrl) {
				$('#sc-chart-save-image').attr('href', dataUrl).attr('download', 'Sales-Report-' + Date.now() + '.png');
			});
		}, 200);
		// trigger resize on sidebar toggle
		scutum.$doc.on('sc-sidebar:toggle', function () {
			salesReport.flush(true);
		});
	}
	var chartsData = {
		hours: {
			xFormat: '%Y-%m-%d %H:%M',
			x: ['x',
				'2019-04-08 00:00',
				'2019-04-08 01:00',
				'2019-04-08 02:00',
				'2019-04-08 03:00',
				'2019-04-08 04:00',
				'2019-04-08 05:00',
				'2019-04-08 06:00',
				'2019-04-08 07:00',
				'2019-04-08 08:00',
				'2019-04-08 09:00',
				'2019-04-08 10:00',
				'2019-04-08 11:00',
				'2019-04-08 12:00',
				'2019-04-08 13:00',
				'2019-04-08 14:00',
				'2019-04-08 15:00',
				'2019-04-08 16:00',
				'2019-04-08 17:00',
				'2019-04-08 18:00',
				'2019-04-08 19:00',
				'2019-04-08 20:00',
				'2019-04-08 21:00',
				'2019-04-08 22:00',
				'2019-04-08 23:00',
				'2019-04-08 24:00'],
			data: ["data1", '220', '320', '280', '420', '600', '816', '1210.22', '1421.42', '1503.11', '1311', '1528', '1802.31', '1558.73', '1649.04', '1523.36', '1306.55', '2143.92', '2041.04', '1830.24', '1921', '1842', '1420', '842', '531.44'],
			axis: {
				x: {
					tick: {
						format: '%H',
						culling: true
					}
				}
			},
			tooltip: {
				title: {
					format: 'HH:mm'
				}
			},
			color: scutum.helpers.colors.multi[4],
			bar: {
				width: {
					ratio: 0.8,
					max: 24
				}
			}
		},
		week: {
			xFormat: '%Y-%m-%d',
			x: ['x', '2019-04-08', '2019-04-09', '2019-04-10', '2019-04-11', '2019-04-12', '2019-04-13', '2019-04-14'],
			data: ["data1", '220', '320', '280', '420', '600', '816', '1210.22'],
			axis: {
				x: {
					tick: {
						format: "%A",
						culling: false
					}
				}
			},
			tooltip: {
				title: {
					format: 'dddd'
				}
			},
			color: scutum.helpers.colors.multi[2],
			bar: {
				width: {
					ratio: 0.8,
					max: 48
				}
			}
		},
		months: {
			xFormat: '%Y-%m-%d',
			x: ['x', '2018-01-01', '2018-02-01', '2018-03-01', '2018-04-01', '2018-05-01', '2018-06-01', '2018-07-01', '2018-08-01', '2018-09-01', '2018-10-01', '2018-11-01', '2018-12-01'],
			data: ["data1", '140231', '160223', '130221', '180221', '200236', '214566', '190322', '201234', '140234', '152324', '210612', '280332'],
			axis: {
				x: {
					tick: {
						format: "%b",
						culling: false
					}
				}
			},
			tooltip: {
				title: {
					format: 'MMMM'
				}
			},
			color: scutum.helpers.colors.multi[0],
			bar: {
				width: {
					ratio: 0.8,
					max: 36
				}
			}
		},
		years: {
			xFormat: '%Y-%m-%d',
			x: ['x', '2013-01-01', '2014-01-01', '2015-01-01', '2016-01-01', '2017-01-01', '2018-01-01', '2019-01-01'],
			data: ["data1", '1324235.23', '1524236.83', '1842341.36', '2235433.27', '2114523.83', '2602362.44', '2834428.11'],
			axis: {
				x: {
					tick: {
						format: "%Y",
						culling: false
					}
				}
			},
			tooltip: {
				title: {
					format: 'YYYY'
				}
			},
			color: scutum.helpers.colors.multi[5],
			bar: {
				width: {
					ratio: 0.8,
					max: 48
				}
			}
		}
	};
	var $el = $('#sc-js-chart-sales-report');
	if ($el.length) {
		generateChart('months');
		// change view
		$('.sc-js-chart-view').on('click', function () {
			var $this = $(this);
			if (!$this.hasClass('uk-active')) {
				$this.addClass('uk-active').siblings().removeClass('uk-active');
				var view = $this.attr('data-view');
				generateChart(view, true);
			}
		})
	}
	$('#sc-chart-reload').on('click', function () {
		var $this = $(this);
		var $card = $this.closest('.uk-card');
		if (!$card.hasClass('sc-card-minimized')) {
			scutum.cards.hideContent($this, true);
			setTimeout(function () {
				scutum.cards.showContent($this, true);
			}, 1000)
		}
	});
};
scutum.dashboard.charts.referrals = function () {
	var $el = $('#sc-js-chart-referrals');
	if ($el.length) {
		var referrals = bb.generate({
			data: {
				columns: [
					["Google", 125234],
					["Bookmarks", 104234],
					["Facebook", 78342],
					["Envato", 41895],
					["Twitter", 23619],
					["Bing", 4268]
				],
				type: "donut"
			},
			transition: {
				duration: 0
			},
			legend: {
				position: 'right'
			},
			color: {
				pattern: scutum.helpers.colors.multi
			},
			bindto: $el[0]
		});
		// trigger resize on sidebar toggle
		// scutum.$doc.on('sc-sidebar:toggle', function () {
		// 	referrals.resize();
		// });
	}
};
