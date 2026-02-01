<div id="sc-page-wrapper">
	<div id="sc-page-content">

        <div class="uk-child-width-1-4@l uk-child-width-1-2@s" data-uk-grid="">
            <div>
                <div class="uk-card">
                    <a href="#" class="uk-display-block uk-text-center uk-card-body sc-padding-medium uk-position-relative">
                        <i class="mdi mdi-bullhorn sc-color-primary sc-icon-28 uk-display-inline-block"></i>
                        <h4 class="uk-margin-remove">Announcements</h4>
                        <span class="uk-badge md-bg-purple-600 uk-position-absolute <?php rtlReplace('uk-position-top-right uk-margin-small-right', 'uk-position-top-left uk-margin-small-left'); ?> uk-margin-small-top">24</span>
                    </a>
                </div>
            </div>
            <div>
                <div class="uk-card">
                    <a href="#" class="uk-display-block uk-text-center uk-card-body sc-padding-medium uk-position-relative">
                        <i class="mdi mdi-forum-outline sc-color-primary sc-icon-28 uk-display-inline-block"></i>
                        <h4 class="uk-margin-remove">General</h4>
                        <span class="uk-badge md-bg-blue-600 uk-position-absolute <?php rtlReplace('uk-position-top-right uk-margin-small-right', 'uk-position-top-left uk-margin-small-left'); ?> uk-margin-small-top">7</span>
                    </a>
                </div>
            </div>
            <div>
                <div class="uk-card">
                    <a href="#" class="uk-display-block uk-text-center uk-card-body sc-padding-medium uk-position-relative">
                        <i class="mdi mdi-bug sc-color-primary sc-icon-28 uk-display-inline-block"></i>
                        <h4 class="uk-margin-remove">Bugs</h4>
                        <span class="uk-badge md-bg-red-600 uk-position-absolute <?php rtlReplace('uk-position-top-right uk-margin-small-right', 'uk-position-top-left uk-margin-small-left'); ?> uk-margin-small-top">46</span>
                    </a>
                </div>
            </div>
            <div>
                <div class="uk-card">
                    <a href="#" class="uk-display-block uk-text-center uk-card-body sc-padding-medium uk-position-relative">
                        <i class="mdi mdi-thought-bubble-outline sc-color-primary sc-icon-28 uk-display-inline-block"></i>
                        <h4 class="uk-margin-remove">Off Topic</h4>
                        <span class="uk-badge md-bg-light-green-600 uk-position-absolute <?php rtlReplace('uk-position-top-right uk-margin-small-right', 'uk-position-top-left uk-margin-small-left'); ?> uk-margin-small-top">118</span>
                    </a>
                </div>
            </div>
        </div>

		<div data-uk-grid>
			<div class="uk-width-4-5@l">
				<div class="uk-card">
					<div class="uk-card-body">
						<h3 class="uk-margin-small-bottom">Frequently Asked Questions</h3>
						<p class="sc-color-secondary uk-margin-remove">Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatibus, tenetur!</p>
						<ul class="uk-accordion-alt uk-margin-large-top" data-uk-accordion>
<?php for($i=1;$i<10;$i++) { ?>
							<li>
								<h3 class="uk-accordion-title"><span class="uk-text-muted uk-margin-small-right"><?php echo $i; ?></span><?php echo $faker->sentence(10); ?></h3>
								<div class="uk-accordion-content">
									<div data-uk-grid>
										<div class="uk-width-expand@m"><?php echo $faker->sentence(60); ?></div>
									</div>
								</div>
							</li>
<?php }; ?>
						</ul>

					</div>
				</div>
			</div>
			<div class="uk-width-1-5@l">
                <h3 class="uk-card-title">Categories</h3>
                <ul class="uk-list uk-list-divider uk-margin-remove">
                    <li class="sc-list-group">
                        <div class="sc-list-addon"><i class="mdi mdi-headphones"></i></div>
                        <div class="sc-list-body">
                            <a class="uk-flex-column sc-flex-items-left">
                                <span class="sc-text-semibold">Category 1</span>
                                <span class="sc-list-secondary-text">Lorem ipsum dolor sit.</span>
                            </a>
                        </div>
                    </li>
                    <li class="sc-list-group">
                        <div class="sc-list-addon"><i class="mdi mdi-tag-heart"></i></div>
                        <div class="sc-list-body">
                            <a href="#" class="uk-flex-column sc-flex-items-left">
                                <span class="sc-text-semibold">Category 2</span>
                                <span class="sc-list-secondary-text">Lorem ipsum dolor sit.</span>
                            </a>
                        </div>
                    </li>
                    <li class="sc-list-group">
                        <div class="sc-list-addon"><i class="mdi mdi-mushroom"></i></div>
                        <div class="sc-list-body">
                            <a href="#" class="uk-flex-column sc-flex-items-left">
                                <span class="sc-text-semibold">Category 3</span>
                                <span class="sc-list-secondary-text">Lorem ipsum dolor sit.</span>
                            </a>
                        </div>
                    </li>
                    <li class="sc-list-group">
                        <div class="sc-list-addon"><i class="mdi mdi-access-point"></i></div>
                        <div class="sc-list-body">
                            <a href="#" class="uk-flex-column sc-flex-items-left">
                                <span class="sc-text-semibold">Category 4</span>
                                <span class="sc-list-secondary-text">Lorem ipsum dolor sit.</span>
                            </a>
                        </div>
                    </li>
                    <li class="sc-list-group">
                        <div class="sc-list-addon"><i class="mdi mdi-cake"></i></div>
                        <div class="sc-list-body">
                            <a href="#" class="uk-flex-column sc-flex-items-left">
                                <span class="sc-text-semibold">Category 5</span>
                                <span class="sc-list-secondary-text">Lorem ipsum dolor sit.</span>
                            </a>
                        </div>
                    </li>
                </ul>
			</div>
		</div>

	</div>
</div>
