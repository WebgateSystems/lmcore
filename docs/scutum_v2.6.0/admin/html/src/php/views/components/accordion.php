<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-child-width-1-2@l" data-uk-grid>
			<div>
				<div class="uk-card uk-card-body uk-margin-medium">
					<ul data-uk-accordion>
						<li class="uk-open">
							<h3 class="uk-accordion-title">Item 1</h3>
							<div class="uk-accordion-content">
								<?php echo $faker->sentence(40); ?>
							</div>
						</li>
						<li>
							<h3 class="uk-accordion-title">Item 2</h3>
							<div class="uk-accordion-content">
								<?php echo $faker->sentence(40); ?>
							</div>
						</li>
						<li>
							<h3 class="uk-accordion-title">Item 3</h3>
							<div class="uk-accordion-content">
								<?php echo $faker->sentence(40); ?>
							</div>
						</li>
					</ul>
				</div>
				<div class="uk-card uk-margin">
					<div class="uk-card-header">
						<h2 class="uk-card-title">Outline</h2>
					</div>
					<div class="uk-card-body">
						<ul class="uk-accordion-outline" data-uk-accordion>
							<li class="uk-open">
								<h3 class="uk-accordion-title">Item 1</h3>
								<div class="uk-accordion-content">
									<div data-uk-grid>
										<div class="uk-width-1-3@m"><?php photo(4,'','uk-border-rounded uk-box-shadow') ?></div>
										<div class="uk-width-expand@m"><?php echo $faker->sentence(60); ?></div>
									</div>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title md-bg-light-blue-50">Item 2</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title">Item 3</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title">Item 4</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
						</ul>
					</div>
				</div>
				<div class="uk-card uk-margin">
					<div class="uk-card-header">
						<h2 class="uk-card-title">Alternative</h2>
					</div>
					<div class="uk-card-body">
					<ul class="uk-accordion-alt" data-uk-accordion>
							<li class="uk-open">
								<h3 class="uk-accordion-title md-bg-light-green-600 md-color-white">Item 1</h3>
								<div class="uk-accordion-content">
									<div data-uk-grid>
										<div class="uk-width-1-3@m"><?php photo(4,'','uk-border-rounded uk-box-shadow') ?></div>
										<div class="uk-width-expand@m"><?php echo $faker->sentence(60); ?></div>
									</div>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title">Item 2</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title">Item 3</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title">Item 4</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
						</ul>
					</div>
				</div>
			</div>
			<div>
				<div class="uk-card uk-margin">
					<div class="uk-card-header">
						<h2 class="uk-card-title">Multiple Open Items</h2>
					</div>
					<div class="uk-card-body">
						<ul data-uk-accordion="multiple: true">
							<li class="uk-open">
								<h3 class="uk-accordion-title">Item 1</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title">Item 2</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
							<li>
								<h3 class="uk-accordion-title">Item 3</h3>
								<div class="uk-accordion-content">
									<?php echo $faker->sentence(60); ?>
								</div>
							</li>
						</ul>
					</div>
				</div>
				<div class="uk-card uk-margin">
					<div class="uk-card-header">
						<h2 class="uk-card-title">Form Fields</h2>
					</div>
					<div class="uk-card-body">
						<div class="uk-child-width-1-2@s" data-uk-grid>
							<div>
								<label for="form-f-name">First Name</label>
								<input class="uk-input" id="form-f-name" type="text" data-sc-input>
							</div>
							<div>
								<label for="form-l-name">Last Name</label>
								<input class="uk-input" id="form-l-name" type="text" data-sc-input>
							</div>
						</div>
						<ul class="uk-margin" data-uk-accordion>
							<li>
								<h4 class="uk-accordion-title md-color-light-blue-800 uk-text-medium">Optional details</h4>
								<div class="uk-accordion-content">
									<div class="uk-child-width-1-2@s" data-uk-grid>
										<div>
											<label class="uk-form-label" for="form-m-name">Middle Name</label>
											<input class="uk-input" id="form-m-name" type="text" data-sc-input>
										</div>
										<div>
											<label class="uk-form-label" for="form-md-name">Maiden Name</label>
											<input class="uk-input" id="form-md-name" type="text" data-sc-input>
										</div>
									</div>
								</div>
							</li>
						</ul>
						<button class="uk-margin sc-button">Submit</button>
					</div>
				</div>
				<h5 class="uk-margin uk-margin-small-bottom">Accordion Menu</h5>
				<div class="uk-width-1-2@s uk-width-1-3@l">
					<div class="uk-card uk-card-body">
						<form>
							<ul data-uk-accordion>
								<li class="uk-open">
									<h3 class="uk-accordion-title"><i class="mdi mdi-ruler"></i>Size</h3>
									<div class="uk-accordion-content sc-padding-medium md-bg-grey-100 sc-round">
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-radio" type="radio" name="ac-size" id="ac-size-sm" data-sc-icheck><label for="ac-size-sm">Small</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-radio" type="radio" name="ac-size" id="ac-size-md" data-sc-icheck><label for="ac-size-md">Medium</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-radio" type="radio" name="ac-size" id="ac-size-lg" data-sc-icheck><label for="ac-size-lg">Large</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-radio" type="radio" name="ac-size" id="ac-size-xl" data-sc-icheck><label for="ac-size-xl">X-Large</label>
										</div>
									</div>
								</li>
								<li>
									<h3 class="uk-accordion-title"><i class="mdi mdi-palette"></i>Colors</h3>
									<div class="uk-accordion-content sc-padding-medium md-bg-grey-100 sc-round">
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-checkbox" type="checkbox" name="ac-red" id="ac-red" data-sc-icheck><label for="ac-red" class="md-color-red-600">Red</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-checkbox" type="checkbox" name="ac-blue" id="ac-blue" data-sc-icheck><label for="ac-blue" class="md-color-blue-600">Blue</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-checkbox" type="checkbox" name="ac-green" id="ac-green" data-sc-icheck><label for="ac-green" class="md-color-green-600">Green</label>
										</div>
									</div>
								</li>
								<li>
									<h3 class="uk-accordion-title"><i class="mdi mdi-cash-usd"></i>Price</h3>
									<div class="uk-accordion-content sc-padding-medium md-bg-grey-100 sc-round">
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-checkbox" type="checkbox" name="ac-price" id="ac-price-100" data-sc-icheck><label for="ac-price-100">$100.00</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-checkbox" type="checkbox" name="ac-price" id="ac-price-500" data-sc-icheck><label for="ac-price-500">$500.00</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-checkbox" type="checkbox" name="ac-price" id="ac-price-1000" data-sc-icheck><label for="ac-price-1000">$1000.00</label>
										</div>
										<div class="uk-margin-small uk-flex uk-flex-middle">
											<input class="uk-checkbox" type="checkbox" name="ac-price" id="ac-price-5000" data-sc-icheck><label for="ac-price-5000">$5000.00</label>
										</div>
									</div>
								</li>
							</ul>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
