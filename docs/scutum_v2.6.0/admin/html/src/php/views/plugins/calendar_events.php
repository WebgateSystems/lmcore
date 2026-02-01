<div id="sc-page-wrapper">
    <div id="sc-page-content">

        <div class="uk-margin-auto uk-width-1-3@l">
            <h4>Default</h4>
            <div class="uk-card">
                <div id="clndr-events-full" class="clndr-wrapper"></div>
                <script id="clndr-events-full-template" type="text/x-handlebars-template">
                    <div class="clndr-toolbar">
                        <h3 class="clndr-toolbar-heading">
                            {{ month }} {{ year }}
                        </h3>
                        <div class="clndr-toolbar-actions">
                            <a href="javascript:void(0)" class="clndr-today sc-actions-icon">
                                <i class="mdi mdi-calendar"></i>
                            </a>
                            <a href="javascript:void(0)" class="clndr-prev sc-actions-icon">
                                <i class="mdi <?php rtlReplace('mdi-chevron-left', 'mdi-chevron-right'); ?>"></i>
                            </a>
                            <a href="javascript:void(0)" class="clndr-next sc-actions-icon">
                                <i class="mdi <?php rtlReplace('mdi-chevron-right', 'mdi-chevron-left'); ?>"></i>
                            </a>
                        </div>
                    </div>
                    <div class="clndr-days">
                        <div class="clndr-days-names">
                            {{#each daysOfTheWeek}}
                                <div class="day-header">{{ this }}</div>
                            {{/each}}
                        </div>
                        <div class="clndr-days-grid">
                            {{#each days}}
                                <div class="{{ this.classes }}" {{#if this.id }} id="{{ this.id }}" {{/if}}>
                                    <span class="day-inner">
                                        {{ this.day }}
                                        <span class="events-indicator"></span>
                                    </span>
                                </div>
                            {{/each}}
                        </div>
                    </div>
                    <div class="clndr-events">
                        {{#each eventsThisMonth}}
                            <div class="clndr-event" style="--event-color: {{ this.eventColor }}" data-clndr-event="{{ dateFormat this.date format='YYYY-MM-DD' }}">
                                <span class="clndr-event-title">
                                    {{~#ifCond this.url "!==" null }}<a href="{{ this.url }}">{{/ifCond}}
                                        {{ this.title }}
                                    {{~#ifCond this.url "!==" null }}</a>{{/ifCond}}
                                    {{~#ifCond this.url "===" null }}{{ this.title }}{{/ifCond}}
                                </span>
                                <span class="clndr-event-more-info">
                                    {{~dateFormat this.date format='MMM Do'}}
                                    {{~#ifCond this.timeStart '||' this.timeEnd}} ({{/ifCond}}
                                    {{~#if this.timeStart }} {{~this.timeStart~}} {{/if}}
                                    {{~#ifCond this.timeStart '&&' this.timeEnd}} - {{/ifCond}}
                                    {{~#if this.timeEnd }} {{~this.timeEnd~}} {{/if}}
                                    {{~#ifCond this.timeStart '||' this.timeEnd}}){{/ifCond~}}
                                </span>
                            </div>
                        {{/each}}
                    </div>
                </script>
            </div>
        </div>
        <div class="uk-margin-auto uk-width-1-3@l uk-margin-top">
            <h4>Swiper plugin</h4>
            <div class="uk-card">
                <div id="clndr-events-compact_v1" class="clndr-wrapper clndr-small"></div>
                <script id="clndr-events-compact_v1-template" type="text/x-handlebars-template">
                    <div class="clndr-toolbar">
                        <h3 class="clndr-toolbar-heading">
                            {{ month }} {{ year }}
                        </h3>
                        <div class="clndr-toolbar-actions">
                            <a href="javascript:void(0)" class="clndr-today sc-actions-icon">
                                <i class="mdi mdi-calendar"></i>
                            </a>
                            <a href="javascript:void(0)" class="clndr-prev sc-actions-icon">
                                <i class="mdi <?php rtlReplace('mdi-chevron-left', 'mdi-chevron-right'); ?>"></i>
                            </a>
                            <a href="javascript:void(0)" class="clndr-next sc-actions-icon">
                                <i class="mdi <?php rtlReplace('mdi-chevron-right', 'mdi-chevron-left'); ?>"></i>
                            </a>
                        </div>
                    </div>
                    <div class="clndr-days">
                        <div class="clndr-days-names">
                            {{#each daysOfTheWeek}}
                                <div class="day-header">{{ this }}</div>
                            {{/each}}
                        </div>
                        <div class="clndr-days-grid swiper-container uk-width-1-1">
                            <div class="swiper-wrapper">
                                {{#each days}}
                                    <div class="{{ this.classes }} swiper-slide" {{#if this.id }} id="{{ this.id }}" {{/if}}>
                                        <span class="day-inner">
                                            {{ this.day }}
                                            <span class="events-indicator"></span>
                                        </span>
                                    </div>
                                {{/each}}
                            </div>
                        </div>
                    </div>
                    <div class="clndr-events">
                        {{#each eventsThisMonth}}
                            <div class="clndr-event" style="--event-color: {{ this.eventColor }}" data-clndr-event="{{ dateFormat this.date format='YYYY-MM-DD' }}">
                                <span class="clndr-event-title">
                                    {{~#ifCond this.url "!==" null }}<a href="{{ this.url }}">{{/ifCond}}
                                    {{ this.title }}
                                    {{~#ifCond this.url "!==" null }}</a>{{/ifCond}}
                                    {{~#ifCond this.url "===" null }}{{ this.title }}{{/ifCond}}
                                </span>
                                <span class="clndr-event-more-info">
                                    {{~dateFormat this.date format='MMM Do'}}
                                    {{~#ifCond this.timeStart '||' this.timeEnd}} ({{/ifCond}}
                                    {{~#if this.timeStart }} {{~this.timeStart~}} {{/if}}
                                    {{~#ifCond this.timeStart '&&' this.timeEnd}} - {{/ifCond}}
                                    {{~#if this.timeEnd }} {{~this.timeEnd~}} {{/if}}
                                    {{~#ifCond this.timeStart '||' this.timeEnd}}){{/ifCond~}}
                                </span>
                            </div>
                        {{/each}}
                    </div>
                </script>
            </div>
            <div class="uk-card uk-margin-top">
                <div id="clndr-events-compact_v2" class="clndr-wrapper clndr-small"></div>
                <script id="clndr-events-compact_v2-template" type="text/x-handlebars-template">
                    <div class="clndr-toolbar">
                        <h3 class="clndr-toolbar-heading">
                            {{ month }} {{ year }}
                        </h3>
                        <div class="clndr-toolbar-actions">
                            <a href="javascript:void(0)" class="clndr-select sc-actions-icon" data-uk-toggle="target: #clndr-events-compact_v2-modal">
                                <i class="mdi mdi-calendar-search"></i>
                            </a>
                            <a href="javascript:void(0)" class="clndr-today sc-actions-icon">
                                <i class="mdi mdi-calendar"></i>
                            </a>
                            <a href="javascript:void(0)" class="clndr-prev sc-actions-icon">
                                <i class="mdi <?php rtlReplace('mdi-chevron-left', 'mdi-chevron-right'); ?>"></i>
                            </a>
                            <a href="javascript:void(0)" class="clndr-next sc-actions-icon">
                                <i class="mdi <?php rtlReplace('mdi-chevron-right', 'mdi-chevron-left'); ?>"></i>
                            </a>
                        </div>
                    </div>
                    <div class="clndr-days clndr-days-names">
                        <div class="clndr-days-grid swiper-container uk-width-1-1">
                            <div class="swiper-wrapper">
                                {{#each days}}
                                    <div class="{{ this.classes }} swiper-slide" {{#if this.id }} id="{{ this.id }}" {{/if}}>
                                        <span class="day-inner">
                                            <span class="event-day-name">{{ dateFormat this.date format="dd" }}</span>
                                            {{ this.day }}
                                            <span class="events-indicator"></span>
                                        </span>
                                    </div>
                                {{/each}}
                            </div>
                        </div>
                    </div>
                    <div class="clndr-events">
                        {{#each eventsThisMonth}}
                            <div class="clndr-event" style="--event-color: {{ this.eventColor }}" data-clndr-event="{{ dateFormat this.date format='YYYY-MM-DD' }}">
                                <span class="clndr-event-title">
                                    {{~#ifCond this.url "!==" null }}<a href="{{ this.url }}">{{/ifCond}}
                                    {{ this.title }}
                                    {{~#ifCond this.url "!==" null }}</a>{{/ifCond}}
                                    {{~#ifCond this.url "===" null }}{{ this.title }}{{/ifCond}}
                                </span>
                                <span class="clndr-event-more-info">
                                    {{~dateFormat this.date format='MMM Do'}}
                                    {{~#ifCond this.timeStart '||' this.timeEnd}} ({{/ifCond}}
                                    {{~#if this.timeStart }} {{~this.timeStart~}} {{/if}}
                                    {{~#ifCond this.timeStart '&&' this.timeEnd}} - {{/ifCond}}
                                    {{~#if this.timeEnd }} {{~this.timeEnd~}} {{/if}}
                                    {{~#ifCond this.timeStart '||' this.timeEnd}}){{/ifCond~}}
                                </span>
                            </div>
                        {{/each}}
                    </div>
                </script>
                <div id="clndr-events-compact_v2-modal" class="uk-flex-top" data-uk-modal>
                    <div class="uk-modal-dialog uk-modal-body uk-width-large uk-margin-auto-vertical">
                        <h2 class="uk-modal-title">Select date</h2>
                        <div class="uk-child-width-expand" data-uk-grid>
                            <div>
                                <label>Year</label>
                                <select class="uk-select date-select-year">
                                    <option value="2016">2016</option>
                                    <option value="2017">2017</option>
                                    <option value="2018">2018</option>
                                    <option value="2019">2019</option>
                                    <option value="2020">2020</option>
                                    <option value="2021" selected>2021</option>
                                    <option value="2022">2022</option>
                                    <option value="2023">2023</option>
                                </select>
                            </div>
                            <div>
                                <label>Month</label>
                                <select class="uk-select date-select-month">
                                    <option value="01">January</option>
                                    <option value="02">February</option>
                                    <option value="03">March</option>
                                    <option value="04">April</option>
                                    <option value="05">May</option>
                                    <option value="06">June</option>
                                    <option value="07">July</option>
                                    <option value="08">August</option>
                                    <option value="09">September</option>
                                    <option value="10">October</option>
                                    <option value="11">November</option>
                                    <option value="12">December</option>
                                </select>
                            </div>
                            <div>
                                <label>Day</label>
                                <select class="uk-select date-select-day">
                                    <option value="01">1</option>
                                    <option value="02">2</option>
                                    <option value="03">3</option>
                                    <option value="04">4</option>
                                    <option value="05">5</option>
                                    <option value="06">6</option>
                                    <option value="07">7</option>
                                    <option value="08">8</option>
                                    <option value="09">9</option>
                                    <option value="10">10</option>
                                    <option value="11">11</option>
                                    <option value="12">12</option>
                                    <option value="13">13</option>
                                    <option value="14">14</option>
                                    <option value="15">15</option>
                                    <option value="16">16</option>
                                    <option value="17">17</option>
                                    <option value="18">18</option>
                                    <option value="19">19</option>
                                    <option value="20">20</option>
                                    <option value="21">21</option>
                                    <option value="22">22</option>
                                    <option value="23">23</option>
                                    <option value="24">24</option>
                                    <option value="25">25</option>
                                    <option value="26">26</option>
                                    <option value="27">27</option>
                                    <option value="28">28</option>
                                    <option value="29">29</option>
                                    <option value="30">30</option>
                                    <option value="31">31</option>
                                </select>
                            </div>
                        </div>
                        <button class="sc-button uk-margin-medium-top" id="clndr-events-compact_v2-select-date">Select</button>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>
