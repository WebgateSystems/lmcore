<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-2-3@l">
				<div class="uk-card">
					<div class="uk-card-header uk-margin-medium-bottom">
						<div class="md-bg-blue-800 uk-card-header-bg uk-light uk-flex uk-flex-middle">
							<i class="mdi mdi-medical-bag sc-icon-24 uk-margin-medium-right md-color-white"></i>
							<h3 class="uk-card-title">Medical History</h3>
						</div>
					</div>
					<div class="uk-card-body">
						<form class="uk-form-stacked ">
							<div class="uk-child-width-1-2@l" data-uk-grid>
								<div class="uk-width-2-3@m">
									<label class="uk-form-label" for="f-patient-name">Patient Name</label>
									<input class="uk-input" id="f-patient-name" type="text" data-sc-input="outline">
								</div>
								<div class="uk-width-1-3@m">
									<label class="uk-form-label" for="f-patient-birthdate">Birth Date</label>
									<input class="uk-input" id="f-patient-birthdate" type="text" data-sc-input="outline">
								</div>
							</div>
							<hr class="uk-margin-large">
							<h4 class="uk-margin-large-top">Please answer the following</h4>
							<div class="uk-margin-small">
								<input type="checkbox" class="sc-js-med-info" id="f-med-q-1" data-sc-switchery data-switchery-size="small" data-switchery-color="#1c7cd6">
								<label for="f-med-q-1" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Are you under a physician's care now?</label>
								<div class="sc-js-el-show uk-margin-small-top uk-margin-medium-bottom">
									<input type="text" class="uk-input" placeholder="Please add more info..." data-sc-input>
								</div>
							</div>
							<div class="uk-margin-small">
								<input type="checkbox" class="sc-js-med-info" id="f-med-q-2" data-sc-switchery data-switchery-size="small" data-switchery-color="#1c7cd6">
								<label for="f-med-q-2" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Have you ever been hospitalized or had a major operation?</label>
								<div class="sc-js-el-show uk-margin-small-top uk-margin-medium-bottom">
									<input type="text" class="uk-input" placeholder="Please add more info..." data-sc-input>
								</div>
							</div>
							<div class="uk-margin-small">
								<input type="checkbox" class="sc-js-med-info" id="f-med-q-3" data-sc-switchery data-switchery-size="small" data-switchery-color="#1c7cd6">
								<label for="f-med-q-3" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Have you ever had a serious head or neck injury?</label>
								<div class="sc-js-el-show uk-margin-small-top uk-margin-medium-bottom">
									<input type="text" class="uk-input" placeholder="Please add more info..." data-sc-input>
								</div>
							</div>
							<div class="uk-margin-small">
								<input type="checkbox" class="sc-js-med-info" id="f-med-q-4" data-sc-switchery data-switchery-size="small" data-switchery-color="#1c7cd6">
								<label for="f-med-q-4" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Are you taking any medications, pills or drugs?</label>
								<div class="sc-js-el-show uk-margin-small-top uk-margin-medium-bottom">
									<input type="text" class="uk-input" placeholder="Please add more info..." data-sc-input>
								</div>
							</div>
							<div class="uk-margin-small">
								<input type="checkbox" id="f-med-q-5" data-sc-switchery data-switchery-size="small" data-switchery-color="#1c7cd6">
								<label for="f-med-q-5" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Are you on a special diet?</label>
							</div>
							<div class="uk-margin-small">
								<input type="checkbox" id="f-med-q-6" data-sc-switchery data-switchery-size="small" data-switchery-color="#1c7cd6">
								<label for="f-med-q-6" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Do you use tobaco?</label>
							</div>
							<h4 class="uk-margin-large-top">Do you have or have you had any of the following?</h4>
							<div class="uk-child-width-expand@l" data-uk-grid>
								<div class="uk-margin-remove">
									<ul class="uk-list">
										<li>
											<input type="checkbox" id="f-q-1" name="f-q-1" data-sc-icheck>
											<label for="f-q-1">AIDS/HIV Positive</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-2" name="f-q-2" data-sc-icheck>
											<label for="f-q-2">Anemia</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-3" name="f-q-3" data-sc-icheck>
											<label for="f-q-3">Asthma</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-4" name="f-q-4" data-sc-icheck>
											<label for="f-q-4">Breathing Problem</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-5" name="f-q-5" data-sc-icheck>
											<label for="f-q-5">Cancer</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-6" name="f-q-6" data-sc-icheck>
											<label for="f-q-6">Chemotherapy</label>
										</li>
									</ul>
								</div>
								<div class="uk-margin-remove">
									<ul class="uk-list">
										<li>
											<input type="checkbox" id="f-q-7" name="f-q-7" data-sc-icheck>
											<label for="f-q-7">Chest Pains</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-8" name="f-q-8" data-sc-icheck>
											<label for="f-q-8">Cold Sores/Fever Blisters</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-9" name="f-q-9" data-sc-icheck>
											<label for="f-q-9">Convulsions</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-10" name="f-q-10" data-sc-icheck>
											<label for="f-q-10">Diabetes</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-11" name="f-q-11" data-sc-icheck>
											<label for="f-q-11">Drug Addition</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-12" name="f-q-12" data-sc-icheck>
											<label for="f-q-12">Frequent Cough</label>
										</li>
									</ul>
								</div>
								<div class="uk-margin-remove">
									<ul class="uk-list">
										<li>
											<input type="checkbox" id="f-q-13" name="f-q-13" data-sc-icheck>
											<label for="f-q-13">Hypoglycemia</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-14" name="f-q-14" data-sc-icheck>
											<label for="f-q-14">Glaucoma</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-15" name="f-q-15" data-sc-icheck>
											<label for="f-q-15">Heart Attack/Failure</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-16" name="f-q-16" data-sc-icheck>
											<label for="f-q-16">Low Blood Pressure</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-17" name="f-q-17" data-sc-icheck>
											<label for="f-q-17">Stroke</label>
										</li>
										<li>
											<input type="checkbox" id="f-q-18" name="f-q-18" data-sc-icheck>
											<label for="f-q-18">Tuberculosis</label>
										</li>
									</ul>
								</div>
							</div>
							<div class="uk-margin-large">
								<label class="uk-form-label" for="f-med-message">Additional info</label>
								<textarea name="f-med-message" id="f-med-message" cols="30" rows="6" class="uk-textarea" data-sc-input="outline"></textarea>
							</div>
							<div class="uk-margin-medium-top">
								<button class="sc-button sc-button-large sc-button-custom md-bg-blue-800" type="button">Save history</button>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
