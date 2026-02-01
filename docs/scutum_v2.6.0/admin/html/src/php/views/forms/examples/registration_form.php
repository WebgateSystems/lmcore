<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-3-5@l">
				<div class="uk-card">
					<div class="uk-card-body">
						<form>
							<fieldset class="uk-fieldset md-bg-grey-100 sc-padding">
								<p class="sc-text-semibold uk-text-large uk-margin-remove-top">Personal info</p>
								<div class="uk-child-width-1-2@m" data-uk-grid>
									<div>
										<label class="uk-form-label" for="f-f-name">First Name</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-f-name" type="text">
										</div>
									</div>
									<div>
										<label class="uk-form-label" for="f-l-name">Last Name</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-l-name" type="text">
										</div>
									</div>
								</div>
								<div class="uk-child-width-1-2@m uk-flex-top uk-margin-top" data-uk-grid>
									<div>
										<label class="uk-form-label" for="f-birthdate">Date of Birth</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-birthdate" type="text">
										</div>
									</div>
									<div>
										<label class="uk-form-label" for="f-l-name">Gender</label>
										<div class="uk-flex uk-margin-small-top <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">
											<span class="<?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?>">
												<input type="radio" id="f-r-male" name="f-r-gender" data-sc-icheck>
												<label for="f-r-male">Male</label>
											</span>
											<span>
												<input type="radio" id="f-r-female" name="f-r-gender" data-sc-icheck>
												<label for="f-r-female">Female</label>
											</span>
										</div>
									</div>
								</div>
							</fieldset>
							<fieldset class="uk-fieldset md-bg-grey-100 sc-padding uk-margin-top">
								<p class="sc-text-semibold uk-text-large uk-margin-remove-top">Login info</p>
								<div class="uk-child-width-1-2@m" data-uk-grid>
									<div>
										<label class="uk-form-label" for="f-email">Email</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-email" type="text" data-inputmask="'alias': 'email'">
										</div>
									</div>
									<div>
										<label class="uk-form-label" for="f-re-email">Re-enter Email</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-re-email" type="text" data-inputmask="'alias': 'email'">
										</div>
									</div>
								</div>
								<div class="uk-child-width-1-2@m uk-margin-top" data-uk-grid>
									<div>
										<label class="uk-form-label" for="f-password">Password</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-password" type="password">
										</div>
									</div>
									<div>
										<label class="uk-form-label" for="f-re-password">Re-enter Password</label>
										<div class="uk-form-controls">
											<input class="uk-input" id="f-re-password" type="password">
										</div>
									</div>
								</div>
							</fieldset>
							<div class="uk-margin-top uk-flex uk-flex-middle">
								<input type="checkbox" name="f-terms" data-sc-icheck id="sc-js-terms">
								<label for="sc-js-terms">I agree to <a href="#" data-uk-toggle="target: #sc-terms-modal">Terms of Use</a></label>
								<div id="sc-terms-modal" class="uk-flex-top" data-uk-modal>
									<div class="uk-modal-dialog uk-margin-auto-vertical">
										<div class="uk-modal-body">
											<h2 class="uk-modal-title uk-margin-remove-ends">Terms and Conditions</h2>
											<button class="uk-modal-close-default" type="button" data-uk-close></button>
											<hr class="uk-margin-medium-top uk-margin-large-bottom">
											<div>
												<h4 class="uk-margin-small">1. <?php echo $faker->sentence(10); ?></h4>
												<p class="uk-margin-remove"><?php echo $faker->sentence(40) ?></p>
												<h4 class="uk-margin-small uk-margin-top">2. <?php echo $faker->sentence(10); ?></h4>
												<p class="uk-margin-remove"><?php echo $faker->sentence(40) ?></p>
											</div>
										</div>
										<div class="uk-modal-footer uk-margin-top">
											<button class="sc-button sc-button-default sc-button-outline" id="sc-js-terms-btn">I agree</button>
										</div>
									</div>
								</div>
							</div>
							<div class="uk-margin-top">
								<button class="sc-button sc-button-primary" type="button">Register</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
