scutum.components = {};
scutum.components.progressSpinners = {
	'init': function () {
		var $el = $('.sc-js-progress');
		var $bar = $el.find('.sc-progress-bar');
		var animate = setInterval(function () {
			var barWidth = Math.round($bar.width() / $el.width() * 100);
			var rand = Math.floor(Math.random() * 10) + 5;
			if ((barWidth + rand) >= 33) {
				$bar.removeClass('md-bg-red-400 md-bg-amber-400').addClass('md-bg-amber-400');
			}
			if ((barWidth + rand) >= 66) {
				$bar.removeClass('md-bg-red-400 md-bg-amber-400').addClass('md-bg-green-400');
			}
			if ((barWidth + rand) >= 100) {
				$bar.css({
					'width': '100%'
				});
				clearInterval(animate);
			} else {
				$bar.css({
					'width': barWidth + rand + '%'
				});
			}
		}, 1200)
		// uikit progress
		var $UIkitBar = $('#sc-js-progress-uikit')[0];
		var UIkitanimate = setInterval(function () {
			$UIkitBar.value += 10;
			if ($UIkitBar.value >= $UIkitBar.max) {
				clearInterval(UIkitanimate);
			}
		}, 1000);
		// overlay spinners
		$('.sc-js-spinner-css').on('click', function (e) {
			e.preventDefault();
			$('.sc-spinner-overlay').remove();
			scutum.helpers.preloader.overlayShow(true);
		})
		$('.sc-js-spinner-uikit').on('click', function (e) {
			e.preventDefault()
			$('.sc-spinner-overlay').remove();
			scutum.helpers.preloader.overlayShow(false);
		})
		$('.sc-js-spinner-in-container').on('click', function (e) {
			e.preventDefault();
			$('.sc-spinner-overlay').remove();
			scutum.helpers.preloader.overlayShow(false, '#sc-spinner-container');
		})
		$('.sc-js-spinner-hide').on('click', function (e) {
			e.preventDefault();
			scutum.helpers.preloader.overlayHide();
		})
	}
};
