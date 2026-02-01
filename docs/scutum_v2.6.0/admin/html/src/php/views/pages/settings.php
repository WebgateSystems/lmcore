<?php
$data_countries = file_get_contents ('./data/json/countries.json');
$json_countries = json_decode($data_countries, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">

		<div class="uk-flex uk-flex-center">
			<div class="uk-width-4-5@l">
				<div data-uk-grid>
					<div class="uk-width-1-4@m uk-width-1-5@l">
						<ul class="uk-subnav uk-subnav-pill uk-flex-column" data-uk-switcher="connect: .sc-settings-container; animation: uk-animation-slide-bottom-small; swiping: false" data-uk-sticky="offset:72;media: @s">
							<li><a href="#"><span class="uk-flex uk-flex-middle uk-text-medium sc-text-semibold"><i class="mdi mdi-cogs <?php rtlReplace('uk-margin-medium-right', 'uk-margin-medium-left'); ?>"></i>Basic Settings</span></a></li>
							<li><a href="#"><span class="uk-flex uk-flex-middle uk-text-medium sc-text-semibold"><i class="mdi mdi-account-group <?php rtlReplace('uk-margin-medium-right', 'uk-margin-medium-left'); ?>"></i>Users</span></a></li>
							<li><a href="#"><span class="uk-flex uk-flex-middle uk-text-medium sc-text-semibold"><i class="mdi mdi-brush <?php rtlReplace('uk-margin-medium-right', 'uk-margin-medium-left'); ?>"></i>Appearance</span></a></li>
							<li><a href="#"><span class="uk-flex uk-flex-middle uk-text-medium sc-text-semibold"><i class="mdi mdi-puzzle-outline <?php rtlReplace('uk-margin-medium-right', 'uk-margin-medium-left'); ?>"></i>Plugins</span></a></li>
						</ul>
					</div>
					<div class="uk-width-3-4@m uk-width-4-5@l">
						<ul class="uk-switcher sc-settings-container">
							<li>
								<div class="uk-card">
									<div class="uk-flex uk-flex-middle sc-theme-bg-dark sc-light sc-round-top sc-padding sc-padding-medium-ends">
										<h3 class="uk-card-title uk-flex-1">
											Settings
											<span class="uk-display-block uk-card-subtitle">Lorem ipsum dolor, sit amet consectetur adipisicing elit. Unde, nulla.</span>
										</h3>
										<div class="<?php rtlReplace('uk-margin-left', 'uk-margin-right'); ?>">
											<button class="sc-button">Save</button>
										</div>
									</div>
									<hr class="uk-margin-remove">
									<div class="uk-card-body">
										<div class="uk-margin">
											<div class="uk-grid-small uk-flex-middle" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary" for="settings-page-online">Page Online</label>
												</div>
												<div class="uk-width-expand">
													<input type="checkbox" id="settings-page-online" name="settings-page-online" data-sc-switchery data-switchery-color="#7CB342" checked />
												</div>
											</div>
										</div>
										<div class="uk-margin">
											<div class="uk-grid-small uk-flex-middle" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary" for="settings-page-title">Page Title</label>
												</div>
												<div class="uk-width-expand">
													<input type="text" class="uk-input" name="settings-page-title" id="settings-page-title" data-sc-input value="Scutum Admin Template">
												</div>
											</div>
										</div>
										<div class="uk-margin">
											<div class="uk-grid-small uk-flex-middle" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary" for="settings-page-slogan">Page Slogan</label>
												</div>
												<div class="uk-width-expand">
													<input type="text" class="uk-input" name="settings-page-slogan" id="settings-page-slogan" data-sc-input>
												</div>
											</div>
										</div>
										<div class="uk-margin">
											<div class="uk-grid-small" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary uk-margin-small-top uk-display-inline-block" for="settings-page-description">Description</label>
												</div>
												<div class="uk-width-expand">
													<textarea class="uk-textarea" name="settings-page-description" id="settings-page-description" cols="20" rows="4" data-sc-input></textarea>
												</div>
											</div>
										</div>
										<div class="uk-margin">
											<div class="uk-grid-small uk-flex-middle" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary" for="settings-page-keywords">Keywords</label>
												</div>
												<div class="uk-width-expand">
													<select name="settings-page-keywords" id="settings-page-keywords" class="uk-select" data-sc-select2='{"tags": true, "tokenSeparators": [","], "closeOnSelect": true}' multiple>
														<option value="1" selected>Admin template</option>
														<option value="2" selected>UIkit</option>
														<option value="3">Multipurpose</option>
													</select>
												</div>
											</div>
										</div>
										<div class="uk-margin">
											<div class="uk-grid-small" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary uk-margin-small-top uk-display-inline-block" for="settings-page-www">Website's address</label>
												</div>
												<div class="uk-width-expand">
													<input type="text" class="uk-input" name="settings-page-www" id="settings-page-www" placeholder="https://" data-sc-input>
												</div>
											</div>
										</div>
										<div class="uk-margin">
											<div class="uk-grid-small uk-flex-middle" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary" for="settings-page-lang">Allow access from</label>
												</div>
												<div class="uk-width-expand">
													<select name="settings-page-lang" id="settings-page-lang" class="uk-select" data-sc-select2='{"templateResult": "formatCountryResult", "templateSelection": "formatCountrySelection", "placeholder": "Select countries..."}' multiple>
														<option value="">Select countries...</option>
                                                        <?php $countries = ['US','CN','BR','PL','ES','IN']; ?>
														<?php foreach ($json_countries as $value) {?>
															<option value="<?php echo $value['code']?>"<?php if(in_array($value['code'], $countries)) { ?> selected<?php }; ?>><?php echo $value['name']?></option>
														<?php }; ?>
													</select>
												</div>
											</div>
										</div>
										<div class="uk-margin">
											<div class="uk-grid-small" data-uk-grid>
												<div class="uk-width-1-4@m">
													<label class="sc-color-secondary uk-display-inline-block" for="settings-page-www">Use SSL</label>
												</div>
												<div class="uk-width-expand uk-flex">
													<span class="<?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?>">
														<input type="radio" id="settings-page-ssl-yes" name="settings-page-ssl" data-sc-icheck>
														<label for="settings-page-ssl-yes">Yes</label>
													</span>
													<span>
														<input type="radio" id="settings-page-ssl-no" name="settings-page-ssl" data-sc-icheck>
														<label for="settings-page-ssl-no">No</label>
													</span>
												</div>
											</div>
										</div>
									</div>
								</div>
							</li>
							<li>
								<div class="uk-card">
                                    <div class="uk-flex uk-flex-middle sc-theme-bg-dark sc-light sc-round-top sc-padding sc-padding-medium-ends">
                                        <h3 class="uk-card-title uk-flex-1">
                                            Users
                                            <span class="uk-display-block uk-card-subtitle">Lorem ipsum dolor, sit amet consectetur adipisicing elit. Unde, nulla.</span>
                                        </h3>
                                    </div>
                                    <hr class="uk-margin-remove">
									<div class="uk-card-body">
                                        <div class="uk-overflow-auto">
                                            <table class="uk-table uk-table-divider">
                                                <thead>
                                                    <tr>
                                                        <th><input id="sc-users-check-all" class="uk-checkbox sc-main-checkbox" type="checkbox" data-sc-icheck data-group=".sc-js-settings-users"></th>
                                                        <th>User Name</th>
                                                        <th>Email</th>
                                                        <th>Phone Number</th>
                                                        <th>Status</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <?php for($i=0;$i<8;$i++) { ?>
                                                    <tr>
                                                        <td class="uk-table-shrink"><input id="sc-users-check-<?php echo $i;?>" class="uk-checkbox sc-js-settings-users" type="checkbox" data-sc-icheck></td>
                                                        <td class="sc-text-semibold uk-text-nowrap"><?php echo $faker->firstName; ?> <?php echo $faker->lastName; ?></td>
                                                        <td><?php echo $faker->email; ?></td>
                                                        <td class="uk-text-nowrap"><?php echo $faker->phoneNumber; ?></td>
                                                        <td>
                                                            <?php if($i !== 3 && $i !== 6) { ?>
                                                                <span class="uk-label uk-label-success">Active</span>
                                                            <?php }; ?>
                                                            <?php if($i === 3 || $i === 6) { ?>
                                                                <span class="uk-label uk-label-danger">Disabled</span>
                                                            <?php }; ?>
                                                        </td>
                                                        <td class="uk-text-nowrap">
                                                            <a href="#" class="mdi mdi-pencil sc-icon-square"></a>
                                                            <a href="#" class="mdi mdi-trash-can-outline sc-icon-square"></a>
                                                        </td>
                                                    </tr>
                                                    <?php }; ?>
                                                </tbody>
                                            </table>
                                        </div>
									</div>
								</div>
							</li>
							<li>
                                <div class="uk-card">
                                    <div class="uk-flex uk-flex-middle sc-theme-bg-dark sc-light sc-round-top sc-padding sc-padding-medium-ends">
                                        <h3 class="uk-card-title uk-flex-1">
                                            Appearance
                                            <span class="uk-display-block uk-card-subtitle">Lorem ipsum dolor, sit amet consectetur adipisicing elit. Unde, nulla.</span>
                                        </h3>
                                        <div>
                                            <button class="sc-button">Save</button>
                                        </div>
                                    </div>
                                    <hr class="uk-margin-remove">
                                    <div class="uk-card-body">
                                        <div class="uk-margin">
                                            <div class="uk-grid-small uk-flex-middle" data-uk-grid>
                                                <div class="uk-width-1-4@m">
                                                    <label class="sc-color-secondary" for="settings-page-appearance-scheme">Color Scheme</label>
                                                </div>
                                                <div class="uk-width-1-4@m">
                                                    <select name="settings-page-appearance-scheme" id="settings-page-appearance-scheme" class="uk-select" data-sc-select2='{"placeholder": "Select color scheme...", "minimumResultsForSearch": -1, "allowClear": true}'>
                                                        <option value="">Select color scheme...</option>
                                                        <option value="light">Light</option>
                                                        <option value="dark">Dark</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="uk-margin">
                                            <div class="uk-grid-small uk-flex-middle" data-uk-grid>
                                                <div class="uk-width-1-4@m">
                                                    <label class="sc-color-secondary" for="settings-page-appearance-layout">Layout</label>
                                                </div>
                                                <div class="uk-width-1-4@m">
                                                    <select name="settings-page-appearance-layout" id="settings-page-appearance-layout" class="uk-select" data-sc-select2='{"minimumResultsForSearch": -1}'>
                                                        <option value="default">Default</option>
                                                        <option value="blog">Blog</option>
                                                        <option value="portfolio">Portfolio</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="uk-margin-medium">
                                            <div class="uk-grid-small" data-uk-grid>
                                                <div class="uk-width-1-4@m">
                                                    <label class="sc-color-secondary uk-display-inline-block">Sticky Header</label>
                                                </div>
                                                <div class="uk-width-expand@m uk-flex">
													<span class="<?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?>">
														<input type="radio" id="settings-page-appearance-header-yes" name="settings-page-appearance-header" data-sc-icheck>
														<label for="settings-page-appearance-header-yes">Yes</label>
													</span>
                                                    <span>
														<input type="radio" id="settings-page-appearance-header-no" name="settings-page-appearance-header" data-sc-icheck checked>
														<label for="settings-page-appearance-header-no">No</label>
													</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="uk-margin-medium">
                                            <div class="uk-grid-small" data-uk-grid>
                                                <div class="uk-width-1-4@m">
                                                    <label class="sc-color-secondary uk-display-inline-block" for="settings-page-appearance-fonts">Global Font</label>
                                                </div>
                                                <div class="uk-width-1-2@m">
                                                    <select name="settings-page-appearance-fonts" id="settings-page-appearance-fonts" class="uk-select" data-sc-select2='{"minimumResultsForSearch": -1}'>
                                                        <option value="1">Roboto, sans-serif</option>
                                                        <option value="2">Helvetica, sans-serif</option>
                                                        <option value="3">Trebuchet MS, sans-serif</option>
                                                        <option value="4">Avantgarde, TeX Gyre Adventor, URW Gothic L, sans-serif</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>
                                        <h4 class="uk-heading-line"><span>Colors</span></h4>
                                        <div class="uk-margin-medium">
                                            <div class="uk-grid-small" data-uk-grid>
                                                <div class="uk-width-1-4@m">
                                                    <label class="sc-color-secondary uk-display-inline-block" for="settings-page-appearance-color-primary">Primary</label>
                                                </div>
                                                <div class="uk-width-1-2@m">
                                                    <input type="text" id="settings-page-appearance-color-primary" name="settings-page-appearance-color-primary" data-sc-colorpicker />
                                                    <span class="uk-form-help-block <?php rtlReplace('uk-margin-remove-left', 'uk-margin-remove-right'); ?> uk-margin-mini-top">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Fuga, ullam.</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="uk-margin-medium">
                                            <div class="uk-grid-small" data-uk-grid>
                                                <div class="uk-width-1-4@m">
                                                    <label class="sc-color-secondary uk-display-inline-block" for="settings-page-appearance-color-secondary">Secondary</label>
                                                </div>
                                                <div class="uk-width-1-2@m">
                                                    <input id="settings-page-appearance-color-secondary" type="text" name="settings-page-appearance-color-primary" data-sc-colorpicker />
                                                    <span class="uk-form-help-block <?php rtlReplace('uk-margin-remove-left', 'uk-margin-remove-right'); ?> uk-margin-mini-top">Lorem ipsum dolor sit amet, ullam.</span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="uk-margin-medium">
                                            <div class="uk-grid-small" data-uk-grid>
                                                <div class="uk-width-1-4@m">
                                                    <label class="sc-color-secondary uk-display-inline-block" for="settings-page-appearance-color-links">Links</label>
                                                </div>
                                                <div class="uk-width-1-2@m">
                                                    <input id="settings-page-appearance-color-links" type="text" name="settings-page-appearance-color-primary" value="#1e88e5" data-sc-colorpicker='{"pallete": "#5e35b1,#689f38,#1e88e5,#e53935"}' />
                                                    <span class="uk-form-help-block <?php rtlReplace('uk-margin-remove-left', 'uk-margin-remove-right'); ?> uk-margin-mini-top">Lorem ipsum dolor sit amet.</span>
                                                </div>
                                            </div>
                                        </div>
									</div>
								</div>
							</li>
							<li>
								<div class="uk-card">
                                    <div class="uk-flex uk-flex-middle sc-theme-bg-dark sc-light sc-round-top sc-padding sc-padding-medium-ends">
                                        <h3 class="uk-card-title uk-flex-1">
                                            Plugins
                                            <span class="uk-display-block uk-text-small uk-margin-mini-top">Lorem ipsum dolor, sit amet consectetur adipisicing elit. Unde, nulla.</span>
                                        </h3>
                                    </div>
                                    <hr class="uk-margin-remove">
									<div class="uk-card-body">
                                        <div class="uk-overflow-auto">
                                            <table class="uk-table uk-table-divider">
                                                <thead>
                                                <tr>
                                                    <th><input id="sc-plugins-check-all" class="uk-checkbox sc-main-checkbox" type="checkbox" data-sc-icheck data-group=".sc-js-settings-plugins"></th>
                                                    <th>Name</th>
                                                    <th>Version</th>
                                                    <th>Description</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                                </thead>
                                                <tbody>
                                                <?php for($i=0;$i<5;$i++) { ?>
                                                    <tr>
                                                        <td class="uk-table-shrink"><input class="uk-checkbox sc-js-settings-plugins" type="checkbox" data-sc-icheck></td>
                                                        <td class="sc-text-semibold uk-text-nowrap">Plugin Name <?php echo $i; ?></td>
                                                        <td class="uk-text-nowrap">ver. 1.<?php echo rand(1,10);?></td>
                                                        <td class="uk-text-nowrap"><?php echo $faker->sentence(10); ?></td>
                                                        <td class="uk-table-middle">
                                                            <?php if($i !== 2 && $i !== 3) { ?>
                                                                <span class="uk-label uk-label-success">Active</span>
                                                            <?php }; ?>
                                                            <?php if($i === 2 || $i === 3) { ?>
                                                                <span class="uk-label md-bg-grey-500">Disabled</span>
                                                            <?php }; ?>
                                                        </td>
                                                        <td class="uk-text-nowrap uk-table-middle">
                                                            <?php if($i !== 2 && $i !== 3) { ?>
                                                                <a href="#" class="mdi mdi-toggle-switch sc-icon-square md-color-green-600" data-uk-tooltip="Deactivate"></a>
                                                            <?php } else { ?>
                                                                <a href="#" class="mdi mdi-toggle-switch-off sc-icon-square" data-uk-tooltip="Activate"></a>
                                                            <?php }; ?>
                                                            <a href="#" class="mdi mdi-trash-can-outline sc-icon-square"></a>
                                                        </td>
                                                    </tr>
                                                <?php }; ?>
                                                </tbody>
                                            </table>
                                        </div>
									</div>
								</div>
							</li>
						</ul>
					</div>
				</div>
			</div>
		</div>

	</div>
</div>
