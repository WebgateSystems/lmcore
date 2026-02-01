<?php
$data_states = file_get_contents('./data/json/us_states.json');
$json_states = json_decode($data_states, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<form action="#" id="sc-js-form">
			<div class="uk-child-width-1-2@l" data-uk-grid>
				<div>
					<div class="uk-card">
						<div class="uk-card-body">
							<div>
								<h5>Regular inputs</h5>
								<div class="uk-margin">
									<label for="f-v-input">Label</label>
									<input class="uk-input" id="f-v-input" type="text" data-sc-input required>
								</div>
								<div class="uk-margin">
									<label for="f-v-textarea">Label</label>
									<textarea class="uk-textarea sc-js-autosize uk-height-max-medium" id="f-v-textarea" rows="3"  data-sc-input required data-parsley-minlength="10"></textarea>
								</div>
								<div class="uk-margin">
									<label for="f-v-input-outline">Label</label>
									<input class="uk-input" id="f-v-input-outline" type="text" data-sc-input="outline" required>
								</div>
								<div class="uk-margin">
									<label for="f-v-textarea-outline">Label</label>
									<textarea class="uk-textarea sc-textarea-outline sc-js-autosize uk-height-max-small" id="f-v-textarea-outline" rows="3" data-sc-input data-parsley-minlength="10" required></textarea>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div>
					<div class="uk-card">
						<div class="uk-card-body">
							<h5>Advanced controls</h5>
							<div class="uk-margin-large">
								<div class="sc-validation-wrapper">
									<select name="f-v-select2" id="f-v-select2" class="uk-select" data-sc-select2='{"placeholder": "Select state...", "allowClear": true }' required>
	                                    <option value="">Select state...</option>
										<?php foreach ($json_states as $value) {?>
											<option value="<?php echo $value['val']?>"><?php echo $value['name']?></option>
										<?php }; ?>
									</select>
								</div>
							</div>
							<div class="uk-margin-large">
								<div class="sc-validation-wrapper">
									<div class="uk-flex-inline uk-flex-middle <?php rtlReplace('uk-margin-right', 'uk-margin-small-left'); ?>">
										<input type="checkbox" id="square-checkbox-1" data-sc-icheck required data-parsley-mincheck="2" data-parsley-multiple="multipleCheckboxes">
										<label for="square-checkbox-1">Checkbox 1</label>
									</div>
									<div class="uk-flex-inline uk-flex-middle <?php rtlReplace('uk-margin-right', 'uk-margin-small-left'); ?>">
										<input type="checkbox" id="square-checkbox-2" data-sc-icheck data-parsley-multiple="multipleCheckboxes">
										<label for="square-checkbox-2">Checkbox 2</label>
									</div>
									<div class="uk-flex-inline uk-flex-middle">
										<input type="checkbox" id="square-checkbox-3" data-sc-icheck data-parsley-multiple="multipleCheckboxes">
										<label for="square-checkbox-3">Checkbox 3</label>
									</div>
								</div>
							</div>
							<div class="uk-margin-large">
								<div class="sc-validation-wrapper">
									<div class="uk-flex-inline uk-flex-middle <?php rtlReplace('uk-margin-right', 'uk-margin-small-left'); ?>">
										<input type="radio" id="square-radio-1" name="square-radio" data-sc-icheck required>
										<label for="square-radio-1">Radio button 1</label>
									</div>
									<div class="uk-flex-inline uk-flex-middle">
										<input type="radio" id="square-radio-2" name="square-radio" data-sc-icheck required>
										<label for="square-radio-2">Radio button 1</label>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="uk-margin">
				<button class="sc-button sc-button-secondary">Validate</button>
			</div>
		</form>
	</div>
</div>
