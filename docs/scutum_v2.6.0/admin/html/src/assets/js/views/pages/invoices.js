var $invoiceList = $('#sc-js-invoices-list');
var $invoice = $('#sc-js-invoice');

scutum.pages.invoices = {};
scutum.pages.invoices.init = function () {
	scutum.pages.invoices.search();
	scutum.pages.invoices.renderInvoice();
	// show notification
	var rtlReplace = scutum.helpers.isRTL() ? 'uk-margin-small-left' : 'uk-margin-small-right';
	UIkit.notification('<span class="md-color-red-400 mdi mdi-alert-outline ' + rtlReplace +'"></span> There are 3 unpaid invoices', {
		pos: scutum.helpers.mq.mediumMin() ? scutum.helpers.isRTL() ? 'bottom-right' : 'bottom-left' : 'top-center'
	});
	scutum.pages.invoices.print();
};
scutum.pages.invoices.search = function () {
	scutum.require(['listjs'], function () {
		var options = {
			searchClass: 'sc-js-list-search',
			listClass: 'uk-list',
			valueNames: ['sc-js-list-number', 'sc-js-list-company']
		};
		var list = new List('sc-js-invoices-list', options);
	});
};
scutum.pages.invoices.renderInvoice = function () {
	scutum.require(['handlebars', 'accounting'], function () {
		// Register the Handlebars Intl
		if (typeof HandlebarsIntl !== "undefined") {
			HandlebarsIntl.registerWith(Handlebars);
			var intlData = {
				"locales": "en-US"
			};
		}
		// register partial
		scutum.handlebars.getPartial('invoice-items').then(function (result) {
			Handlebars.registerPartial('invoice-items', result);
		});
		scutum.helpers.ajax('data/pages/invoices.json', 'GET', 'json').then(function (result) {
			$('#sc-js-invoices-list, #sc-offcanvas').find('ul').on('click', '>li', function (e) {
				e.preventDefault();
				var $this = $(this);
				$this.addClass('uk-active').siblings('li').removeClass('uk-active');
				// hide offcanvas
				if (scutum.helpers.mq.mediumMax()) {
					UIkit.offcanvas(scutum.$offcanvas).hide();
				}
				// show preloader
				scutum.helpers.preloader.overlayShow(false, '#sc-js-invoice');
				var $invoiceBody = $invoice.find('.uk-card-body');
				if ($invoiceBody.length) {
					$invoice.find('.uk-card-body.sc-js-el-show').velocity("transition.slideDownBigOut", {
						delay: 120,
						duration: 240
					});
					$invoice.find('.uk-card-title.sc-js-el-show').velocity("transition.fadeOut", {
						duration: 240
					});
				}
				var id = $this.attr('data-invoice-id');
				if (id) {
					scutum.helpers.findObjectByKey(result, 'id', id).then(function (response) {
						if (response) {
							var timeout = 1000;
							var items = response.items;
							var total = 0;
							items.forEach(function (item) {
								total += parseFloat(item.total);
							});
							// fake loading
							setTimeout(function () {
								scutum.helpers.preloader.overlayHide();
							}, timeout - 300);
							setTimeout(function () {
								$invoice
									.one('render.handlebars', function () {
										$invoice.find('.uk-card-body.sc-js-el-show').velocity("transition.slideUpBigIn", {
											delay: 120,
											duration: 360
										});
										$invoice.find('.uk-card-title.sc-js-el-show').velocity("transition.fadeIn", {
											duration: 360
										});
										scutum.helpers.hiResImagesProcess();
										// update grid/margins
										setTimeout(function () {
											UIkit.update();
										}, 300);
									})
									.hbRender('invoice', {
										invoice: response,
										total: parseFloat(total.toFixed(2))
									});
							}, timeout);
						}
					}).catch(function (error) { console.log('There has been a error: ' + error.message);throw error; });
				}
			});
		})
	}, false)
};
scutum.pages.invoices.print = function () {
	scutum.require(['printThis'], function () {
		scutum.$body.on('click', '.sc-js-invoice-print', function (e) {
			e.preventDefault();
			$('.sc-js-invoice-content').printThis({
				debug: true,
				importStyle: true,
				loadCSS: "assets/css/print.css"
			});
		})
	});
};
