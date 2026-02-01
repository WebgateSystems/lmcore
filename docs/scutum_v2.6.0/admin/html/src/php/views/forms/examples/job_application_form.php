<?php
$data_states = file_get_contents('./data/json/us_states.json');
$json_states = json_decode($data_states, TRUE);
$data_cities = file_get_contents ('./data/json/us_cities.json');
$json_cities = json_decode($data_cities, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-2-3@l">
				<div class="uk-card ">
					<div class="uk-card-body">
						<form class="uk-form-stacked ">
							<h4>Personal Informations</h4>
							<div class="md-bg-grey-100 sc-padding">
								<div class="uk-child-width-1-2@s uk-grid-divider" data-uk-grid>
									<div>
										<label class="uk-form-label" for="f-job-fname">First Name</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-job-fname" type="text">
										</div>
									</div>
									<div>
										<label class="uk-form-label" for="f-job-lname">Last Name</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-job-lname" type="text">
										</div>
									</div>
								</div>
								<hr>
								<div class="uk-grid-divider" data-uk-grid>
									<div class="uk-width-1-1@m">
										<label class="uk-form-label" for="f-job-address">Address</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-job-address" type="text">
										</div>
									</div>
									<div class="uk-width-2-5@m">
										<label class="uk-form-label" for="f-address-city">City</label>
										<div class="uk-form-controls">
											<select name="f-address-city" id="f-address-city" class="uk-select" data-sc-select2='{ "placeholder": "Select a city..."}'>
												<option value="">Select a city...</option>
												<?php foreach ($json_cities as $value) {?>
													<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
												<?php }; ?>
											</select>
										</div>
									</div>
									<div class="uk-width-2-5@m">
										<label class="uk-form-label" for="f-address-state">State</label>
										<div class="uk-form-controls">
											<select name="f-address-state" id="f-address-state" class="uk-select" data-sc-select2='{ "placeholder": "Select a state..."}'>
												<option value="">Select a state...</option>
												<?php foreach ($json_states as $value) {?>
													<option value="<?php echo $value['val']?>"><?php echo $value['name']?></option>
												<?php }; ?>
											</select>
										</div>
									</div>
									<div class="uk-width-1-5@m">
										<label class="uk-form-label" for="f-address-postal">Zip-Code</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-address-postal" type="text">
										</div>
									</div>
								</div>
								<hr>
								<div class="uk-grid-divider" data-uk-grid>
									<div class="uk-width-1-4@l uk-width-1-2@s">
										<label class="uk-form-label" for="f-job-phone-number">Phone Number</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-job-phone-number" type="text">
										</div>
									</div>
									<div class="uk-width-1-4@l uk-width-1-2@s">
										<label class="uk-form-label" for="f-job-mobile-number">Mobile Number</label>
										<div class="uk-form-controls">
											<div class="uk-position-relative">
												<span class="uk-form-icon uk-form-icon-flip"><i class="mdi mdi-alert-circle sc-color-danger"></i></span>
												<input class="uk-input uk-form-danger" id="f-job-mobile-number" type="text">
											</div>
											<span class="uk-form-help-block sc-color-danger">This field is required.</span>
										</div>
									</div>
									<div class="uk-width-1-2@l">
										<label class="uk-form-label" for="f-job-email">Email</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-job-email" type="text" data-inputmask="'alias': 'email'">
										</div>
									</div>
								</div>
							</div>
							<h4 class="uk-margin-large-top">Position</h4>
							<div class="md-bg-grey-100 sc-padding">
								<div class="uk-grid-divider" data-uk-grid>
									<div class="uk-width-1-2@l">
										<label class="uk-form-label" for="f-job-position">Position You Are Applying For</label>
										<div class="uk-form-controls">
											<select class="uk-select" name="f-job-position" id="f-job-position" data-sc-select2='{"placeholder": "Select position from the list..."}'>
												<option value="">Select position from the list...</option>
												<option value="job-p-0">Web Programmer</option>
												<option value="job-p-1">Back-end Developer</option>
												<option value="job-p-2">Mobile Developer</option>
												<option value="job-p-3">Database Developer</option>
												<option value="job-p-4">Front-end Developer</option>
												<option value="job-p-5">System Analyst</option>
												<option value="job-p-6">Business Analyst</option>
												<option value="job-p-7">Network Administrator</option>
												<option value="job-p-8">Embedded Software Engineer</option>
												<option value="job-p-9">Software Architect</option>
												<option value="job-p-10">IT Coordinator</option>
												<option value="job-p-11">Data Manager</option>
												<option value="job-p-12">Application Developer</option>
												<option value="job-p-13">Chief Information Officer – CIO</option>
												<option value="job-p-14">IT Consultant Programmer</option>
												<option value="job-p-15">IT Director Software Engineer</option>
												<option value="job-p-16">Database Administrator (DBA)</option>
												<option value="job-p-17">Telecommunications Specialist</option>
												<option value="job-p-18">IT Manager</option>
												<option value="job-p-19">Game Developer</option>
												<option value="job-p-20">PHP Developer</option>
												<option value="job-p-21">Computer Technician</option>
												<option value="job-p-22">Web Developer</option>
												<option value="job-p-23">System Security Engineer</option>
												<option value="job-p-24">Software Security Engineer</option>
											</select>
										</div>
									</div>
									<div class="uk-width-1-4@l uk-width-1-2@s">
										<label class="uk-form-label" for="dp-job-start-date">Available Start Date</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="dp-job-start-date" type="text">
										</div>
									</div>
									<div class="uk-width-1-4@l uk-width-1-2@s">
										<label class="uk-form-label" for="f-job-pay">Desired Pay</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-job-pay" type="text" data-inputmask="'alias': 'numeric', 'groupSeparator': ',', 'autoGroup': true, 'digits': 2, 'digitsOptional': false, 'prefix': '$ ', 'placeholder': '0'" />
										</div>
									</div>
								</div>
								<hr>
								<label class="uk-form-label uk-margin-small-bottom sc-padding-remove">Employment Desired</label>
								<div class="uk-child-width-auto uk-grid-medium" data-uk-grid>
									<div>
										<input type="checkbox" id="f-job-empl-full" name="f-job-empl-full" data-sc-icheck>
										<label for="f-job-empl-full">Full Time</label>
									</div>
									<div>
										<input type="checkbox" id="f-job-empl-part" name="f-job-empl-part" data-sc-icheck>
										<label for="f-job-empl-part">Part Time</label>
									</div>
									<div>
										<input type="checkbox" id="f-job-empl-temp" name="f-job-empl-temp" data-sc-icheck>
										<label for="f-job-empl-temp">Seasonal/Temporary</label>
									</div>
								</div>
							</div>
							<h4 class="uk-margin-large-top">Shift Availability</h4>
							<div class="md-bg-grey-100 sc-padding">
								<div class="uk-overflow-auto">
									<table class="uk-table uk-table-small">
										<thead>
											<tr>
												<th></th>
												<th class="uk-text-center">Monday</th>
												<th class="uk-text-center">Tuesday</th>
												<th class="uk-text-center">Wednesday</th>
												<th class="uk-text-center">Thursday</th>
												<th class="uk-text-center">Friday</th>
												<th class="uk-text-center">Saturday</th>
												<th class="uk-text-center">Sunday</th>
											</tr>
										</thead>
										<tbody>
											<tr>
												<td>From</td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
											</tr>
											<tr>
												<td>To</td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
												<td><input type="text" class="uk-input uk-form-small uk-text-center" data-inputmask="'alias': 'datetime', 'inputformat': 'HH', 'clearIncomplete': true" /></td>
											</tr>
											<tr>
												<td>Overnight</td>
												<td class="uk-text-center"><input type="checkbox" id="shift-night-1" name="square-radio" data-sc-icheck></td>
												<td class="uk-text-center"><input type="checkbox" id="shift-night-2" name="square-radio" data-sc-icheck></td>
												<td class="uk-text-center"><input type="checkbox" id="shift-night-3" name="square-radio" data-sc-icheck></td>
												<td class="uk-text-center"><input type="checkbox" id="shift-night-4" name="square-radio" data-sc-icheck></td>
												<td class="uk-text-center"><input type="checkbox" id="shift-night-5" name="square-radio" data-sc-icheck></td>
												<td class="uk-text-center"><input type="checkbox" id="shift-night-6" name="square-radio" data-sc-icheck></td>
												<td class="uk-text-center"><input type="checkbox" id="shift-night-7" name="square-radio" data-sc-icheck></td>
											</tr>
										</tbody>
									</table>
								</div>
							</div>
							<h4 class="uk-margin-large-top">Education</h4>
							<div class="md-bg-grey-100 sc-padding">
								<div class="uk-overflow-auto">
									<table class="uk-table uk-table-small uk-table-middle uk-table-divider uk-margin-remove" id="sc-js-dynamic-fields-education">
										<thead>
											<tr>
												<th></th>
												<th class="uk-text-nowrap">School Name</th>
												<th class="uk-text-nowrap">Location</th>
												<th class="uk-text-nowrap">Years Attended</th>
												<th class="uk-text-nowrap">Degree Received</th>
												<th class="uk-text-nowrap">Major</th>
												<th></th>
											</tr>
										</thead>
										<tbody data-sc-dynamic-fields="educationTemplate"></tbody>
									</table>
									<script id="educationTemplate" type="text/x-handlebars-template">
										<tr class="sc-form-section">
											<td class="sc-js-edu-counter">1</td>
											<td class="uk-width-1-3"><input type="text" class="uk-input uk-form-small" name="f-edu-school-{{index}}" /></td>
											<td><input type="text" class="uk-input uk-form-small" name="f-edu-location-{{index}}" /></td>
											<td><input type="text" class="uk-input uk-form-small" name="f-edu-years-{{index}}" /></td>
											<td><input type="text" class="uk-input uk-form-small" name="f-edu-degree-{{index}}" /></td>
											<td><input type="text" class="uk-input uk-form-small" name="f-edu-major-{{index}}" /></td>
											<td class="uk-table-middle uk-text-center">
												<a href="#" class="sc-js-section-clone sc-color-primary"><i class="mdi mdi-plus sc-icon-24 sc-js-el-hide"></i><i class="mdi mdi-minus sc-icon-24 sc-js-el-show"></i></a>
											</td>
										</tr>
									</script>
								</div>
							</div>
							<h4 class="uk-margin-large-top">Employment History</h4>
							<div class="md-bg-grey-100 sc-padding" id="sc-js-dynamic-fields-empl-history">
								<div data-sc-dynamic-fields="emplHistoryTemplate"></div>
								<script id="emplHistoryTemplate" type="text/x-handlebars-template">
									{{#ifCond index '>' 0 }}
									<hr class="uk-margin-medium">
									{{/ifCond}}
									<div class="uk-grid-match sc-form-section" data-uk-grid>
										<div class="uk-width-expand@m">
											<div class="uk-child-width-1-2@s" data-uk-grid>
												<div>
													<label class="uk-form-label" for="f-employer-{{index}}">Employer</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-{{index}}" type="text">
													</div>
												</div>
												<div>
													<label class="uk-form-label" for="f-employer-title-{{index}}">Job Title</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-title-{{index}}" type="text">
													</div>
												</div>
											</div>
											<div class="uk-child-width-1-4@s uk-margin-top" data-uk-grid>
												<div>
													<label class="uk-form-label" for="f-employer-dates-{{index}}">Dates Employed</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-dates-{{index}}" type="text">
													</div>
												</div>
												<div>
													<label class="uk-form-label" for="f-employer-phone-{{index}}">Work Phone</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-phone-{{index}}" type="text">
													</div>
												</div>
												<div>
													<label class="uk-form-label" for="f-employer-starting-rate-{{index}}">Starting Pay Rate</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-starting-rate-{{index}}" type="text">
													</div>
												</div>
												<div>
													<label class="uk-form-label" for="f-employer-ending-rate-{{index}}">Ending Pay Rate</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-ending-rate-{{index}}" type="text">
													</div>
												</div>
											</div>
											<div class="uk-margin-top" data-uk-grid>
												<div class="uk-width-1-2@m">
													<label class="uk-form-label" for="f-employer-address-{{index}}">Address</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-address-{{index}}" type="text">
													</div>
												</div>
												<div class="uk-width-1-4@m uk-width-1-2@s">
													<label class="uk-form-label" for="f-employer-city-{{index}}">City</label>
													<div class="uk-form-controls">
														<select name="f-employer-city" id="f-employer-city-{{index}}" class="uk-select">
															<option value=""></option>
															<?php foreach ($json_cities as $value) {?>
																<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
															<?php }; ?>
														</select>
													</div>
												</div>
												<div class="uk-width-1-4@m uk-width-1-2@s">
													<label class="uk-form-label" for="f-employer-postal-{{index}}">Zip Code</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="f-employer-postal-{{index}}" type="text">
													</div>
												</div>
											</div>
										</div>
										<div class="uk-width-auto@m uk-flex-middle uk-text-center">
											<a href="#" class="sc-js-section-clone sc-color-primary"><i class="mdi mdi-plus-box-outline sc-icon-24 sc-js-el-hide"></i><i class="mdi mdi-minus-box-outline sc-icon-24 sc-js-el-show"></i></a>
										</div>
									</div>
								</script>
							</div>
							<div class="uk-margin-large-top">
								<button class="sc-button sc-button-large sc-button-primary">Send Application</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
