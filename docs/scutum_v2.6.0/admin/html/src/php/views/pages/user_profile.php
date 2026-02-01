<?php $dt = _carbon(); ?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">
        <div class="uk-flex uk-flex-center">
            <div class="uk-width-4-5@l">
                <div data-uk-grid>
                    <div class="uk-width-1-4@l">
                        <div class="uk-card" data-uk-sticky="offset: 64; media: @l">
                            <div class="uk-card-body">
                                <div class="uk-text-center">
                                    <div class="sc-user-profile-avatar fileinput fileinput-exists uk-margin-bottom" data-provides="fileinput">
                                        <div class="fileinput-new thumbnail thumbnail-lg">
                                            <img src="assets/img/blank.gif" alt="">
                                        </div>
                                        <div class="fileinput-preview fileinput-exists thumbnail thumbnail-lg">
                                            <?php avatar('1',null,'_lg'); ?>
                                        </div>
                                        <div class="user_avatar_controls">
                                            <span class="btn-file">
                                                <span class="fileinput-new"><i class="mdi mdi-upload"></i></span>
                                                <span class="fileinput-exists"><i class="mdi mdi-autorenew"></i></span>
                                                <input type="file" name="user_edit_avatar_control" id="user_edit_avatar_control">
                                            </span>
                                            <a href="#" class="btn-file fileinput-exists" data-dismiss="fileinput"><i class="mdi mdi-trash-can">&#xE5CD;</i></a>
                                        </div>
                                    </div>
                                    <h4 class="uk-card-title"><?php echo $faker->name; ?></h4>
                                    <span class="sc-color-secondary"><?php echo $faker->company; ?></span>
                                </div>
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
				                            <?php echo $faker->company; ?>
                                        </div>
                                    </li>
                                    <li class="sc-list-group">
                                        <div class="sc-list-addon">
                                            <i class="mdi mdi-link"></i>
                                        </div>
                                        <div class="sc-list-body">
			                                https://tzdthemes.com
                                        </div>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="uk-width-expand@l">
                        <div class="uk-card">
                            <div class="uk-card-body">
                                <div class="uk-child-width-1-4@m uk-text-center" data-uk-grid>
                                    <div>
                                        <div class="sc-round sc-padding md-bg-grey-100">
                                            <h2 class="uk-margin-remove md-color-green-500">34 845</h2>
                                            <p class="sc-color-secondary uk-margin-remove">Followers</p>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="sc-round sc-padding md-bg-grey-100">
                                            <h2 class="uk-margin-remove md-color-green-500">2 410</h2>
                                            <p class="sc-color-secondary uk-margin-remove">Following</p>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="sc-round sc-padding md-bg-grey-100">
                                            <h2 class="uk-margin-remove md-color-green-500">148</h2>
                                            <p class="sc-color-secondary uk-margin-remove">Stories</p>
                                        </div>
                                    </div>
                                    <div>
                                        <div class="sc-round sc-padding md-bg-grey-100">
                                            <h2 class="uk-margin-remove md-color-red-500">31</h2>
                                            <p class="sc-color-secondary uk-margin-remove">Posts</p>
                                        </div>
                                    </div>
                                </div>

                                <h4 class="uk-heading-line uk-margin-large-top"><span>Friends</span></h4>
                                <div class="uk-flex uk-flex-wrap uk-grid-medium" data-uk-grid>
                                    <div>
                                        <a href="#" class="sc-avatar-wrapper">
                                            <span class="sc-user-status online"></span>
                                            <?php avatar(2);?>
                                        </a>
                                    </div>
                                    <div>
                                        <a href="#" class="sc-avatar-wrapper">
                                            <span class="sc-user-status away"></span>
		                                    <?php avatar(3);?>
                                        </a>
                                    </div>
                                    <div>
                                        <a href="#" class="sc-avatar-wrapper">
                                            <span class="sc-user-status online"></span>
		                                    <?php avatar(4);?>
                                        </a>
                                    </div>
                                    <div>
                                        <a href="#" class="sc-avatar-wrapper">
                                            <span class="sc-user-status busy"></span>
		                                    <?php avatar(5);?>
                                        </a>
                                    </div>
                                </div>

                                <h4 class="uk-heading-line uk-margin-large-top"><span>Comments</span></h4>
                                <div class="sc-round md-bg-grey-100 sc-padding">
                                    <ul class="uk-list uk-list-divider uk-margin-bottom sc-list-align">
                                        <li class="sc-list-group">
                                            <div class="sc-list-body">
                                                <p class="uk-margin-remove uk-text-small uk-text-meta">14/11/2019 14:31</p>
                                                <a href="#" class="sc-link uk-text-large uk-text-truncate uk-display-block"><?php echo $faker->sentence(4);?></a>
                                                <p class="uk-margin-remove uk-text-wrap"><?php echo $faker->sentence(20); ?></p>
                                            </div>
                                        </li>
                                        <li class="sc-list-group">
                                            <div class="sc-list-body">
                                                <p class="uk-margin-remove uk-text-small uk-text-meta">16/11/2019 08:45</p>
                                                <a href="#" class="sc-link uk-text-large uk-text-truncate uk-display-block"><?php echo $faker->sentence(4);?></a>
                                                <p class="uk-margin-remove uk-text-wrap"><?php echo $faker->sentence(20); ?></p>
                                            </div>
                                        </li>
                                        <li class="sc-list-group">
                                            <div class="sc-list-body">
                                                <p class="uk-margin-remove uk-text-small uk-text-meta">28/11/2019 20:11</p>
                                                <a href="#" class="sc-link uk-text-large uk-text-truncate uk-display-block"><?php echo $faker->sentence(4);?></a>
                                                <p class="uk-margin-remove uk-text-wrap"><?php echo $faker->sentence(20); ?></p>
                                            </div>
                                        </li>
                                    </ul>
                                    <button class="sc-button sc-button-small">More comments</button>
                                </div>

                                <h4 class="uk-heading-line uk-margin-large-top"><span>Timeline</span></h4>
                                <div class="sc-timeline">
                                    <div class="sc-timeline-item">
                                        <div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('d M'); ?></div>
                                        <div class="sc-timeline-icon md-bg-red-500 sc-light">
                                            <i class="mdi mdi-image"></i>
                                        </div>
                                        <div class="sc-timeline-body sc-timeline-body-border">
                                            <h4 class="sc-timeline-header">Created New Album</h4>
                                            <hr>
                                            <div class="sc-timeline-content">
                                                <ul class="sc-list-images uk-list uk-list-inline">
                                                    <li><?php photo(7, '_md'); ?></li>
                                                    <li><?php photo(1, '_md'); ?></li>
                                                    <li><?php photo(2, '_md'); ?></li>
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
                                            <h4 class="sc-timeline-header">Added New posts in <a href="#">Businness</a> category</h4>
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
                                        <div class="sc-timeline-body uk-box-shadow-small">
                                            <h4 class="sc-timeline-header">Added 3 commments</h4>
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
                                            <h4 class="sc-timeline-header">Completed 2 tasks</h4>
                                            <div class="sc-timeline-content">
                                                <ul class="sc-list-shadow uk-margin-top">
                                                    <li>
                                                        <a href="#"><?php echo $faker->sentence(4); ?></a>
                                                        <p class="sc-list-secondary-text uk-text-small">Logged: 2h 12m</p>
                                                    </li>
                                                    <li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
                                                </ul>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <h4 class="uk-heading-line uk-margin-large-top"><span>Notes</span></h4>
                                <p><?php echo $faker->sentence(80); ?></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
	</div>
    <div class="sc-fab-page-wrapper">
        <a href="#" class="sc-fab sc-fab-secondary sc-fab-large"><i class="mdi mdi-pencil"></i></a>
    </div>
</div>
