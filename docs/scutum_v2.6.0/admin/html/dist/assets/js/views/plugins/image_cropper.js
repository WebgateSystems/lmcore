var URL = window.URL || window.webkitURL;
var $image = $('#sc-cropper-image');
var $dataX = $('#sc-cropper-dataX');
var $dataY = $('#sc-cropper-dataY');
var $dataHeight = $('#sc-cropper-dataHeight');
var $dataWidth = $('#sc-cropper-dataWidth');
var $dataRotate = $('#sc-cropper-dataRotate');
var $dataScaleX = $('#sc-cropper-dataScaleX');
var $dataScaleY = $('#sc-cropper-dataScaleY');
var options = {
	aspectRatio: 16 / 9,
	preview: '.sc-cropper-preview',
	crop: function (e) {
		$dataX.val(Math.round(e.detail.x));
		$dataY.val(Math.round(e.detail.y));
		$dataHeight.val(Math.round(e.detail.height));
		$dataWidth.val(Math.round(e.detail.width));
		$dataRotate.val(e.detail.rotate);
		$dataScaleX.val(e.detail.scaleX);
		$dataScaleY.val(e.detail.scaleY);
	}
};
var $download = $('#sc-cropper-download');
if (typeof $download[0].download === 'undefined') {
	$download.addClass('disabled');
}

scutum.plugins.cropper = {};
scutum.plugins.cropper.init = function () {
	scutum.require(['cropper'], function () {
		// initialize cropper
		scutum.plugins.cropper.initPlugin();
		// cropper methods
		scutum.plugins.cropper.methods();
		// set aspect ratio
		scutum.plugins.cropper.aspectRatio();
		// file upload
		scutum.plugins.cropper.uploadImage();
	});
};
scutum.plugins.cropper.initPlugin = function () {
	$image.on({
		ready: function (e) {
			// console.log(e.type);
		},
		cropstart: function (e) {
			// console.log(e.type, e.detail.action);
		},
		cropmove: function (e) {
			// console.log(e.type, e.detail.action);
		},
		cropend: function (e) {
			// console.log(e.type, e.detail.action);
		},
		crop: function (e) {
			// console.log(e.type);
		},
		zoom: function (e) {
			// console.log(e.type, e.detail.ratio);
		}
	}).cropper(options);
};
scutum.plugins.cropper.aspectRatio = function () {
	$('[data-aspect-ratio]').on('click', function () {
		$(this).addClass('uk-active').siblings().removeClass('uk-active');
		options.aspectRatio = $(this).attr('data-aspect-ratio');
		$image.cropper('destroy').cropper(options);
	})
};
scutum.plugins.cropper.methods = function () {
	var $methodButtons = $('.sc-cropper-buttons');
	$methodButtons.find('button[data-method]').each(function () {
		UIkit.tooltip($(this));
	});
	$methodButtons.on('click', '[data-method]', function () {
		var $this = $(this);
		var isRadio = $this.hasClass('sc-button-radio');
		var data = $this.data();
		var cropper = $image.data('cropper');
		var cropped;
		var $target;
		var result;
		var originalImageURL = $image.attr('src');
		var uploadedImageName = 'cropped.jpg';
		var uploadedImageType = 'image/jpeg';
		var uploadedImageURL;

		if ($this.prop('disabled') || $this.hasClass('disabled')) {
			return;
		}

		if (cropper && data.method) {
			if (isRadio) {
				$this.closest('.uk-button-group').find('.sc-button-radio').removeClass('uk-active');
				$this.addClass('uk-active');
			}
			data = $.extend({}, data); // Clone a new one

			if (typeof data.target !== 'undefined') {
				$target = $(data.target);

				if (typeof data.option === 'undefined') {
					try {
						data.option = JSON.parse($target.val());
					} catch (e) {
						console.log(e.message);
					}
				}
			}

			cropped = cropper.cropped;

			switch (data.method) {
			case 'rotate':
				if (cropped && options.viewMode > 0) {
					$image.cropper('clear');
				}
				break;

			case 'getCroppedCanvas':
				if (uploadedImageType === 'image/jpeg') {
					if (!data.option) {
						data.option = {};
					}
					data.option.fillColor = '#fff';
				}
				break;
			}

			result = $image.cropper(data.method, data.option, data.secondOption);

			switch (data.method) {
			case 'rotate':
				if (cropped && options.viewMode > 0) {
					$image.cropper('crop');
				}
				break;

			case 'scaleX':
			case 'scaleY':
				$(this).data('option', -data.option);
				break;

			case 'getCroppedCanvas':
				if (result) {
					var $modal = $('#sc-getCroppedCanvasModal');
					// modal
					UIkit.modal($modal).show();
					$modal.find('.uk-modal-body').html(result);

					if (!$download.hasClass('disabled')) {
						$download.download = uploadedImageName;
						$download.attr('href', result.toDataURL(uploadedImageType));
					}
				}
				break;

			case 'destroy':
				if (uploadedImageURL) {
					URL.revokeObjectURL(uploadedImageURL);
					uploadedImageURL = '';
					$image.attr('src', originalImageURL);
				}

				break;
			}

			if ($.isPlainObject(result) && $target) {
				try {
					$target.val(JSON.stringify(result));
				} catch (e) {
					console.log(e.message);
				}
			}
		}
	});
};
scutum.plugins.cropper.uploadImage = function () {
	// Import image
	var $inputImage = $('#sc-cropper-inputImage');
	if (URL) {
		var uploadedImageName = 'cropped.jpg';
		var uploadedImageType = 'image/jpeg';
		var uploadedImageURL;
		$inputImage.change(function () {
			var files = this.files;
			var file;

			if (!$image.data('cropper')) {
				return;
			}

			if (files && files.length) {
				file = files[0];

				if (/^image\/\w+$/.test(file.type)) {
					uploadedImageName = file.name;
					uploadedImageType = file.type;

					if (uploadedImageURL) {
						URL.revokeObjectURL(uploadedImageURL);
					}

					uploadedImageURL = URL.createObjectURL(file);
					$image.cropper('destroy').attr('src', uploadedImageURL).cropper(options);
					$inputImage.val('');
				} else {
					window.alert('Please choose an image file.');
				}
			}
		});
	} else {
		$inputImage.prop('disabled', true).parent().addClass('disabled');
	}
};
