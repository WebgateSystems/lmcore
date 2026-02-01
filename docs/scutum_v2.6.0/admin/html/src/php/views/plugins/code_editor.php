<div id="sc-page-wrapper">
	<div id="sc-page-content" class="uk-height-1-1 uk-flex uk-flex-center sc-page-over-header">
		<div class="uk-width-5-6@l uk-height-1-1">
			<div class="uk-card uk-height-1-1">
				<div class="uk-grid-collapse uk-grid-divider uk-height-1-1" data-uk-grid>
					<div id="cmEditor-col" class="uk-width-expand@s uk-height-1-1 uk-flex uk-flex-column">
						<div class="uk-card-header sc-padding sc-padding-medium-ends">
							<div class="uk-flex uk-flex-middle">
								<div class="uk-flex-1">
									<h3 class="uk-card-title">Code Editor</h3>
								</div>
								<div class="sc-actions">
                                    <a href="#" class="sc-actions-icon mdi mdi-content-save"></a>
                                    <a href="#" class="sc-actions-icon mdi mdi-fullscreen" id="sc-code-editor-fs-enable"></a>
                                </div>
							</div>
						</div>
                        <div class="uk-card-body sc-padding-remove">
                            <textarea name="sc-code-editor" id="sc-code-editor" cols="30" rows="10"></textarea>
                        </div>
					</div>
			        <div class="uk-width-1-4@s sc-js-column uk-visible@l" data-column-collapse-callback="scutum.plugins.codeEditor.refresh">
				        <div class="uk-card-header sc-padding sc-padding-medium-ends">
					        <div class="uk-flex uk-flex-middle">
						        <div class="uk-flex-1 sc-js-el-hide">
							        <h3 class="uk-card-title">Files</h3>
						        </div>
                                <a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-column-collapse" data-uk-tooltip title="Hide files"></a>
                                <a href="#" class="sc-actions-icon mdi mdi-file-outline sc-js-el-show sc-js-column-expand" data-uk-tooltip title="Show files"></a>
					        </div>
				        </div>
				        <div class="uk-card-body sc-js-el-hide">
					        <ul class="uk-list uk-list-divider sc-list-hoverable sc-code-editor-files">
                                <li class="sc-list-group uk-active">
                                    <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
                                    <a href="#" class="sc-list-body sc-flex-items-left" data-file="index.html" data-mode="html">
                                        <span class="sc-text-semibold sc-width-expand">index.html</span>
                                        <span class="sc-list-secondary-text uk-text-small">Modified: 27/11/2019</span>
                                    </a>
                                </li>
						        <li class="sc-list-group">
                                    <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
							        <a href="#" class="sc-list-body sc-flex-items-left" data-file="database.php" data-mode="php">
								        <span class="sc-text-semibold sc-width-expand">database.php</span>
								        <span class="sc-list-secondary-text uk-text-small">Modified: 24/11/2019</span>
							        </a>
						        </li>
                                <li class="sc-list-group">
                                    <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
                                    <a href="#" class="sc-list-body sc-flex-items-left">
                                        <span class="sc-text-semibold sc-width-expand" data-file="helpers.js" data-mode="js">helpers.js</span>
                                        <span class="sc-list-secondary-text uk-text-small">Modified: 22/11/2019</span>
                                    </a>
                                </li>
                                <li class="sc-list-group">
                                    <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
                                    <a href="#" class="sc-list-body sc-flex-items-left" data-file="data.json" data-mode="json">
                                        <span class="sc-text-semibold sc-width-expand">data.json</span>
                                        <span class="sc-list-secondary-text uk-text-small">Modified: 22/11/2019</span>
                                    </a>
                                </li>
                                <li class="sc-list-group">
                                    <div class="sc-list-addon"><i class="mdi mdi-file-alert-outline md-color-red-500"></i></div>
                                    <a href="#" class="sc-list-body sc-flex-items-left" data-file="" data-mode="php">
                                        <span class="sc-text-semibold sc-width-expand">config.php</span>
                                        <span class="sc-list-secondary-text uk-text-small">Modified: 14/11/2019</span>
                                    </a>
                                </li>
					        </ul>
				        </div>
			        </div>
				</div>
			</div>
		</div>
	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar">
	    <p class="uk-text-large">Files</p>
        <ul class="uk-list uk-list-divider sc-list-hoverable sc-code-editor-files">
            <li class="sc-list-group uk-active">
                <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
                <a href="#" class="sc-list-body sc-flex-items-left" data-file="index.html" data-mode="html">
                    <span class="sc-text-semibold sc-width-expand">index.html</span>
                    <span class="sc-list-secondary-text uk-text-small">Modified: 27/11/2019</span>
                </a>
            </li>
            <li class="sc-list-group">
                <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
                <a href="#" class="sc-list-body sc-flex-items-left" data-file="database.php" data-mode="php">
                    <span class="sc-text-semibold sc-width-expand">database.php</span>
                    <span class="sc-list-secondary-text uk-text-small">Modified: 24/11/2019</span>
                </a>
            </li>
            <li class="sc-list-group">
                <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
                <a href="#" class="sc-list-body sc-flex-items-left">
                    <span class="sc-text-semibold sc-width-expand" data-file="helpers.js" data-mode="js">helpers.js</span>
                    <span class="sc-list-secondary-text uk-text-small">Modified: 22/11/2019</span>
                </a>
            </li>
            <li class="sc-list-group">
                <div class="sc-list-addon"><i class="mdi mdi-file-outline"></i></div>
                <a href="#" class="sc-list-body sc-flex-items-left" data-file="data.json" data-mode="json">
                    <span class="sc-text-semibold sc-width-expand">data.json</span>
                    <span class="sc-list-secondary-text uk-text-small">Modified: 22/11/2019</span>
                </a>
            </li>
            <li class="sc-list-group">
                <div class="sc-list-addon"><i class="mdi mdi-file-alert-outline md-color-red-500"></i></div>
                <a href="#" class="sc-list-body sc-flex-items-left" data-file="" data-mode="php">
                    <span class="sc-text-semibold sc-width-expand">config.php</span>
                    <span class="sc-list-secondary-text uk-text-small">Modified: 14/11/2019</span>
                </a>
            </li>
        </ul>
    </div>
</div>
