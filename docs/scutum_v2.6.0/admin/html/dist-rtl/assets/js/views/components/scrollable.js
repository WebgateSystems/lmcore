scutum.components.scrollable = {};
scutum.components.scrollable.init = function () {
	scutum.require(['perfect-scrollbar'], function () {
		$('.sc-js-scrollable').each(function () {
			var $this = $(this);
			var ps = new PerfectScrollbar($this[0]);
			$this.addClass('uk-position-relative').data('ps', ps);
		})
	});
	// update drop container
	UIkit.util.on('.uk-drop', 'shown', function () {
		$('.uk-drop').find('.sc-js-scrollable').data('ps').update()
		//self.$refs.psDrop.ps.update()
	});
	// update dropdown container
	UIkit.util.on('.uk-dropdown', 'shown', function () {
		$('.uk-dropdown').find('.sc-js-scrollable').data('ps').update()
	});
};