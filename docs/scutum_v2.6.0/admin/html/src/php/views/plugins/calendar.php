<div id="sc-page-wrapper">
	<div id="sc-page-content" class="uk-height-1-1">

        <div class="uk-card uk-height-1-1">
            <div class="uk-grid-collapse uk-grid-divider uk-height-1-1" data-uk-grid>
                <div class="uk-width-expand@m uk-height-1-1 uk-flex uk-flex-column">
                    <div class="uk-card-header sc-padding sc-padding-medium-ends">
                        <div class="uk-flex-middle uk-grid-small" data-uk-grid>
                            <div class="uk-width-auto uk-flex-last@m">
                                <button class="sc-button sc-button-default sc-button-outline uk-button-dropdown" type="button"><span id="sc-js-cal-view-name">Month</span></button>
                                <div data-uk-dropdown="boundary: #sc-page-content; mode: click">
                                    <ul class="uk-nav uk-dropdown-nav">
                                        <li><a href="#" class="sc-js-cal-view" data-view-action="toggle-daily">Day</a></li>
                                        <li><a href="#" class="sc-js-cal-view" data-view-action="toggle-weekly">Week</a></li>
                                        <li><a href="#" class="sc-js-cal-view sc-text-semibold" data-view-action="toggle-monthly">Month</a></li>
                                        <li><a href="#" class="sc-js-cal-view" data-view-action="toggle-weeks2">2 Weeks</a></li>
                                        <li class="uk-nav-divider"></li>
                                        <li>
                                            <div class="sc-padding-medium sc-padding-small-ends">
                                                <div class="uk-margin-small uk-flex uk-flex-middle">
                                                    <input type="checkbox" id="sc-cal-show-weekends" data-control-action="toggle-workweek" data-sc-icheck checked>
                                                    <label for="sc-cal-show-weekends">Show weekends</label>
                                                </div>
                                                <div class="uk-flex uk-flex-middle">
                                                    <input type="checkbox" id="sc-cal-weekends-narrower" data-control-action="toggle-narrow-weekend" data-sc-icheck checked>
                                                    <label for="sc-cal-weekends-narrower">Narrower weekends</label>
                                                </div>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <div class="uk-width-auto uk-visible@m">
                                <button type="button" class="sc-button sc-button-default sc-button-flat" data-nav-action="move-today">Today</button>
                            </div>
                            <div class="uk-width-auto uk-flex uk-flex-middle">
                                <button type="button" class="sc-button sc-button-default sc-button-flat sc-button-icon" data-nav-action="move-prev">
                                    <i class="mdi <?php rtlReplace('mdi-chevron-left', 'mdi-chevron-right'); ?>"></i>
                                </button>
                                <button type="button" class="sc-button sc-button-default sc-button-flat sc-button-icon" data-nav-action="move-next">
                                    <i class="mdi <?php rtlReplace('mdi-chevron-right', 'mdi-chevron-left'); ?>"></i>
                                </button>
                            </div>
                            <div class="uk-width-expand@s">
                                <h1 id="sc-cal-range-text" class="tui-full-calendar-range-name"><?php echo date("Y"); ?></h1>
                            </div>
                        </div>
                    </div>
                    <div class="uk-card-body">
                        <div id="sc-calendar"></div>
                    </div>
                </div>
                <div class="uk-width-1-6@m sc-js-column uk-visible@l">
                    <div class="uk-card-header sc-padding md-bg-grey-200 sc-padding-medium-ends sc-border-bottom uk-margin-bottom">
                        <div class="uk-flex uk-flex-middle">
                            <div class="uk-flex-1 sc-js-el-hide">
                                <p class="uk-margin-remove">My calendars</p>
                            </div>
                            <a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-column-collapse" data-uk-tooltip title="Hide column"></a>
                            <a href="#" class="sc-actions-icon mdi mdi-format-list-checks sc-js-el-show sc-js-column-expand" data-uk-tooltip title="Show column"></a>
                        </div>
                    </div>
                    <div class="uk-card-body sc-js-el-hide">
                        <ul class="uk-list uk-margin-remove-ends sc-list-align">
                            <li>
                                <input id="calendars-toggle-all" class="sc-js-calendar-toggle calendars-toggle-all" type="checkbox" value="all" checked>
                                <label for="calendars-toggle-all"><strong>View all</strong></label>
                            </li>
                        </ul>
                        <ul class="sc-calendars-list uk-list uk-margin-remove-ends sc-list-align"></ul>
                        <script id="sc-calendars-list-template" type="text/x-handlebars-template">
                            {{#each calendars}}
                            <li>
                                <input type="checkbox" id="calendar_{{id}}" class="sc-js-calendar-toggle" data-color="{{ bgColor }}" value="{{ id }}" checked>
                                <label for="calendar_{{id}}">{{ name }}</label>
                            </li>
                            {{/each}}
                        </script>
                    </div>
                </div>
            </div>
        </div>

	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar">
        <ul class="uk-list uk-margin-remove-ends">
            <li>
                <input class="sc-js-calendar-toggle calendars-toggle-all" id="calendars-toggle-all-offcanvas" type="checkbox" value="all" checked>
                <label for="calendars-toggle-all-offcanvas"><strong>View all</strong></label>
            </li>
        </ul>
        <hr class="uk-margin-small">
        <ul class="sc-calendars-list uk-list uk-list-condensed uk-margin-remove-ends"></ul>
        <script id="sc-calendars-list-template-offcanvas" type="text/x-handlebars-template">
            {{#each calendars}}
            <li>
                <input type="checkbox" id="offc_calendar_{{id}}" class="sc-js-calendar-toggle" data-color="{{ bgColor }}" value="{{ id }}" checked>
                <label for="offc_calendar_{{id}}">{{ name }}</label>
            </li>
            {{/each}}
        </script>
    </div>
</div>
