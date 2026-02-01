<?php
$data_cities = file_get_contents ('./data/json/us_cities.json');
$json_cities = json_decode($data_cities, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content" class="uk-height-1-1 uk-flex uk-flex-center sc-page-over-header">
		<div class="uk-width-2-3@l">
			<div class="uk-card uk-height-1-1 uk-flex uk-flex-column">
				<div class="uk-card-header uk-flex uk-flex-middle">
					<h3 class="uk-card-title uk-flex-1">Car Rental Form</h3>
					<i class="mdi mdi-car-side sc-icon-32 <?php rtlReplace('uk-margin-left', 'uk-margin-small-right'); ?>"></i>
				</div>
				<hr class="uk-margin-remove">
				<div class="uk-card-body sc-padding-remove">
					<form class="sc-padding">
						<h4 class="uk-heading-line uk-margin-medium-bottom md-color-indigo-500"><span>Personal Informations</span></h4>
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
						<div class="uk-child-width-1-3@m" data-uk-grid>
							<div>
								<label class="uk-form-label" for="f-phone">Phone</label>
								<input class="uk-input" id="f-phone" type="text" data-sc-input="outline">
							</div>
							<div>
								<label class="uk-form-label" for="f-email">Email</label>
								<input class="uk-input" id="f-email" type="text" data-sc-input="outline">
							</div>
							<div>
								<label class="uk-form-label" for="dp-birthdate">Birth Date</label>
								<input class="uk-input" id="dp-birthdate" type="text" data-sc-input="outline">
							</div>
						</div>
						<h4 class="uk-heading-line uk-margin-medium-bottom uk-margin-large-top md-color-indigo-500"><span>Car Rental Details</span></h4>
						<div class="uk-child-width-1-2@m uk-flex-bottom" data-uk-grid>
							<div>
								<label class="uk-form-label" for="f-pick-up">Pick-up Location</label>
								<div class="uk-form-controls">
									<select name="f-pick-up" id="f-pick-up" class="uk-select" data-sc-select2='{ "placeholder": "Select a city..." }'>
										<option value="">Select a city...</option>
										<?php foreach ($json_cities as $value) {?>
											<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
										<?php }; ?>
									</select>
								</div>
							</div>
							<div>
								<label class="uk-form-label" for="dp-pick-up-date">Pick-up Date</label>
								<input class="uk-input" id="dp-pick-up-date" type="text" data-sc-input="outline">
							</div>
						</div>
						<div class="uk-child-width-1-2@m uk-flex-bottom" data-uk-grid>
							<div>
								<label class="uk-form-label" for="f-drop-off">Drop-off Location</label>
								<div class="uk-form-controls">
									<select name="f-drop-off" id="f-drop-off" class="uk-select" data-sc-select2='{ "placeholder": "Select a city..." }'>
										<option value="">Select a city...</option>
										<?php foreach ($json_cities as $value) {?>
											<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
										<?php }; ?>
									</select>
								</div>
							</div>
							<div>
								<label class="uk-form-label" for="dp-drop-off-date">Drop-off Date</label>
								<input class="uk-input" id="dp-drop-off-date" type="text" data-sc-input="outline">
							</div>
						</div>
						<h4 class="uk-heading-line uk-margin-medium-bottom uk-margin-large-top md-color-indigo-500"><span>Car type</span></h4>
						<div class="uk-child-width-1-3@m" data-uk-grid>
							<div>
								<label for="f-car-type" class="uk-form-label">Type</label>
								<select name="f-car-type" id="f-car-type" class="uk-select" data-sc-select2='{ "placeholder": "Select...", "minimumResultsForSearch": "Infinity"}'>
									<option value="">---</option>
									<option value="vt-a">Economy</option>
									<option value="vt-b">Compact</option>
									<option value="vt-c">Mid-size</option>
									<option value="vt-d">Full-size</option>
									<option value="vt-e">Premium</option>
									<option value="vt-f">Luxury</option>
									<option value="vt-g">Minivan</option>
								</select>
							</div>
							<div>
								<label for="f-car-subtype" class="uk-form-label">Subtype</label>
								<select name="f-car-subtype" id="f-car-subtype" class="uk-select" data-sc-select2='{ "placeholder": "First select a type...", "minimumResultsForSearch": "Infinity"}'>
									<option value="">---</option>
									<option value="vt-a-1" class="vt-a">Chevrolet Spark</option>
									<option value="vt-a-2" class="vt-a">Hyundai Accent</option>
									<option value="vt-a-3" class="vt-a">Chevrolet Aveo</option>
									<option value="vt-b-1" class="vt-b">Nissan Versa</option>
									<option value="vt-b-2" class="vt-b">Toyota Yaris</option>
									<option value="vt-b-3" class="vt-b">Huyndai Accent</option>
									<option value="vt-b-4" class="vt-b">Ford Focus</option>
									<option value="vt-c-1" class="vt-c">Toyota Corolla</option>
									<option value="vt-c-2" class="vt-c">Nissan Sentra</option>
									<option value="vt-c-3" class="vt-c">Chevrolet Cruze</option>
									<option value="vt-c-4" class="vt-c">Dodge Avenger</option>
									<option value="vt-d-1" class="vt-d">Ford Fusion</option>
									<option value="vt-d-2" class="vt-d">Nissan Altima</option>
									<option value="vt-d-3" class="vt-d">Dodge Charger</option>
									<option value="vt-d-4" class="vt-d">Chevrolet Impala</option>
									<option value="vt-d-5" class="vt-d">Ford Taurus</option>
									<option value="vt-e-1" class="vt-e">Nissan Maxima</option>
									<option value="vt-e-1" class="vt-e">Chrysler 300</option>
									<option value="vt-e-1" class="vt-e">Toyota Avalon</option>
									<option value="vt-e-2" class="vt-e">Mercury Grand Marquis</option>
									<option value="vt-e-3" class="vt-e">Ford Crown Victoria</option>
									<option value="vt-f-1" class="vt-f">Cadillac ATZ</option>
									<option value="vt-f-2" class="vt-f">Lincoln MKZ</option>
									<option value="vt-f-3" class="vt-f">Buick LaCrosse</option>
									<option value="vt-f-4" class="vt-f">Cadillac STS</option>
									<option value="vt-g-1" class="vt-g">Dodge Grand Caravan</option>
									<option value="vt-g-2" class="vt-g">Chrysler Town and Country</option>
									<option value="vt-g-3" class="vt-g">Kia Sedona</option>
								</select>
							</div>
						</div>
						<h4 class="uk-heading-line uk-margin-medium-bottom uk-margin-large-top md-color-indigo-500"><span>Extras</span></h4>
						<div class="uk-margin-small-top">
							<ul class="uk-list">
								<li>
									<input type="checkbox" id="f-car-extra-1" name="f-car-extra-1" data-sc-icheck>
									<label for="f-car-extra-1">GPS navigation system</label>
								</li>
								<li>
									<input type="checkbox" id="f-car-extra-2" name="f-car-extra-2" data-sc-icheck>
									<label for="f-car-extra-2">Booster</label>
								</li>
								<li>
									<input type="checkbox" id="f-car-extra-3" name="f-car-extra-3" data-sc-icheck>
									<label for="f-car-extra-3">Child safety seat</label>
								</li>
								<li>
									<input type="checkbox" id="f-car-extra-4" name="f-car-extra-4" data-sc-icheck>
									<label for="f-car-extra-4">Additional driver</label>
								</li>
							</ul>
						</div>
						<hr>
						<label class="uk-form-label" for="f-car-additional">Additional Requests</label>
						<textarea name="f-car-additional" id="f-car-additional" cols="30" rows="6" class="uk-textarea" data-sc-input="outline"></textarea>
						<div class="uk-margin-large-top">
							<button class="sc-button sc-button-large md-bg-light-blue-600 sc-button-custom">Book now</button>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
