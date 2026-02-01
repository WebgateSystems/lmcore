scutum.plugins.dataGrid = {};
scutum.plugins.dataGrid.init = function () {
	scutum.require(['xhr-mock', 'tui-snippets', 'tui-pagination', 'tui-grid'], function () {
		tui.Grid.applyTheme('striped', {
			grid: {
				text: '#222'
			},
			cell: {
				normal: {
					border: '#e0e0e0',
					showVerticalBorder: true
				},
				disabled: {
					text: '#999'
				},
				head: {
					border: '#bdbdbd',
					background: '#eeeeee'
				},
				selectedHead: {
					background: '#e0e0e0'
				},
				focused: {
					border: "#1565C0"
				}
			},
			area: {
				summary: {
					border: '#bdbdbd'
				}
			}
		});
		// basic grid
		scutum.plugins.dataGrid.basic();
		// using summary
		scutum.plugins.dataGrid.summary();
		// input types
		scutum.plugins.dataGrid.inputTypes();
		// data source
		scutum.plugins.dataGrid.mock();
		scutum.plugins.dataGrid.dataSrc();
	}, false);
};
scutum.plugins.dataGrid.basic = function () {
	var grid = new tui.Grid({
		el: document.getElementById('sc-data-grid-basic'),
		scrollY: true,
		scrollX: scutum.helpers.mq.mediumMax(),
		usageStatistics: false,
		rowHeight: 35,
		rowHeaders: ['rowNum'],
		header: {
			height: 40
		},
		columns: [
			{
				header: 'Name',
				name: 'name'
			},
			{
				header: 'Artist',
				name: 'artist'
			},
			{
				header: 'Type',
				name: 'type'
			},
			{
				header: 'Release',
				name: 'release'
			},
			{
				header: 'Genre',
				name: 'genre'
			}
		],
		columnOptions: {
			minWidth: scutum.helpers.mq.mediumMax() ? 150 : 50
		}
	});
	grid.resetData(scutum.plugins.dataGrid.data.basic);
	grid.setBodyHeight('400');
	setTimeout(function () {
		grid.refreshLayout();
	}, 100);
};
scutum.plugins.dataGrid.summary = function () {
	var gridData = [];
	(function () {
		var _names = ["Evelyn Haynes", "Jonathan Butler", "Tillie Guerrero", "Erik Cobb", "Adele Gutierrez", "Beulah Carter", "Noah Vargas", "Helen Chambers", "Jean Taylor", "Gregory Lopez", "Inez Ray", "Nelle Gibson", "Jerry Barker", "Amanda Cole", "Annie Bates", "Lilly Barrett", "Bettie Manning", "Della Howard", "Jonathan Hunter", "Genevieve Mullins", "Lena Warner", "Flora Pratt", "Lily Osborne", "Adrian Yates", "Nettie Rios", "Kate Howell", "Mae Tyler", "Ethan Woods", "Myra Reese", "Rosalie Hogan", "Don Hogan", "Johanna Carter", "Sophie Wolfe", "Richard Chambers", "Scott Paul", "Bernard Oliver", "Clayton Munoz", "Celia Ferguson", "Beatrice Romero", "Harold Clarke", "Christina Guerrero", "Randall Parker", "Jesus Webb", "Francis Walker", "Andre Simmons", "Anne Cox", "Clifford Adkins", "Elizabeth Lane", "Fanny Daniels", "Maurice French", "Maggie Pierce", "Hettie Banks", "Eva Horton", "Thomas Henderson", "Dominic Bell", "Wesley Walton", "Lelia May", "Brett Johnson", "Dennis Woods", "Robert Barber", "Ethel Herrera", "Ralph McGee", "Russell Joseph", "Madge Webb", "Alexander Elliott", "Cody Blake", "Ricardo Vargas", "Dominic Thompson", "Eleanor Bailey", "Kyle Patterson", "George Rodgers", "Micheal Jensen", "Estelle Evans", "Nelle Greene", "Jean Rogers", "Andre Casey", "Bertha Wilkerson", "Wayne Garrett", "Gregory Allison", "Jay Torres", "Genevieve Hill", "Emily Wagner", "Adeline Ramsey", "Adele Cain", "Vernon Flowers", "Lou Owens", "Adam Blair", "Ina Hampton", "Ray Cain", "Lida Knight", "Ophelia Jackson", "Cornelia Ferguson", "Sean Henry", "Brett Elliott", "Billy Flores", "Jim Valdez", "Gavin Gray", "Bradley Dennis", "Leona Potter", "Agnes Flowers", "Alejandro Jacobs", "Victor Higgins", "Austin Moss", "Herbert Hanson", "Rhoda Morrison", "Hannah Wright", "Harriet Lawson", "Bertha Garrett", "Virginia Fletcher", "Beulah Gill", "Ricky Rios", "Ethan Washington", "Landon Stewart", "Lucile Holland", "Arthur Frank", "Benjamin Boyd", "Stanley Lloyd", "Douglas Valdez", "Hilda Ruiz", "Lloyd Palmer"];
		for (var i = 0; i <= 120; i++) {
			gridData.push({
				c1: _names[i],
				c2: ((i + 5) % 8) * 100 + i,
				c3: ((i + 3) % 7) * 60
			});
		}
	})();

	var grid = new tui.Grid({
		el: document.getElementById('sc-data-grid-summary'),
		scrollX: scutum.helpers.mq.mediumMax(),
		bodyHeight: 300,
		usageStatistics: false,
		rowHeaders: ['rowNum'],
		data: gridData,
		columnOptions: {
			width: 100,
			minWidth: scutum.helpers.mq.mediumMax() ? 150 : 50
		},
		columns: [
			{
				header: 'User ID',
				name: 'c1',
				align: 'center',
				editor: 'text'
			},
			{
				header: 'Score',
				name: 'c2',
				className: 'clickable',
				editor: 'text'
			},
			{
				header: 'Item Count',
				name: 'c3',
				editor: 'text'
			}
		],
		summary: {
			height: 50,
			position: 'bottom', // or 'top'
			columnContent: {
				c2: {
					template: function (valueMap) {
						return '<div class="uk-text-center">MAX: ' + valueMap.max + '<br>MIN: ' + valueMap.min + '</div>';
					}
				},
				c3: {
					template: function (valueMap) {
						return '<div class="uk-text-center">TOTAL: ' + valueMap.sum + '<br>AVG: ' + valueMap.avg.toFixed(2) + '</div>';
					}
				}
			}
		}
	});
};
scutum.plugins.dataGrid.inputTypes = function () {
	function _instanceof(left, right) { if (right != null && typeof Symbol !== "undefined" && right[Symbol.hasInstance]) { return right[Symbol.hasInstance](left); } else { return left instanceof right; } }
	function _classCallCheck(instance, Constructor) { if (!_instanceof(instance, Constructor)) { throw new TypeError("Cannot call a class as a function"); } }
	function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }
	function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }
	var CustomTextEditor = function () {
		function CustomTextEditor(props) {
			_classCallCheck(this, CustomTextEditor);
			var el = document.createElement('input');
			var maxLength = props.columnInfo.editor.options.maxLength;
			el.type = 'text';
			el.maxLength = maxLength;
			el.value = String(props.value);
			this.el = el;
		}
		_createClass(CustomTextEditor, [{
			key: "getElement",
			value: function getElement() {
				return this.el;
			}
		},
		{
			key: "getValue",
			value: function getValue() {
				return this.el.value;
			}
		},
		{
			key: "mounted",
			value: function mounted() {
				this.el.select();
			}
		}]);
		return CustomTextEditor;
	}();

	var grid = new tui.Grid({
		el: document.getElementById('sc-data-grid-input-types'),
		scrollX: scutum.helpers.mq.mediumMax(),
		scrollY: false,
		usageStatistics: false,
		columns: [
			{
				header: 'Name',
				name: 'name',
				onBeforeChange: function (ev) {
					console.log('Before change:' + ev);
					ev.stop();
				},
				onAfterChange: function (ev) {
					console.log('After change:' + ev);
				},
				editor: 'text'
			},
			{
				header: 'Artist',
				name: 'artist',
				onBeforeChange: function (ev) {
					console.log('Before change:' + ev);
				},
				onAfterChange: function (ev) {
					console.log('After change:' + ev);
				},
				editor: {
					type: CustomTextEditor,
					options: {
						maxLength: 10
					}
				}
			},
			{
				header: 'Type',
				name: 'typeCode',
				onBeforeChange: function (ev){
					console.log('Before change:' + ev);
				},
				onAfterChange: function (ev){
					console.log('After change:' + ev);
				},
				formatter: 'listItemText',
				editor: {
					type: 'select',
					options: {
						listItems: [
							{ text: 'Deluxe', value: '1' },
							{ text: 'EP', value: '2' },
							{ text: 'Single', value: '3' }
						]
					}
				}
			},
			{
				header: 'Genre',
				name: 'genreCode',
				onBeforeChange: function (ev){
					console.log('Before change:' + ev);
				},
				onAfterChange: function (ev){
					console.log('After change:' + ev);
				},
				formatter: 'listItemText',
				editor: {
					type: 'checkbox',
					options: {
						listItems: [
							{ text: 'Pop', value: '1' },
							{ text: 'Rock', value: '2' },
							{ text: 'R&B', value: '3' },
							{ text: 'Electronic', value: '4' },
							{ text: 'etc.', value: '5' }
						]
					}
				},
				copyOptions: {
					useListItemText: true // when this option is used, the copy value is concatenated text
				}
			},
			{
				header: 'Grade',
				name: 'grade',
				onBeforeChange: function(ev){
					console.log('Before change:' + ev);
				},
				onAfterChange: function(ev){
					console.log('After change:' + ev);
				},
				copyOptions: {
					useListItemText: true
				},
				formatter: function(obj) {
					var stars = '';
					for (var i = 0; i < obj.value; i++) {
						stars += '<span class="mdi mdi-star"></span>'
					}
					for (var i = 4; i >= obj.value; i--) {
						stars += '<span class="mdi mdi-star-outline"></span>'
					}
					return stars;
				},
				editor: {
					type: 'radio',
					options: {
						listItems: [
							{ text: '1★', value: '1' },
							{ text: '2★', value: '2' },
							{ text: '3★', value: '3' },
							{ text: '4★', value: '4' },
							{ text: '5★', value: '5' }
						],
						useVieMode: true
					}
				}
			}
		],
		columnOptions: {
			minWidth: scutum.helpers.mq.mediumMax() ? 150 : 50
		}
	});
	grid.resetData(scutum.plugins.dataGrid.data.basic);
};
scutum.plugins.dataGrid.dataSrc = function () {
	var grid = new tui.Grid({
		el: document.getElementById('sc-data-grid-dataSrc'),
		scrollX: scutum.helpers.mq.mediumMax(),
		scrollY: false,
		minBodyHeight: 30,
		usageStatistics: false,
		data: {
			api: {
				readData: { url: '/api/readData', method: 'GET' }
			}
		},
		pageOptions: {
			perPage: 5
		},
		columns: [
			{
				header: 'Name',
				name: 'name'
			},
			{
				header: 'Artist',
				name: 'artist'
			},
			{
				header: 'Type',
				name: 'type'
			},
			{
				header: 'Release',
				name: 'release'
			},
			{
				header: 'Genre',
				name: 'genre'
			}
		],
		columnOptions: {
			minWidth: scutum.helpers.mq.mediumMax() ? 150 : 50
		}
	});
	$('#sc-data-grid-perPage').on('change', function () {
		grid.setPerPage(this.value);
		var pagination = grid.getPagination();
		pagination.reset();
	})
};
scutum.plugins.dataGrid.data = {
	'basic': [
		{
			id: 549731,
			name: 'Beautiful Lies',
			artist: 'Birdy',
			release: '2016.03.26',
			type: 'Deluxe',
			typeCode: '1',
			genre: 'Pop',
			genreCode: '1',
			grade: '4',
			price: 10000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 436461,
			name: 'X',
			artist: 'Ed Sheeran',
			release: '2014.06.24',
			type: 'Deluxe',
			typeCode: '1',
			genre: 'Pop',
			genreCode: '1',
			grade: '5',
			price: 20000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 295651,
			name: 'Moves Like Jagger',
			release: '2011.08.08',
			artist: 'Maroon5',
			type: 'Single',
			typeCode: '3',
			genre: 'Pop,Rock',
			genreCode: '1,2',
			grade: '2',
			price: 7000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 541713,
			name: 'A Head Full Of Dreams',
			artist: 'Coldplay',
			release: '2015.12.04',
			type: 'Deluxe',
			typeCode: '1',
			genre: 'Rock',
			genreCode: '2',
			grade: '3',
			price: 25000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 265289,
			name: '21',
			artist: 'Adele',
			release: '2011.01.21',
			type: 'Deluxe',
			typeCode: '1',
			genre: 'Pop,R&B',
			genreCode: '1,3',
			grade: '5',
			price: 15000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 555871,
			name: 'Warm On A Cold Night',
			artist: 'HONNE',
			release: '2016.07.22',
			type: 'EP',
			typeCode: '1',
			genre: 'R&B,Electronic',
			genreCode: '3,4',
			grade: '4',
			price: 11000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 550571,
			name: 'Take Me To The Alley',
			artist: 'Gregory Porter',
			release: '2016.09.02',
			type: 'Deluxe',
			typeCode: '1',
			genre: 'Jazz',
			genreCode: '5',
			grade: '3',
			price: 30000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 544128,
			name: 'Make Out',
			artist: 'LANY',
			release: '2015.12.11',
			type: 'EP',
			typeCode: '2',
			genre: 'Electronic',
			genreCode: '4',
			grade: '2',
			price: 12000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 366374,
			name: 'Get Lucky',
			artist: 'Daft Punk',
			release: '2013.04.23',
			type: 'Single',
			typeCode: '3',
			genre: 'Pop,Funk',
			genreCode: '1,5',
			grade: '3',
			price: 9000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 8012747,
			name: 'Valtari',
			artist: 'Sigur Rós',
			release: '2012.05.31',
			type: 'EP',
			typeCode: '3',
			genre: 'Rock',
			genreCode: '2',
			grade: '5',
			price: 10000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 502792,
			name: 'Bush',
			artist: 'Snoop Dogg',
			release: '2015.05.12',
			type: 'EP',
			typeCode: '2',
			genre: 'Hiphop',
			genreCode: '5',
			grade: '5',
			price: 18000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 294574,
			name: '4',
			artist: 'Beyoncé',
			release: '2011.07.26',
			type: 'Deluxe',
			typeCode: '1',
			genre: 'Pop',
			genreCode: '1',
			grade: '3',
			price: 12000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 317659,
			name: 'I Won\'t Give Up',
			artist: 'Jason Mraz',
			release: '2012.01.03',
			type: 'Single',
			typeCode: '3',
			genre: 'Pop',
			genreCode: '1',
			grade: '2',
			price: 7000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 583551,
			name: 'Following My Intuition',
			artist: 'Craig David',
			release: '2016.10.01',
			type: 'Deluxe',
			typeCode: '1',
			genre: 'R&B,Electronic',
			genreCode: '3,4',
			grade: '5',
			price: 15000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 490500,
			name: 'Blue Skies',
			release: '2015.03.18',
			artist: 'Lenka',
			type: 'Single',
			typeCode: '3',
			genre: 'Pop,Rock',
			genreCode: '1,2',
			grade: '5',
			price: 6000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 587871,
			name: 'This Is Acting',
			artist: 'Sia',
			release: '2016.10.22',
			type: 'EP',
			typeCode: '2',
			genre: 'Pop',
			genreCode: '1',
			grade: '3',
			price: 20000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 504288,
			name: 'Blurryface',
			artist: 'Twenty One Pilots',
			release: '2015.05.19',
			type: 'EP',
			typeCode: '2',
			genre: 'Rock',
			genreCode: '2',
			grade: '1',
			price: 13000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 450720,
			name: 'I\'m Not The Only One',
			artist: 'Sam Smith',
			release: '2014.09.15',
			type: 'Single',
			typeCode: '3',
			genre: 'Pop,R&B',
			genreCode: '1,3',
			grade: '4',
			price: 8000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 498896,
			name: 'The Magic Whip',
			artist: 'Blur',
			release: '2015.04.27',
			type: 'EP',
			typeCode: '2',
			genre: 'Rock',
			genreCode: '2',
			grade: '3',
			price: 15000,
			downloadCount: 1000,
			listenCount: 5000
		},
		{
			id: 491379,
			name: 'Chaos And The Calm',
			artist: 'James Bay',
			release: '2015.03.23',
			type: 'EP',
			typeCode: '2',
			genre: 'Pop,Rock',
			genreCode: '1,2',
			grade: '5',
			price: 12000,
			downloadCount: 1000,
			listenCount: 5000
		}
	]
};
scutum.plugins.dataGrid.mock = function () {
	XHRMock
		.setup()
		.get('/api/readData?perPage=5&page=1', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(0, 5),
					pagination: {
						page: 1,
						totalCount: 20
					}
				}
			})
		})
		.get('/api/readData?perPage=5&page=2', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(5, 10),
					pagination: {
						page: 2,
						totalCount: 20
					}
				}
			})
		})
		.get('/api/readData?perPage=5&page=3', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(10, 15),
					pagination: {
						page: 3,
						totalCount: 20
					}
				}
			})
		})
		.get('/api/readData?perPage=5&page=4', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(15, 20),
					pagination: {
						page: 4,
						totalCount: 20
					}
				}
			})
		})
		.get('/api/readData?perPage=10&page=1', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(0, 10),
					pagination: {
						page: 1,
						totalCount: 20
					}
				}
			})
		})
		.get('/api/readData?perPage=10&page=2', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(11, 20),
					pagination: {
						page: 2,
						totalCount: 20
					}
				}
			})
		})
		.get('/api/readData?perPage=15&page=1', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(0, 15),
					pagination: {
						page: 1,
						totalCount: 20
					}
				}
			})
		})
		.get('/api/readData?perPage=15&page=2', {
			status: 200,
			body: JSON.stringify({
				result: true,
				data: {
					contents: scutum.plugins.dataGrid.data.basic.slice(16, 20),
					pagination: {
						page: 2,
						totalCount: 20
					}
				}
			})
		});
};