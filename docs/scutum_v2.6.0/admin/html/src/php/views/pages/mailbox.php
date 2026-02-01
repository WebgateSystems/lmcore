<?php
	$badges = [
		[ "Work" => "md-bg-blue-400" ],
		[ "To Do" => "md-bg-grey-400" ],
		[ "Important" => "md-bg-amber-400" ],
		[ "Personal" => "md-bg-red-400" ],
		[ "Work" => "md-bg-blue-400" ],
		[ "Personal" => "md-bg-red-400" ]
	];
?>
<div id="sc-page-wrapper" class="uk-flex uk-flex-column">
	<div id="sc-page-top-bar" class="sc-top-bar">
		<div class="sc-top-bar-aside uk-visible@l"></div>
		<div class="sc-top-bar-content uk-flex-1">
            <div class="sc-checkbox-wrapper">
			    <input type="checkbox" id="mailbox-check-all" class="sc-main-checkbox" data-group=".sc-js-group-1" data-sc-icheck>
            </div>
            <div class="uk-flex-1 uk-grid-collapse" data-uk-grid>
                <div class="sc-message-back">
                    <a href="#" class="sc-actions-icon sc-js-block-wave sc-js-message-close" data-uk-tooltip title="Close message"><i class="mdi <?php rtlReplace('mdi-arrow-left', 'mdi-arrow-right'); ?>"></i></a>
                </div>
                <div class="sc-actions">
                    <a href="#" class="sc-actions-icon sc-js-block-wave" data-uk-tooltip title="Reply"><i class="mdi mdi-reply"></i></a>
                    <a href="#" class="sc-actions-icon sc-js-block-wave" data-uk-tooltip title="Archive"><i class="mdi mdi-archive"></i></a>
                    <a href="#" class="sc-actions-icon sc-js-block-wave" data-uk-tooltip title="Delete"><i class="mdi mdi-delete-outline"></i></a>
                </div>
            </div>
		</div>
	</div>
	<div id="sc-page-wrapper-inner" class="uk-flex">
		<div id="sc-page-aside">
			<div class="sc-page-aside-body">
				<button class="sc-button sc-button-block sc-button-danger sc-js-message-compose" type="button" data-uk-toggle="target: #sc-message-compose">Compose</button>
				<ul class="uk-margin-top" data-uk-accordion="multiple: true">
					<li class="uk-open">
						<a class="uk-accordion-title" href="#">Folders</a>
						<div class="uk-accordion-content">
							<ul class="uk-list">
								<li><a href="#"><i class="mdi mdi-inbox <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>"></i>Inbox (24)</a></li>
								<li><a href="#"><i class="mdi mdi-inbox-arrow-up <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>"></i>Sent</a></li>
								<li><a href="#"><i class="mdi mdi-block-helper <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?> sc-icon-22"></i>Spam</a></li>
								<li><a href="#"><i class="mdi mdi-delete <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>"></i>Trash</a></li>
							</ul>
						</div>
					</li>
					<li class="uk-open">
						<a class="uk-accordion-title" href="#">Tags</a>
						<div class="uk-accordion-content">
							<ul class="uk-list">
								<li data-uk-filter-control class="sc-js-filter-clear">
									<a href="#"><span class="sc-color-label md-bg-white"><i class="mdi mdi-close"></i></span>All Folders</a>
								</li>
<?php
	for($i=0;$i<4;$i++) {
	foreach ( $badges[$i] as $k => $v) {
		$name = $k;
		$color = $v;
	}
?>
								<li data-uk-filter-control="filter: .sc-js-tag-<?php echo strtolower( preg_replace( '/\s*/', '', $name ) ); ?>">
									<a href="#"><span class="sc-color-label <?php echo $color; ?>"></span><?php echo $name; ?></a>
								</li>
<?php }; ?>
							</ul>
						</div>
					</li>
				</ul>
			</div>
		</div>
		<div id="sc-page-content" class="sc-padding-remove uk-height-1-1" data-sc-scrollbar>
			<ul
                id="sc-mailbox-messages"
                class="sc-list-messages sc-js-message-expand sc-js-message-filter sc-sequence-show-manual"
                data-sc-sequence-show='{ "animation": "uk-animation-slide-bottom-medium", "delay": 0.7 }'
            >
				<!-- handlebars/templates/mailbox-message.hbs -->
			</ul>
			<div id="sc-message-single"></div>
		</div>
	</div>
    <div class="sc-fab-page-wrapper uk-hidden@l">
        <a href="#sc-message-compose" class="sc-fab sc-fab-large sc-fab-danger" data-uk-toggle><i class="mdi mdi-plus"></i></a>
    </div>
	<div id="sc-message-compose" class="uk-flex-top" data-uk-modal="bg-close: false">
		<div class="uk-modal-dialog uk-margin-auto-vertical">
			<button class="uk-modal-close-default md-color-white" type="button" data-uk-close></button>
			<div class="uk-modal-header md-bg-grey-800">
				<h3 class="uk-modal-title uk-modal-title-medium md-color-white">New message</h3>
			</div>
			<div class="uk-modal-body sc-padding-ends" data-uk-overflow-auto>
				<select name="mesage-compose-send-to" id="sc-message-compose-send-to" multiple data-sc-select2='{ "tags": true, "tokenSeparators": [","," "], "createTag": "tag_emailAddress", "placeholder": "To..." }' data-sc-select2-manual>
					<option value="">To...</option>
					<option value="email_1"><?php echo $faker->email; ?></option>
					<option value="email_2"><?php echo $faker->email; ?></option>
					<option value="email_3"><?php echo $faker->email; ?></option>
				</select>
				<div class="uk-margin-medium-top">
					<label>Subject</label>
					<input type="text" class="uk-input" data-sc-input>
				</div>
				<div class="uk-margin-medium-top">
					<label for="sc-message-compose-input">Message</label>
					<textarea name="message-compose" id="sc-message-compose-input" data-sc-input class="uk-textarea sc-js-autosize" rows="8" cols="10"></textarea>
				</div>
				<div class="uk-margin-medium-top">
					<span class="uk-display-block uk-margin-small-bottom uk-text-muted uk-text-medium <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Attachments:</span>
					<ul class="sc-message-attachments uk-flex uk-flex-middle">
						<li class="sc-flex-no-shrink">
							<div class="sc-attachment">
								<a href="#">file1.png <span>(241KB)</span></a>
								<a href="#" class="mdi mdi-close sc-attachment-remove"></a>
							</div>
						</li>
						<li class="sc-flex-no-shrink">
							<div class="sc-attachment">
								<a href="#">file2.pdf <span>(1240KB)</span></a>
								<a href="#" class="mdi mdi-close sc-attachment-remove"></a>
							</div>
						</li>
					</ul>
				</div>
			</div>
			<div class="uk-modal-footer <?php rtlReplace('uk-text-right', ''); ?> sc-padding-medium-ends">
				<button class="sc-button sc-button-flat sc-button-flat-danger uk-modal-close" type="button">Cancel</button>
				<button class="sc-button sc-button-primary" type="button">Send</button>
			</div>
		</div>
	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar">
        <p class="uk-text-large uk-margin-small">Folders</p>
        <ul class="uk-list uk-margin-remove sc-list-align">
            <li><a href="#"><i class="mdi mdi-inbox <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>"></i>Inbox (24)</a></li>
            <li><a href="#"><i class="mdi mdi-inbox-arrow-up <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>"></i>Sent</a></li>
            <li><a href="#"><i class="mdi mdi-block-helper <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?> sc-icon-22"></i>Spam</a></li>
            <li><a href="#"><i class="mdi mdi-delete <?php rtlReplace('uk-margin-small-right', 'uk-margin-small-left'); ?>"></i>Trash</a></li>
        </ul>
    </div>
</div>
