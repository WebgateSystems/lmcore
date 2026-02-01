<div id="sc-page-wrapper">
	<div id="sc-page-content">
		
		<div class="uk-flex-center" data-uk-grid>
			<div class="uk-width-2-3@l">
				<?php $dt = _carbon(); ?>
				<div class="uk-card">
					<div class="uk-card-body">
						<div class="sc-timeline sc-timeline-center">
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
											<li><?php photo(1, '_md'); ?></li>
											<li><?php photo(6, '_md'); ?></li>
											<li><?php photo(7, '_md'); ?></li>
											<li><?php photo(5, '_md'); ?></li>
											<li><?php photo(4, '_md'); ?></li>
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
								<div class="sc-timeline-body uk-box-shadow-small">
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
												<a href="#"><?php echo $faker->sentence(4); ?></a>
												<p class="sc-list-secondary-text uk-text-small">Logged: 2h 12m</p>
											</li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<?php $dt = _carbon(); ?>
				<div class="uk-card uk-margin">
					<div class="uk-card-body">
						<div class="sc-timeline">
							<div class="sc-timeline-item">
								<div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('D'); ?></div>
								<div class="sc-timeline-icon md-bg-purple-500 sc-light">
									<i class="mdi mdi-image"></i>
								</div>
								<div class="sc-timeline-body sc-timeline-body-border">
									<h4 class="sc-timeline-header">New album</h4>
									<hr>
									<div class="sc-timeline-content">
										<ul class="sc-list-images uk-list uk-list-inline">
											<li><?php photo(1, '_md'); ?></li>
											<li><?php photo(6, '_md'); ?></li>
											<li><?php photo(7, '_md'); ?></li>
											<li><?php photo(5, '_md'); ?></li>
											<li><?php photo(4, '_md'); ?></li>
										</ul>
									</div>
								</div>
							</div>
							<div class="sc-timeline-item">
								<div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('D'); ?></div>
								<div class="sc-timeline-icon md-bg-amber-500 sc-light">
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
								<div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('D'); ?></div>
								<div class="sc-timeline-icon md-bg-light-green-500 sc-light">
									<i class="mdi mdi-comment"></i>
								</div>
								<div class="sc-timeline-body uk-box-shadow-small">
									<h4 class="sc-timeline-header">14 new commments</h4>
									<span class="sc-timeline-meta"></span>
									<div class="sc-timeline-content"></div>
								</div>
							</div>
							<div class="sc-timeline-item">
								<div class="sc-timeline-date"><?php echo $dt->subDays(1)->format('D'); ?></div>
								<div class="sc-timeline-icon md-bg-cyan-500 sc-light">
									<i class="mdi mdi-calendar-check"></i>
								</div>
								<div class="sc-timeline-body md-bg-grey-100">
									<h4 class="sc-timeline-header">User <a href="#"><?php echo $faker->userName; ?></a> have completed 4 tasks</h4>
									<div class="sc-timeline-content">
										<ul class="sc-list-shadow uk-margin-top">
											<li>
												<a href="#"><?php echo $faker->sentence(4); ?></a>
												<p class="sc-list-secondary-text uk-text-small">Logged: 2h 12m</p>
											</li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
				<?php $dt = _carbon(); ?>
				<div class="uk-card uk-margin">
					<div class="uk-card-body">
						<div class="sc-timeline sc-timeline-right">
							<div class="sc-timeline-item">
								<div class="sc-timeline-date"><?php echo $dt->format('M Y'); ?></div>
								<div class="sc-timeline-icon">
									<?php avatar(5); ?>
								</div>
								<div class="sc-timeline-body sc-timeline-body-border">
									<h4 class="sc-timeline-header">New album</h4>
									<hr>
									<div class="sc-timeline-content">
										<ul class="sc-list-images uk-list uk-list-inline">
											<li><?php photo(1, '_md'); ?></li>
											<li><?php photo(6, '_md'); ?></li>
											<li><?php photo(7, '_md'); ?></li>
											<li><?php photo(5, '_md'); ?></li>
											<li><?php photo(4, '_md'); ?></li>
										</ul>
									</div>
								</div>
							</div>
							<div class="sc-timeline-item">
								<div class="sc-timeline-date"><?php echo $dt->subMonths(1)->format('M Y'); ?></div>
								<div class="sc-timeline-icon">
									<i class="mdi mdi-file-document md-color-green-800 sc-icon-32"></i>
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
								<div class="sc-timeline-date"><?php echo $dt->subMonths(1)->format('M Y'); ?></div>
								<div class="sc-timeline-icon">
									<i class="mdi mdi-comment md-color-deep-orange-500 sc-icon-32"></i>
								</div>
								<div class="sc-timeline-body uk-box-shadow-small">
									<h4 class="sc-timeline-header">14 new commments</h4>
									<span class="sc-timeline-meta"></span>
									<div class="sc-timeline-content"></div>
								</div>
							</div>
							<div class="sc-timeline-item">
								<div class="sc-timeline-date"><?php echo $dt->subMonths(1)->format('M Y'); ?></div>
								<div class="sc-timeline-icon">
									<?php avatar(6); ?>
								</div>
								<div class="sc-timeline-body md-bg-grey-100">
									<h4 class="sc-timeline-header">User <a href="#"><?php echo $faker->userName; ?></a> have completed 4 tasks</h4>
									<div class="sc-timeline-content">
										<ul class="sc-list-shadow uk-margin-top">
											<li>
												<a href="#"><?php echo $faker->sentence(4); ?></a>
												<p class="sc-list-secondary-text uk-text-small">Logged: 2h 12m</p>
											</li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
											<li><a href="#"><?php echo $faker->sentence(4); ?></a></li>
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