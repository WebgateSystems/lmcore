var $mailbox = $('#sc-mailbox-messages');
var $single = $('#sc-message-single');
var activeId = null;
var messages = [];

scutum.pages.mailbox = {};
scutum.pages.mailbox.init = function () {
	scutum.pages.mailbox.render();
	// messages actions
	scutum.pages.mailbox.message.show();
	scutum.pages.mailbox.message.close();
	scutum.pages.mailbox.message.remove();
	scutum.pages.mailbox.message.filter();
	// sticky toolbar
	if(scutum.helpers.mq.mediumMax()) {
		UIkit.sticky('#sc-page-top-bar', {
			offset: scutum.$header.height()
		})
	}
	// compose message modal
	$('#sc-message-compose').on('shown', function () {
		$('#sc-message-compose-send-to').trigger('change');
	})
};
scutum.pages.mailbox.message = {};
scutum.pages.mailbox.render = function () {
	$mailbox.addClass('uk-invisible');
	scutum.require(['handlebars'], function () {
		$.when(
			scutum.handlebars.getPartial('mailbox-messages'),
			scutum.helpers.ajax('data/pages/mailbox_messages.json', 'GET', 'json')
		).done(function (p, result) {
			// register partial
			Handlebars.registerPartial('mailbox-messages', p);
			// get messages
			$.each(result, function (index, item) {
				// format date
				item.date = moment(item.date).format("ddd, MMM Do HH:mm");
				messages.push(item);
			});
			$mailbox
				.one('render.handlebars', function (template, data) {
					scutum.helpers.sequenceShow.init(null, true);
					$mailbox.removeClass('uk-invisible');
					// init components
					scutum.forms.common.icheck($mailbox.find('.sc-js-item-check'));
					scutum.helpers.iCheck.toggleSingleItem();
					if (scutum.config.customScrollbar) {
						scutum.$pageContent.data('ps').update()
					}
				}).hbRender('mailbox-messages', {
					messages: messages
				});
		});
	}, false)
};
scutum.pages.mailbox.message.show = function () {
	scutum.$doc.on('click', '.sc-js-message-expand .sc-message-card', function (e) {
		if (!$(e.target).closest('.sc-js-item-check').length && !$(e.target).closest('.sc-message-actions').length) {
			var $message = $(this);
			var winScrollTop  = scutum.$win.scrollTop();
			var contentScrollTop  = scutum.$pageContent.scrollTop();
			var _top = parseFloat($message.position().top) - parseFloat(scutum.$pageContent.position().top);
			var top = scutum.helpers.mq.mediumMax() ? _top : _top + scutum.$pageContent.scrollTop();
			var height = $message.outerHeight();
			activeId = $message.closest('li').attr('data-id');
			if ($message.hasClass('sc-message-expanded')) {
				return;
			}
			// disable scrollbars (page content)
			scutum.$pageContent
				.addClass('sc-page-overflow sc-message-expanded')
				.css({'padding-right': scutum.helpers.scrollbar.width()});
			// add overlay
			scutum.helpers.overlay.add(scutum.$pageContent, true, scutum.$pageContent.scrollTop());
			// disable scrollbars (document)
			if (scutum.helpers.mq.mediumMax()) {
				scutum.helpers.scrollbar.disable();
			}
			// TODO disable custom scrollbar
			if (scutum.config.customScrollbar) {
				// scutum.$pageContent.data('ps').destroy();
			}

			// register handlebars partial
			Handlebars.registerPartial('mailbox-message-single', scutum.handlebars.getPartial('mailbox-message-single'));
			// find message
			scutum.helpers.findObjectByKey(messages, 'id', activeId ).then(function (response) {
				if (response) {
					// render/show message
					$single
						.one('render.handlebars', function (template, data) {
							$single
								.show()
								.css({
									top: top,
									height: height
								}).velocity({
									top: scutum.$pageContent.scrollTop(),
									height: parseFloat(scutum.$win.height()) - parseFloat(scutum.$pageContent.position().top) + 'px'
								}, {
									delay: 100,
									duration: 360,
									easing: scutum.easingSwiftOut,
									begin: function () {
										scutum.$pageWrapper.addClass('sc-message-single');
										scutum.forms.common.select2($single);
									},
									complete: function () {
										$single.find('.sc-js-el-show').show().velocity("transition.slideUpIn", { stagger: 120, duration: 280 });
										$single.addClass('sc-js-expanded');
									}
								});
						}).hbRender('mailbox-message-single', {
							message: response
						});
				}
			});
		}
	})
};
scutum.pages.mailbox.message.close = function () {
	scutum.$doc.on('click', '.sc-js-message-close', function (e) {
		e.preventDefault();
		var $message = $('[data-id="' + activeId + '"]');
		// hide content
		$single.find('.sc-js-el-show').velocity("transition.slideDownOut", {
				stagger: 80,
				duration: 140,
				complete: function () {
					// hide single message
					$single.velocity(
						{
							height: $message.height(),
							top: parseFloat($message.position().top) + parseFloat(scutum.$pageContent.scrollTop())
						},
						{
							duration: 200,
							begin: function () {
								$single.removeClass('sc-js-expanded');
							},
							complete: function () {
								$single.fadeOut();
								scutum.$pageWrapper.removeClass('sc-message-single');
								scutum.helpers.overlay.remove(scutum.$pageContent, true);
								setTimeout(function () {
									scutum.$pageContent
										.removeClass('sc-page-overflow')
										.css({'padding-right': ''});
									if (scutum.helpers.mq.mediumMax()) {
										scutum.helpers.scrollbar.enable();
									}
								}, 320);
							}
						})
				}
			}
		);
	})
};
scutum.pages.mailbox.message.remove = function () {
	scutum.$doc.on('click', '.sc-js-message-remove', function (e) {
		e.preventDefault();
		var $message = $(this).closest('li');
		var id = $message.closest('li').attr('data-id');
		$message.velocity(
			{
				'translateX': '100%',
				'opacity': 0
			},
			{
				duration: 280,
				easing: scutum.easingSwiftOut,
				complete: function () {
					$message.remove();
					UIkit.notification('<div class="uk-flex uk-flex-middle"><span class="uk-flex-1">Message deleted!</span><a href="#" class="md-color-amber-500 uk-margin-small-left">undo</a></div>');
				}
			}
		)
	})
};
scutum.pages.mailbox.message.filter = function () {
	var $filterEl = scutum.$pageWrapper;
	var filter = UIkit.filter($filterEl, {
		'target': '.sc-js-message-filter'
	});
	var $filterClear = $('.sc-js-filter-clear');
	if ($filterClear.length) {
		scutum.$pageWrapper.on('beforeFilter', function () {
			scutum.$pageContent[0].scrollTop = 0;
		});
		// fires after the filter has been applied
		scutum.$pageWrapper.on('afterFilter', function () {
			var state = filter.getState();
			if (typeof state.filter[""] === 'undefined') {
				$filterEl.removeClass('sc-filtered-items');
			} else {
				$filterEl.addClass('sc-filtered-items');
			}
		});
	}
	$('.sc-js-offcanvas-filters').find('li').on('click', function () {
		var filter = $(this).attr('data-uk-filter-control');
		$('.sc-js-offcanvas-filter')
			.attr('data-uk-filter-control', filter)
			.click();
	});
};
