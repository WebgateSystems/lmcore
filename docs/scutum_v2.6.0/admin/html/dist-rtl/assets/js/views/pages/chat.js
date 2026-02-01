var $chat = $('#sc-chat');
var $submit = $('#sc-chat-message-submit');
var $input = $('#sc-chat-message-input');
var messages = [];

scutum.pages.chat = {};
scutum.pages.chat.init = function () {
	$chat.addClass('sc-light');
	scutum.pages.chat.message.fillChat();
	scutum.pages.chat.message.send();
	scutum.pages.chat.users();
	scutum.pages.chat.generateUserList();
	scutum.pages.chat.events();
};
scutum.pages.chat.message = {
	'fillChat': function () {
		scutum.require(['handlebars'], function () {
			$.when(
				scutum.handlebars.getPartial('chat-message'),
				scutum.helpers.ajax('data/pages/chat_messages.json', 'GET', 'json')
			).done(function (p, result) {
				// register partial
				Handlebars.registerPartial('chat-message', p);
				// get messages
				var delayedMessages = [];
				$.each(result, function (index, item) {
					if (index < 4) {
						messages.push(item);
					} else {
						delayedMessages.push(item);
					}
				});

				$chat
					.one('render.handlebars', function (template, data) {
						scutum.helpers.hiResImagesProcess();
					}).hbRender('chat-messages', {
						messages: messages
					});

				// update chat
				setTimeout(function () {
					$chat
						.one('render.handlebars', function (template, data) {
							$chat.find('.sc-sequence-show.sc-chat-messages-wrapper').each(function (index) {
								var $this = $(this);
								var delay = 200 * (index + 1);
								setTimeout(function () {
									scutum.helpers.sequenceShow.activate($this, 'uk-animation-slide-left');
									scutum.helpers.hiResImagesProcess();
								}, delay);
							})
						}).hbRender('chat-messages', {
							messages: delayedMessages,
							delayed: true
						}, true);
				}, 1000);
			});
		}, false)
	},
	'send': function () {
		function sendMessage () {
			var message = scutum.helpers.escapeHTML($input.val());
			var $last = $chat.find('.sc-chat-messages-wrapper').last();
			var callback = function () {
				$input.val('');
				$chat.closest('.uk-card-body').scrollTop($chat[0].scrollHeight);
			};
			if (message !== '') {
				if ($last.hasClass('my')) {
					var last_message_time = $last.find('[data-message-time]:last').find('time').text();
					var time = moment().format('HH:mm');
					$last.find('.sc-chat-messages')
						.one('render.handlebars', function (template, data) {
							scutum.helpers.sequenceShow.activate($last.find('.sc-sequence-show').last(), 'uk-animation-slide-right');
							callback();
						})
						.hbRender('chat-message', {
							"content": message,
							"time": last_message_time !== time ? moment().format('HH:mm') : "",
							animated: true
						}, true);
				} else {
					$chat
						.one('render.handlebars', function (template, data) {
							scutum.helpers.sequenceShow.activate($chat.find('.sc-sequence-show').last(), 'uk-animation-slide-right');

							callback();
						}).hbRender('chat-messages', {
							messages: [
								{
									"id": scutum.helpers.uniqueID(),
									"own": true,
									"messages": [
										{
											"content": message,
											"time": moment().format('HH:mm')
										}
									]
								}
							],
							delayed: true
						}, true);
				}
			}
		}

		$submit.on('click', function (e) {
			e.preventDefault();
			sendMessage()
		});

		$input.on('keyup', function (e) {
			var char = event.which || event.keyCode;
			if (char === 13) {
				sendMessage();
			}
		});
	}
};
scutum.pages.chat.users = function () {
	var $list = $('.sc-js-chat-users-list');
	if ($list.length) {
		$list.children('li').on('click', function () {
			console.log('new chat window');
		});
	}
};
scutum.pages.chat.generateUserList = function () {
	scutum.require(['handlebars', 'chancejs'], function () {
		var $containerLg = $('#sc-user-list').html('');
		var $containerSm = $('#sc-user-list-offcanvas').html('');
		var $container = scutum.helpers.mq.largeMin() ? $containerLg : $containerSm;
		var users = [];
		var status = ['online','offline','busy','away'];

		// generate list
		var source = $('#userListTemplate').html();
		var tmpl = Handlebars.compile(source);
		for (var i = 0; i < 10; i++) {
			users.push({
				id: scutum.helpers.uniqueID(),
				avatar: '0' + (Math.floor(Math.random() * 10) + 1).toString(),
				username: chance.name(),
				sentence: chance.sentence({ 'words': 10}),
				status: status[Math.floor(Math.random() * status.length)]
			})
		}
		var theCompiledHtml = tmpl({
			users: users
		});
		$container.html(theCompiledHtml);

		// animate list
		scutum.helpers.sequenceShow.init(null, true);
	})
};
scutum.pages.chat.events = function () {
	scutum.$win.on('resize', scutum.helpers.debounce(scutum.pages.chat.generateUserList, 500));
}