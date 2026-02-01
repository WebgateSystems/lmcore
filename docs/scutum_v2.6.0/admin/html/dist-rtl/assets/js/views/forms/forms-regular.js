scutum.forms.regular = {};
scutum.forms.regular.init = function () {
    scutum.require(['chancejs'], function () {
        // autosize update on external change
        $('.sc-js-autosize-change').on('click', function (e) {
            e.preventDefault();
            $('#sc-js-autosize-external-change')
                .val(chance.sentence({ words: Math.floor((Math.random() * 220) + 100) }))
                .trigger('autosize.change')
        })
    })
};