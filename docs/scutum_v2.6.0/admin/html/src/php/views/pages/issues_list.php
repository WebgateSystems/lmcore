<?php
$dt = _carbon();
$task_priority = [
	'minor' => 'info',
	'major' => 'success',
	'critical' => 'warning',
	'blocker' => 'danger'
];
$task_status = ['closed','open','fixed'];
$assignee = ['rhianna.walsh','anderson.swift','shea.west','fay.schultz'];
?>
<div id="sc-page-wrapper">
	<div id="sc-page-top-bar" class="sc-top-bar uk-flex-middle">
		<div class="sc-top-bar-content sc-padding-medium-ends uk-flex-1">
			<div class="uk-flex uk-flex-column uk-flex-1">
				<h1 class="sc-top-bar-title uk-text-uppercase uk-margin-small-bottom">Project Scutum</h1>
				<span class="sc-top-bar-subtitle">Lead: <a href="javascript:void(0)">Kate Walsh</a></span>
			</div>
			<div class="sc-actions uk-margin-left">
				<a href="javascript:void(0)" class="sc-actions-icon mdi mdi-printer"></a>
				<a href="javascript:void(0)" class="sc-actions-icon mdi mdi-archive"></a>
				<a href="javascript:void(0)" class="sc-actions-icon mdi mdi-dots-vertical"></a>
			</div>
		</div>
	</div>
	<div id="sc-page-content">

		<div class="uk-card">
          <div class="uk-overflow-auto">
            <table class="uk-table uk-table-divider" id="ts-issues">
              <thead>
                <tr>
                  <th class="uk-table-shrink"><input class="uk-checkbox ts-checkAll" type="checkbox"></th>
                  <th>Key</th>
                  <th>Title</th>
                  <th class="filter-select" data-placeholder="Select...">Assignee</th>
                  <th class="filter-select" data-placeholder="Select...">Priority</th>
                  <th>Created</th>
                  <th>Updated</th>
                  <th class="filter-select" data-placeholder="Select...">Status</th>
                </tr>
              </thead>
              <tbody>
<?php
  for($i=0;$i<32;$i++) {
  $randPrio = array_rand($task_priority);
  $priority = $task_priority[$randPrio];
?>
                    <tr>
                      <td><input class="ts-checkbox" type="checkbox"></td>
                      <td><a href="pages-issue_details.html">SC-<?php echo rand(1,500);?></a></td>
                      <td><?php echo $faker->sentence('10');?></td>
                      <td><?php echo $assignee[array_rand($assignee)]; ?></td>
                      <td><span class="uk-label uk-label-<?php echo $priority;?>"><?php echo $randPrio; ?></span></td>
                      <td><?php echo $dt->subDays(1)->format('d M Y'); ?></td>
                      <td><?php echo $dt->subDays(1)->format('d M Y'); ?></td>
                      <td><span class="uk-label uk-label-outline"><?php echo $task_status[array_rand($task_status)] ?></span></td>
                    </tr>
<?php }; ?>
                </tbody>
            </table>
          </div>
        </div>

	</div>
</div>
