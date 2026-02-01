<?php
$json = file_get_contents("data/json/users.json");
$users = json_decode($json, true);
$dt = _carbon();
?>
<div id="sc-page-wrapper" class="uk-flex uk-flex-column">
	<div class="uk-flex uk-height-1-1">
		<div id="sc-page-content" data-sc-scrollbar="visible-y">
			<div class="sc-js-sticky-parent">
				<div class="uk-card sc-light sc-card-user-profile" data-sc-sticky='{ "container": "#sc-page-content", "media": "mediumMin" }' data-sc-bg-gradient="#7B1FA2,#4527A0">
					<div class="sc-card-user-profile-body">
						<?php avatar('4',null,'_lg','uk-margin-right'); ?>
						<div>
							<h4 class="uk-card-title"><?php echo $faker->name; ?></h4>
							<div class="sc-color-secondary uk-flex uk-flex-middle"><?php echo $faker->company; ?></div>
						</div>
					</div>
					<div class="sc-actions uk-visible@m">
						<a href="#" class="sc-actions-icon mdi mdi-pencil"></a>
						<a href="#" class="sc-actions-icon mdi mdi-message-outline"></a>
						<a href="#" class="sc-actions-icon mdi mdi-information-outline"></a>
					</div>
				</div>
				<div class="uk-card uk-margin">
					<div class="uk-card-header">
						<h5 class="uk-card-title"><span>Address</span></h5>
					</div>
					<div id="sc-js-address-map" class="sc-gmap"></div>
					<div class="uk-card-body">
						<address>
							<span><?php echo $faker->address; ?></span><br>
							<span><?php echo $faker->city; ?></span><br>
							<span><?php echo $faker->country; ?></span>
						</address>
					</div>
				</div>
			</div>
            <div class="uk-child-width-1-2@l" data-uk-grid>
                <div>
                    <div class="uk-card uk-margin">
                        <div class="uk-card-body">
                            <h5 class="uk-heading-line"><span>Personal informations</span></h5>
                            <ul class="uk-list uk-list-divider">
                                <li class="sc-list-group">
                                    <div class="sc-list-addon">
                                        <i class="mdi mdi-email"></i>
                                    </div>
                                    <div class="sc-list-body">
                                        <div class="sc-list-body-inner"><?php echo $faker->email; ?></div>
                                    </div>
                                </li>
                                <li class="sc-list-group">
                                    <div class="sc-list-addon">
                                        <i class="mdi mdi-phone"></i>
                                    </div>
                                    <div class="sc-list-body">
                                        <?php echo $faker->phoneNumber; ?>
                                    </div>
                                </li>
                                <li class="sc-list-group">
                                    <div class="sc-list-addon">
                                        <i class="mdi mdi-office-building"></i>
                                    </div>
                                    <div class="sc-list-body">
	                                    <span class="uk-text-wrap">
	                                        <?php echo $faker->company; ?>
	                                    </span>
                                    </div>
                                </li>
                                <li class="sc-list-group">
                                    <div class="sc-list-addon">
                                        <i class="mdi mdi-earth"></i>
                                    </div>
                                    <div class="sc-list-body">
                                        <span class="uk-text-wrap"><?php echo $faker->address; ?></span>
                                        <span class="sc-list-secondary-text"><?php echo $faker->city; ?></span>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div>
                    <div class="uk-margin">
                        <div class="uk-card uk-margin">
                            <div class="uk-card-body">
                                <h5 class="uk-heading-line"><span>Timeline</span></h5>
                                <div class="sc-timeline">
                                    <div class="sc-timeline-item">
                                        <div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('d M'); ?></div>
                                        <div class="sc-timeline-icon md-bg-red-500 sc-light">
                                            <i class="mdi mdi-image"></i>
                                        </div>
                                        <div class="sc-timeline-body sc-timeline-body-border">
                                            <h4 class="sc-timeline-header">New album</h4>
                                            <hr>
                                            <div class="sc-timeline-content">
                                                <ul class="sc-list-images uk-list uk-list-inline">
                                                    <li><?php photo(2,'_md');?></li>
                                                    <li><?php photo(3,'_md');?></li>
                                                    <li><?php photo(4,'_md');?></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="sc-timeline-item">
                                        <div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('d M'); ?></div>
                                        <div class="sc-timeline-icon md-bg-green-500 sc-light">
                                            <i class="mdi mdi-file-document"></i>
                                        </div>
                                        <div class="sc-timeline-body sc-timeline-body-border">
                                            <h4 class="sc-timeline-header">New posts in <a href="#">Travel</a> category</h4>
                                            <span class="sc-timeline-meta">23 comments; 14 pingbacks</span>
                                            <hr>
                                            <div class="sc-timeline-content">
                                                <?php echo $faker->sentence(20); ?>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="sc-timeline-item">
                                        <div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('d M'); ?></div>
                                        <div class="sc-timeline-icon md-bg-light-blue-500 sc-light">
                                            <i class="mdi mdi-comment"></i>
                                        </div>
                                        <div class="sc-timeline-body sc-timeline-body-shadow">
                                            <h4 class="sc-timeline-header">14 new commments</h4>
                                            <span class="sc-timeline-meta"></span>
                                            <div class="sc-timeline-content"></div>
                                        </div>
                                    </div>
                                    <div class="sc-timeline-item">
                                        <div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('d M'); ?></div>
                                        <div class="sc-timeline-icon md-bg-amber-500 sc-light">
                                            <i class="mdi mdi-calendar-check"></i>
                                        </div>
                                        <div class="sc-timeline-body md-bg-grey-100">
                                            <h4 class="sc-timeline-header">User <a href="#"><?php echo $faker->userName; ?></a> have completed 4 tasks</h4>
                                            <div class="sc-timeline-content">
                                                <ul class="sc-list-shadow uk-margin-top">
                                                    <li>
                                                        <a href="#"><?php echo $faker->sentence(4);?></a>
                                                        <p class="sc-list-secondary-text uk-text-small">Logged: 2h 12m</p>
                                                    </li>
                                                    <li><a href="#"><?php echo $faker->sentence(4);?></a></li>
                                                    <li><a href="#"><?php echo $faker->sentence(4);?></a></li>
                                                    <li><a href="#"><?php echo $faker->sentence(4);?></a></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
		</div>
		<div id="sc-page-aside" class="sc-page-aside-large md-bg-white sc-padding-remove">
			<div class="sc-page-aside-header md-bg-grey-100 sc-border-bottom sc-padding sc-padding-medium-ends">
				<input type="text" class="uk-input sc-js-list-search" placeholder="Find user...">
			</div>
			<div class="sc-page-aside-body sc-padding-remove" data-sc-scrollbar="visible-y">
				<ul class="uk-list uk-list-divider sc-list-clickable sc-padding-medium">
	<?php foreach ($users as $key => $value) { ?>
					<li class="sc-list-group" data-user-id="<?php echo $value['id']; ?>">
						<div class="sc-list-addon">
							<div class="sc-avatar-wrapper sc-avatar-wrapper-sm">
								<?php avatar(rand(1,9), null); ?>
							</div>
						</div>
						<div class="sc-list-body">
							<div>
								<span class="sc-js-list-fName"><?php echo $value['fName']; ?></span>
								<span class="sc-js-list-lName"><?php echo $value['lName']; ?></span>
							</div>
							<div class="sc-list-secondary-text sc-js-list-company"><?php echo $value['company']; ?></div>
						</div>
					</li>
	<?php }; ?>
				</ul>
			</div>
		</div>
	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar sc-padding-remove">
        <div class="sc-page-aside-body sc-padding-remove">
	        <div class="sc-padding">
	            <ul class="uk-list uk-list-divider sc-list-clickable sc-list-align">
				    <?php foreach ($users as $key => $value) { PHP_EOL; ?>
	                    <li class="sc-list-group" data-user-id="<?php echo $value['id']; ?>">
	                        <div class="sc-list-addon">
	                            <div class="sc-avatar-wrapper sc-avatar-wrapper-sm">
								    <?php avatar(rand(1,9), null); ?>
	                            </div>
	                        </div>
	                        <div class="sc-list-body">
	                            <div>
	                                <span class="sc-js-list-fName"><?php echo $value['fName']; ?></span>
	                                <span class="sc-js-list-lName"><?php echo $value['lName']; ?></span>
	                            </div>
	                            <div class="sc-list-secondary-text sc-js-list-company"><?php echo $value['company']; ?> Lorem ipsum dolor sit amet, consectetur adipisicing elit. Expedita, ullam!</div>
	                        </div>
	                    </li>
				    <?php }; PHP_EOL; ?>
	            </ul>
	        </div>
        </div>
    </div>
</div>
