scutum.dashboard = {};
scutum.dashboard.init = function () {
	scutum.require(['d3', 'billboard'], function () {
		// widget charts
		scutum.dashboard.charts.widgets();
		// traffic sources chart
		scutum.dashboard.charts.traffic();
		// best sellers chart
		scutum.dashboard.charts.sellers();
	}, false);
	// widget ram usage
	scutum.dashboard.memoryUsage();
	// unique visits map
	scutum.dashboard.map();
	// to-do list
	scutum.dashboard.todo();
	// reload card content
	scutum.dashboard.reloadCard();
	// country flags
	scutum.require(['flagsCSS'], function () {});
};
scutum.dashboard.charts = {};
scutum.dashboard.charts.widgets = function () {
	var $el = $('.sc-js-chart-widget');
	if ($el.length) {
		var widgetCharts = {};
		$el.each(function (index) {
			var $this = $(this);
			var chartData = $this.attr('data-chart-data');
			var data = ['data'];
			var color = $this.attr('data-chart-color');
			var x_ = $this.attr('data-chart-x');
			var x = ['x'];
			var x_format = 'MMMM';
			var date_;

			if (x_) {
				date_ = x_.split(',');
				for (var i = 1; i < date_[1]; i++) {
					if (date_[0] === '-') {
						x.push(moment().subtract(i, date_[2]).format('YYYY-MM-DD'));
					}
					if (date_[0] === '+') {
						x.push(moment().add(i, date_[2]).format('YYYY-MM-DD'));
					}
				}
				x_format = 'YYYY-MM-DD'
			} else {
				x = ['x', '2018-01-01', '2018-02-01', '2018-03-01', '2018-04-01', '2018-05-01', '2018-06-01']
			}

			JSON.parse(chartData).forEach(function (entry) {
				data.push(entry)
			});

			widgetCharts[index] = bb.generate({
				padding: {
					bottom: -10,
					left: -6,
					right: -5
				},
				data: {
					x: 'x',
					columns: [
						x,
						data
					],
					type: 'area'
				},
				legend: {
					show: false
				},
				transition: {
					duration: 0
				},
				point: {
					show: false
				},
				axis: {
					y: {
						show: false
					},
					x: {
						type: 'timeseries',
						tick: {
							format: function (x) {
								return moment(x).format(x_format);
							}
						},
						show: false
					}
				},
				color: {
					pattern: [color]
				},
				bindto: $this[0]
			});
			setTimeout(function() {
				widgetCharts[index].flush(true);
				scutum.helpers.sequenceShow.activate($this);
			},50);
		});
		// trigger resize on sidebar toggle
		scutum.$doc.on('sc-sidebar:toggle', function () {
			Object.keys(widgetCharts).forEach(function (key) {
				widgetCharts[key].flush(true);
			});
		});
	}
};
scutum.dashboard.charts.traffic = function () {
	var $el = $('.sc-js-traffic-sources');
	if ($el.length) {
		var traffic = bb.generate({
			data: {
				columns: [
					["Organic", 30],
					["Referral", 45],
					["Social", 25]
				],
				type: "donut"
			},
			donut: {
				title: "Jan 2018",
				padAngle: 0.1
			},
			transition: {
				duration: 0
			},
			legend: {
				position: 'right'
			},
			color: {
				pattern: scutum.helpers.colors.blue
			},
			bindto: $el[0]
		});
		traffic.flush(true);
		scutum.helpers.sequenceShow.activate($el);
		// trigger resize on sidebar toggle
		// scutum.$doc.on('sc-sidebar:toggle', function () {
		// 	traffic.resize();
		// });
	}
};
scutum.dashboard.charts.sellers = function () {
	var $el = $('.sc-js-best-sellers');
	if ($el.length) {
		scutum.require(['accounting'], function () {
			var bestSellers = bb.generate({
				data: {
					columns: [
						["Automotive", 2640.72],
						["Books", 4200],
						["Software", 1651.43],
						["Toys", 617.55],
						["Video Games", 1231.94]
					],
					type: "pie"
				},
				donut: {
					title: "2017"
				},
				legend: {
					position: 'right'
				},
				transition: {
					duration: 0
				},
				pie: {
					label: {
						ratio: 1.3
					},
					padding: 2
				},
				tooltip: {
					format: {
						value: function (value, ratio, id) {
							return accounting.formatMoney(value);
						}
					}
				},
				color: {
					pattern: scutum.helpers.colors.multi
				},
				bindto: $el[0]
			});
			bestSellers.flush(true);
			scutum.helpers.sequenceShow.activate($el);
			// trigger resize on sidebar toggle
			// scutum.$doc.on('sc-sidebar:toggle', function () {
			// 	bestSellers.resize();
			// });
		});
	}
};
scutum.dashboard.map = function () {
	var $el = $('#sc-js-map-visits');
	if ($el.length) {
		scutum.require(['jqvmap'], function () {
			$el.vectorMap({
				map: 'world_en',
				backgroundColor: '#f5f5f5',
				borderOpacity: 0.25,
				color: '#BDBDBD',
				colors: {
					br: scutum.helpers.colors.blue[1],
					us: scutum.helpers.colors.blue[0],
					au: scutum.helpers.colors.blue[2],
					pl: scutum.helpers.colors.blue[3],
					cn: scutum.helpers.colors.blue[1]
				},
				hoverColor: '#424242',
				selectedColor: '#424242'
			});
			var highlighted = null;
			$('.sc-js-map-table')
				.find('[data-region]')
				.on('mouseenter', function () {
					var region = $(this).attr('data-region');
					if (highlighted) {
						$el.vectorMap('unhighlight', highlighted);
					}
					$el.vectorMap('highlight', region);
					highlighted = region;
				})
				.on('mouseout', function () {
					if (highlighted) {
						$el.vectorMap('unhighlight', highlighted);
					}
				});
		}, false);
	}
};
scutum.dashboard.reloadCard = function () {
	$('.sc-js-card-reload').on('click', function () {
		var $this = $(this);
		var $card = $this.closest('.uk-card');
		if (!$card.hasClass('sc-card-minimized')) {
			scutum.cards.hideContent($this, true);
			setTimeout(function () {
				scutum.cards.showContent($this, true);
			}, 2000)
		}
	})
};
scutum.dashboard.memoryUsage = function () {
	var $el = $('.sc-js-ram-usage');
	if ($el.length) {
		var $bar = $el.find('.sc-progress-bar');
		setInterval(function () {
			$bar.css({
				'width': (Math.floor(Math.random() * 100) + 15) + '%'
			});
		}, 2000)
	}
};
scutum.dashboard.todo = function () {
	var $el = $('.sc-js-checklist');
	if ($el.length) {
		$el.each(function () {
			$(this).find('[data-sc-icheck]').each(function () {
				if ($(this).is(':checked')) {
					$(this).closest('.sc-list-group').addClass('sc-item-checked');
				}
				$(this).on('ifToggled', function (event) {
					$(this).closest('.sc-list-group').toggleClass('sc-item-checked');
				})
			});
		})
	}
};
