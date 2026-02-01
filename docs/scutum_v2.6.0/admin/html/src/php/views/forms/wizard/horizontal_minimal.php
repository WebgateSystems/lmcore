<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-2-3@l">
				<div class="uk-card  uk-card-body">
					<form action="#">
						<div id="sc-wizard-h-min" class="minimal">
							<h3><i class="mdi mdi-account step-icon"></i>Personal</h3>
							<section>
								<h4><?php echo $faker->sentence(rand(5,12));?></h4>
								<div data-uk-grid>
									<div class="uk-width-1-4@m">
										<?php photo(2); ?>
									</div>
									<div class="uk-width-expand@m">
										<?php echo $faker->sentence(rand(50,200));?>
									</div>
								</div>
							</section>
							<h3><i class="mdi mdi-home step-icon"></i>Address</h3>
							<section>
								<h4><?php echo $faker->sentence(rand(5,12));?></h4>
								<?php echo $faker->sentence(rand(50,200));?>
							</section>
							<h3><i class="mdi mdi-credit-card step-icon"></i>Payment</h3>
							<section>
								<h4><?php echo $faker->sentence(rand(5,12));?></h4>
								<?php echo $faker->sentence(rand(50,200));?>
							</section>
							<h3><i class="mdi mdi-star step-icon"></i>Review</h3>
							<section>
								<h4><?php echo $faker->sentence(rand(5,12));?></h4>
								<?php echo $faker->sentence(rand(50,200));?>
							</section>
							<h3><i class="mdi mdi-check-all step-icon"></i>Finish</h3>
							<section>
								<h4><?php echo $faker->sentence(rand(5,12));?></h4>
								<?php echo $faker->sentence(rand(50,200));?>
							</section>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
