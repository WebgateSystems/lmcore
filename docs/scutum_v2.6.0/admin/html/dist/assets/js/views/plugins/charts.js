scutum.plugins.charts = {};
scutum.plugins.charts.init = function () {
	// billboard.js
	scutum.require(['d3', 'billboard'], function () {
		// area chart
		scutum.plugins.charts.bb.areaChart();
		// bar chart
		scutum.plugins.charts.bb.barChart();
		// donut chart
		scutum.plugins.charts.bb.donutChart();
		// line chart
		scutum.plugins.charts.bb.lineChart();
		// radar chart
		scutum.plugins.charts.bb.radarChart();
		// scatter chart
		scutum.plugins.charts.bb.scatterChart();
	}, false);
	// chart.js
	scutum.require(['chartjs'], function () {
		// generate random data
		scutum.plugins.charts.cjs.helpers.srand(Date.now());
		// default options
		scutum.plugins.charts.cjs.defaults();
		// bar chart
		scutum.plugins.charts.cjs.barChart();
		// bar stacked chart
		scutum.plugins.charts.cjs.barStackedChart();
		// line chart
		scutum.plugins.charts.cjs.lineChart();
		// line interpolation chart
		scutum.plugins.charts.cjs.lineInterpolationChart();
		// line stepped chart
		scutum.plugins.charts.cjs.lineSteppedChart();
		// line points chart
		scutum.plugins.charts.cjs.linePointsChart();
		// area chart
		scutum.plugins.charts.cjs.areaChart();
		// area stacked chart
		scutum.plugins.charts.cjs.areaStackedChart();
		// doughnut chart
		scutum.plugins.charts.cjs.doughnutChart();
		// pie chart
		scutum.plugins.charts.cjs.pieChart();
		// polar area chart
		scutum.plugins.charts.cjs.polarAreaChart();
	});
};
// bilboard.js
scutum.plugins.charts.bb = {};
scutum.plugins.charts.bb.areaChart = function () {
	var chart = bb.generate({
		data: {
			columns: [
				["data1", 300, 350, 300, 0, 0, 0],
				["data2", 130, 100, 140, 200, 150, 50]
			],
			types: {
				data1: "area-spline",
				data2: "area"
			}
		},
		area: {
			linearGradient: true
		},
		color: {
			pattern: scutum.helpers.colors.multi
		},
		bindto: "#sc-charts-bb-area-chart"
	});
	// trigger resize on sidebar toggle
	scutum.$doc.on('sc-sidebar:toggle', function () {
		chart.resize();
	});
};
scutum.plugins.charts.bb.barChart = function () {
	var chart = bb.generate({
		data: {
			columns: [
				["data1", 30, 200, 100, 400, 150, 250],
				["data2", 130, 100, 140, 200, 150, 50]
			],
			type: "bar"
		},
		bar: {
			width: {
				ratio: 0.5
			}
		},
		color: {
			pattern: scutum.helpers.colors.multi
		},
		grid: {
			y: {
				show: true
			}
		},
		bindto: "#sc-charts-bb-bar-chart"
	});
	setTimeout(function () {
		chart.load({
			columns: [
				["data3", 130, -150, 200, 300, -200, 100]
			]
		});
	}, 1000);
	// trigger resize on sidebar toggle
	scutum.$doc.on('sc-sidebar:toggle', function () {
		chart.resize();
	});
};
scutum.plugins.charts.bb.donutChart = function () {
	var chart = bb.generate({
		data: {
			columns: [
				["data1", 30],
				["data2", 120]
			],
			type: "donut",
			onclick: function (d, i) {
				console.log("onclick", d, i);
			},
			onover: function (d, i) {
				console.log("onover", d, i);
			},
			onout: function (d, i) {
				console.log("onout", d, i);
			}
		},
		donut: {
			title: "Iris Petal Width"
		},
		color: {
			pattern: scutum.helpers.colors.multi
		},
		bindto: "#sc-charts-bb-donut-chart"
	});

	setTimeout(function () {
		chart.load({
			columns: [
				["setosa", 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.2, 0.1, 0.1, 0.2, 0.4, 0.4, 0.3, 0.3, 0.3, 0.2, 0.4, 0.2, 0.5, 0.2, 0.2, 0.4, 0.2, 0.2, 0.2, 0.2, 0.4, 0.1, 0.2, 0.2, 0.2, 0.2, 0.1, 0.2, 0.2, 0.3, 0.3, 0.2, 0.6, 0.4, 0.3, 0.2, 0.2, 0.2, 0.2],
				["versicolor", 1.4, 1.5, 1.5, 1.3, 1.5, 1.3, 1.6, 1.0, 1.3, 1.4, 1.0, 1.5, 1.0, 1.4, 1.3, 1.4, 1.5, 1.0, 1.5, 1.1, 1.8, 1.3, 1.5, 1.2, 1.3, 1.4, 1.4, 1.7, 1.5, 1.0, 1.1, 1.0, 1.2, 1.6, 1.5, 1.6, 1.5, 1.3, 1.3, 1.3, 1.2, 1.4, 1.2, 1.0, 1.3, 1.2, 1.3, 1.3, 1.1, 1.3],
				["virginica", 2.5, 1.9, 2.1, 1.8, 2.2, 2.1, 1.7, 1.8, 1.8, 2.5, 2.0, 1.9, 2.1, 2.0, 2.4, 2.3, 1.8, 2.2, 2.3, 1.5, 2.3, 2.0, 2.0, 1.8, 2.1, 1.8, 1.8, 1.8, 2.1, 1.6, 1.9, 2.0, 2.2, 1.5, 1.4, 2.3, 2.4, 1.8, 1.8, 2.1, 2.4, 2.3, 1.9, 2.3, 2.5, 2.3, 1.9, 2.0, 2.3, 1.8]
			]
		});
	}, 1500);

	setTimeout(function () {
		chart.unload({
			ids: "data1"
		});
		chart.unload({
			ids: "data2"
		});
	}, 2500);
	// trigger resize on sidebar toggle
	scutum.$doc.on('sc-sidebar:toggle', function () {
		chart.resize();
	});
};
scutum.plugins.charts.bb.lineChart = function () {
	var chart = bb.generate({
		data: {
			columns: [
				["data1", 30, 200, 100, 400, 150, 250],
				["data2", 50, 20, 10, 40, 15, 25]
			]
		},
		color: {
			pattern: scutum.helpers.colors.multi
		},
		grid: {
			x: {
				show: true
			},
			y: {
				show: true
			}
		},
		bindto: "#sc-charts-bb-line-chart"
	});

	setTimeout(function () {
		chart.load({
			columns: [
				["data1", 230, 190, 300, 500, 300, 400]
			]
		});
	}, 1000);

	setTimeout(function () {
		chart.load({
			columns: [
				["data3", 130, 150, 200, 300, 200, 100]
			]
		});
	}, 1500);

	setTimeout(function () {
		chart.unload({
			ids: "data1"
		});
	}, 2000);
	// trigger resize on sidebar toggle
	scutum.$doc.on('sc-sidebar:toggle', function () {
		chart.resize();
	});
};
scutum.plugins.charts.bb.radarChart = function () {
	var chart = bb.generate({
		data: {
			x: "x",
			columns: [
				["x", "Data A", "Data B", "Data C", "Data D", "Data E"],
				["data1", 330, 350, 200, 380, 150],
				["data2", 130, 100, 30, 200, 80],
				["data3", 230, 153, 85, 300, 250]
			],
			type: "radar",
			labels: true
		},
		radar: {
			axis: {
				max: 400
			},
			level: {
				depth: 4
			},
			direction: {
				clockwise: true
			}
		},
		color: {
			pattern: scutum.helpers.colors.multi
		},
		bindto: "#sc-charts-bb-radar-chart"
	});
	// trigger resize on sidebar toggle
	scutum.$doc.on('sc-sidebar:toggle', function () {
		chart.resize();
	});
};
scutum.plugins.charts.bb.scatterChart = function () {
	var chart = bb.generate({
		data: {
			xs: {
				setosa: "setosa_x",
				versicolor: "versicolor_x",
				virginica: "virginica_x"
			},
			columns: [
				["setosa_x", 3.5, 3, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.4, 3, 3, 4, 4.4, 3.9, 3.5, 3.8, 3.8, 3.4, 3.7, 3.6, 3.3, 3.4, 3, 3.4, 3.5, 3.4, 3.2, 3.1, 3.4, 4.1, 4.2, 3.1, 3.2, 3.5, 3.6, 3, 3.4, 3.5, 2.3, 3.2, 3.5, 3.8, 3, 3.8, 3.2, 3.7, 3.3],
				["versicolor_x", 3.2, 3.2, 3.1, 2.3, 2.8, 2.8, 3.3, 2.4, 2.9, 2.7, 2, 3, 2.2, 2.9, 2.9, 3.1, 3, 2.7, 2.2, 2.5, 3.2, 2.8, 2.5, 2.8, 2.9, 3, 2.8, 3, 2.9, 2.6, 2.4, 2.4, 2.7, 2.7, 3, 3.4, 3.1, 2.3, 3, 2.5, 2.6, 3, 2.6, 2.3, 2.7, 3, 2.9, 2.9, 2.5, 2.8],
				["setosa", 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.2, 0.1, 0.1, 0.2, 0.4, 0.4, 0.3, 0.3, 0.3, 0.2, 0.4, 0.2, 0.5, 0.2, 0.2, 0.4, 0.2, 0.2, 0.2, 0.2, 0.4, 0.1, 0.2, 0.2, 0.2, 0.2, 0.1, 0.2, 0.2, 0.3, 0.3, 0.2, 0.6, 0.4, 0.3, 0.2, 0.2, 0.2, 0.2],
				["versicolor", 1.4, 1.5, 1.5, 1.3, 1.5, 1.3, 1.6, 1, 1.3, 1.4, 1, 1.5, 1, 1.4, 1.3, 1.4, 1.5, 1, 1.5, 1.1, 1.8, 1.3, 1.5, 1.2, 1.3, 1.4, 1.4, 1.7, 1.5, 1, 1.1, 1, 1.2, 1.6, 1.5, 1.6, 1.5, 1.3, 1.3, 1.3, 1.2, 1.4, 1.2, 1, 1.3, 1.2, 1.3, 1.3, 1.1, 1.3]
			],
			type: "scatter"
		},
		axis: {
			x: {
				label: "Sepal.Width",
				tick: {
					fit: false
				}
			},
			y: {
				label: "Petal.Width"
			}
		},
		color: {
			pattern: scutum.helpers.colors.multi
		},
		bindto: "#sc-charts-bb-scatter-chart"
	});

	setTimeout(function () {
		chart.load({
			xs: {
				virginica: "virginica_x"
			},
			columns: [
				["virginica_x", 3.3, 2.7, 3.0, 2.9, 3.0, 3.0, 2.5, 2.9, 2.5, 3.6, 3.2, 2.7, 3.0, 2.5, 2.8, 3.2, 3.0, 3.8, 2.6, 2.2, 3.2, 2.8, 2.8, 2.7, 3.3, 3.2, 2.8, 3.0, 2.8, 3.0, 2.8, 3.8, 2.8, 2.8, 2.6, 3.0, 3.4, 3.1, 3.0, 3.1, 3.1, 3.1, 2.7, 3.2, 3.3, 3.0, 2.5, 3.0, 3.4, 3.0],
				["virginica", 2.5, 1.9, 2.1, 1.8, 2.2, 2.1, 1.7, 1.8, 1.8, 2.5, 2.0, 1.9, 2.1, 2.0, 2.4, 2.3, 1.8, 2.2, 2.3, 1.5, 2.3, 2.0, 2.0, 1.8, 2.1, 1.8, 1.8, 1.8, 2.1, 1.6, 1.9, 2.0, 2.2, 1.5, 1.4, 2.3, 2.4, 1.8, 1.8, 2.1, 2.4, 2.3, 1.9, 2.3, 2.5, 2.3, 1.9, 2.0, 2.3, 1.8]
			]
		});
	}, 1000);
	setTimeout(function () {
		chart.unload({
			ids: "setosa"
		});
	}, 2000);
	setTimeout(function () {
		chart.load({
			columns: [
				["virginica", 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.2, 0.1, 0.1, 0.2, 0.4, 0.4, 0.3, 0.3, 0.3, 0.2, 0.4, 0.2, 0.5, 0.2, 0.2, 0.4, 0.2, 0.2, 0.2, 0.2, 0.4, 0.1, 0.2, 0.2, 0.2, 0.2, 0.1, 0.2, 0.2, 0.3, 0.3, 0.2, 0.6, 0.4, 0.3, 0.2, 0.2, 0.2, 0.2]
			]
		});
	}, 3000);
	// trigger resize on sidebar toggle
	scutum.$doc.on('sc-sidebar:toggle', function () {
		chart.resize();
	});
};
// chart.js
scutum.plugins.charts.cjs = {};
scutum.plugins.charts.cjs.defaults = function () {
	Chart.defaults.global.defaultFontFamily = "'Roboto', 'Helvetica', 'Arial', sans-serif";
	Chart.defaults.global.defaultFontColor = "rgba(0,0,0,.87)";
	Chart.defaults.global.title.fontFamily = "'Roboto', 'Helvetica', 'Arial', sans-serif";
	Chart.defaults.global.title.fontColor = "rgba(0,0,0,.87)";
	Chart.defaults.global.title.fontSize = 14;
	Chart.defaults.global.title.fontStyle = '500';
	Chart.defaults.global.tooltips.titleMarginBottom = 10;
	Chart.defaults.global.tooltips.titleFontFamily = "'Roboto', 'Helvetica', 'Arial', sans-serif";
	Chart.defaults.global.tooltips.bodyFontFamily = "'Roboto', 'Helvetica', 'Arial', sans-serif";
	Chart.defaults.global.tooltips.footerFontFamily = "'Roboto', 'Helvetica', 'Arial', sans-serif";
	Chart.defaults.global.tooltips.cornerRadius = 4;
	Chart.defaults.global.tooltips.bodySpacing = 8;
	Chart.defaults.global.tooltips.caretSize = 4;
	Chart.defaults.global.tooltips.xPadding = 8;
	Chart.defaults.global.tooltips.yPadding = 8;
	Chart.defaults.global.legend.labels.boxWidth = 24;
	Chart.defaults.global.legend.labels.fontFamily = "'Roboto', 'Helvetica', 'Arial', sans-serif";
	Chart.defaults.global.legend.labels.fontColor = "rgba(0,0,0,.87)";
	if(scutum.$html.hasClass('sc-theme-dark')) {
		Chart.defaults.global.defaultFontColor = "rgba(255,255,255,.87)";
		Chart.defaults.global.title.fontColor = "rgba(255,255,255,.87)";
		Chart.defaults.global.legend.labels.fontColor = "rgba(255,255,255,.87)";
		Chart.defaults.scale.gridLines.color = "rgba(255,255,255,.2)";
	}
};
scutum.plugins.charts.cjs.helpers = {
	'srand': function (seed) {
		this._seed = seed;
	},
	'randomScalingFactor': function () {
		return Math.round(scutum.plugins.charts.cjs.helpers.randData(-100, 100));
	},
	'randData': function (min, max) {
		var seed = this._seed;
		min = min === undefined ? 0 : min;
		max = max === undefined ? 1 : max;
		this._seed = (seed * 9301 + 49297) % 233280;
		return min + (this._seed / 233280) * (max - min);
	},
	'transparentize': function (color, opacity) {
		var Color = Chart.helpers.color;
		var alpha = opacity === undefined ? 0.5 : 1 - opacity;
		return Color(color).alpha(alpha).rgbString();
	}
};
scutum.plugins.charts.cjs.barChart = function () {
	var color = Chart.helpers.color;
	var config = {
		type: 'bar',
		data: {
			labels: ['January', 'February', 'March', 'April', 'May', 'June'],
			datasets: [{
				label: 'Dataset 1',
				backgroundColor: color(scutum.helpers.colors.multi[0]).alpha(0.8).rgbString(),
				borderColor: scutum.helpers.colors.multi[0],
				borderWidth: 1,
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}, {
				label: 'Dataset 2',
				backgroundColor: color(scutum.helpers.colors.multi[1]).alpha(0.8).rgbString(),
				borderColor: scutum.helpers.colors.multi[1],
				borderWidth: 1,
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			legend: {
				position: 'top'
			},
			title: {
				display: true,
				text: 'Chart.js Bar Chart'
			}
		}
	};
	var $el = $('#sc-charts-cjs-bar-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart1 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart1.update();
	})
};
scutum.plugins.charts.cjs.barStackedChart = function () {
	var config = {
		type: 'bar',
		data: {
			labels: ['January', 'February', 'March', 'April', 'May', 'June'],
			datasets: [{
				label: 'Dataset 1',
				backgroundColor: scutum.helpers.colors.multi[1],
				stack: 'Stack 0',
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}, {
				label: 'Dataset 2',
				backgroundColor: scutum.helpers.colors.multi[3],
				stack: 'Stack 0',
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}, {
				label: 'Dataset 3',
				backgroundColor: scutum.helpers.colors.multi[0],
				stack: 'Stack 1',
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}]

		},
		options: {
			title: {
				display: true,
				text: 'Chart.js Bar Chart - Stacked'
			},
			tooltips: {
				mode: 'index',
				intersect: false
			},
			responsive: true,
			maintainAspectRatio: false,
			scales: {
				xAxes: [{
					stacked: true
				}],
				yAxes: [{
					stacked: true
				}]
			}
		}
	};
	var $el = $('#sc-charts-cjs-bar-stacked-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart2 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart2.update();
	})
};
scutum.plugins.charts.cjs.lineChart = function () {
	var config = {
		type: 'line',
		data: {
			labels: ['January', 'February', 'March', 'April', 'May', 'June'],
			datasets: [{
				label: 'My First dataset',
				backgroundColor: scutum.helpers.colors.multi[4],
				borderColor: scutum.helpers.colors.multi[4],
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				fill: false
			}, {
				label: 'My Second dataset',
				fill: false,
				backgroundColor: scutum.helpers.colors.multi[5],
				borderColor: scutum.helpers.colors.multi[5],
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			title: {
				display: true,
				text: 'Chart.js Line Chart'
			},
			tooltips: {
				mode: 'index',
				intersect: false
			},
			hover: {
				mode: 'nearest',
				intersect: true
			},
			scales: {
				xAxes: [{
					display: true,
					scaleLabel: {
						display: true,
						labelString: 'Month'
					}
				}],
				yAxes: [{
					display: true,
					scaleLabel: {
						display: true,
						labelString: 'Value'
					}
				}]
			}
		}
	};
	var $el = $('#sc-charts-cjs-line-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart3 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart3.update();
	})
};
scutum.plugins.charts.cjs.lineInterpolationChart = function () {
	var datapoints = [0, 20, 20, 60, 60, 120, NaN, 180, 120, 125, 105, 110, 170];
	var config = {
		type: 'line',
		data: {
			labels: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'],
			datasets: [{
				label: 'Cubic interpolation (monotone)',
				data: datapoints,
				borderColor: scutum.helpers.colors.multi[0],
				backgroundColor: 'rgba(0, 0, 0, 0)',
				fill: false,
				cubicInterpolationMode: 'monotone'
			}, {
				label: 'Cubic interpolation (default)',
				data: datapoints,
				borderColor: scutum.helpers.colors.multi[1],
				backgroundColor: 'rgba(0, 0, 0, 0)',
				fill: false
			}, {
				label: 'Linear interpolation',
				data: datapoints,
				borderColor: scutum.helpers.colors.multi[2],
				backgroundColor: 'rgba(0, 0, 0, 0)',
				fill: false,
				lineTension: 0
			}]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			title: {
				display: true,
				text: 'Chart.js Line Chart - Cubic interpolation mode'
			},
			tooltips: {
				mode: 'index'
			},
			scales: {
				xAxes: [{
					display: true,
					scaleLabel: {
						display: true
					}
				}],
				yAxes: [{
					display: true,
					scaleLabel: {
						display: true,
						labelString: 'Value'
					},
					ticks: {
						suggestedMin: -10,
						suggestedMax: 200
					}
				}]
			}
		}
	};
	var $el = $('#sc-charts-cjs-line-interpolation-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart4 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		for (var i = 0, len = datapoints.length; i < len; ++i) {
			datapoints[i] = Math.random() < 0.05 ? NaN : scutum.plugins.charts.cjs.helpers.randomScalingFactor();
		}
		window.cjsChart4.update();
	})
};
scutum.plugins.charts.cjs.lineSteppedChart = function () {
	var config = {
		type: 'line',
		steppedLine: true,
		data: {
			labels: ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5', 'Day 6'],
			datasets: [{
				label: 'steppedLine: true',
				steppedLine: true,
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				borderColor: scutum.helpers.colors.multi[5],
				fill: false
			}]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			title: {
				display: true,
				text: 'Step Before Interpolation'
			}
		}
	};
	var $el = $('#sc-charts-cjs-line-stepped-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart5 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart5.update();
	})
};
scutum.plugins.charts.cjs.linePointsChart = function () {
	var config = {
		type: 'line',
		data: {
			labels: ['January', 'February', 'March', 'April', 'May', 'June'],
			datasets: [{
				label: 'dataset - big points',
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				backgroundColor: scutum.helpers.colors.multi[0],
				borderColor: scutum.helpers.colors.multi[0],
				fill: false,
				borderDash: [5, 5],
				pointRadius: 15,
				pointHoverRadius: 25
			}, {
				label: 'dataset - individual point sizes',
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				backgroundColor: scutum.helpers.colors.multi[1],
				borderColor: scutum.helpers.colors.multi[1],
				fill: false,
				borderDash: [5, 5],
				pointRadius: [2, 4, 6, 18, 0, 12, 20]
			}, {
				label: 'dataset - large pointHoverRadius',
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				backgroundColor: scutum.helpers.colors.multi[2],
				borderColor: scutum.helpers.colors.multi[2],
				fill: false,
				pointHoverRadius: 30
			}, {
				label: 'dataset - large pointHitRadius',
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				backgroundColor: scutum.helpers.colors.multi[3],
				borderColor: scutum.helpers.colors.multi[3],
				fill: false,
				pointHitRadius: 20
			}]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			legend: {
				position: 'bottom'
			},
			hover: {
				mode: 'index'
			},
			scales: {
				xAxes: [{
					display: true,
					scaleLabel: {
						display: true,
						labelString: 'Month'
					}
				}],
				yAxes: [{
					display: true,
					scaleLabel: {
						display: true,
						labelString: 'Value'
					}
				}]
			},
			title: {
				display: true,
				text: 'Chart.js Line Chart - Different point sizes'
			}
		}
	};
	var $el = $('#sc-charts-cjs-line-points-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart6 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart6.update();
	})
};
scutum.plugins.charts.cjs.areaChart = function () {
	var config = {
		type: 'line',
		data: {
			labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
			datasets: [{
				label: 'My First dataset',
				backgroundColor: scutum.plugins.charts.cjs.helpers.transparentize(scutum.helpers.colors.multi[3]),
				borderColor: scutum.plugins.charts.cjs.helpers.transparentize(scutum.helpers.colors.multi[3]),
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				fill: 'start'
			}]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			title: {
				display: true,
				text: 'Chart.js - fill: start'
			}
		}
	};
	var $el = $('#sc-charts-cjs-area-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart7 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart7.update();
	})
};
scutum.plugins.charts.cjs.areaStackedChart = function () {
	var config = {
		type: 'line',
		data: {
			labels: ['January', 'February', 'March', 'April', 'May', 'June'],
			datasets: [{
				label: 'My First dataset',
				borderColor: scutum.helpers.colors.multi[0],
				backgroundColor: scutum.helpers.colors.multi[0],
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}, {
				label: 'My Second dataset',
				borderColor: scutum.helpers.colors.multi[1],
				backgroundColor: scutum.helpers.colors.multi[1],
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}, {
				label: 'My Third dataset',
				borderColor: scutum.helpers.colors.multi[2],
				backgroundColor: scutum.helpers.colors.multi[2],
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}, {
				label: 'My Third dataset',
				borderColor: scutum.helpers.colors.multi[3],
				backgroundColor: scutum.helpers.colors.multi[3],
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				]
			}]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			title: {
				display: true,
				text: 'Chart.js Line Chart - Stacked Area'
			},
			tooltips: {
				mode: 'index'
			},
			hover: {
				mode: 'index'
			},
			scales: {
				xAxes: [{
					scaleLabel: {
						display: true,
						labelString: 'Month'
					}
				}],
				yAxes: [{
					stacked: true,
					scaleLabel: {
						display: true,
						labelString: 'Value'
					}
				}]
			}
		}
	};
	var $el = $('#sc-charts-cjs-area-stacked-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart8 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart8.update();
	})
};
scutum.plugins.charts.cjs.doughnutChart = function () {
	var config = {
		type: 'doughnut',
		data: {
			datasets: [
				{
					data: [
						scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
						scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
						scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
						scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
						scutum.plugins.charts.cjs.helpers.randomScalingFactor()
					],
					backgroundColor: [
						scutum.helpers.colors.multi[0],
						scutum.helpers.colors.multi[1],
						scutum.helpers.colors.multi[2],
						scutum.helpers.colors.multi[3],
						scutum.helpers.colors.multi[4]
					],
					label: 'Dataset 1'
				}
			],
			labels: [
				'Blue',
				'Orange',
				'Green',
				'Purple',
				'Red'
			]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			legend: {
				position: 'right'
			},
			title: {
				display: true,
				text: 'Chart.js Doughnut Chart'
			},
			animation: {
				animateScale: true,
				animateRotate: true
			}
		}
	};
	var $el = $('#sc-charts-cjs-doughnut-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart9 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart9.update();
	})
};
scutum.plugins.charts.cjs.pieChart = function () {
	var config = {
		type: 'pie',
		data: {
			datasets: [{
				data: [
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor(),
					scutum.plugins.charts.cjs.helpers.randomScalingFactor()
				],
				backgroundColor: [
					scutum.helpers.colors.multi[0],
					scutum.helpers.colors.multi[1],
					scutum.helpers.colors.multi[2],
					scutum.helpers.colors.multi[3],
					scutum.helpers.colors.multi[4]
				],
				label: 'Dataset 1'
			}],
			labels: [
				'Blue',
				'Orange',
				'Green',
				'Purple',
				'Red'
			]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			legend: {
				position: 'right'
			},
			title: {
				display: true,
				text: 'Chart.js Pie Chart'
			}
		}
	};
	var $el = $('#sc-charts-cjs-pie-chart');
	var ctx = $el[0].getContext('2d');
	window.cjsChart10 = new Chart(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = scutum.plugins.charts.cjs.helpers.randomScalingFactor();
			});
		});
		window.cjsChart10.update();
	})
};
scutum.plugins.charts.cjs.polarAreaChart = function () {
	var color = Chart.helpers.color;
	var randomScalingFactor = function () {
		return Math.round(Math.random() * 100);
	};
	var config = {
		data: {
			datasets: [{
				data: [
					randomScalingFactor(),
					randomScalingFactor(),
					randomScalingFactor(),
					randomScalingFactor(),
					randomScalingFactor()
				],
				backgroundColor: [
					color(scutum.helpers.colors.multi[0]).alpha(0.6).rgbString(),
					color(scutum.helpers.colors.multi[1]).alpha(0.6).rgbString(),
					color(scutum.helpers.colors.multi[2]).alpha(0.6).rgbString(),
					color(scutum.helpers.colors.multi[3]).alpha(0.6).rgbString(),
					color(scutum.helpers.colors.multi[4]).alpha(0.6).rgbString()
				],
				label: 'My dataset'
			}],
			labels: [
				'Blue',
				'Orange',
				'Green',
				'Purple',
				'Red'
			]
		},
		options: {
			responsive: true,
			maintainAspectRatio: false,
			legend: {
				position: 'right'
			},
			title: {
				display: true,
				text: 'Chart.js Polar Area Chart'
			},
			scale: {
				ticks: {
					beginAtZero: true
				},
				reverse: false
			},
			animation: {
				animateRotate: false,
				animateScale: true
			}
		}
	};
	var $el = $('#sc-charts-cjs-polar-area-chart');
	var ctx = $el[0];
	window.cjsChart11 = new Chart.PolarArea(ctx, config);
	UIkit.scrollspy($el.parent('div'), {
		'delay': 500
	});
	$el.parent('div').on('inview', function () {
		config.data.datasets.forEach(function (piece, i) {
			piece.data.forEach(function (value, j) {
				config.data.datasets[i].data[j] = randomScalingFactor();
			});
		});
		window.cjsChart11.update();
	})
};
