<div id="sc-page-wrapper">
	<div id="sc-page-content">

		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-2-3@l">
				<div class="uk-card">
					<form action="#">
						<div data-sc-dynamic-fields="fields-template" data-sc-dynamic-fields-counter="1"></div>
						<div class="sc-padding">
							<button class="sc-button">Submit</button>
						</div>
					</form>
				</div>
			</div>
		</div>

		<script id="fields-template" type="text/x-handlebars-template">
			<div class="uk-card-body sc-form-section{{#if_even index}} md-bg-grey-100{{/if_even}}">
				<h4 class="uk-margin uk-heading-line">
					<span>User {{ index }}</span>
				</h4>
				<div class="uk-grid-match" data-uk-grid>
					<div class="uk-width-expand@m">
						<div class="uk-child-width-1-2@m uk-flex-bottom" data-uk-grid>
							<div>
								<label class="uk-form-label" for="f-f-name-{{index}}">First Name</label>
								<input class="uk-input" id="f-f-name-{{index}}" type="text" data-sc-input />
							</div>
							<div>
								<label class="uk-form-label" for="f-l-name-{{index}}">Last Name</label>
								<input class="uk-input" id="f-l-name-{{index}}" type="text" data-sc-input>
							</div>
						</div>
						<div class="uk-child-width-1-3@m uk-flex-middle" data-uk-grid>
							<div>
								<label class="uk-form-label" for="f-email-{{index}}">Email</label>
								<input class="uk-input" id="f-email-{{index}}" type="text" data-inputmask="'alias': 'email'" data-sc-input>
							</div>
							<div>
								<label class="uk-form-label" for="f-phone-{{index}}">Phone Number</label>
								<input class="uk-input" id="f-phone-{{index}}" type="text" data-sc-input>
							</div>
							<div>
								<input type="checkbox" id="f-register-{{index}}" data-sc-switchery /><label for="f-register-{{index}}" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Register User</label>
							</div>
						</div>
					</div>
					<div class="uk-width-auto@m uk-flex-middle">
						<a href="#" class="sc-js-section-clone sc-button sc-button-icon sc-button-outline sc-button-default sc-button-outline-square"><i class="mdi mdi-plus sc-js-el-hide"></i><i class="mdi mdi-trash-can-outline sc-js-el-show md-color-red-600"></i></a>
					</div>
				</div>
			</div>
		</script>

	</div>
</div>
