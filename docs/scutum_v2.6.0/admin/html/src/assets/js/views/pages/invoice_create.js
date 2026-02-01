scutum.pages.invoiceCreate = {};
scutum.pages.invoiceCreate.init = function () {
    scutum.require(['flatpickr'], function () {
        flatpickr("#invoice-issueDate", {
            dateFormat: 'd-m-Y',
            defaultDate: moment().format('D-M-YYYY')
        });
    });
    scutum.forms.common.dynamicFields(null, true);
    $('#invoice-items').on('change input', '.sc-js-calculate-item', function () {
        var $this = $(this)
        var $parent = $this.closest('.uk-grid')
        var $quantity = $parent.find('[data-item="quantity"]')
        var $rate = $parent.find('[data-item="rate"]')
        var $amount = $parent.find('[data-item="amount"]')

        if(!isNaN($quantity.val()) && !isNaN($rate.val()) && $quantity.val() !== '' && $rate.val() !== '') {
            $amount.val(new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format($quantity.val() * $rate.val()))
        } else {
            $amount.val('')
        }
    })
};

