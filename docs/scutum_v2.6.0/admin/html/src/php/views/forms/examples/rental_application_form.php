<?php
$data_states = file_get_contents('./data/json/us_states.json');
$json_states = json_decode($data_states, TRUE);
$data_cities = file_get_contents ('./data/json/us_cities.json');
$json_cities = json_decode($data_cities, TRUE);
$data_countries = file_get_contents ('./data/json/countries.json');
$json_countries = json_decode($data_countries, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-3-4@l">
				<div class="uk-card">
					<div class="uk-card-header sc-padding">
						<div class="uk-flex uk-flex-middle">
							<div>
								<span data-uk-icon="icon:home;ratio:1.4" class="<?php rtlReplace('uk-margin-medium-right', 'uk-margin-medium-left'); ?>"></span>
							</div>
							<h3 class="uk-card-title">
								Rental Application Form
							</h3>
						</div>
					</div>
					<div class="uk-card-body">
						<form action="#">
							<ul class="uk-accordion-outline" data-uk-accordion="multiple: true">
								<li class="uk-open">
									<h3 class="uk-accordion-title">1. Personal Information</h3>
									<div class="uk-accordion-content">
										<div class="uk-child-width-1-2@m" data-uk-grid>
											<div>
												<label class="uk-form-label" for="f-f-name">First Name</label>
												<input class="uk-input" id="f-f-name" type="text" data-sc-input="outline">
											</div>
											<div>
												<label class="uk-form-label" for="f-l-name">Last Name</label>
												<input class="uk-input" id="f-l-name" type="text" data-sc-input="outline">
											</div>
										</div>
										<div class="uk-child-width-1-2@m" data-uk-grid>
											<div>
												<label class="uk-form-label" for="f-email">Email</label>
												<input class="uk-input" id="f-email" type="text" data-inputmask="'alias': 'email'" data-sc-input="outline">
											</div>
											<div>
												<label class="uk-form-label" for="f-phone">Phone Number</label>
												<input class="uk-input" id="f-phone" type="text" data-sc-input="outline">
											</div>
										</div>
										<div class="uk-child-width-1-3@m" data-uk-grid>
											<div>
												<label class="uk-form-label" for="f-birthdate">Birth Date</label>
												<input class="uk-input" id="f-birthdate" type="text" data-sc-input="outline">
											</div>
											<div>
												<label class="uk-form-label" for="f-ssn">Social Security Number</label>
												<input class="uk-input" id="f-ssn" type="text" data-inputmask="'mask': '999-99-9999'" data-sc-input="outline">
											</div>
											<div>
												<label class="uk-form-label" for="f-driver-license-number">Drivers License Number</label>
												<input class="uk-input" id="f-driver-license-number" type="text" data-inputmask="'mask': 'a999-999-99-999-9'" data-sc-input="outline">
											</div>
										</div>
									</div>
								</li>
								<li>
									<h3 class="uk-accordion-title">2. Employment History</h3>
									<div class="uk-accordion-content">
										<div class="uk-margin">
											<label class="uk-form-label" for="f-empl-recent">Current or Most Recent Employer</label>
											<input class="uk-input" id="f-empl-recent" type="text" data-sc-input="outline">
										</div>
										<div class="uk-child-width-1-3@m uk-margin-top" data-uk-grid>
											<div>
												<label class="uk-form-label" for="f-empl-position">Position</label>
												<input class="uk-input" id="f-empl-position" type="text" data-sc-input="outline">
											</div>
											<div>
												<label class="uk-form-label" for="f-empl-length">Length of Employment</label>
												<input class="uk-input" id="f-empl-length" type="text" data-sc-input="outline">
											</div>
											<div>
												<label class="uk-form-label" for="f-empl-salary">Monthly Salary</label>
												<input class="uk-input" id="f-empl-salary" type="text" data-inputmask="'alias': 'numeric', 'groupSeparator': ',', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'prefix': '$ ', 'placeholder': '0'" data-sc-input="outline">
											</div>
										</div>
										<div class="uk-child-width-1-2@m uk-margin-top" data-uk-grid>
											<div>
												<label class="uk-form-label" for="f-empl-supervisor">Supervisor Name</label>
												<input class="uk-input" id="f-empl-supervisor" type="text" data-sc-input="outline">
											</div>
											<div>
												<label class="uk-form-label" for="f-empl-supervisor-phone">Supervisor Phone</label>
												<input class="uk-input" id="f-empl-supervisor-phone" type="text" data-sc-input="outline">
											</div>
										</div>
									</div>
								</li>
								<li>
									<h3 class="uk-accordion-title">3. Rental History</h3>
									<div class="uk-accordion-content" id="sc-js-dynamic-fields-rental-history">
										<div data-sc-dynamic-fields="rentalHistoryTemplate"></div>
										<script id="rentalHistoryTemplate" type="text/x-handlebars-template">
											{{#ifCond index '>' 0 }}
											<hr class="uk-margin-medium">
											{{/ifCond}}
											<div class="uk-grid-match sc-form-section" data-uk-grid>
												<div class="uk-width-expand@m">
													<div class="uk-child-width-1-2@m" data-uk-grid>
														<div class="uk-width-expand@m">
															<label class="uk-form-label" for="f-address-{{index}}">Address</label>
															<input class="uk-input" id="f-address-{{index}}" type="text" data-sc-input="outline">
														</div>
														<div class="uk-width-1-3@m">
															<label class="uk-form-label" for="f-address-postal-{{index}}">Postal/Zip-Code</label>
															<input class="uk-input" id="f-address-postal-{{index}}" type="text" data-sc-input="outline">
														</div>
													</div>
													<div class="uk-child-width-1-3@m" data-uk-grid>
														<div>
															<label class="uk-form-label" for="f-city-{{index}}">City</label>
															<div class="uk-form-controls">
																<select name="f-employer-city" id="f-city-{{index}}" class="uk-select" data-sc-select2='{ "placeholder": "Select a city..." }'>
																	<option value=""></option>
																	<?php foreach ($json_cities as $value) { ?>
																		<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
																	<?php }; ?>
																</select>
															</div>
														</div>
														<div>
															<label class="uk-form-label" for="f-address-state-{{index}}">State/Province</label>
															<div class="uk-form-controls">
																<select name="f-address-state" id="f-address-state-{{index}}" class="uk-select" data-sc-select2='{ "placeholder": "Select a state..." }'>
																	<option value=""></option>
	<?php foreach ($json_states as $value) {?>
																	<option value="<?php echo $value['val']?>"><?php echo $value['name']?></option>
	<?php }; ?>
																</select>
															</div>
														</div>
														<div>
															<label class="uk-form-label" for="f-address-country-{{index}}">Country</label>
															<div class="uk-form-controls">
																<select name="f-address-country-{{index}}" id="f-address-country-{{index}}" class="uk-select" data-sc-select2='{"templateResult": "formatCountryResult", "templateSelection": "formatCountrySelection", "placeholder": "Select a country..."}'>
																	<option value=""></option>
	<?php foreach ($json_countries as $value) { ?>
																	<option value="<?php echo $value['code']?>"><?php echo $value['name']?></option>
	<?php }; ?>
																</select>
															</div>
														</div>
													</div>
													<hr class="uk-margin-medium">
													<div class="uk-child-width-1-2@m" data-uk-grid>
														<div>
															<div class="uk-position-relative">
																<span class="uk-form-icon uk-form-icon-flip"><i class="mdi mdi-login"></i></span>
																<label class="uk-form-label" for="f-move-in-{{index}}">Move in Date</label>
																<input class="uk-input" id="f-move-in-{{index}}" type="text" data-sc-flatpickr data-sc-input="outline">
															</div>
														</div>
														<div>
															<span class="uk-form-icon uk-form-icon-flip"><i class="mdi mdi-logout"></i></span>
															<label class="uk-form-label" for="f-move-out-{{index}}">Move out Date</label>
															<input class="uk-input" id="f-move-out-{{index}}" type="text" data-sc-flatpickr data-sc-input="outline">
														</div>
													</div>
													<hr class="uk-margin-medium">
													<div class="uk-child-width-1-2@m" data-uk-grid>
														<div>
															<label class="uk-form-label" for="f-landlord-{{index}}">Landlord Name</label>
															<input class="uk-input" id="f-landlord-{{index}}" type="text" data-sc-input="outline">
														</div>
														<div>
															<label class="uk-form-label" for="f-landlord-phone-{{index}}">Landlord Phone</label>
															<input class="uk-input" id="f-landlord-phone-{{index}}" type="text" data-sc-input="outline">
														</div>
													</div>
												</div>
												<div class="uk-width-auto@m uk-flex-middle">
													<a href="#" class="sc-js-section-clone sc-color-primary"><i class="mdi mdi-plus-box-outline sc-icon-24 sc-js-el-hide"></i><i class="mdi mdi-minus-box-outline sc-icon-24 sc-js-el-show"></i></a>
												</div>
											</div>
										</script>
									</div>
								</li>
								<li>
									<h3 class="uk-accordion-title">4. Personal References</h3>
									<div class="uk-accordion-content" id="sc-js-dynamic-fields-personal-references">
										<div data-sc-dynamic-fields="personalReferencesTemplate" data-sc-dynamic-fields-counter="1"></div>
										<script id="personalReferencesTemplate" type="text/x-handlebars-template">
											<div class="sc-form-section uk-margin-medium">
												<h5 class="uk-margin-bottom uk-heading-line">
													<span>Reference {{ index }}</span>
												</h5>
												<div class="uk-grid-match" data-uk-grid>
													<div class="uk-width-expand@m">
														<div class="uk-child-width-1-2@m" data-uk-grid>
															<div>
																<label class="uk-form-label" for="f-ref-f-name-{{index}}">First Name</label>
																<input class="uk-input" id="f-ref-f-name-{{index}}" type="text" data-sc-input="outline">
															</div>
															<div>
																<label class="uk-form-label" for="f-ref-l-name-{{index}}">Last Name</label>
																<input class="uk-input" id="f-ref-l-name-{{index}}" type="text" data-sc-input="outline">
															</div>
														</div>
														<div data-uk-grid>
															<div class="uk-width-1-3@l">
																<label class="uk-form-label" for="f-ref-relationship-{{index}}">Relationship to Applicant</label>
																<input class="uk-input" id="f-ref-relationship-{{index}}" type="text" data-sc-input="outline">
															</div>
															<div class="uk-width-1-3@l uk-width-1-2@m">
																<label class="uk-form-label" for="f-ref-phone-{{index}}">Phone</label>
																<input class="uk-input" id="f-ref-phone-{{index}}" type="text" data-sc-input="outline">
															</div>
															<div class="uk-width-1-3@l uk-width-1-2@m">
																<label class="uk-form-label" for="f-ref-email-{{index}}">Email</label>
																<input class="uk-input" id="f-ref-email-{{index}}" type="text" data-sc-input="outline">
															</div>
														</div>
													</div>
													<div class="uk-width-auto@m uk-flex-middle">
														<a href="#" class="sc-js-section-clone sc-color-primary"><i class="mdi mdi-plus-box-outline sc-icon-24 sc-js-el-hide"></i><i class="mdi mdi-minus-box-outline sc-icon-24 sc-js-el-show"></i></a>
													</div>
												</div>
											</div>
										</script>
									</div>
								</li>
								<li>
									<h3 class="uk-accordion-title">5. Other Information</h3>
									<div class="uk-accordion-content">
										<div>
											<label class="uk-form-label" for="f-info-pets">Pets (please describe)</label>
											<textarea class="uk-textarea" name="f-info-pets" id="f-info-pets" cols="30" rows="4" data-sc-input="outline"></textarea>
										</div>
										<div class="uk-margin-top">
											<label class="uk-form-label" for="f-info-vehicles">Vehicles to be parked on premises</label>
											<textarea class="uk-textarea" name="f-info-pets" id="f-info-vehicles" cols="30" rows="4" data-sc-input="outline"></textarea>
										</div>
									</div>
								</li>
							</ul>
							<div class="uk-margin-top">
								<button class="sc-button sc-button-primary sc-button-large">Submit Application</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
