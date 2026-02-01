<?php $dt = _carbon(); ?>
<header id="sc-header">
	<nav class="uk-navbar uk-navbar-container" data-uk-navbar="mode: click; duration: 360">
		<div class="<?php rtlReplace('uk-navbar-left', 'uk-navbar-right'); ?> nav-overlay-small <?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?> uk-navbar-aside">
            <?php if($page !== 'top_menu') { ?>
			<a href="#" id="sc-sidebar-main-toggle"><i class="mdi mdi-backburger sc-menu-close"></i><i class="mdi mdi-menu sc-menu-open"></i></a>
            <?php }; ?>
			<div class="sc-brand uk-visible@s">
				<a href="dashboard-v1.html"><img src="assets/img/logo.png" alt=""></a>
			</div>
		</div>
    <?php if($page !== 'top_menu') { ?>
		<div class="<?php rtlReplace('uk-navbar-left', 'uk-navbar-right'); ?> nav-overlay <?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?> uk-visible@m">
			<ul class="uk-navbar-nav">
				<li>
					<a href="javascript:void(0)" class="md-color-white sc-padding-remove-left"><i class="mdi mdi-view-grid"></i></a>
					<div class="uk-navbar-dropdown sc-padding-medium">
						<div class="uk-child-width-1-2 uk-child-width-1-3@s uk-grid uk-grid-small" data-uk-grid>
							<div>
								<a href="pages-mailbox.html" class="uk-flex uk-flex-column uk-flex-middle uk-box-shadow-hover-small sc-round sc-padding-small">
									<i class="mdi mdi-email-outline sc-icon-32 sc-text-lh-1 md-color-green-700"></i>
									<span class="uk-text-medium sc-color-primary">Mailbox</span>
								</a>
							</div>
							<div>
								<a href="pages-poi_listing.html" class="uk-flex uk-flex-column uk-flex-middle uk-box-shadow-hover-small sc-round sc-padding-small">
									<i class="mdi mdi-map-marker sc-icon-32 sc-text-lh-1 md-color-red-700"></i>
									<span class="uk-text-medium sc-color-primary">POI</span>
								</a>
							</div>
							<div>
								<a href="pages-chat.html" class="uk-flex uk-flex-column uk-flex-middle uk-box-shadow-hover-small sc-round sc-padding-small">
									<i class="mdi mdi-message-outline sc-icon-32 sc-text-lh-1 md-color-purple-700"></i>
									<span class="uk-text-medium sc-color-primary">Chat</span>
								</a>
							</div>
							<div>
								<a href="plugins-calendar.html" class="uk-flex uk-flex-column uk-flex-middle uk-box-shadow-hover-small sc-round sc-padding-small">
									<i class="mdi mdi-calendar sc-icon-32 sc-text-lh-1 md-color-light-blue-700"></i>
									<span class="uk-text-medium sc-color-primary">Calendar</span>
								</a>
							</div>
							<div>
								<a href="pages-user_profile.html" class="uk-flex uk-flex-column uk-flex-middle uk-box-shadow-hover-small sc-round sc-padding-small">
									<i class="mdi mdi-account sc-icon-32 sc-text-lh-1 md-color-blue-grey-700"></i>
									<span class="uk-text-medium sc-color-primary">Profile</span>
								</a>
							</div>
							<div>
								<a href="plugins-charts.html" class="uk-flex uk-flex-column uk-flex-middle uk-box-shadow-hover-small sc-round sc-padding-small">
									<i class="mdi mdi-chart-multiline sc-icon-32 sc-text-lh-1 md-color-amber-700"></i>
									<span class="uk-text-medium sc-color-primary">Charts</span>
								</a>
							</div>
						</div>
					</div>
				</li>
			</ul>
		</div>
    <?php } else { ?>
        <div class="<?php rtlReplace('uk-navbar-left', 'uk-navbar-right'); ?> nav-overlay nav-overlay-small <?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?> uk-visible@m">
            <ul class="uk-navbar-nav sc-top-menu">
			    <li>
                    <a href="#">Mailbox</a>
                </li>
                <li>
                    <a href="#">Components</a>
                    <ul>
                        <li>
                            <a href="#">Accordion</a>
                        </li>
                        <li>
                            <a href="#">Alert</a>
                        </li>
                        <li>
                            <a href="#">...</a>
                        </li>
                    </ul>
                </li>
                <li>
                    <a href="#">Pages</a>
                    <ul>
                        <li><a href="#">Blank</a></li>
                        <li><a href="#">Contact Page</a></li>
                        <li><a href="#">Gallery</a></li>
                        <li><a href="#">Settings</a></li>
                        <li><a href="#">User Profile</a></li>
                    </ul>
                </li>
                <li>
                    <a href="#">Nested</a>
                    <ul>
                        <li>
                            <a href="#">Level 1.0.0</a>
                        </li>
                        <li>
                            <a href="#">Level 1.0.0</a>
                        </li>
                        <li>
                            <a href="#">Level 1.0.0</a>
                            <ul>
                                <li>
                                    <a href="#">Level 1.1.0</a>
                                </li>
                                <li>
                                    <a href="#">Level 1.1.0</a>
                                    <ul>
                                        <li>
                                            <a href="#">Level 1.1.1</a>
                                        </li>
                                        <li>
                                            <a href="#">Level 1.1.1</a>
                                        </li>
                                        <li>
                                            <a href="#">Level 1.1.1</a>
                                        </li>
                                        <li>
                                            <a href="#">Level 1.1.1</a>
                                        </li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    <?php }?>
		<div class="nav-overlay nav-overlay-small <?php rtlReplace('uk-navbar-right', 'uk-navbar-left'); ?> uk-flex-1" hidden>
			<a class="uk-navbar-toggle uk-visible@m" data-uk-toggle="target: .nav-overlay; animation: uk-animation-slide-top" href="#">
				<i class="mdi mdi-close sc-icon-24"></i>
			</a>
			<a class="uk-navbar-toggle uk-hidden@m <?php rtlReplace('uk-padding-remove-left', 'uk-padding-remove-right'); ?>" data-uk-toggle="target: .nav-overlay-small; animation: uk-animation-slide-top" href="#">
				<i class="mdi mdi-close sc-icon-24"></i>
			</a>
			<div class="uk-navbar-item uk-width-expand <?php rtlReplace('uk-padding-remove-right', 'uk-padding-remove-left'); ?>">
				<form class="uk-search uk-search-navbar uk-width-1-1 uk-flex">
                    <div class="uk-flex-1 uk-position-relative">
                        <a class="uk-form-icon uk-form-icon-flip" href="javascript:void(0)" data-uk-icon="icon: close" data-sc-clear-input></a>
                        <input class="uk-search-input" type="search" placeholder="Search..." autofocus>
                    </div>
					<button class="sc-button sc-button-default sc-button-small sc-button-icon sc-button-flat <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>" type="button"><i class="mdi mdi-magnify sc-icon-24 md-color-white"></i></button>
				</form>
			</div>
		</div>
		<div class="nav-overlay nav-overlay-small <?php rtlReplace('uk-navbar-right', 'uk-navbar-left'); ?>">
			<ul class="uk-navbar-nav">
				<li>
					<a class="uk-navbar-toggle uk-visible@m" href="#" data-uk-toggle="target: .nav-overlay; animation: uk-animation-slide-top"><i class="mdi mdi-magnify"></i></a>
                    <a class="uk-navbar-toggle uk-hidden@m" href="#" id="sc-search-main-toggle-mobile" data-uk-toggle="target: .nav-overlay-small; animation: uk-animation-slide-top"><i class="mdi mdi-magnify"></i></a>
				</li>
				<li class="uk-visible@l">
					<a href="#" id="sc-js-fullscreen-toggle"><i class="mdi mdi-fullscreen sc-js-el-hide"></i><i class="mdi mdi-fullscreen-exit sc-js-el-show"></i></a>
				</li>
				<li class="uk-visible@s">
					<a href="#" class="sc-text-semibold">
						EN
					</a>
					<div class="uk-navbar-dropdown uk-dropdown-small">
						<ul class="uk-nav uk-navbar-dropdown-nav">
							<li><a href="#">Deutsch</a></li>
							<li><a href="#">Español</a></li>
							<li><a href="#">Français</a></li>
						</ul>
					</div>
				</li>
				<li>
					<a href="#">
						<span class="mdi mdi-email"></span>
					</a>
					<div class="uk-navbar-dropdown sc-padding-remove">
						<div class="uk-panel uk-panel-scrollable uk-height-medium">
							<ul class="uk-list uk-list-divider sc-js-edge-fix">
								<li class="sc-list-group">
									<div class="sc-list-addon">
										<?php avatarInitials('MO','md-color-white md-bg-red-500'); echo PHP_EOL; ?>
									</div>
									<a href="#" class="sc-list-body uk-display-block">
										<span class="uk-text-small uk-text-muted uk-width-expand"><?php echo $dt->subHours(2)->format('h:i A'); ?></span>
										<span class="uk-display-block uk-text-truncate"><?php echo $faker->sentence(8); ?></span>
									</a>
								</li>
								<li class="sc-list-group">
									<div class="sc-list-addon">
										<?php avatar('5',null); echo PHP_EOL; ?>
									</div>
									<a href="#" class="sc-list-body uk-display-block">
										<div class="uk-text-small uk-text-muted uk-width-expand"><?php echo $dt->subDays(1)->toFormattedDateString(); ?></div>
										<span class="uk-display-block uk-text-truncate"><?php echo $faker->sentence(8); ?></span>
									</a>
								</li>
								<li class="sc-list-group">
									<div class="sc-list-addon">
										<?php avatarInitials('KS','md-color-white md-bg-light-green-500'); echo PHP_EOL; ?>
									</div>
									<a href="#" class="sc-list-body uk-display-block">
										<span class="uk-text-small uk-text-muted uk-width-expand"><?php echo $dt->subHours(2)->format('h:i A'); ?></span>
										<span class="uk-display-block uk-text-truncate"><?php echo $faker->sentence(8); ?></span>
									</a>
								</li>
								<li class="sc-list-group">
									<div class="sc-list-addon">
										<?php avatar('6',null); echo PHP_EOL; ?>
									</div>
									<a href="#" class="sc-list-body uk-display-block">
										<span class="uk-text-small uk-text-muted uk-width-expand"><?php echo $dt->subDays(1)->toFormattedDateString(); ?></span>
										<span class="uk-display-block uk-text-truncate"><?php echo $faker->sentence(8); ?></span>
									</a>
								</li>
								<li class="sc-list-group">
									<div class="sc-list-addon">
										<?php avatar('2',null); echo PHP_EOL;  ?>
									</div>
									<a href="#" class="sc-list-body uk-display-block">
										<span class="uk-text-small uk-text-muted uk-width-expand"><?php echo $dt->subDays(2)->toFormattedDateString(); ?></span>
										<span class="uk-display-block uk-text-truncate"><?php echo $faker->sentence(8); ?></span>
									</a>
								</li>
								<li class="sc-list-group">
									<div class="sc-list-addon">
										<?php avatarInitials('FA','md-color-white md-bg-purple-500'); echo PHP_EOL; ?>
									</div>
									<a href="#" class="sc-list-body uk-display-block">
										<span class="uk-text-small uk-text-muted uk-width-expand"><?php echo $dt->subDays(2)->toFormattedDateString(); ?></span>
										<span class="uk-display-block uk-text-truncate"><?php echo $faker->sentence(8); ?></span>
									</a>
								</li>
							</ul>
						</div>
						<a href="pages-mailbox.html" class="uk-flex uk-text-small sc-padding-small-ends sc-padding-medium">Show all in mailbox</a>
					</div>
				</li>
				<li class="uk-visible@s">
					<a href="#">
						<span class="mdi mdi-bell uk-display-inline-block">
							<span class="sc-indicator md-bg-color-red-600"></span>
						</span>
					</a>
					<div class="uk-navbar-dropdown md-bg-grey-100">
                        <div class="sc-padding-medium sc-padding-small-ends">
                            <div class="uk-text-right uk-margin-medium-bottom">
                                <button class="sc-button sc-button-default sc-button-outline sc-button-mini sc-js-clear-alerts">Clear all</button>
                            </div>
                            <ul class="uk-list uk-margin-remove" id="sc-header-alerts">
                                <li class="sc-border sc-round md-bg-white">
                                    <div class="<?php rtlReplace('uk-margin-right uk-margin-small-left', 'uk-margin-left uk-margin-small-right'); ?>"><i class="mdi mdi-alert-outline md-color-red-600"></i></div>
                                    <div class="uk-flex-1 uk-text-small">
                                        Information Page Not Found!
                                    </div>
                                </li>
                                <li class="uk-margin-small-top sc-border sc-round md-bg-white">
                                    <div class="<?php rtlReplace('uk-margin-right uk-margin-small-left', 'uk-margin-left uk-margin-small-right'); ?>"><i class="mdi mdi-email-check-outline md-color-blue-600"></i></div>
                                    <div class="uk-flex-1 uk-text-small">
                                        A new password has been sent to your e-mail address.
                                    </div>
                                </li>
                                <li class="uk-margin-small-top sc-border sc-round md-bg-white">
                                    <div class="<?php rtlReplace('uk-margin-right uk-margin-small-left', 'uk-margin-left uk-margin-small-right'); ?>"><i class="mdi mdi-alert-outline md-color-red-600"></i></div>
                                    <div class="uk-flex-1 uk-text-small">
                                        You do not have permission to access the API!
                                    </div>
                                </li>
                                <li class="uk-margin-small-top sc-border sc-round md-bg-white">
                                    <div class="<?php rtlReplace('uk-margin-right uk-margin-small-left', 'uk-margin-left uk-margin-small-right'); ?>"><i class="mdi mdi-check-all md-color-light-green-600"></i></div>
                                    <div class="uk-flex-1 uk-text-small">
                                        Your enquiry has been successfully sent.
                                    </div>
                                </li>
                            </ul>
                            <div class="uk-text-medium uk-text-center sc-js-empty-message sc-text-semibold sc-padding-ends" style="display: none">No alerts!</div>
                        </div>
					</div>
				</li>
				<li>
					<a href="#"><img src="assets/img/avatars/avatar_default_sm.png" alt=""></a>
					<div class="uk-navbar-dropdown uk-dropdown-small">
						<ul class="uk-nav uk-nav-navbar">
							<li><a href="pages-user_profile.html">Profile</a></li>
							<li><a href="pages-settings.html">Settings</a></li>
							<li><a href="login_page.html">Log Out</a></li>
						</ul>
					</div>
				</li>
			</ul>
            <a href="#" class="sc-js-offcanvas-toggle md-color-white <?php rtlReplace('uk-margin-left', 'uk-margin-right'); ?> uk-hidden@l">
	            <i class="mdi mdi-menu sc-offcanvas-open"></i>
	            <i class="mdi mdi-arrow-right sc-offcanvas-close"></i>
            </a>
		</div>
	</nav>
</header>
