<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-child-width-1-2@l" data-uk-grid>
			<div>
				<div class="uk-card">
					<h3 class="uk-card-title">CSS Spinners</h3>
					<div class="uk-card-body">
						<div class="uk-child-width-auto uk-grid-margin uk-flex-middle" data-uk-grid>
							<div>
								<div class="sc-spinner sc-spinner-small"></div>
							</div>
							<div>
								<div class="sc-spinner"></div>
							</div>
							<div>
								<div class="sc-spinner sc-spinner-large"></div>
							</div>
							<div>
								<div class="sc-spinner sc-spinner-small sc-spinner-secondary"></div>
							</div>
							<div>
								<div class="sc-spinner sc-spinner-secondary"></div>
							</div>
							<div>
								<div class="sc-spinner sc-spinner-large sc-spinner-secondary"></div>
							</div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin">
					<h3 class="uk-card-title">UIkit Spinners</h3>
					<div class="uk-card-body">
						<div class="uk-child-width-auto uk-grid-margin uk-flex-middle" data-uk-grid>
							<div>
								<div data-uk-spinner="ratio: 0.6"></div>
							</div>
							<div>
								<div data-uk-spinner></div>
							</div>
							<div>
								<div data-uk-spinner="ratio: 3"></div>
							</div>
							<div>
								<div class="md-color-red-600" data-uk-spinner="ratio: 2"></div>
							</div>
							<div>
								<div class="md-color-blue-600" data-uk-spinner="ratio: 2"></div>
							</div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin uk-position-relative" id="sc-spinner-container">
					<h3 class="uk-card-title">Overlay Spinners</h3>
					<div class="uk-card-body">
                        <div class="uk-height-medium uk-flex-bottom uk-flex">
                            <div class="uk-child-width-auto uk-flex-middle uk-grid-medium" data-uk-grid>
                                <div>
                                    <button class="sc-button sc-js-spinner-css">CSS</button>
                                </div>
                                <div>
                                    <button class="sc-button sc-js-spinner-uikit">UIkit</button>
                                </div>
                                <div>
                                    <button class="sc-button sc-js-spinner-in-container">In container</button>
                                </div>
                                <div>
                                    <button class="sc-button sc-js-spinner-hide">Hide</button>
                                </div>
                            </div>
                        </div>
					</div>
				</div>
			</div>
			<div>
				<div class="uk-card">
					<h3 class="uk-card-title">Progress</h3>
					<div class="uk-card-body">
						<p class="sc-color-secondary uk-margin-small">Default</p>
						<div class="sc-progress uk-margin-remove">
							<div class="sc-progress-bar md-bg-light-green-400" style="width: 62%"></div>
						</div>
						<hr>
						<p class="sc-color-secondary uk-margin-small">Small</p>
						<div class="sc-progress sc-progress-small uk-margin-remove">
							<div class="sc-progress-bar md-bg-red-400" style="width: 21%"></div>
						</div>
						<hr>
						<p class="sc-color-secondary uk-margin-small">Group</p>
						<div class="sc-progress sc-progress-small uk-margin-remove sc-progress-group">
							<div class="sc-progress-bar md-bg-red-400" style="width: 14%"></div>
							<div class="sc-progress-bar md-bg-amber-400" style="width: 25%"></div>
							<div class="sc-progress-bar md-bg-light-green-400" style="width: 31%"></div>
						</div>
						<hr>
						<div class="sc-progress sc-progress-small">
							<span class="sc-progress-label uk-text-center">Progress Label</span>
							<div class="sc-progress-bar md-bg-light-blue-800" style="width: 21%"></div>
						</div>
						<hr>
						<p class="sc-color-secondary uk-margin-small">Indeterminate</p>
						<div class="sc-progress sc-progress-small uk-margin-remove sc-progress-indeterminate">
							<div class="sc-progress-bar md-bg-light-blue-800"></div>
						</div>
						<hr>
						<p class="sc-color-secondary uk-margin-small">Dynamic progress</p>
						<div class="sc-progress sc-progress-small uk-margin-remove sc-js-progress">
							<div class="sc-progress-bar md-bg-red-400" style="width: 12%"></div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin">
					<h3 class="uk-card-title">UIkit Progress</h3>
					<div class="uk-card-body">
						<progress class="uk-progress" value="10" max="100"></progress>
						<hr>
						<progress id="sc-js-progress-uikit" class="uk-progress" value="10" max="100"></progress>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
