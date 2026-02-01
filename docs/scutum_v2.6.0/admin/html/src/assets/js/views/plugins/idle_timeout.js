scutum.plugins.idleTimeout = {};
scutum.plugins.idleTimeout.init = function () {
	scutum.require(['idle-timeout'], function () {
		// append modal to <body>
		var hText = scutum.helpers.isRTL() ? 'uk-text-left' : 'uk-text-right'
		scutum.$body.append('<div class="uk-modal" id="sc-modal-idle">' +
			'<div class="uk-modal-dialog">' +
				'<div class="uk-modal-body">' +
					'<h3 class="uk-modal-title">Your session is about to expire!</h3>' +
					'<hr>' +
					'<p class="uk-margin-remove">You\'ve been inactive for a while. For your security, we\'ll log you out automatically.</p>' +
					'<p class="uk-margin-remove">Click "Stay Online" to continue your session.</p>' +
					'<p>Your session will expire in <span class="sc-text-semibold md-color-red-600" id="sc-session-timer"></span> second(s).</p>' +
				'</div>' +
				'<div class="uk-modal-footer ' + hText + '">' +
					'<button id="sc-session-stay" type="button" class="sc-button sc-button-default sc-button-flat uk-modal-close">Stay Online</button><button type="button" class="sc-button sc-button-outline sc-button-outline-primary uk-margin-small-left" id="sc-session-logout">Logout</button>' +
				'</div>' +
			'</div>' +
		'</div>');

		var modal = UIkit.modal("#sc-modal-idle", {
			'bgClose': false,
			'escClose': false
		});

		var session = {
			// Logout Settings
			inactiveTimeout: 5000, // (ms) The time until we display a warning message
			warningTimeout: 30000, // (ms) The time until we log them out
			minWarning: 5000, // (ms) If they come back to page (on mobile), The minimum amount, before we just log them out
			warningStart: null, // Date time the warning was started
			warningTimer: null, // Timer running every second to countdown to logout
			autologout: {
				url: "login_page.html"
			},
			// Logout function once warningTimeout has expired
			logout: function () {
				window.location = session.autologout.url;
			}
		};

		var $sessionCounter = $('#sc-session-timer').html(session.warningTimeout / 1000);

		$(document).on("idle.idleTimer", function (event, elem, obj) {
			// Get time when user was last active
			var diff = (+new Date()) - obj.lastActive - obj.timeout;

			var warning = (+new Date()) - diff;

			// On mobile js is paused, so see if this was triggered while we were sleeping
			if (diff >= session.warningTimeout || warning <= session.minWarning) {
				modal.hide();
			} else {
				// Show dialog, and note the time
				$sessionCounter.html(Math.round((session.warningTimeout - diff) / 1000));
				modal.show();
				session.warningStart = (+new Date()) - diff;

				// Update counter every second
				session.warningTimer = setInterval(function () {
					var remaining = Math.round((session.warningTimeout / 1000) - (((+new Date()) - session.warningStart) / 1000));
					if (remaining >= 0) {
						$sessionCounter.html(remaining);
					} else {
						session.logout();
					}
				}, 1000)
			}
		});

		scutum.$body
		// User clicked ok to stay online
			.on('click', '#sc-session-stay', function () {
				clearTimeout(session.warningTimer);
				modal.hide();
			})
			// User clicked logout
			.on('click', '#sc-session-logout', function () {
				session.logout();
			});

		// Set up the timer, if inactive for 5 seconds log them out
		$(document).idleTimer(session.inactiveTimeout);
	})
};
