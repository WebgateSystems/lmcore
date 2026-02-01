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
			<div class="uk-width-2-3@xl uk-width-3-4@l ">
				<div class="uk-card">
					<div class="uk-card-header">
						<div class="uk-flex uk-flex-middle">
							<i class="mdi mdi-calendar sc-icon-24 uk-margin-medium-right"></i>
							<h3 class="uk-card-title">
								Booking Form
							</h3>
						</div>
					</div>
					<div class="uk-card-body">
						<form id="sc-booking-form">
							<h4 class="uk-heading-line uk-margin-medium-bottom"><span>Arrival/Departure Date</span></h4>
							<div id="drp-arival-departure-container" class="uk-margin-medium-bottom date-picker-custom no-top-bar no-padding large-picker"></div>
							<div class="uk-child-width-1-3@l uk-child-width-1-2@m" data-uk-grid id="drp-arival-departure">
								<div>
									<label class="uk-form-label" for="drp-arival">Arrival Date</label>
									<input class="uk-input" id="drp-arival" type="text" data-sc-input>
								</div>
								<div>
									<label class="uk-form-label" for="drp-departure">Departure Date</label>
									<input class="uk-input" id="drp-departure" type="text" data-sc-input>
								</div>
							</div>
							<h4 class="uk-heading-line uk-margin-xlarge-top uk-margin-medium-bottom"><span>Personal Informations</span></h4>
							<div class="uk-child-width-1-2@m" data-uk-grid>
								<div>
									<label class="uk-form-label" for="f-f-name">First Name</label>
									<input class="uk-input" id="f-f-name" type="text" data-sc-input>
								</div>
								<div>
									<label class="uk-form-label" for="f-l-name">Last Name</label>
									<input class="uk-input" id="f-l-name" type="text" data-sc-input>
								</div>
							</div>
							<div class="uk-child-width-1-2@m uk-margin-top" data-uk-grid>
								<div>
									<label class="uk-form-label" for="f-email">Email</label>
									<input class="uk-input" id="f-email" type="text" data-inputmask="'alias': 'email'" data-sc-input>
								</div>
								<div>
									<label class="uk-form-label" for="f-phone">Phone Number</label>
									<input class="uk-input" id="f-phone" type="text" data-sc-input>
								</div>
							</div>
							<h4 class="uk-heading-line uk-margin-xlarge-top uk-margin-medium-bottom"><span>Address</span></h4>
							<div class="uk-margin">
								<label class="uk-form-label" for="f-address-street">Street Address</label>
								<input class="uk-input" id="f-address-street" type="text" data-sc-input>
							</div>
							<div class="uk-margin">
								<label class="uk-form-label" for="f-address-street-2">Street Address</label>
								<input class="uk-input" id="f-address-street-2" type="text" data-sc-input>
								<span class="uk-form-help-block">Line 2</span>
							</div>
							<div class="uk-margin uk-child-width-1-2@m" data-uk-grid>
								<div>
									<div class="uk-form-controls">
										<select name="f-address-city" id="f-address-city" class="uk-select" data-sc-select2='{ "placeholder": "Select a city..." }'>
											<option value="">Select a city...</option>
											<?php foreach ($json_cities as $value) {?>
												<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
											<?php }; ?>
										</select>
									</div>
								</div>
								<div>
									<div class="uk-form-controls">
										<select name="f-address-state" id="f-address-state" class="uk-select" data-sc-select2='{ "placeholder": "Select a state..." }'>
											<option value="">Select a state...</option>
											<?php foreach ($json_states as $value) {?>
												<option value="<?php echo $value['val']?>"><?php echo $value['name']?></option>
											<?php }; ?>
										</select>
									</div>
								</div>
							</div>
							<div class="uk-margin uk-flex uk-flex-bottom" data-uk-grid>
								<div class="uk-width-1-3@m">
									<label class="uk-form-label" for="f-address-postal">Postal/Zip-Code</label>
									<input class="uk-input" id="f-address-postal" type="text" data-sc-input>
								</div>
								<div class="uk-width-2-3@m">
									<div class="uk-form-controls">
										<select name="f-address-country" id="f-address-country" class="uk-select" data-sc-select2='{"templateResult": "formatCountryResult", "templateSelection": "formatCountrySelection", "placeholder": "Select a country..."}'>
											<option value="">Select a country...</option>
											<?php foreach ($json_countries as $value) {?>
												<option value="<?php echo $value['code']?>"><?php echo $value['name']?></option>
											<?php }; ?>
										</select>
									</div>
								</div>
							</div>
							<h4 class="uk-heading-line uk-margin-xlarge-top uk-margin-medium-bottom"><span>Additional Informations</span></h4>
							<div>
								<textarea name="f-message" id="f-message" cols="30" rows="6" class="uk-textarea" placeholder="Your special request..."></textarea>
							</div>
							<div class="uk-margin-large-top">
								<button class="sc-button sc-button-large sc-button-primary" type="button">Confirm</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
