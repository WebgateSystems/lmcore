<?php
$data_cities = file_get_contents ('./data/json/us_cities.json');
$json_cities = json_decode($data_cities, TRUE);
$data_countries = file_get_contents ('./data/json/countries.json');
$json_countries = json_decode($data_countries, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-4-5@l">
				<div class="uk-card uk-card-body">
					<form action="#" id="sc-wizard-h-form">
						<div id="sc-wizard-h">
							<h3><span>Billing<span class="sub-text">Enter your billing information.</span></span></h3>
							<section class="border md-bg-grey-50">
								<div data-uk-grid>
									<div class="uk-width-expand@l">
										<div class="sc-validation-wrapper">
											<div class="sc-input-match-field">
												<span class="<?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?> uk-text-nowrap">
													<input type="radio" id="wiz-title-mr" name="wiz-title" value="mr" data-sc-icheck data-parsley-required>
													<label for="wiz-title-mr">Mr.</label>
												</span>
												<span class="uk-text-nowrap">
													<input type="radio" id="wiz-title-mrs" name="wiz-title" value="mrs" data-sc-icheck data-parsley-required>
													<label for="wiz-title-mrs">Mrs.</label>
												</span>
											</div>
										</div>
									</div>
									<div class="uk-width-2-5@l uk-width-1-2@s">
										<label class="uk-form-label" for="wiz-fname">First Name</label>
										<input class="uk-input" id="wiz-fname" name="wiz-fname" type="text" data-sc-input data-parsley-required>
									</div>
									<div class="uk-width-2-5@l uk-width-1-2@s">
										<label class="uk-form-label" for="wiz-lname">Last Name</label>
										<input class="uk-input" id="wiz-lname" name="wiz-lname" type="text" data-sc-input data-parsley-required>
									</div>
								</div>
								<div class="uk-child-width-1-2@s uk-margin" data-uk-grid>
									<div>
										<label class="uk-form-label" for="wiz-email">Email</label>
										<input class="uk-input" id="wiz-email" name="wiz-email" type="text" data-inputmask="'alias': 'email'" data-sc-input>
									</div>
									<div>
										<label class="uk-form-label" for="wiz-phone">Phone Number</label>
										<input class="uk-input" id="wiz-phone" name="wiz-phone" type="text" data-sc-input>
									</div>
								</div>
								<div class="uk-margin" data-uk-grid>
									<div class="uk-width-expand@s">
										<label class="uk-form-label" for="wiz-company">Company</label>
										<input class="uk-input" id="wiz-company" name="wiz-company" type="text" data-sc-input>
									</div>
									<div class="uk-width-2-5@s">
										<label class="uk-form-label" for="wiz-company-id">Company ID</label>
										<input class="uk-input" id="wiz-company-id" name="wiz-company-id" type="text" data-sc-input>
									</div>
								</div>
								<hr>
								<div id="sc-js-dynamic-fields-billing-address">
									<div data-sc-dynamic-fields="billingAddressTemplate"></div>
									<script id="billingAddressTemplate" type="text/x-handlebars-template">
										{{#ifCond index '>' 0 }}
										<hr class="uk-margin">
										{{/ifCond}}
										<div class="sc-form-section">
											<div class="uk-grid-match" data-uk-grid>
												<div class="uk-width-expand@m">
													<div class="uk-margin" data-uk-grid>
														<div class="uk-width-expand@m">
															<label class="uk-form-label" for="wiz-address-{{ index }}">Billing Addres</label>
															<input class="uk-input" id="wiz-address-{{ index }}" name="wiz-address-{{ index }}" type="text" data-sc-input>
														</div>
														<div class="uk-width-2-5@m">
															<label class="uk-form-label" for="wiz-address-postal-{{ index }}">Postal/Zip-Code</label>
															<input class="uk-input" id="wiz-address-postal-{{ index }}" name="wiz-address-postal-{{ index }}" type="text" data-sc-input>
														</div>
													</div>
													<div class="uk-margin-top-remove uk-child-width-1-2@m" data-uk-grid>
														<div>
															<label class="uk-form-label" for="wiz-address-city">City</label>
															<div class="uk-form-controls">
																<select name="wiz-address-city-{{ index }}" id="wiz-address-city-{{ index }}" class="uk-select" data-sc-select2='{ "placeholder": "Select a city..." }'>
																	<option value="">Select a city...</option>
																	<?php foreach ($json_cities as $value) {?>
																		<option value="<?php echo $value['rank']?>"><?php echo $value['city']?></option>
																	<?php }; ?>
																</select>
															</div>
														</div>
														<div>
															<label class="uk-form-label" for="wiz-address-country">Country</label>
															<div class="uk-form-controls">
																<select name="wiz-address-country-{{ index }}" id="wiz-address-country-{{ index }}" class="uk-select" data-sc-select2='{"templateResult": "formatCountryResult", "templateSelection": "formatCountrySelection", "placeholder": "Select a country..."}'>
																	<option value=""></option>
																	<?php foreach ($json_countries as $value) {?>
																		<option value="<?php echo $value['code']?>"><?php echo $value['name']?></option>
																	<?php }; ?>
																</select>
															</div>
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
							</section>
							<h3><i class="mdi mdi-credit-card step-icon"></i><span>Payment<span class="sub-text">Choose your payment method</span></span></h3>
							<section class="border">
								<div data-uk-grid>
									<div class="uk-width-1-4@m">
										<ul class="uk-list uk-list-condensed">
											<li>
												<input type="radio" id="wiz-pay-cc" name="wiz-payment" data-sc-icheck data-payment-info="more-info-cc" value="credit card" checked>
												<label for="wiz-pay-cc"><img src="assets/icons/payment-icons/color/visa.png" alt="" width="64" height="40" class="<?php rtlReplace('uk-margin-mini-right', 'uk-margin-mini-left'); ?>"><img src="assets/icons/payment-icons/color/mastercard.png" alt="" width="64" height="40"></label>
											</li>
											<li>
												<input type="radio" id="wiz-pay-paypal" name="wiz-payment" data-sc-icheck data-payment-info="more-info-paypal" value="paypal">
												<label for="wiz-pay-paypal"><img src="assets/icons/payment-icons/color/PayPal.png" alt="" width="64" height="40"></label>
											</li>
											<li>
												<input type="radio" id="wiz-pay-amazon" name="wiz-payment" data-sc-icheck data-payment-info="more-info-amazon" value="amazon">
												<label for="wiz-pay-amazon"><img src="assets/icons/payment-icons/color/Amazon.png" alt="" width="64" height="40"></label>
											</li>
											<li>
												<input type="radio" id="wiz-pay-moneybookers" name="wiz-payment" data-sc-icheck data-payment-info="more-info-moneybookers" value="moneybookers">
												<label for="wiz-pay-moneybookers"><img src="assets/icons/payment-icons/color/Skrill.png" alt="" width="64" height="40"></label>
											</li>
										</ul>
									</div>
									<div class="uk-width-3-4@m uk-flex uk-flex-middle">
										<div id="more-info-cc" class="uk-width-1-1">
											<div class="uk-margin">
												<div class="cc-validate-wrapper">
													<span class="cc-icon"><img src="assets/img/blank.gif" alt="" width="52" height="32"></span>
													<label class="uk-form-label" for="wiz-pay-cc-number">Credit card number</label>
													<input class="uk-input" type="text" id="wiz-pay-cc-number" name="wiz-pay-cc-number" data-cc-validate>
													<div class="uk-form-help-block cc-numbers">Examples: <a href="#">4000 0000 0000 0002</a> | <a href="#">4026 0000 0000 0002</a> | <a href="#">5018 0000 0009</a> | <a href="#">5100 0000 0000 0008</a> | <a href="#">6011 0000 0000 0004</a></div>
												</div>
											</div>
											<div class="uk-margin">
												<label class="uk-form-label" for="wiz-pay-cc-holder">Credit card holder Name</label>
												<div class="uk-form-controls">
													<input class="uk-input" id="wiz-pay-cc-holder" name="wiz-pay-cc-holder" type="text">
												</div>
											</div>
											<div class="uk-child-width-1-2@m uk-child-width-1-4@l" data-uk-grid>
												<div>
													<label class="uk-form-label" for="wiz-pay-cc-validation-date">Validation date</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="wiz-pay-cc-validation-date" name="wiz-pay-cc-validation-date" type="text" data-inputmask=" 'alias': 'datetime', 'inputFormat': 'mm/yyyy'" placeholder="mm/yyyy" >
													</div>
												</div>
												<div>
													<label class="uk-form-label" for="wiz-pay-cc-cvv">CVV</label>
													<div class="uk-form-controls">
														<input class="uk-input" id="wiz-pay-cc-cvv" name="wiz-pay-cc-cvv" type="text" data-inputmask="'mask': '999'" placeholder="123">
													</div>
												</div>
											</div>
										</div>
										<div id="more-info-paypal" style="display: none" class="uk-width-1-1">
											<label class="uk-form-label" for="wiz-pay-paypal-name">PayPal Account</label>
											<input class="uk-input" id="wiz-pay-paypal-name" name="wiz-pay-paypal-name" type="text" data-sc-input="outline">
										</div>
										<div style="display: none"  id="more-info-amazon" class="uk-width-1-1">
											<label class="uk-form-label" for="wiz-pay-amazon-name">Amazon Account</label>
											<input class="uk-input" id="wiz-pay-amazon-name" name="wiz-pay-amazon-name" type="text" data-sc-input="outline">
										</div>
										<div style="display: none"  id="more-info-moneybookers" class="uk-width-1-1">
											<label class="uk-form-label" for="wiz-pay-moneybookers-name">Skrill Account</label>
											<input class="uk-input" id="wiz-pay-moneybookers-name" name="wiz-pay-moneybookers-name" type="text" data-sc-input="outline">
										</div>
									</div>
								</div>
							</section>
							<h3><i class="ion-md-checkmark step-icon"></i><span>Confirm Order<span class="sub-text">Verify order details</span></span></h3>
							<section>
								<h4 class="uk-heading-line"><span>Billing Information</span></h4>
								<address>
									Ernest J. Holt<br>
									3879 College Street<br>
									Atlanta, GA 30338
								</address>
								<h4 class="uk-heading-line uk-margin-medium-top"><span>Payment</span></h4>
								<div class="uk-grid-small" data-uk-grid>
									<div class="uk-width-1-5@m uk-text-muted">
										Mastercard
									</div>
									<div class="uk-width-3-5@m">
										**** **** **** 3157
									</div>
								</div>
								<div class="uk-grid-small" data-uk-grid>
									<div class="uk-width-1-5@m uk-text-muted">
										Expires
									</div>
									<div class="uk-width-3-5@m">
										05/2020
									</div>
								</div>
								<div class="uk-grid-small" data-uk-grid>
									<div class="uk-width-1-5@m uk-text-muted">
										Card Holder
									</div>
									<div class="uk-width-3-5@m">
										Ernest J. Holt
									</div>
								</div>
								<h4 class="uk-heading-line uk-margin-medium-top"><span>Products</span></h4>
								<div class="uk-overflow-auto">
									<table class="uk-table uk-table-striped uk-table-small">
										<thead>
										<tr>
											<th>Product Name</th>
											<th>Quantity</th>
											<th>Price</th>
											<th>Total</th>
										</tr>
										</thead>
										<tbody>
										<tr>
											<td class="uk-text-nowrap">Lorem ipsum dolor sit amet, consectetur.</td>
											<td>4</td>
											<td>$100</td>
											<td>$400</td>
										</tr>
										<tr>
											<td>Lorem ipsum dolor sit amet, consectetur.</td>
											<td>4</td>
											<td>$100</td>
											<td>$400</td>
										</tr>
										<tr>
											<td>Lorem ipsum dolor sit amet, consectetur.</td>
											<td>4</td>
											<td>$100</td>
											<td>$400</td>
										</tr>
										</tbody>
									</table>
								</div>
							</section>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
