<div id="sc-page-wrapper">
	<div id="sc-page-content" class="uk-height-1-1 uk-flex uk-flex-center sc-page-over-header">
		<div class="uk-width-5-6@l">
			<div class="sc-chat-card uk-card uk-height-1-1">
				<div class="uk-grid-divider uk-grid-collapse uk-height-1-1" data-uk-grid data-uk-height-match="target: > div > div > .uk-card-header">
					<div class="uk-flex-1 uk-height-1-1">
						<div class="uk-flex uk-flex-column uk-height-1-1">
							<div class="uk-card-header sc-chat-header sc-padding sc-padding-medium-ends">
								<div class="uk-flex uk-flex-middle">
									<div class="uk-flex-1">
										<h3 class="uk-card-title">General</h3>
										<ul class="sc-chat-user-list-inline">
											<li><a href="#"><span class="sc-user-status online"></span>Mark</a></li>
											<li><a href="#"><span class="sc-user-status away"></span>Kate</a></li>
											<li><a href="#"><span class="sc-user-status offline"></span>Lisa</a></li>
											<li><a href="#"><span class="sc-user-status busy"></span>John</a></li>
										</ul>
									</div>
									<div class="sc-actions uk-margin-remove">
										<div class="sc-dropdown">
											<a href="#" class="sc-actions-icon mdi mdi-dots-vertical"></a>
											<div class="uk-width-small" data-uk-dropdown="mode:click">
												<ul class="uk-nav uk-dropdown-nav">
													<li><a href="#">Info</a></li>
													<li><a href="#">Settings</a></li>
													<li><a href="#">Clear chat</a></li>
													<li class="uk-nav-divider"></li>
													<li><a href="#" class="md-color-red-500">Close</a></li>
												</ul>
											</div>
										</div>
									</div>
								</div>
							</div>
							<div class="uk-card-body sc-padding-remove md-bg-grey-200" data-sc-scrollbar="visible-y">
								<div id="sc-chat" class="sc-chat-body"><!--  handlebars/templates/chat-messages.hbs --></div>
							</div>
							<div class="sc-chat-user-input uk-flex uk-flex-middle">
								<div class="uk-flex-1">
									<input class="uk-input" type="text" id="sc-chat-message-input" data-sc-input="outline" placeholder="Write something...">
								</div>
								<a href="#" class="mdi mdi-send sc-icon-square uk-margin-medium-left" id="sc-chat-message-submit"></a>
							</div>
						</div>
					</div>
					<div class="uk-width-1-4@l uk-height-1-1 sc-js-column uk-visible@m">
						<div class="uk-flex uk-flex-column uk-height-1-1">
							<div class="uk-card-header uk-flex uk-flex-middle sc-border-bottom">
								<div class="uk-flex-1 sc-js-el-hide">
									<h3 class="uk-card-title sc-actions-match">Users <span class="uk-text-muted uk-text-small">(10)</span></h3>
								</div>
								<a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-column-collapse" data-uk-tooltip title="Hide users"></a>
								<a href="#" class="sc-actions-icon mdi mdi-account-multiple sc-js-el-show sc-js-column-expand" data-uk-tooltip title="Show users"></a>
								<div class="sc-actions sc-js-el-hide">
									<div class="sc-dropdown">
										<a href="#" class="sc-actions-icon mdi mdi-dots-vertical"></a>
										<div class="uk-width-small" data-uk-dropdown="mode:click">
											<ul class="uk-nav uk-dropdown-nav">
												<li><a href="#">Settings</a></li>
												<li><a href="#">New chat group</a></li>
												<li class="uk-nav-divider"></li>
												<li><a href="#">Add User</a></li>
												<li><a href="#">Search User</a></li>
											</ul>
										</div>
									</div>
								</div>
							</div>
							<div class="uk-card-body uk-flex-1 sc-js-el-hide sc-padding sc-padding-medium-ends">
								<ul
                                    id="sc-user-list"
                                    class="uk-list uk-list-divider sc-list-clickable sc-js-chat-users-list sc-list-align"
                                    data-sc-sequence-show='{"animation": "uk-animation-slide-bottom-medium", "delay": 1.2}'
                                >
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar">
        <h4>Users</h4>
        <ul
            id="sc-user-list-offcanvas"
            class="uk-list uk-list-divider sc-list-clickable sc-list-align uk-margin-top-remove"
        ></ul>
    </div>
</div>

<script id="userListTemplate" type="text/x-handlebars-template">
    {{#each users }}
    <li class="sc-list-group uk-visible-toggle" tabindex="-1" style="">
        <div class="sc-list-addon">
            <div class="sc-avatar-wrapper">
                <span class="sc-user-status {{ status }}"></span>
                <img src="assets/img/avatars/avatar_{{ avatar }}_sm.png" class="sc-avatar " alt="{{ username }}">
            </div>
        </div>
        <div class="sc-list-body">
            <div class="uk-flex uk-flex-middle">
                <div class="uk-width-expand">
                    <div class="uk-text-truncate">{{ username }}</div>
                    <div class="sc-list-secondary-text">
                        {{ sentence }}
                    </div>
                </div>
                <div class="uk-width-auto">
                    <ul class="uk-hidden-hover uk-flex uk-flex-middle sc-padding-remove-left uk-margin-small-left">
                        <li><a href="#" class="sc-actions-icon mdi mdi-pencil-outline icon sc-icon-24 sc-icon-square"></a></li>
                        <li>
                            <a href="#" class="sc-actions-icon mdi mdi-dots-vertical icon sc-icon-24 sc-icon-square" aria-expanded="false"></a>
                            <div class="uk-dropdown-small uk-dropdown" data-uk-dropdown="">
                                <ul class="uk-nav uk-dropdown-nav sc-padding-remove-left">
                                    <li>
                                        <a href="javascript:void(0)">
                                            Item
                                        </a>
                                    </li>
                                    <li>
                                        <a href="javascript:void(0)">
                                            Item
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </li>
    {{/each}}
</script>
