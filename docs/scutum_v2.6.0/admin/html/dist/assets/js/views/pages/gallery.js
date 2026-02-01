scutum.pages.gallery = {};
scutum.pages.gallery.init = function () {
	var $grid = $('#sc-gallery-grid');
	// fix for masonry grid height
	var recalculateHeight = function () {
		var height = 0;
		$grid.children('div').each(function () {
			var $this = $(this);
			var bottom = parseInt(($this.position().top + $this.outerHeight()).toFixed(2));
			if (bottom >= height) {
				height = bottom;
			}
		});
		$grid.height((height + 24).toFixed(2));
	}
	// recalculate height on windows resize
	scutum.$win.on('resize', function () {
		UIkit.update($grid);
		setTimeout(function () {
			recalculateHeight();
		}, 150);
	})
	scutum.require(['imagesLoaded'], function () {
		$grid.imagesLoaded()
			.done(function (instance) {
				// initialize grid when all images are loaded
				UIkit.grid($grid, {
					masonry: true
				});
				// set height for masonry grid
				setTimeout(function () {
					recalculateHeight();
					$grid.addClass('sc-massonry-grid')
				}, 50);
			});
	});
}
