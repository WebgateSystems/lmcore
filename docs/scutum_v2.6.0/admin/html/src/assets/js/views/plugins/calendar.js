var cal;
var calendars;
var $calendar = $('#sc-calendar');
scutum.plugins.calendar = {};
scutum.plugins.calendar.init = function () {
	scutum.require(['tui-snippets', 'tui-timepicker', 'tui-datepicker', 'tui-calendar', 'handlebars'], function () {
		tui.usageStatistics = false;
		// calendars
		scutum.plugins.calendar.calendars();
		// create calendar instance
		scutum.plugins.calendar.instance();
		// calendar controls
		scutum.plugins.calendar.controls();
		// add events to calendar
		scutum.plugins.calendar.events();
		// add schedule to calendar
		scutum.plugins.calendar.schedule();
		// toggle calendars
		scutum.plugins.calendar.calendarsToggle();
	}, false);
};
scutum.plugins.calendar.instance = function () {
	$calendar.height(scutum.$win.height() - $calendar.position().top - 120);
	var Calendar = tui.Calendar;
	cal = new Calendar('#sc-calendar', {
		usageStatistics: false,
		defaultView: 'month',
		taskView: true, // can be also ['milestone', 'task']
		scheduleView: true, // can be also ['allday', 'time']
		calendars: calendars,
		useCreationPopup: true,
		useDetailPopup: true,
		template: {
			monthGridHeader: function (model) {
				var date = new Date(model.date);
				return '<span class="tui-full-calendar-weekday-grid-date">' + date.getDate() + '</span>';
			},
			milestone: function (model) {
				return '<span class="mdi mdi-flag-outline"></span>' + model.title;
			},
			task: function (model) {
				return '<span class="mdi mdi-calendar-check"></span>' + model.title;
			},
			allday: function (schedule) {
				return scutum.plugins.calendar.helpers.getTimeTemplate(schedule, true);
			},
			time: function (schedule) {
				return scutum.plugins.calendar.helpers.getTimeTemplate(schedule, false);
			}
		},
		week: {
			narrowWeekend: !scutum.helpers.mq.mediumMax(),
			startDayOfWeek: 1 // monday
		},
		month: {
			narrowWeekend: !scutum.helpers.mq.mediumMax(),
			startDayOfWeek: 1 // monday
		}
	});
	// set calendar range text
	scutum.plugins.calendar.helpers.setRenderRangeText();
	// calendar theme
	cal.setTheme(scutum.plugins.calendar.theme);
	// render calendars
	var $calendarList = $('.sc-calendars-list');
	var $template = scutum.helpers.mq.mediumMax() ? $('#sc-calendars-list-template-offcanvas') : $('#sc-calendars-list-template');
	var calendarListTempl = $template.html();
	var compiledTemplate = Handlebars.compile(calendarListTempl);
	var html = compiledTemplate({
		calendars: calendars
	});
	$calendarList.html(html);
	// initialize checkboxes
	scutum.forms.common.icheck($('.sc-js-calendar-toggle'));
};
scutum.plugins.calendar.calendars = function () {
	var CalendarList = [];
	function addCalendar (calendar) {
		CalendarList.push(calendar);
	}
	(function () {
		var calendar;
		var id = 0;

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'My Calendar';
		calendar.color = '#ffffff';
		calendar.bgColor = '#0288D1';
		calendar.dragBgColor = '#0288D1';
		calendar.borderColor = '#0277BD';
		addCalendar(calendar);

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'Company';
		calendar.color = '#ffffff';
		calendar.bgColor = '#E53935';
		calendar.dragBgColor = '#E53935';
		calendar.borderColor = '#C62828';
		addCalendar(calendar);

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'Family';
		calendar.color = '#ffffff';
		calendar.bgColor = '#0097A7';
		calendar.dragBgColor = '#0097A7';
		calendar.borderColor = '#00838F';
		addCalendar(calendar);

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'Friends';
		calendar.color = '#ffffff';
		calendar.bgColor = '#5E35B1';
		calendar.dragBgColor = '#5E35B1';
		calendar.borderColor = '#4527A0';
		addCalendar(calendar);

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'Travel';
		calendar.color = '#ffffff';
		calendar.bgColor = '#43A047';
		calendar.dragBgColor = '#43A047';
		calendar.borderColor = '#2E7D32';
		addCalendar(calendar);

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'etc';
		calendar.color = '#ffffff';
		calendar.bgColor = '#757575';
		calendar.dragBgColor = '#757575';
		calendar.borderColor = '#424242';
		addCalendar(calendar);

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'Birthdays';
		calendar.color = '#222222';
		calendar.bgColor = '#FDD835';
		calendar.dragBgColor = '#FDD835';
		calendar.borderColor = '#F9A825';
		addCalendar(calendar);

		calendar = new scutum.plugins.calendar.helpers.CalendarInfo();
		id += 1;
		calendar.id = String(id);
		calendar.name = 'National Holidays';
		calendar.color = '#ffffff';
		calendar.bgColor = '#00897B';
		calendar.dragBgColor = '#00897B';
		calendar.borderColor = '#00695C';
		addCalendar(calendar);
	})();
	calendars = CalendarList;
};
scutum.plugins.calendar.calendarsToggle = function () {
	function onChangeCalendars (e) {
		var calendarId = e.target.value;
		var checked = e.target.checked;
		var $viewAll = scutum.helpers.mq.mediumMax() ? scutum.$offcanvas.find('.calendars-toggle-all') : scutum.$pageWrapper.find('.calendars-toggle-all');
		var calendarElements = Array.prototype.slice.call(document.querySelectorAll('.sc-calendars-list .sc-js-calendar-toggle'));
		var allCheckedCalendars = true;
		if (calendarId === 'all') {
			calendars.forEach(function (calendar) {
				calendar.checked = checked;
			});
			calendarElements.forEach(function (input) {
				input.checked = checked;
				$(input).iCheck('update');
			});
		} else {
			scutum.plugins.calendar.helpers.findCalendar(calendarId).checked = checked;
			allCheckedCalendars = calendarElements.every(function (input) {
				return input.checked;
			});
			$viewAll[0].checked = allCheckedCalendars;
			$viewAll.iCheck('update');
		}
		scutum.plugins.calendar.helpers.refreshScheduleVisibility();
	}
	$('.sc-js-calendar-toggle').on('ifChanged', function (event) {
		onChangeCalendars(event);
	});
};
scutum.plugins.calendar.schedule = function () {
	// https://nhnent.github.io/tui.calendar/latest/global.html#Schedule
	cal.createSchedules([
		{
			id: '1',
			calendarId: '1',
			title: 'Book Flight to France',
			category: 'allday',
			dragBgColor: calendars[0].dragBgColor,
			start: moment().startOf('month').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').format('YYYY-MM-DD HH:mm')
		},
		{
			id: '2',
			calendarId: '2',
			title: 'Staff meeting',
			category: 'time',
			dragBgColor: calendars[1].dragBgColor,
			recurrenceRule: true,
			raw: {
				attendees: ['Mark', 'John', 'Lisa']
			},
			start: moment().startOf('month').add(4, 'day').startOf('day').add(10, 'hours').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').add(4, 'day').startOf('day').add(11, 'hours').format('YYYY-MM-DD HH:mm')
		},
		{
			id: '3',
			calendarId: '3',
			title: 'Get Dentist appointment for John',
			category: 'time',
			dragBgColor: calendars[2].dragBgColor,
			raw: {
				isImportant: true
			},
			start: moment().startOf('month').add(12, 'day').startOf('day').add(13, 'hours').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').add(12, 'day').startOf('day').add(13, 'hours').format('YYYY-MM-DD HH:mm')
		},
		{
			id: '4',
			calendarId: '4',
			title: 'Weekend getaway with friends',
			category: 'time',
			dragBgColor: calendars[3].dragBgColor,
			location: 'Cinque Terre, Italy',
			start: moment().startOf('month').add(15, 'day').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').add(17, 'day').format('YYYY-MM-DD HH:mm')
		},
		{
			id: '5',
			calendarId: '5',
			title: 'Trip to France',
			category: 'time',
			dragBgColor: calendars[4].dragBgColor,
			isReadOnly: true,
			start: moment().startOf('month').add(26, 'day').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').add(30, 'day').format('YYYY-MM-DD HH:mm')
		},
		{
			id: '6',
			calendarId: '6',
			title: 'Review insurance services',
			category: 'time',
			dragBgColor: calendars[5].dragBgColor,
			isAllDay: true,
			isPrivate: true,
			start: moment().startOf('month').add(6, 'day').format('YYYY-MM-DD'),
			end: moment().startOf('month').add(7, 'day').format('YYYY-MM-DD')
		},
		{
			id: '7',
			calendarId: '7',
			title: 'Get a present for Dad',
			category: 'allday',
			dragBgColor: calendars[6].dragBgColor,
			raw: {
				icon: 'mdi mdi-gift'
			},
			start: moment().startOf('month').add(22, 'day').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').add(22, 'day').format('YYYY-MM-DD HH:mm')
		},
		{
			id: '8',
			calendarId: '8',
			title: 'National Hugging Day',
			category: 'allday',
			dragBgColor: calendars[7].dragBgColor,
			raw: {
				icon: 'mdi mdi-emoticon-happy'
			},
			start: moment().startOf('month').add(19, 'day').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').add(19, 'day').format('YYYY-MM-DD HH:mm')
		},
		{
			id: '9',
			calendarId: '6',
			title: 'Check project status',
			category: 'task',
			dragBgColor: calendars[5].dragBgColor,
			dueDate: 'morning',
			start: moment().format('YYYY-MM-DD HH:mm'),
			end: moment().format('YYYY-MM-DD HH:mm')
		},
		{
			id: '10',
			calendarId: '2',
			title: 'My project v2.0',
			category: 'milestone',
			dragBgColor: calendars[1].dragBgColor,
			start: moment().format('YYYY-MM-DD HH:mm'),
			end: moment().format('YYYY-MM-DD HH:mm')
		},
		{
			id: '11',
			calendarId: '2',
			title: 'Company picnic',
			category: 'allday',
			dragBgColor: calendars[1].dragBgColor,
			raw: {
				icon: 'mdi mdi-food-fork-drink'
			},
			start: moment().startOf('month').add(9, 'day').startOf('day').add(8, 'hours').format('YYYY-MM-DD HH:mm'),
			end: moment().startOf('month').add(10, 'day').startOf('day').add(20, 'hours').format('YYYY-MM-DD HH:mm')
		}
	]);
};
scutum.plugins.calendar.controls = function () {
	// calendar navigation
	$('[data-nav-action]').on('click', function () {
		var action = $(this).attr('data-nav-action');
		switch (action) {
		case 'move-prev':
			cal.prev();
			break;
		case 'move-next':
			cal.next();
			break;
		case 'move-today':
			cal.today();
			break;
		}
		scutum.plugins.calendar.helpers.setRenderRangeText();
	});
	// calendar view mode
	$('[data-view-action]').on('click', function () {
		var action = $(this).attr('data-view-action');
		var options = cal.getOptions();
		var viewName = '';
		var viewText = '';

		switch (action) {
		case 'toggle-daily':
			viewName = 'day';
			viewText = 'Day';
			break;
		case 'toggle-weekly':
			viewName = 'week';
			viewText = 'Week';
			break;
		case 'toggle-monthly':
			options.month.visibleWeeksCount = 0;
			viewName = 'month';
			viewText = 'Month';
			break;
		case 'toggle-weeks2':
			options.month.visibleWeeksCount = 2;
			viewName = 'month';
			viewText = '2 weeks';
			break;
		}
		cal.setOptions(options, true);
		cal.changeView(viewName, true);
		// change calendar range text
		scutum.plugins.calendar.helpers.setRenderRangeText();
		// change calendar view name in dropdown
		scutum.plugins.calendar.helpers.setDropdownTexts($(this), viewText);
	});
	// calendar options
	$('[data-control-action]').on('ifChanged', function () {
		var action = $(this).attr('data-control-action');
		var options = cal.getOptions();
		var viewName = '';

		switch (action) {
		case 'toggle-narrow-weekend':
			options.month.narrowWeekend = !options.month.narrowWeekend;
			options.week.narrowWeekend = !options.week.narrowWeekend;
			viewName = cal.getViewName();
			break;
		case 'toggle-workweek':
			options.month.workweek = !options.month.workweek;
			options.week.workweek = !options.week.workweek;
			viewName = cal.getViewName();
			break;
		}
		cal.setOptions(options, true);
		cal.changeView(viewName, true);
		// change calendar range text
		scutum.plugins.calendar.helpers.setRenderRangeText();
	});
	// uncheck narrower weekends on mobile
	$('#sc-cal-weekends-narrower')
		.prop('checked', false)
		.iCheck('update');
};
// https://nhnent.github.io/tui.calendar/latest/global.html#themeConfig
scutum.plugins.calendar.theme = {
	'common.border': '1px solid rgba(0,0,0,.12)',
	'common.holiday.color': '#f44336',
	'common.saturday.color': 'rgba(0,0,0,.54)',
	'common.dayname.color': 'rgba(0,0,0,.87)',

	// creation guide style
	'common.creationGuide.backgroundColor': 'rgba(19, 93, 230, 0.1)',
	'common.creationGuide.border': '1px solid #135de6',

	// month header 'dayname'
	'month.dayname.height': '32px',
	'month.dayname.borderLeft': '1px solid rgba(0,0,0,.12)',
	'month.dayname.paddingLeft': '8px',
	'month.dayname.paddingRight': '8px',
	'month.dayname.fontWeight': 'normal',
	'month.dayname.textAlign': 'left',

	// month schedule style
	'month.schedule.borderRadius': '4px',

	// month more view
	'month.moreView.boxShadow': 'none',
	'month.moreView.paddingBottom': '0',
	'month.moreViewTitle.height': '28px',
	'month.moreViewTitle.marginBottom': '0',
	'month.moreViewTitle.backgroundColor': '#f5f5f5',
	'month.moreViewTitle.borderBottom': '1px solid rgba(0,0,0,.12)',
	'month.moreViewTitle.padding': '0 8px',
	'month.moreViewList.padding': '8px',

	// week header 'dayname'
	'week.dayname.height': '42px',
	'week.dayname.borderTop': '1px solid rgba(0,0,0,.12)',
	'week.dayname.borderBottom': '1px solid rgba(0,0,0,.12)',
	'week.dayname.borderLeft': '1px solid rgba(0,0,0,.12)',
	'week.dayname.paddingLeft': '4px',
	'week.dayname.backgroundColor': 'inherit',
	'week.dayname.textAlign': 'left',
	'week.pastDay.color': 'rgba(0,0,0,.54)',

	// week vertical panel 'vpanel'
	'week.vpanelSplitter.border': '1px solid #ddd',
	'week.vpanelSplitter.height': '3px',

	// week daygrid 'daygrid'
	'week.daygrid.borderRight': '1px solid #ddd',

	'week.daygridLeft.width': '80px',
	'week.daygridLeft.backgroundColor': '',
	'week.daygridLeft.paddingRight': '4px',
	'week.daygridLeft.borderRight': '1px solid #ddd',

	'week.today.color': 'rgba(0,0,0,.87)',
	'week.today.backgroundColor': '#inherit',
	'week.weekend.backgroundColor': 'inherit',

	// week timegrid 'timegrid'
	'week.timegridLeft.width': '80px',
	'week.timegridLeft.backgroundColor': '#fafafa',
	'week.timegridLeft.borderRight': '1px solid #ddd',
	'week.timegridLeft.fontSize': '12px',
	'week.timegridLeftTimezoneLabel.height': '51px',
	'week.timegridLeftAdditionalTimezone.backgroundColor': '#fdfdfd',

	'week.timegridOneHour.height': '48px',
	'week.timegridHalfHour.height': '24px',
	'week.timegridHalfHour.borderBottom': '1px dotted #f9f9f9',
	'week.timegridHorizontalLine.borderBottom': '1px solid #eee',

	'week.timegrid.paddingRight': '10px',
	'week.timegrid.borderRight': '1px solid #ddd',
	'week.timegridSchedule.borderRadius': '0',
	'week.timegridSchedule.paddingLeft': '0',

	'week.currentTime.color': '#135de6',
	'week.currentTime.fontSize': '12px',
	'week.currentTime.fontWeight': 'bold',

	'week.pastTime.color': '#999',
	'week.pastTime.fontWeight': 'normal',

	'week.futureTime.color': '#333',
	'week.futureTime.fontWeight': 'normal',

	'week.currentTimeLinePast.border': '1px solid rgba(19, 93, 230, 0.3)',
	'week.currentTimeLineBullet.backgroundColor': '#135de6',
	'week.currentTimeLineToday.border': '1px solid #135de6',
	'week.currentTimeLineFuture.border': '1px solid #135de6',

	// week creation guide style
	'week.creationGuide.color': '#135de6',
	'week.creationGuide.fontSize': '12px',
	'week.creationGuide.fontWeight': 'bold',

	// week daygrid schedule style
	'week.dayGridSchedule.borderRadius': '0',
	'week.dayGridSchedule.height': '22px',
	'week.dayGridSchedule.marginTop': '2px',
	'week.dayGridSchedule.marginLeft': '8px',
	'week.dayGridSchedule.marginRight': '8px'
};
scutum.plugins.calendar.events = function () {
	window.clickedSchedule = null;
	// event handlers
	cal.on({
		"clickSchedule": function (e) {
			// console.log("clickSchedule", e);
			window.clickedSchedule = e.schedule;
		},
		"clickDayname": function (date) {
			// console.log("clickDayname", date);
		},
		"beforeCreateSchedule": function (e) {
			// console.log("beforeCreateSchedule", e);
			scutum.plugins.calendar.helpers.saveNewSchedule(e);
		},
		"beforeUpdateSchedule": function (e) {
			// console.log("beforeUpdateSchedule", e);
			if (window.clickedSchedule) {
				var schedule = cal.getSchedule(e.schedule.id, window.clickedSchedule.calendarId);
				var calendar = scutum.plugins.calendar.helpers.findCalendar(e.schedule.calendarId);
				if (calendar) {
					schedule.calendarId = calendar.id;
					schedule.color = calendar.color;
					schedule.bgColor = calendar.bgColor;
					schedule.dragBgColor = calendar.dragBgColor;
					schedule.borderColor = calendar.borderColor;
				}
				schedule.title = e.schedule.title;
				schedule.location = e.schedule.location;
				schedule.isAllDay = e.schedule.isAllDay;
				schedule.state = e.schedule.state;
				cal.deleteSchedule(e.schedule.id, window.clickedSchedule.calendarId);
				cal.createSchedules([schedule]);
				window.clickedSchedule = null;
			} else {
				e.schedule.start = e.start;
				e.schedule.end = e.end;
				cal.updateSchedule(e.schedule.id, e.schedule.calendarId, e.schedule);
			}
		},
		"beforeDeleteSchedule": function (e) {
			// console.log("beforeDeleteSchedule", e);
			cal.deleteSchedule(e.schedule.id, e.schedule.calendarId);
		},
		"afterRenderSchedule": function (e) {
			var schedule = e.schedule;
			var element = cal.getElement(schedule.id, schedule.calendarId);
			// console.log('afterRenderSchedule', element);
		},
		"clickTimezonesCollapseBtn": function (timezonesCollapsed) {
			// console.log("timezonesCollapsed", timezonesCollapsed);
			if (timezonesCollapsed) {
				cal.setTheme({
					"week.daygridLeft.width": "77px",
					"week.timegridLeft.width": "77px"
				});
			} else {
				cal.setTheme({
					"week.daygridLeft.width": "60px",
					"week.timegridLeft.width": "60px"
				});
			}
			return true;
		}
	});
};
scutum.plugins.calendar.helpers = {
	'findCalendar': function (id) {
		var found;
		calendars.forEach(function (calendar) {
			if (calendar.id === id) {
				found = calendar;
			}
		});
		return found;
	},
	'saveNewSchedule': function (scheduleData) {
		var calendar = scheduleData.calendar || scutum.plugins.calendar.helpers.findCalendar(scheduleData.calendarId);
		var schedule = {
			id: String(scutum.helpers.uniqueID()),
			title: scheduleData.title,
			isAllDay: scheduleData.isAllDay,
			start: scheduleData.start,
			end: scheduleData.end,
			category: scheduleData.isAllDay ? 'allday' : 'time',
			dueDateClass: '',
			color: calendar.color,
			bgColor: calendar.bgColor,
			dragBgColor: calendar.dragBgColor,
			borderColor: calendar.borderColor,
			location: scheduleData.location,
			raw: {
				class: scheduleData.raw['class']
			},
			state: scheduleData.state
		};
		if (calendar) {
			schedule.calendarId = calendar.id;
			schedule.color = calendar.color;
			schedule.bgColor = calendar.bgColor;
			schedule.borderColor = calendar.borderColor;
		}
		cal.createSchedules([schedule]);
		scutum.plugins.calendar.helpers.refreshScheduleVisibility();
	},
	'refreshScheduleVisibility': function () {
		calendars.forEach(function (calendar) {
			cal.toggleSchedules(calendar.id, !calendar.checked, false);
		});
		cal.render(true);
	},
	'CalendarInfo': function () {
		this.id = null;
		this.name = null;
		this.checked = true;
		this.color = null;
		this.bgColor = null;
		this.borderColor = null;
	},
	'setRenderRangeText': function () {
		var $renderRange = $('#sc-cal-range-text');
		var options = cal.getOptions();
		var viewName = cal.getViewName();
		var html = [];
		if (viewName === 'day') {
			html.push(moment(cal.getDate().getTime()).format('MMMM Do YYYY'));
		} else if (viewName === 'month' &&
			(!options.month.visibleWeeksCount || options.month.visibleWeeksCount > 4)) {
			html.push(moment(cal.getDate().getTime()).format('MMMM YYYY'));
		} else {
			html.push(moment(cal.getDateRangeStart().getTime()).format('MMMM Do YYYY'));
			html.push(' ~ ');
			html.push(moment(cal.getDateRangeEnd().getTime()).format('MMMM Do YYYY'));
		}
		$renderRange.html(html.join(''));
	},
	'setDropdownTexts': function (el, viewText) {
		console.log(viewText);
		$('#sc-js-cal-view-name').text(viewText);
		$('[data-view-action]').removeClass('sc-text-semibold');
		$(el).addClass('sc-text-semibold');
	},
	'getTimeTemplate': function (schedule, isAllDay) {
		var html = [];
		var start = moment(schedule.start.toUTCString());
		if (!isAllDay) {
			html.push('<strong>' + start.format('HH:mm') + '</strong> ');
		}
		if (schedule.isPrivate) {
			html.push('<span class="mdi mdi-lock-outline"></span>');
			html.push(' ' + schedule.title);
		} else {
			if (schedule.isReadOnly) {
				html.push('<span class="mdi mdi-pencil-lock"></span>');
			}
			if (schedule.attendees.length) {
				html.push('<span class="mdi mdi-account-multiple-outline"></span>');
			}
			if (schedule.location) {
				html.push('<span class="mdi mdi-map-marker-outline"></span>');
			}
			if (schedule.hasOwnProperty('raw') && schedule.raw) {
				if (schedule.raw.hasOwnProperty('attendees')) {
					html.push('<span class="mdi mdi-account-multiple"></span>');
				}
				if (schedule.raw.hasOwnProperty('isImportant')) {
					html.push('<span class="mdi mdi-alert-outline"></span>');
				}
				if (schedule.raw.hasOwnProperty('icon')) {
					html.push('<span class="' + schedule.raw.icon + '"></span>');
				}
			}
			html.push(' ' + schedule.title);
		}
		return html.join('');
	}
};
