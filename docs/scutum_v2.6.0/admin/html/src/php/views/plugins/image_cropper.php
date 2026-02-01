<div id="sc-page-wrapper">
    <div id="sc-page-content">

        <div data-uk-grid>
            <div class="uk-width-2-3@l">
                <div class="uk-card">
                    <div class="uk-card-body">
                        <div id="sc-cropper-container">
                            <img src="assets/img/photos/rachel-park-366508-unsplash.jpg" id="sc-cropper-image" alt="">
                        </div>
                        <div class="sc-cropper-buttons uk-margin">
                            <div class="uk-flex uk-flex-wrap uk-flex-top" data-uk-margin>
                                <div class="uk-button-group <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon sc-button-radio uk-active" data-method="setDragMode" data-option="move" title="Move">
                                          <span class="mdi mdi-arrow-all"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon sc-button-radio" data-method="setDragMode" data-option="crop" title="Crop">
                                            <span class="mdi mdi-crop"></span>
                                    </button>
                                </div>
                                <div class="uk-button-group <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="zoom" data-option="0.1" title="Zoom In">
                                        <span class="mdi mdi-magnify-plus-outline"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="zoom" data-option="-0.1" title="Zoom Out">
                                        <span class="mdi mdi-magnify-minus-outline"></span>
                                    </button>
                                </div>
                                <div class="uk-button-group sc-buttons-stacked@s <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="move" data-option="-10" data-second-option="0" title="Move Left">
                                        <span class="mdi mdi-arrow-left"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="move" data-option="10" data-second-option="0" title="Move Right">
                                        <span class="mdi mdi-arrow-right"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="move" data-option="0" data-second-option="-10" title="Move Up">
                                        <span class="mdi mdi-arrow-up"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="move" data-option="0" data-second-option="10" title="Move Down">
                                        <span class="mdi mdi-arrow-down"></span>
                                    </button>
                                </div>
                                <div class="uk-button-group <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="rotate" data-option="-45" title="Rotate Left">
                                        <span class="mdi mdi-rotate-left"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="rotate" data-option="45" title="Rotate Right">
                                        <span class="mdi mdi-rotate-right"></span>
                                    </button>
                                </div>
                                <div class="uk-button-group <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="scaleX" data-option="-1" title="Flip Horizontal">
                                        <span class="mdi mdi-swap-horizontal"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="scaleY" data-option="-1" title="Flip Vertical">
                                        <span class="mdi mdi-swap-vertical"></span>
                                    </button>
                                </div>
                                <div class="uk-button-group <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="crop" title="Crop">
                                        <span class="mdi mdi-check"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="clear" title="Clear">
                                        <span class="mdi mdi-close"></span>
                                    </button>
                                </div>
                                <div class="uk-button-group <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon sc-button-radio" data-method="disable" title="Disable">
                                        <span class="mdi mdi-lock-outline"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon sc-button-radio uk-active" data-method="enable" title="Enable">
                                        <span class="mdi mdi-lock-open-outline"></span>
                                    </button>
                                </div>
                                <div class="uk-button-group">
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="reset" title="Reset">
                                        <span class="mdi mdi-refresh"></span>
                                    </button>
                                    <button type="button" class="sc-button sc-button-primary sc-button-icon" data-method="destroy" title="Destroy">
                                        <span class="mdi mdi-power"></span>
                                    </button>
                                </div>
                            </div>
                            <div class="uk-flex uk-margin">
                                <div class="uk-button-group sc-buttons-stacked@m">
                                    <button type="button" class="sc-button sc-button-success" data-method="getCroppedCanvas" data-option="{ &quot;maxWidth&quot;: 4096, &quot;maxHeight&quot;: 4096 }" title="Get Cropped Canvas">
                                        Get Cropped Canvas
                                    </button>
                                    <button type="button" class="sc-button sc-button-success" data-method="getCroppedCanvas" data-option="{ &quot;width&quot;: 320, &quot;height&quot;: 180 }" title="Get 320x180 Canvas">
                                        320x180
                                    </button>
                                    <button type="button" class="sc-button sc-button-success" data-method="getCroppedCanvas" data-option="{ &quot;width&quot;: 240, &quot;height&quot;: 100 }" title="Get 240x100 Canvas">
                                        240x100
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="uk-width-1-3@l">
                <div class="uk-card">
                    <div class="uk-card-body">
                        <p class="uk-margin-small">Preview:</p>
                        <div>
                            <div class="sc-cropper-preview sc-cropper-preview-lg"></div>
                            <div class="uk-width-auto@m uk-flex-top uk-grid-small uk-margin" data-uk-grid="">
                                <div><div class="sc-cropper-preview sc-cropper-preview-md"></div></div>
                                <div><div class="sc-cropper-preview sc-cropper-preview-sm"></div></div>
                                <div><div class="sc-cropper-preview sc-cropper-preview-xs"></div></div>
                            </div>
                        </div>
                        <p class="uk-margin-medium-top uk-margin-small-bottom">Aspect Ratio:</p>
                        <div>
                            <div class="uk-button-group sc-buttons-stacked@m">
                                <button type="button" class="sc-button sc-button-primary sc-button-radio uk-active" data-aspect-ratio="1.7777777777777777" title="aspectRatio: 16/9">
                                    16:9
                                </button>
                                <button type="button" class="sc-button sc-button-primary sc-button-radio" data-aspect-ratio="1.3333333333333333" title="aspectRatio: 4/3">
                                    4:3
                                </button>
                                <button type="button" class="sc-button sc-button-primary sc-button-radio" data-aspect-ratio="1" title="aspectRatio: 1/1">
                                    1:1
                                </button>
                                <button type="button" class="sc-button sc-button-primary sc-button-radio" data-aspect-ratio="0.6666666666666666" title="aspectRatio: 2/3">
                                    2:3
                                </button>
                                <button type="button" class="sc-button sc-button-primary sc-button-radio" data-aspect-ratio="NaN" title="aspectRatio: NaN">
                                    Free
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="sc-getCroppedCanvasModal" data-uk-modal aria-hidden="true" aria-labelledby="sc-getCroppedCanvasTitle" role="dialog">
            <div class="uk-modal-dialog">
                <button class="uk-modal-close-default" type="button" data-uk-close></button>
                <div class="uk-modal-header">
                    <h2 class="uk-modal-title" id="sc-getCroppedCanvasTitle">Cropped Canvas</h2>
                </div>
                <div class="uk-modal-body uk-text-center"></div>
                <div class="uk-modal-footer <?php rtlReplace('uk-text-right', 'uk-text-left'); ?>">
                    <button class="sc-button sc-button-flat sc-button-flat-danger uk-modal-close" type="button">Cancel</button>
                    <a href="javascript:void(0);" class="sc-button" id="sc-cropper-download" download="cropped.jpg">Download</a>
                </div>
            </div>
        </div>

    </div>
    <div class="js-upload" >
    </div>
    <div class="sc-fab-page-wrapper" data-uk-form-custom>
        <input type="file" id="sc-cropper-inputImage" name="file" accept=".jpg,.jpeg,.png,.gif,.bmp,.tiff">
        <button class="sc-fab sc-fab-large sc-fab-danger" type="button" tabindex="-1"><i class="mdi mdi-file-upload"></i></button>
    </div>
</div>
