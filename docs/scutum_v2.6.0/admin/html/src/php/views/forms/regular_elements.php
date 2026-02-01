<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-child-width-1-2@l" data-uk-grid>
			<div>
				<div class="uk-card">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>Form Inputs</span></h5>
						<form>
							<fieldset class="uk-fieldset">
								<legend class="uk-legend">Legend</legend>
								<div class="uk-margin">
									<input class="uk-input" type="text" placeholder="Input ..." data-sc-input>
								</div>
								<div class="uk-margin">
									<textarea class="uk-textarea" rows="5" placeholder="Textarea ..." data-sc-input></textarea>
								</div>
								<div class="uk-margin">
									<textarea class="uk-textarea sc-js-autosize" rows="3" placeholder="Autosize textarea ..." data-sc-input></textarea>
								</div>
                                <div class="uk-margin">
									<textarea id="sc-js-autosize-external-change" class="uk-textarea sc-js-autosize" rows="2" placeholder="Autosize textarea ..." data-sc-input></textarea>
	                                <button class="sc-button sc-button-small sc-js-autosize-change uk-margin-small-top">Change value</button>
								</div>
								<div class="uk-margin">
									<select class="uk-select">
										<option>Option 01</option>
										<option>Option 02</option>
									</select>
								</div>
								<hr>
								<div class="uk-child-width-expand@m uk-grid-divider" data-uk-grid>
									<div>
										<p class="uk-margin-small-bottom">Radio boxes (CSS)</p>
										<div class="uk-grid-small uk-child-width-auto" data-uk-grid>
											<label><input class="uk-radio" type="radio" name="radio2">A</label>
											<label><input class="uk-radio" type="radio" name="radio2" checked>B</label>
											<label><input class="uk-radio" type="radio" name="radio2c" disabled>C</label>
											<label><input class="uk-radio" type="radio" name="radio2d" checked disabled>D</label>
										</div>
									</div>
									<div>
										<p class="uk-margin-small-bottom">Checkboxes (CSS)</p>
										<div class="uk-grid-small uk-child-width-auto" data-uk-grid>
											<label><input class="uk-checkbox" type="checkbox" checked>A</label>
											<label><input class="uk-checkbox" type="checkbox">B</label>
											<label><input class="uk-checkbox" type="checkbox" disabled>C</label>
											<label><input class="uk-checkbox" type="checkbox" checked disabled>D</label>
										</div>
									</div>
									<div>
										<p class="uk-margin-mini-bottom">Switch (CSS)</p>
										<div>
											<input type="checkbox" class="sc-switch-input" id="switch-css">
											<label for="switch-css" class="sc-switch-label">
												Switch
												<span class="sc-switch-toggle-on">On</span>
												<span class="sc-switch-toggle-off">Off</span>
											</label>
										</div>
									</div>
								</div>
							</fieldset>
						</form>
					</div>
				</div>
				<div class="uk-card uk-margin-top">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>Outlined Form Inputs</span></h5>
						<div class="uk-child-width-1-2@s" data-uk-grid>
							<div>
								<label>Label</label>
								<input class="uk-input" type="text" data-sc-input="outline">
							</div>
							<div>
								<label>Label</label>
								<textarea class="uk-textarea" rows="5" data-sc-input="outline"></textarea>
							</div>
							<div>
								<input class="uk-input" type="text" placeholder="Input ..." data-sc-input="outline">
							</div>
							<div>
								<textarea class="uk-textarea" rows="5" placeholder="Textarea ..." data-sc-input="outline"></textarea>
							</div>
							<div>
								<label>Label</label>
								<input class="uk-input uk-form-danger" type="text" data-sc-input="outline">
							</div>
							<div>
								<label>Label</label>
								<input class="uk-input uk-form-success" type="text" data-sc-input="outline">
							</div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin-top">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>Help text</span></h5>
						<form>
							<div class="uk-margin">
								<input type="text" placeholder="Text input" class="uk-input uk-form-width-medium" data-sc-input><span class="uk-form-help-inline">The <code>.uk-form-help-inline</code> class creates spacing to the left.</span>
							</div>
							<div class="uk-margin-top">
								<textarea cols="30" rows="5" placeholder="Textarea" class="uk-textarea uk-form-width-large" data-sc-input></textarea>
								<p class="uk-form-help-block">The <code>.uk-form-help-block</code> class creates an associated paragraph.</p>
							</div>
						</form>
					</div>
				</div>
				<div class="uk-card uk-margin-top">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>Icons</span></h5>
						<div class="uk-child-width-1-2@s uk-flex-bottom" data-uk-grid>
							<div>
								<span class="uk-form-icon uk-form-icon-flip"><i class="mdi mdi-alert-circle"></i></span>
								<input type="text" placeholder="form-danger" class="uk-form-danger uk-input" data-sc-input>
							</div>
							<div>
								<span class="uk-form-icon uk-form-icon-flip mdi mdi-thumb-up sc-form-icon"></span>
								<label>form-success</label>
								<input type="text" class="uk-form-success uk-input" data-sc-input>
							</div>
							<div>
								<span class="uk-form-icon" data-uk-icon="icon: user"></span>
								<input class="uk-input" type="text" data-sc-input>
							</div>
							<div>
								<span class="uk-form-icon uk-form-icon-flip" data-uk-icon="icon: lock"></span>
								<input class="uk-input" type="text" data-sc-input>
							</div>
							<div>
								<label>Clickable icon</label>
								<a class="uk-form-icon sc-form-icon" href="#" data-uk-icon="icon: pencil"></a>
								<input class="uk-input" type="text" data-sc-input>
							</div>
							<div>
								<a class="uk-form-icon uk-form-icon-flip" href="#" data-uk-icon="icon: link"></a>
								<input class="uk-input" type="text" placeholder="clickable" data-sc-input>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div>
				<div class="uk-card">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>States modifiers</span></h5>
						<div class="uk-child-width-1-2@s uk-child-width-1-3@m" data-uk-grid>
							<div>
								<input type="text" placeholder="form-danger" class="uk-form-danger uk-input" data-sc-input>
							</div>
							<div>
								<input type="text" placeholder="form-success" class="uk-form-success uk-input" data-sc-input>
							</div>
							<div>
								<input type="text" placeholder="disabled" disabled class="uk-input" data-sc-input>
							</div>
							<div>
								<select disabled class="uk-select" data-sc-input>
									<option>select disabled</option>
									<option>Option 02</option>
								</select>
							</div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin-top">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>Size modifiers</span></h5>
						<div class="uk-margin">
							<label class="uk-label-large">form-large</label>
							<input type="text" class="uk-form-large uk-input" data-sc-input>
						</div>
						<div class="uk-margin">
							<label>default</label>
							<input type="text" class="uk-input" data-sc-input>
						</div>
						<div class="uk-margin">
							<label class="uk-label-small">form-small</label>
							<input type="text" class="uk-form-small uk-input" data-sc-input>
						</div>
						<h5 class="uk-heading-line uk-margin-large-top"><span>Width modifiers</span></h5>
						<div class="uk-margin">
							<form action="#">
								<div class="uk-margin-small">
									<input type="text" placeholder="uk-width-1-1" class="uk-width-1-1 uk-input" data-sc-input>
								</div>
								<div class="uk-margin-small">
									<input type="text" placeholder="large" class="uk-form-width-large uk-input" data-sc-input>
								</div>
								<div class="uk-margin-small">
									<input type="text" placeholder="medium" class="uk-form-width-medium uk-input" data-sc-input>
								</div>
								<div class="uk-margin-small">
									<input type="text" placeholder="small" class="uk-form-width-small uk-input" data-sc-input>
								</div>
								<div class="uk-margin-small">
									<input type="text" placeholder="xsmall" class="uk-form-width-xsmall uk-input" data-sc-input>
								</div>
							</form>
						</div>
						<h5 class="uk-heading-line uk-margin-large-top"><span>Form and grid</span></h5>
						<div class="uk-margin">
							<form class="uk-grid-medium" data-uk-grid>
								<div class="uk-width-1-1">
									<input class="uk-input" type="text" placeholder="100%" data-sc-input>
								</div>
								<div class="uk-width-1-2@s">
									<input class="uk-input" type="text" placeholder="50%" data-sc-input>
								</div>
								<div class="uk-width-1-4@s">
									<input class="uk-input" type="text" placeholder="25%" data-sc-input>
								</div>
								<div class="uk-width-1-4@s">
									<input class="uk-input" type="text" placeholder="25%" data-sc-input>
								</div>
								<div class="uk-width-1-2@s">
									<input class="uk-input" type="text" placeholder="50%" data-sc-input>
								</div>
								<div class="uk-width-1-2@s">
									<input class="uk-input" type="text" placeholder="50%" data-sc-input>
								</div>
							</form>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin-top">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>Horizontal form</span></h5>
						<form class="uk-form-horizontal">
							<div class="uk-margin">
								<label class="uk-form-label" for="form-h-text">Text</label>
								<div class="uk-form-controls">
									<input class="uk-input" id="form-h-text" type="text" placeholder="Some text..." data-sc-input>
								</div>
							</div>
							<div class="uk-margin">
								<label class="uk-form-label" for="form-h-select">Select</label>
								<div class="uk-form-controls">
									<select class="uk-select" id="form-h-select" data-sc-input>
										<option>Option 01</option>
										<option>Option 02</option>
									</select>
								</div>
							</div>
						</form>
					</div>
				</div>
				<div class="uk-card uk-margin-top">
					<div class="uk-card-body">
						<h5 class="uk-heading-line"><span>Custom select</span></h5>
						<div class="uk-child-width-auto@s uk-flex-middle" data-uk-grid>
							<div>
								<div data-uk-form-custom="target: true">
									<select>
										<option value="1">Option 01</option>
										<option value="2">Option 02</option>
										<option value="3">Option 03</option>
										<option value="4">Option 04</option>
									</select>
									<span></span>
								</div>
							</div>
							<div>
								<div data-uk-form-custom="target: > * > span:last-child">
									<select>
										<option value="1">Option 01</option>
										<option value="2">Option 02</option>
										<option value="3">Option 03</option>
										<option value="4">Option 04</option>
									</select>
									<span class="uk-link">
										<span data-uk-icon="icon: pencil"></span>
										<span></span>
									</span>
								</div>
							</div>
							<div>
								<div data-uk-form-custom="target: > * > span:first-child">
									<select>
										<option value="">Please select...</option>
										<option value="1">Option 01</option>
										<option value="2">Option 02</option>
										<option value="3">Option 03</option>
										<option value="4">Option 04</option>
									</select>
									<button class="sc-button sc-button-default sc-button-outline" type="button">
										<span></span>
										<span data-uk-icon="icon: chevron-down"></span>
									</button>
								</div>
							</div>
							<div>
								<div data-uk-form-custom="target: > * > span:first-child">
									<select>
										<option value="">Select user...</option>
										<option value="1">User 01</option>
										<option value="2">User 02</option>
										<option value="3">User 03</option>
										<option value="4">User 04</option>
									</select>
									<button class="sc-button sc-button-default sc-button-outline sc-button-flex sc-button-icon" type="button">
										<span class="uk-margin-small-left uk-margin-small-right"></span>
										<span class="mdi mdi-account-badge-outline uk-flex-first"></span>
										<span data-uk-icon="icon: chevron-down"></span>
									</button>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin-top">
					<div class="uk-card-body">
						<h5 class="uk-heading-line">
							<span>Custom controls</span>
						</h5>
						<div class="uk-child-width-auto@s uk-grid" data-uk-grid>
							<div>
								<div data-uk-form-custom>
									<input type="file">
									<button class="uk-button uk-button-default" type="button" tabindex="-1">
										Select
									</button>
								</div>
							</div>
							<div>
								<span class="uk-text-middle">Here is a text</span>
								<div data-uk-form-custom>
									<input type="file">
									<span class="uk-link">upload</span>
								</div>
							</div>
							<div>
								<div data-uk-form-custom="target: true">
									<input type="file">
									<input class="uk-input uk-form-width-medium uk-visible@m" type="text" placeholder="Select file" disabled>
									<input class="uk-input uk-form-width-small uk-hidden@m" type="text" placeholder="Select file" disabled>
								</div>
								<button class="uk-button uk-button-default">
									Submit
								</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
