<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div data-uk-alert class="md-bg-light-blue-800 md-color-white">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.<a class="uk-alert-close" data-uk-close></a></div>
		<div class="uk-child-width-1-2@l" data-uk-grid>
			<div>
				<div class="uk-card uk-card-body">
					<div data-uk-alert>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</div>
					<div data-uk-alert>
						<a class="uk-alert-close" data-uk-close></a>
						<h4>Notice</h4>
						<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
					</div>
					<div class="uk-alert-icon" data-uk-alert>
						<a class="uk-alert-close" data-uk-close></a>
						<div class="uk-flex uk-flex-middle">
							<i class="mdi mdi-bullhorn sc-icon-32 <?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?>"></i>
							<div class="uk-alert-content">
								<h5>Have you heard about our mailing list?</h5>
								<p>Get the best news in your e-mail every day.</p>
							</div>
						</div>
					</div>
				</div>
				<div class="uk-card uk-card-body uk-margin">
					<div class="uk-alert-primary" data-uk-alert>
						<a class="uk-alert-close" data-uk-close></a>
						<?php echo $faker->sentence(10); ?>
					</div>
					<div class="uk-alert-danger" data-uk-alert>
						<a class="uk-alert-close" data-uk-close></a>
						<?php echo $faker->sentence(10); ?>
					</div>
					<div class="uk-alert-success" data-uk-alert>
						<a class="uk-alert-close" data-uk-close></a>
						<?php echo $faker->sentence(10); ?>
					</div>
					<div class="uk-alert-warning" data-uk-alert>
						<a class="uk-alert-close" data-uk-close></a>
						<?php echo $faker->sentence(10); ?>
					</div>
				</div>
			</div>
			<div>
				<div class="uk-card ">
					<div class="uk-alert-attached-top md-bg-light-green-600 md-color-white" data-uk-alert><a class="uk-alert-close" data-uk-close></a>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</div>
					<div class="uk-card-body">
						<?php echo $faker->sentence(100); ?>
					</div>
					<div class="uk-alert-attached-bottom" data-uk-alert>Lorem ipsum dolor sit amet, consectetur <a href="#">adipisicing elit</a>. Expedita, ipsum.</div>
				</div>
				<div class="uk-card  uk-margin">
					<div class="uk-card-body">
						<div class="uk-alert-danger" data-uk-alert>
							<h5>There were some errors with your submission</h5>
							<ul class="uk-list uk-margin uk-list-condensed">
								<li>You must include both a upper and lower case letters in your password.</li>
								<li>You need to select your home country.</li>
							</ul>
						</div>
						<form class="uk-margin">
							<div class="uk-margin">
								<input class="uk-input uk-form-danger" type="text" value="Lorem ipsum" data-sc-input>
							</div>
							<div class="uk-margin">
								<textarea class="uk-textarea uk-form-danger" rows="5" data-sc-input>Lorem ipsum dolor</textarea>
							</div>
							<div class="uk-margin-top">
								<button class="sc-button">Submit</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
