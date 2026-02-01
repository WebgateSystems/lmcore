<?php
	$json = file_get_contents("data/pages/tasks.json");
	$tasks = json_decode($json, true);
	$tags = [
		"Integrations" => "md-bg-blue-400",
		"Idea" => "md-bg-amber-400",
		"Feature" => "md-bg-purple-400",
		"Bug" => "md-bg-red-400"
	];
	$users = [
		"user_1" => [
			"name" => $faker->userName,
			"avatar" => "assets/img/avatars/avatar_01_sm.png"
		],
		"user_2" => [
			"name" => $faker->userName,
			"avatar" => "assets/img/avatars/avatar_04_sm.png"
		],
		"user_3" => [
			"name" => $faker->userName,
			"avatar" => "assets/img/avatars/avatar_07_sm.png"
		]
	];
?>
<div id="sc-page-wrapper" class="uk-flex uk-flex-column">
	<div id="sc-page-top-bar" class="sc-top-bar">
		<div class="sc-top-bar-content uk-flex uk-flex-1">
			<h1 class="sc-top-bar-title uk-flex-1">Product Roadmap</h1>
			<span class="uk-text-muted">Public</span>
			<div class="sc-actions <?php rtlReplace('uk-margin-left', 'uk-margin-right'); ?>">
				<a href="#" class="sc-actions-icon mdi mdi-filter-variant sc-js-el-hide md-color-red-800 uk-animation-shake" data-uk-toggle="target: #sc-page-top-bar; cls: sc-top-bar-expanded"></a>
				<a href="#" class="sc-actions-icon mdi mdi-close sc-js-el-show" data-uk-toggle="target: #sc-page-top-bar; cls: sc-top-bar-expanded"></a>
			</div>
		</div>
		<div class="sc-top-bar-content-expanded">
			<p class="uk-text-medium uk-text-uppercase sc-text-semibold md-color-light-blue-700 uk-margin-remove">Filters:</p>
			<div class="uk-flex uk-flex-bottom" data-uk-grid>
				<div class="uk-width-1-4@m">
					<label for="sc-f-task-name">Task name</label>
					<input type="text" id="sc-f-task-name" name="sc-f-task-name" class="uk-input" data-sc-input>
				</div>
				<div class="uk-width-1-4@m">
					<select name="sc-f-tag" id="sc-f-tag" class="uk-select" data-sc-select2='{"placeholder": "Select tags..."}' multiple>
<?php $i=1;foreach($tags as $k => $v) { ?>
						<option value="<?php echo $i?>"><?php echo $k; ?></option>
<?php $i++; }; ?>
					</select>
				</div>
				<div class="uk-width-1-4@m">
					<select name="sc-f-user" id="sc-f-user" class="uk-select" data-sc-select2='{"placeholder": "Select user...", "minimumResultsForSearch": -1}'>
						<option value="">Select user...</option>
						<option value="1">Me</option>
						<option value="2"><?php echo $faker->userName; ?></option>
						<option value="3"><?php echo $faker->userName; ?></option>
						<option value="4"><?php echo $faker->userName; ?></option>
					</select>
				</div>
				<div class="uk-flex-none"><button class="sc-button sc-button-secondary">Filter</button></div>
			</div>
		</div>
	</div>
	<div id="sc-page-wrapper-inner" class="uk-flex">
		<div id="sc-page-aside" class="sc-page-aside-large">
			<div class="sc-page-aside-body uk-flex uk-flex-column sc-padding-remove">
				<div class="sc-task-list-head">
					<h3 class="sc-task-list-header">Tasks</h3>
				</div>
				<ul class="sc-task-list-cards sc-task-js-list-cards">
					<?php foreach ($tasks as $key => $value) { ?>
						<?php if(empty($value['list'])) { ?>
						<li>
							<div class="sc-task-card" data-task-id="<?php echo $value['id']; ?>">
								<h2 class="sc-task-card-title"><?php echo $value['title']; ?></h2>
								<?php if(!empty($value['tags'])) { ?>
									<?php foreach($value['tags'] as $k) { ?>
										<span class="uk-badge <?php echo $tags[$k]; ?>"><?php echo $k; ?></span>
									<?php }?>
								<?php }?>
							</div>
						</li>
						<?php }; ?>
					<?php }; ?>
				</ul>
			</div>
		</div>
		<div id="sc-page-content" class="sc-padding-remove">
			<div class="sc-task-board-wrapper">
				<div class="sc-task-board" id="sc-task-board">
					<div class="sc-task-list" data-list-name="to_do">
						<div class="sc-task-list-head dragula-handle-el">
							<h3 class="sc-task-list-header"><span>To Do</span></h3>
							<div class="sc-actions">
								<a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-list-collapse"></a>
								<a href="#" class="sc-actions-icon mdi mdi-arrow-expand-horizontal sc-js-el-show sc-js-list-expand"></a>
								<div class="sc-dropdown sc-js-el-hide">
									<a href="#" class="sc-actions-icon mdi mdi-dots-vertical"></a>
									<div data-uk-dropdown="mode:click">
										<ul class="uk-nav uk-dropdown-nav">
											<li><a href="#" class="sc-js-card-add-modal">Add Card</a></li>
											<li><a href="#">Copy List&hellip;</a></li>
											<li><a href="#">Move List&hellip;</a></li>
											<li class="uk-nav-divider"></li>
											<li><a href="#">Close This List</a></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
						<ul class="sc-task-list-cards sc-task-js-list-cards">
<?php foreach ($tasks as $key => $value) { ?>
	<?php if($value['list'] == 'todo') { ?>
									<li>
										<div class="sc-task-card" data-task-id="<?php echo $value['id']; ?>">
											<h2 class="sc-task-card-title"><?php echo $value['title']; ?></h2>
											<?php if(!empty($value['tags'])) { ?>
												<div class="uk-flex uk-margin-small-top">
												<?php foreach($value['tags'] as $k) { ?>
													<span class="uk-badge uk-margin-mini-right <?php echo $tags[$k]; ?>"><?php echo $k; ?></span>
												<?php }?>
												</div>
											<?php }?>
											<?php if(!empty($value['assignee'])) { ?>
												<div class="sc-task-card-assignee">
												<?php foreach($value['assignee'] as $k) { ?>
													<a href="#" title="<?php echo $users[$k]['name']?>" class="sc-task-card-assignee-avatar"><img src="<?php echo $users[$k]['avatar']?>" alt=""></a>
												<?php }?>
												<a href="#">+2 more</a>
												</div>
											<?php }?>
										</div>
									</li>
	<?php }; ?>
<?php }; ?>
						</ul>
					</div>
					<div class="sc-task-list" data-list-name="in_progress">
						<div class="sc-task-list-head dragula-handle-el">
							<h3 class="sc-task-list-header"><span>In Progress</span></h3>
							<div class="sc-actions">
								<a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-list-collapse"></a>
								<a href="#" class="sc-actions-icon mdi mdi-arrow-expand-horizontal sc-js-el-show sc-js-list-expand"></a>
								<div class="sc-dropdown sc-js-el-hide">
									<a href="#" class="sc-actions-icon mdi mdi-dots-vertical"></a>
									<div data-uk-dropdown="mode:click">
										<ul class="uk-nav uk-dropdown-nav">
											<li><a href="#" class="sc-js-card-add-modal">Add Card</a></li>
											<li><a href="#">Copy List&hellip;</a></li>
											<li><a href="#">Move List&hellip;</a></li>
											<li class="uk-nav-divider"></li>
											<li><a href="#">Close This List</a></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
						<ul class="sc-task-list-cards sc-task-js-list-cards">
							<?php foreach ($tasks as $key => $value) { ?>
								<?php if($value['list'] == 'in_progress') { ?>
									<li>
										<div class="sc-task-card" data-task-id="<?php echo $value['id']; ?>">
											<h2 class="sc-task-card-title"><?php echo $value['title']; ?></h2>
											<?php if(!empty($value['tags'])) { ?>
												<div class="uk-flex uk-margin-small-top">
												<?php foreach($value['tags'] as $k) { ?>
													<span class="uk-badge uk-margin-mini-right <?php echo $tags[$k]; ?>"><?php echo $k; ?></span>
												<?php }?>
												</div>
											<?php }?>
											<?php if(!empty($value['assignee'])) { ?>
												<div class="sc-task-card-assignee">
												<?php foreach($value['assignee'] as $k) { ?>
													<a href="#" title="<?php echo $users[$k]['name']?>"><img src="<?php echo $users[$k]['avatar']?>" alt=""></a>
												<?php }?>
												<a href="#">+2 more</a>
												</div>
											<?php }?>
											<?php if(!empty($value['progress'])) { ?>
												<?php
													if($value['progress'] <= 20) {
														$progressColor = 'md-bg-red-400';
													} elseif ($value['progress'] <= 60) {
														$progressColor = 'md-bg-amber-400';
													} else {
														$progressColor = 'md-bg-green-400';
													}
												?>
												<div class="sc-progress sc-progress-small uk-margin-small-top" title="<?php echo $value['progress']?>%">
													<div class="sc-progress-bar <?php echo $progressColor; ?>" style="width: <?php echo $value['progress']?>%"></div>
												</div>
											<?php }?>
										</div>
									</li>
								<?php }; ?>
							<?php }; ?>
						</ul>
					</div>
					<div class="sc-task-list sc-task-list-collapsed" data-list-name="testing">
						<div class="sc-task-list-head dragula-handle-el">
							<h3 class="sc-task-list-header"><span>Testing</span></h3>
							<div class="sc-actions">
								<a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-list-collapse"></a>
								<a href="#" class="sc-actions-icon mdi mdi-arrow-expand-horizontal sc-js-el-show sc-js-list-expand"></a>
								<div class="sc-dropdown sc-js-el-hide">
									<a href="#" class="sc-actions-icon mdi mdi-dots-vertical"></a>
									<div data-uk-dropdown="mode:click">
										<ul class="uk-nav uk-dropdown-nav">
											<li><a href="#" class="sc-js-card-add-modal">Add Card</a></li>
											<li><a href="#">Copy List&hellip;</a></li>
											<li><a href="#">Move List&hellip;</a></li>
											<li class="uk-nav-divider"></li>
											<li><a href="#">Close This List</a></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
						<ul class="sc-task-list-cards sc-task-js-list-cards">
							<?php foreach ($tasks as $key => $value) { ?>
								<?php if($value['list'] == 'testing') { ?>
									<li>
										<div class="sc-task-card" data-task-id="<?php echo $value['id']; ?>">
											<h2 class="sc-task-card-title"><?php echo $value['title']; ?></h2>
											<?php if(!empty($value['tags'])) { ?>
												<div class="uk-flex uk-margin-small-top">
												<?php foreach($value['tags'] as $k) { ?>
													<span class="uk-badge uk-margin-mini-right <?php echo $tags[$k]; ?>"><?php echo $k; ?></span>
												<?php }?>
												</div>
											<?php }?>
											<?php if(!empty($value['assignee'])) { ?>
												<div class="sc-task-card-assignee">
												<?php foreach($value['assignee'] as $k) { ?>
													<a href="#" title="<?php echo $users[$k]['name']?>"><img src="<?php echo $users[$k]['avatar']?>" alt=""></a>
												<?php }?>
												</div>
											<?php }?>
										</div>
									</li>
								<?php }; ?>
							<?php }; ?>
						</ul>
					</div>
					<div class="sc-task-list" data-list-name="done">
						<div class="sc-task-list-head dragula-handle-el">
							<h3 class="sc-task-list-header uk-text-truncate"><span>Done</span></h3>
							<div class="sc-actions <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">
								<a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-list-collapse"></a>
								<a href="#" class="sc-actions-icon mdi mdi-arrow-expand-horizontal sc-js-el-show sc-js-list-expand"></a>
								<div class="sc-dropdown sc-js-el-hide">
									<a href="#" class="sc-actions-icon mdi mdi-dots-vertical"></a>
									<div data-uk-dropdown="mode:click">
										<ul class="uk-nav uk-dropdown-nav">
											<li><a href="#" class="sc-js-card-add-modal">Add Card</a></li>
											<li><a href="#">Copy List&hellip;</a></li>
											<li><a href="#">Move List&hellip;</a></li>
											<li class="uk-nav-divider"></li>
											<li><a href="#">Close This List</a></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
						<ul class="sc-task-list-cards">
							<?php foreach ($tasks as $key => $value) { ?>
								<?php if($value['list'] == 'done') { ?>
									<li>
										<div class="sc-task-card" data-task-id="<?php echo $value['id']; ?>">
											<h2 class="sc-task-card-title"><?php echo $value['title']; ?></h2>
											<?php if(!empty($value['tags'])) { ?>
												<div class="uk-flex uk-margin-small-top">
												<?php foreach($value['tags'] as $k) { ?>
													<span class="uk-badge uk-margin-mini-right <?php echo $tags[$k]; ?>"><?php echo $k; ?></span>
												<?php }?>
												</div>
											<?php }?>
											<?php if(!empty($value['assignee'])) { ?>
												<div class="sc-task-card-assignee">
												<?php foreach($value['assignee'] as $k) { ?>
													<a href="#" title="<?php echo $users[$k]['name']?>"><img src="<?php echo $users[$k]['avatar']?>" alt=""></a>
												<?php }?>
												</div>
											<?php }?>
										</div>
									</li>
								<?php }; ?>
							<?php }; ?>
						</ul>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="sc-fab-page-wrapper">
		<a href="#" class="sc-fab sc-fab-large sc-fab-danger"><i class="mdi mdi-plus"></i></a>
	</div>
	<div id="sc-task-modal" class="uk-flex-top" data-uk-modal>
		<div class="uk-modal-dialog uk-modal-body uk-margin-auto-vertical">
			<button class="uk-modal-close-default" type="button" data-uk-close></button>
			<div id="sc-hb-task-modal"></div>
		</div>
	</div>
    <div id="sc-task-board-card-add-modal" class="uk-flex-top" data-uk-modal>
		<div class="uk-modal-dialog uk-margin-auto-vertical">
			<div class="uk-modal-body">
				<button class="uk-modal-close-default" type="button" data-uk-close></button>
				<h2 class="uk-modal-title">Add Card</h2>
	            <div class="uk-margin">
					<label class="uk-form-label" for="card-add-title">Title</label>
					<input class="uk-input" id="card-add-title" type="text" data-sc-input="outline">
				</div>
				<div class="uk-margin-small">
					<label class="uk-form-label" for="card-add-description">Description</label>
					<textarea class="uk-textarea sc-js-autosize" id="card-add-description" rows="3" data-sc-input="outline"></textarea>
				</div>
				<div class="uk-margin-small">
					<label class="uk-form-label" for="card-add-tags">Tags</label>
					<select name="card-add-tags" id="card-add-tags" class="uk-select" multiple>
					<?php foreach ($tags as $key => $value) { ?>
						<option value="<?php echo $key; ?>"><?php echo $key; ?></option>
					<?php }; ?>
					</select>
				</div>
				<div class="uk-margin-small">
					<label class="uk-form-label" for="card-add-assignee">Assignee</label>
					<select name="card-add-assignee" id="card-add-assignee" class="uk-select" multiple>
					<?php foreach ($users as $key => $value) { ?>
						<option value="<?php echo $key; ?>"><?php echo $value['name']; ?></option>
					<?php }; ?>
					</select>
				</div>
				<div class="uk-child-width-1-2@m uk-grid uk-margin" data-uk-grid>
					<div>
						<label class="uk-form-label" for="card-add-due-date">Due Date</label>
						<input class="uk-input" id="card-add-due-date" type="text" data-sc-input="outline">
					</div>
				</div>
			</div>
			<div class="uk-modal-footer uk-text-right">
				<button class="sc-button sc-button-flat sc-button-flat-danger uk-modal-close" type="button">Cancel</button>
				<button class="sc-button" type="button" id="sc-js-card-add">Add Card</button>
			</div>
		</div>
	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar">
        <div class="sc-task-list-head">
            <h3 class="sc-task-list-header">Tasks</h3>
        </div>
        <ul class="sc-task-list-cards sc-task-js-list-cards">
		    <?php foreach ($tasks as $key => $value) { ?>
			    <?php if(empty($value['list'])) { ?>
                    <li>
                        <div class="sc-task-card" data-task-id="<?php echo $value['id']; ?>">
                            <h2 class="sc-task-card-title"><?php echo $value['title']; ?></h2>
						    <?php if(!empty($value['tags'])) { ?>
							    <?php foreach($value['tags'] as $k) { ?>
                                    <span class="uk-badge <?php echo $tags[$k]; ?>"><?php echo $k; ?></span>
							    <?php }?>
						    <?php }?>
                        </div>
                    </li>
			    <?php }; ?>
		    <?php }; ?>
        </ul>
    </div>
</div>
