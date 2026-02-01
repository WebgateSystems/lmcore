<?php
$data_states = file_get_contents('./data/json/us_states.json');
$json_states = json_decode($data_states, TRUE);
$data_cities = file_get_contents ('./data/json/us_cities.json');
$json_cities = json_decode($data_cities, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-card uk-margin">
			<h3 class="uk-card-title">Select/Tagging</h3>
			<div class="uk-card-body">
				<div class="uk-child-width-1-2@m uk-flex-bottom" data-uk-grid>
					<div>
						<select name="select-basic" id="select-basic" class="uk-select">
						<?php foreach ($json_states as $value) {?>
							<option value="<?php echo $value['val']?>"><?php echo $value['name']?></option>
						<?php }; ?>
						</select>
					</div>
					<div>
						<select name="select-multiple" id="select-multiple" class="uk-select" multiple>
							<?php foreach ($json_cities as $value) {?>
								<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
							<?php }; ?>
						</select>
					</div>
				</div>
			</div>
		</div>
		<div class="uk-card uk-margin">
			<h3 class="uk-card-title">Datepicker</h3>
			<div class="uk-card-body">
				<div class="uk-child-width-1-4@l uk-child-width-1-2@m" data-uk-grid>
					<div>
						<input type="text" class="uk-input" data-sc-flatpickr placeholder="Pick a date...">
						<p class="uk-form-help-block">Basic</p>
					</div>
					<div>
						<input type="text" class="uk-input" data-sc-flatpickr='{ "altInput": true, "altFormat": "F j, Y" }' placeholder="Pick a date...">
						<p class="uk-form-help-block">Human-readable date</p>
					</div>
					<div>
						<input type="text" class="uk-input" id="dp-time" placeholder="Pick a date and time...">
						<p class="uk-form-help-block">Datetime picker</p>
					</div>
					<div>
						<input type="text" class="uk-input" data-sc-flatpickr='{ "mode": "range" }' placeholder="Pick a date range...">
						<p class="uk-form-help-block">Selecting a Range of Dates</p>
					</div>
				</div>
				<div data-uk-grid>
					<div class="uk-width-1-4@l uk-width-1-2@m">
						<div class="uk-position-relative" id="dp-multiple">
							<a class="uk-form-icon uk-form-icon-flip" href="#" data-uk-icon="icon: close" data-clear></a>
							<input type="text" class="uk-input" placeholder="Pick a multiple dates..." data-input>
						</div>
					</div>
					<div class="uk-width-1-4@l uk-width-1-2@m">
						<div class="uk-position-relative" data-sc-flatpickr='{ "wrap": true, "clickOpens": false}'>
							<a class="uk-form-icon uk-form-icon-flip" href="#" data-uk-icon="icon: close" data-clear></a>
							<a class="uk-form-icon uk-form-icon-flip" href="#" data-uk-icon="icon: calendar" data-toggle></a>
							<input class="uk-input" type="text" placeholder="Pick a date..." data-input>
						</div>
					</div>
					<div class="uk-width-1-2@l  uk-width-1-1@m">
						<input type="hidden" class="uk-input uk-hidden" id="dp-inline">
					</div>
				</div>
			</div>
		</div>
		<div class="uk-card uk-margin">
			<h3 class="uk-card-title">Timepicker</h3>
			<div class="uk-card-body">
				<div class="uk-child-width-1-3@m" data-uk-grid>
					<div>
						<div class="uk-position-relative">
							<input type="text" class="uk-input" data-sc-flatpickr='{ "enableTime": true, "noCalendar": true, "dateFormat": "H:i" }' placeholder="Pick a time..." data-input>
						</div>
					</div>
					<div>
						<div class="uk-position-relative">
							<input type="text" class="uk-input" id="dp-timepicker-24" placeholder="Pick a time..." data-input>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="uk-card uk-margin">
			<h3 class="uk-card-title">DateRangePicker</h3>
			<div class="uk-card-body">
				<div class="uk-child-width-1-3@m" data-uk-grid>
					<div>
						<input type="text" class="uk-input" id="drp-default" data-sc-input>
						<p class="uk-form-help-block">Default</p>
					</div>
					<div>
						<input type="text" class="uk-input" id="drp-timeEnabled" data-sc-input>
						<p class="uk-form-help-block">Time Enabled</p>
					</div>
					<div>
						<input type="text" class="uk-input" id="drp-shortcuts" data-sc-input>
						<p class="uk-form-help-block">Future date shortcuts</p>
					</div>
					<div>
						<input type="text" class="uk-input" id="drp-extra-content" data-sc-input>
						<p class="uk-form-help-block">Extra content</p>
					</div>
				</div>
			</div>
		</div>
        <div class="uk-card uk-margin">
            <h3 class="uk-card-title">Colorpicker</h3>
            <div class="uk-card-body">
                <div class="uk-grid-small" data-uk-grid>
                    <div class="uk-width-1-4@m">
                        <label>Default</label>
	                    <div>
                            <input type="text" data-sc-colorpicker id="cp123">
	                    </div>
                    </div>
                    <div class="uk-width-1-4@m">
                        <label>Default (right aligned)</label>
                        <div class="uk-flex uk-flex-right">
                            <input type="text" data-sc-colorpicker>
                        </div>
                    </div>
                    <div class="uk-width-1-4@m">
                        <label>Selected color</label>
	                    <div>
                            <input type="text" value="#039be5" data-sc-colorpicker>
	                    </div>
                    </div>
                    <div class="uk-width-1-2@m">
                        <label>Inline</label>
	                    <div>
                            <input type="text" data-sc-colorpicker='{"inline": true}'>
	                    </div>
                    </div>
                </div>
            </div>
        </div>
		<div class="uk-card uk-margin">
			<h3 class="uk-card-title">Range Slider</h3>
			<div class="uk-card-body">
				<div class="uk-child-width-1-3@l uk-child-width-1-2@m" data-uk-grid>
					<div>
						<input type="text" class="uk-input" id="range-01">
					</div>
					<div>
						<input type="text" class="uk-input" id="range-02">
					</div>
					<div>
						<input type="text" class="uk-input" id="range-03">
					</div>
				</div>
				<div class="uk-child-width-1-3@l uk-child-width-1-2@m" data-uk-grid>
					<div>
						<input type="text" class="uk-input" id="range-04">
					</div>
					<div>
						<input type="text" class="uk-input" id="range-05">
					</div>
					<div>
						<input type="text" class="uk-input" id="range-06">
					</div>
				</div>
			</div>
		</div>
		<div class="uk-card">
			<h3 class="uk-card-title">Multiselect</h3>
			<div class="uk-card-body">
				<div class="uk-child-width-1-2@l" data-uk-grid>
					<div>
						<p class="uk-margin-small sc-color-secondary">Default</p>
						<select multiple id="ms-pre-selected-options" class="multiselect" name="pre-selected-options[]">
							<?php for ($i=1;$i<101;$i++) { ?>
								<option value="elem_<?php echo $i;?>"<?php if($i == 4 || $i == 26) { ?> selected<?php }; ?><?php if($i == 6) { ?> disabled<?php }; ?>><?php echo $faker->userName;?></option>
							<?php }; ?>
						</select>
					</div>
					<div>
						<p class="uk-margin-small sc-color-secondary">Optgroups</p>
						<select id="ms-optgroup" multiple>
							<optgroup label="Friends">
								<option value="1">Yoda</option>
								<option value="2">Luke Skywalker</option>
								<option value="3">Han Solo</option>
								<option value="4" selected>Obi Wan Kenobi</option>
							</optgroup>
							<optgroup label="Enemies">
								<option value="5">Emperor Palpatine</option>
								<option value="6">Darth Maul</option>
								<option value="7" disabled>Darth Vader</option>
								<option value="8">Count Dooku</option>
							</optgroup>
						</select>
					</div>
				</div>
				<hr>
				<div class="uk-child-width-1-2@l" data-uk-grid>
					<div>
						<p class="uk-margin-small sc-color-secondary">Custom header/footer</p>
						<select id="ms-custom-headers" multiple>
							<?php for ($i=1;$i<=20;$i++) { ?>
								<option value="elem_<?php echo $i;?>"<?php if($i == 4 || $i == 26) { ?> selected<?php }; ?>><?php echo $faker->userName;?></option>
							<?php }; ?>
						</select>
					</div>
					<div>
						<p class="uk-margin-small sc-color-secondary">Searchable</p>
						<select id="ms-searchable" multiple>
<?php $i=0;foreach ($json_cities as $value) {?>
								<option value="<?php echo $value['rank']?>"<?php if($i > 8 && $i < 20) { ?> selected<?php }; ?>><?php echo $value['city']?></option>
<?php $i++; }; ?>
						</select>
					</div>
				</div>
				<hr>
				<div class="uk-child-width-1-2@l" data-uk-grid>
					<div>
						<p class="uk-margin-small sc-color-secondary">Public methods</p>
						<select multiple id="ms-public-methods" class="multiselect" name="public-methods[]">
							<?php for ($i=1;$i<501;$i++) { ?>
								<option value="elem_<?php echo $i;?>"<?php if($i == 8) { ?> disabled<?php }; ?>><?php echo $faker->city;?></option>
							<?php }; ?>
						</select>
					</div>
					<div data-uk-margin>
						<a class="sc-button sc-button-default sc-button-small sc-button-outline" href="#" id="ms-select-all">select all</a>
						<a class="sc-button sc-button-default sc-button-small sc-button-outline" href="#" id="ms-deselect-all">deselect all</a>
						<br>
						<a class="sc-button sc-button-default sc-button-small sc-button-outline" href="#" id="ms-select-10">select 10 elems</a>
						<a class="sc-button sc-button-default sc-button-small sc-button-outline" href="#" id="ms-deselect-10">deselect 10 elems</a>
					</div>
				</div>
			</div>
		</div>
		<div class="uk-margin" data-uk-grid>
			<div class="uk-width-1-2@l">
				<div class="uk-card">
					<h3 class="uk-card-title">Checkbox, radio</h3>
					<div class="uk-card-body">
						<div class="uk-child-width-1-2@s uk-child-width-1-3@m" data-uk-grid>
							<div>
								<ul class="uk-list">
									<li>
										<input type="checkbox" id="square-checkbox-1" data-sc-icheck>
										<label for="square-checkbox-1">Checkbox 1</label>
									</li>
									<li>
										<input type="checkbox" id="square-checkbox-2" checked data-sc-icheck>
										<label for="square-checkbox-2">Checkbox 2</label>
									</li>
									<li>
										<input type="checkbox" id="square-checkbox-disabled" disabled data-sc-icheck>
										<label for="square-checkbox-disabled">Disabled</label>
									</li>
									<li>
										<input type="checkbox" id="square-checkbox-disabled-checked" checked disabled data-sc-icheck>
										<label for="square-checkbox-disabled-checked">Disabled &amp; checked</label>
									</li>
								</ul>
							</div>
							<div>
								<ul class="uk-list">
									<li>
										<input type="radio" id="square-radio-1" name="square-radio" data-sc-icheck>
										<label for="square-radio-1">Radio button 1</label>
									</li>
									<li>
										<input type="radio" id="square-radio-2" name="square-radio" checked data-sc-icheck>
										<label for="square-radio-2">Radio button 2</label>
									</li>
									<li>
										<input type="radio" id="square-radio-disabled" disabled data-sc-icheck>
										<label for="square-radio-disabled">Disabled</label>
									</li>
									<li>
										<input type="radio" id="square-radio-disabled-checked" checked disabled data-sc-icheck>
										<label for="square-radio-disabled-checked">Disabled &amp; checked</label>
									</li>
								</ul>
							</div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin">
					<h3 class="uk-card-title">Switches</h3>
					<div class="uk-card-body">
						<div class="uk-child-width-1-3@s" data-uk-grid>
							<div>
								<input type="checkbox" id="sw-a" data-sc-switchery checked /><label for="sw-a" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Checked</label>
							</div>
							<div>
								<input type="checkbox" id="sw-b" data-sc-switchery disabled /><label for="sw-b" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Disabled</label>
							</div>
						</div>
						<p class="uk-margin uk-margin-medium-top uk-heading-line"><span>Sizes</span></p>
						<div class="uk-child-width-1-3@s" data-uk-grid>
							<div>
								<input type="checkbox" id="sw-c" data-sc-switchery data-switchery-size="small" /><label for="sw-c" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Small</label>
							</div>
							<div>
								<input type="checkbox" id="sw-d" data-sc-switchery checked /><label for="sw-d" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Regular</label>
							</div>
							<div>
								<input type="checkbox" id="sw-e" data-sc-switchery data-switchery-size="large" /><label for="sw-e" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">large</label>
							</div>
						</div>
						<p class="uk-margin uk-margin-medium-top uk-heading-line"><span>Colors</span></p>
						<div class="uk-child-width-1-3@s" data-uk-grid>
							<div>
								<input type="checkbox" id="sw-f" data-sc-switchery data-switchery-color="#0277BD" data-switchery-secondary-color="#D84315" /><label for="sw-f" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Label</label>
							</div>
							<div>
								<input type="checkbox" id="sw-g" data-sc-switchery checked data-switchery-color="#546E7A" data-switchery-secondary-color="#6A1B9A"/><label for="sw-g" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Label</label>
							</div>
						</div>
						<p class="uk-margin uk-margin-medium-top uk-heading-line"><span>Manual Toggle</span></p>
						<div class="uk-child-width-1-4@s" data-uk-grid>
							<div>
								<input type="checkbox" id="sw-toggle" data-sc-switchery/>
							</div>
							<div>
								<button class="sc-button sc-button-small" id="sw-toggle-btn">Toggle</button>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="uk-width-1-2@l">
				<div class="uk-card">
					<h3 class="uk-card-title">Rating</h3>
					<div class="uk-card-body">
						<div class="uk-child-width-1-2@m" data-uk-grid>
							<div>
								<div data-sc-raty></div>
								<span class="uk-form-help-block">Default</span>
							</div>
							<div>
								<div class="raty-small" data-sc-raty></div>
								<span class="uk-form-help-block">small</span>
							</div>
							<div>
								<div class="raty-large" data-sc-raty></div>
								<span class="uk-form-help-block">Large</span>
							</div>
						</div>
						<div class="uk-child-width-1-2@m" data-uk-grid>
							<div>
								<div data-sc-raty='{ "half": true }'></div>
								<span class="uk-form-help-block">Half Star</span>
							</div>
							<div>
								<div data-sc-raty='{ "cancel": true }'></div>
								<span class="uk-form-help-block">Cancel Button</span>
							</div>
						</div>
						<div class="uk-child-width-1-2@m" data-uk-grid>
							<div>
								<div data-sc-raty='{ "score": 4 }'></div>
								<span class="uk-form-help-block">Saved Score</span>
							</div>
							<div>
								<div data-sc-raty='{ "score": 2, "readOnly": true }'></div>
								<span class="uk-form-help-block">Read Only</span>
							</div>
						</div>
						<div class="uk-margin-medium-top">
							<div data-sc-raty='{ "number": 10 }'></div>
							<span class="uk-form-help-block">10 Stars</span>
						</div>
					</div>
				</div>
				<div class="uk-card uk-margin">
					<h3 class="uk-card-title">Inputmasks</h3>
					<div class="uk-card-body">
						<form>
							<div class="uk-margin-small">
								<input class="uk-input" data-inputmask="'alias': 'datetime', 'inputformat' : 'dd/mm/yyyy'" data-sc-input />
                                <div class="uk-overflow-auto">
								    <p class="uk-form-help-block"><code>'alias': 'datetime', 'inputformat' : 'dd/mm/yyyy'</code></p>
                                </div>
							</div>
							<div class="uk-margin-small">
								<input class="uk-input" data-inputmask="'mask': '9', 'repeat': 10, 'greedy' : false" data-sc-input />
                                <div class="uk-overflow-auto">
								    <p class="uk-form-help-block"><code>'mask': '9', 'repeat': 10, 'greedy' : false</code></p>
                                </div>
							</div>
							<div class="uk-margin-small">
								<input class="uk-input" data-inputmask="'mask': '99-9999999'" data-sc-input />
                                <div class="uk-overflow-auto">
								    <p class="uk-form-help-block"><code>'mask': '99-9999999'</code></p>
                                </div>
							</div>
							<div class="uk-margin-small">
								<input class="uk-input" data-inputmask="'alias': 'numeric', 'groupSeparator': ',', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'prefix': '$ ', 'placeholder': '0'" data-sc-input />
								<div class="uk-overflow-auto"><p class="uk-form-help-block"><code>'alias': 'numeric', 'groupSeparator': ',', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'prefix': '$ ', 'placeholder': '0'</code></p></div>
							</div>
							<div class="uk-margin-small">
								<input class="uk-input" data-inputmask="'alias': 'email'" data-sc-input />
								<p class="uk-form-help-block"><code>'alias': 'email'</code></p>
							</div>
							<div class="uk-margin-small">
								<input class="uk-input" data-inputmask="'alias': 'ip'" data-sc-input />
								<p class="uk-form-help-block"><code>'alias': 'ip'</code></p>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
