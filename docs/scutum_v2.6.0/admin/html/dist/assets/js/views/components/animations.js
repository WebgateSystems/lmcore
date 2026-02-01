scutum.components.animations = {};
scutum.components.animations.init = function () {
	$('#sc-animation-duration').on('change', function () {
		var duration = $(this).find(":selected").val();
		$('.sc-js-animations-grid').removeClass('sc-animation-default sc-animation-fast sc-animation-slow sc-animation-very-slow').addClass(duration);
	});
	$('.sc-js-repeat-animation').on('click', function (e) {
		e.preventDefault();
		var $grid = $(this).next('[data-sc-sequence-show]');
		$grid.removeClass('sc-sequence-show-processed');
		scutum.helpers.sequenceShow.init($grid, true);
	})
};
