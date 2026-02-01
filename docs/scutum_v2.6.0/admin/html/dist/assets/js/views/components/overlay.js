scutum.components = {};
scutum.components.overlay = {};

scutum.components.overlay.init = function () {
    $('.sc-js-content-overlay').on('click', function () {
        scutum.helpers.overlay.add('.uk-card', true)
        setTimeout(function () {
            scutum.helpers.overlay.remove()
        }, 2000)
    })
    $('.sc-js-content-overlay-spinner').on('click', function () {
        scutum.helpers.overlay.add('.uk-card', true)
        scutum.helpers.preloader.overlayShow(false, '.uk-card');
        setTimeout(function () {
            scutum.helpers.preloader.overlayHide();
            scutum.helpers.overlay.remove()
        }, 2000)
    })
    $('.sc-js-page-overlay').on('click', function () {
        scutum.helpers.overlay.add(null, true)
        setTimeout(function () {
            scutum.helpers.overlay.remove()
        }, 2000)
    })
    $('.sc-js-page-overlay-spinner').on('click', function () {
        scutum.helpers.overlay.add(null, true)
        scutum.helpers.preloader.overlayShow(false);
        setTimeout(function () {
            scutum.helpers.preloader.overlayHide();
            scutum.helpers.overlay.remove()
        }, 2000)
    })
}
