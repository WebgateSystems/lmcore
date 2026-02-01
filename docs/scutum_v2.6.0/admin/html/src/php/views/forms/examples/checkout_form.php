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
		<div class="uk-flex-center uk-grid-small" data-uk-grid>
			<div class="uk-width-2-3@l">
				<div class="uk-flex uk-flex-middle uk-margin-bottom md-bg-blue-grey-600 sc-round sc-padding sc-padding-medium-ends">
					<span data-uk-icon="icon: cart; ratio: 1.5" class="<?php rtlReplace('uk-margin-right', 'uk-margin-small-left'); ?> md-color-white"></span>
					<h4 class="md-color-white uk-margin-remove">Checkout Form</h4>
				</div>
				<form>
					<fieldset class="uk-fieldset uk-fieldset-alt md-bg-white">
						<legend class="uk-legend">Billing Details</legend>
						<div class="uk-child-width-1-2@m" data-uk-grid>
							<div>
								<label class="uk-form-label" for="f-f-name">First Name</label>
								<input class="uk-input" id="f-f-name" type="text" data-sc-input>
							</div>
							<div>
								<label class="uk-form-label" for="f-l-name">Last Name</label>
								<input class="uk-input" id="f-l-name" type="text" data-sc-input>
							</div>
							<div>
								<label class="uk-form-label" for="f-email">Email</label>
								<input class="uk-input" id="f-email" type="text" data-inputmask="'alias': 'email'" data-sc-input>
							</div>
							<div>
								<label class="uk-form-label" for="f-phone">Phone Number</label>
								<input class="uk-input" id="f-phone" type="text" data-sc-input>
							</div>
						</div>
						<div data-uk-grid>
							<div class="uk-width-expand@m">
								<label class="uk-form-label" for="f-company">Company</label>
								<input class="uk-input" id="f-company" type="text" data-sc-input>
							</div>
							<div class="uk-width-1-3@m">
								<label class="uk-form-label" for="f-company-id">Company ID</label>
								<input class="uk-input" id="f-company-id" type="text" data-sc-input>
							</div>
						</div>
						<div data-uk-grid>
							<div class="uk-width-expand@m">
								<label class="uk-form-label" for="f-address-billing">Billing Address</label>
								<input class="uk-input" id="f-address-billing" type="text" data-sc-input>
							</div>
							<div class="uk-width-1-3@m">
								<label class="uk-form-label" for="f-address-postal">Postal/Zip-Code</label>
								<input class="uk-input" id="f-address-postal" type="text" data-sc-input>
							</div>
						</div>
						<div class="uk-child-width-1-2@m" data-uk-grid>
							<div>
								<label class="uk-form-label" for="f-address-city">City</label>
								<select name="f-address-city" id="f-address-city" data-sc-select2='{"placeholder": "Select a city..."}' class="uk-select">
									<option value="">Select a city...</option>
									<?php foreach ($json_cities as $value) {?>
										<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
									<?php }; ?>
								</select>
							</div>
							<div>
								<label class="uk-form-label" for="f-address-country">Country</label>
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
					</fieldset>
					<fieldset class="uk-fieldset uk-fieldset-alt md-bg-white">
						<legend class="uk-legend">Payment Details</legend>
						<div class="uk-grid-small" data-uk-grid>
							<div class="uk-width-1-3@s uk-width-1-4@m">
								<ul class="uk-list uk-list-condensed">
									<li>
										<input type="radio" id="f-pay-cc" name="f-payment" data-sc-icheck data-payment-info="more-info-cc" checked>
										<label for="f-pay-cc"><img src="assets/icons/payment-icons/color/visa.png" alt="" width="64" height="40" class="<?php rtlReplace('uk-margin-mini-right', 'uk-margin-mini-left'); ?>"><img src="assets/icons/payment-icons/color/mastercard.png" alt="" width="64" height="40"></label>
									</li>
									<li>
										<input type="radio" id="f-pay-paypal" name="f-payment" data-sc-icheck data-payment-info="more-info-paypal">
										<label for="f-pay-paypal"><img src="assets/icons/payment-icons/color/PayPal.png" alt="" width="64" height="40"></label>
									</li>
									<li>
										<input type="radio" id="f-pay-amazon" name="f-payment" data-sc-icheck data-payment-info="more-info-amazon">
										<label for="f-pay-amazon"><img src="assets/icons/payment-icons/color/Amazon.png" alt="" width="64" height="40"></label>
									</li>
									<li>
										<input type="radio" id="f-pay-moneybookers" name="f-payment" data-sc-icheck data-payment-info="more-info-skrill">
										<label for="f-pay-moneybookers"><img src="assets/icons/payment-icons/color/Skrill.png" alt="" width="64" height="40"></label>
									</li>
								</ul>
							</div>
							<div class="uk-width-2-3@s uk-width-3-4@m more-info-section">
								<div id="more-info-cc">
									<div class="uk-margin">
										<div class="cc-validate-wrapper">
											<span class="cc-icon"><img src="assets/img/blank.gif" alt="" width="52" height="32"></span>
											<label class="uk-form-label" for="f-pay-cc-number">Credit card number</label>
											<input class="uk-input" type="text" id="f-pay-cc-number" data-cc-validate>
											<div class="uk-form-help-block cc-numbers">Examples: <a href="#">4000 0000 0000 0002</a> | <a href="#">4026 0000 0000 0002</a> | <a href="#">5018 0000 0009</a> | <a href="#">5100 0000 0000 0008</a> | <a href="#">6011 0000 0000 0004</a></div>
										</div>
									</div>
									<div class="uk-margin">
										<label class="uk-form-label" for="f-pay-cc-holder">Credit card holder Name</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-pay-cc-holder" type="text">
										</div>
									</div>
									<div class="uk-child-width-1-2@m uk-child-width-1-4@l" data-uk-grid>
										<div>
											<label class="uk-form-label" for="f-pay-cc-validation-date">Validation date</label>
											<div class="uk-form-controls">
												<input class="uk-input" id="f-pay-cc-validation-date" type="text" data-inputmask=" 'alias': 'datetime', 'inputFormat': 'mm/yyyy'" placeholder="mm/yyyy" >
											</div>
										</div>
										<div>
											<label class="uk-form-label" for="f-pay-cc-cvv">CVV</label>
											<div class="uk-form-controls">
												<input class="uk-input" id="f-pay-cc-cvv" type="text" data-inputmask="'mask': '999'" placeholder="123">
											</div>
										</div>
									</div>
								</div>
								<div id="more-info-paypal" style="display: none">
									<label class="uk-form-label" for="f-pay-paypal-name">PayPal Account</label>
									<input class="uk-input" id="f-pay-paypal-name" type="text" data-sc-input="outline">
								</div>
								<div style="display: none"  id="more-info-amazon">
									<label class="uk-form-label" for="f-pay-amazon-name">Amazon Account</label>
									<input class="uk-input" id="f-pay-amazon-name" type="text" data-sc-input="outline">
								</div>
								<div style="display: none"  id="more-info-skrill">
									<label class="uk-form-label" for="f-pay-skrill-name">Skrill Account</label>
									<input class="uk-input" id="f-pay-skrill-name" type="text" data-sc-input="outline">
								</div>
							</div>
						</div>
					</fieldset>
					<fieldset class="uk-fieldset uk-fieldset-alt md-bg-white">
						<legend class="uk-legend">Order info</legend>
                        <div class="uk-width-1-1">
                            <div class="uk-overflow-auto">
                                <table class="uk-table uk-table-striped uk-table-small uk-table-middle">
                                    <thead>
                                        <tr>
                                            <th class="uk-table-shrink"></th>
                                            <th>Product Name</th>
                                            <th class="uk-table-shrink">Quantity</th>
                                            <th class="uk-table-shrink uk-text-center">Price</th>
                                            <th class="uk-table-shrink uk-text-center">Total</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>1.</td>
                                            <td class="uk-text-nowrap">
                                                <a href="#">Product A</a>
                                                <p class="sc-color-secondary uk-margin-remove"><?php echo $faker->sentence(10); ?></p>
                                            </td>
                                            <td class="uk-text-center">4</td>
                                            <td class="<?php rtlReplace('uk-text-right', ''); ?>">$72.99</td>
                                            <td class="<?php rtlReplace('uk-text-right', ''); ?>">$291.96</td>
                                        </tr>
                                        <tr>
                                            <td>2.</td>
                                            <td>
                                                <a href="#">Product B</a>
                                                <p class="sc-color-secondary uk-margin-remove"><?php echo $faker->sentence(10); ?></p>
                                            </td>
                                            <td class="uk-text-center">2</td>
                                            <td class="<?php rtlReplace('uk-text-right', ''); ?>">$43.27</td>
                                            <td class="<?php rtlReplace('uk-text-right', ''); ?>">$86.54</td>
                                        </tr>
                                        <tr>
                                            <td>3.</td>
                                            <td>
                                                <a href="#">Product C</a>
                                                <p class="sc-color-secondary uk-margin-remove"><?php echo $faker->sentence(10); ?></p>
                                            </td>
                                            <td class="uk-text-center">7</td>
                                            <td class="<?php rtlReplace('uk-text-right', ''); ?>">$120.00</td>
                                            <td class="<?php rtlReplace('uk-text-right', ''); ?>">$840.00</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                        </div>
					</fieldset>
					<fieldset class="uk-fieldset uk-fieldset-alt md-bg-white">
						<legend class="uk-legend">Message to the seller</legend>
						<textarea name="f-pay-message" id="f-pay-message" cols="30" rows="6" class="uk-textarea" data-sc-input="outline"></textarea>
					</fieldset>
					<div class="uk-margin-large-top">
						<button type="button" class="sc-button sc-button-primary sc-button-large">Confirm</button>
						<button type="button" class="sc-button sc-button-default sc-button-large sc-button-flat">Cancel</button>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>
