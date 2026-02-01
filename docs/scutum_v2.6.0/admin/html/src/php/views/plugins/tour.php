<div id="sc-page-wrapper">
	<div id="sc-page-content">
        <div class="uk-card">
            <div class="uk-card-body">
                <button class="sc-button sc-button-primary" id="sc-tour-restart">Restart tour</button>
            </div>
        </div>
        <div class="uk-card uk-margin">
            <div class="uk-card-body">
                <h5 class="uk-margin-medium">Highlighting a Single Element – Without Popover</h5>
                <div class="uk-child-width-1-2@s" data-uk-grid>
                    <div>
                        <div id="sc-tour-singleEl-noPopover">
                        <button class="sc-button sc-button-primary">Show</button>
<pre class="sc-js-highlight"><code>var highlightDriver = new Driver();
$('#sc-tour-singleEl-noPopover').on('click', function (e) {
e.preventDefault();
highlightDriver.highlight('#create-post');
});
</code></pre>
                        </div>
                    </div>
                    <div>
                        <div class="uk-margin-small sc-tour-singleEl-noPopover-focus">
                            <label>Focus any of the input</label>
                            <input type="text" class="uk-input" data-sc-input>
                        </div>
                        <div class="uk-margin-small sc-tour-singleEl-noPopover-focus">
                            <label>Focus any of the input</label>
                            <input type="text" class="uk-input" data-sc-input>
                        </div>
                        <div class="uk-margin-small sc-tour-singleEl-noPopover-focus">
                            <label>Focus any of the input</label>
                            <input type="text" class="uk-input" data-sc-input>
                        </div>
                        <div class="uk-margin-small sc-tour-singleEl-noPopover-focus">
                            <label>Focus any of the input</label>
                            <input type="text" class="uk-input" data-sc-input>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="uk-card uk-margin">
            <div class="uk-card-body">
                <div class="uk-child-width-1-2@m" data-uk-grid="">
                    <div>
                        <h5 class="uk-margin-large">Highlighting a Single Element – With Popover</h5>
                        <div id="sc-tour-singleEl-Popover">
                            <button class="sc-button sc-button-primary">Show</button>
<pre class="sc-js-highlight"><code>var highlightDriver = new Driver({
    opacity: 0.6
});
$('#sc-tour-singleEl-Popover button').on('click', function (e) {
    e.preventDefault();
    highlightDriver.highlight({
        element: '#sc-tour-singleEl-Popover',
        popover: {
            title: 'Title for the Popover',
            description: 'Description for highlighted element'
        }
    });
});
</code></pre>
                        </div>
                    </div>
                    <div>
                        <h5 class="uk-margin-large">Popover Positioning</h5>
                        <div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="left">
                                <button class="sc-button">Left</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="left-center">
                                <button class="sc-button">Left Center</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="left-bottom">
                                <button class="sc-button">Left Bottom</button>
                            </div>
                        </div>
                        <div class="uk-margin-small-top">
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="top">
                                <button class="sc-button">Top</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="top-center">
                                <button class="sc-button">Top Center</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="top-right">
                                <button class="sc-button">Top Right</button>
                            </div>
                        </div>
                        <div class="uk-margin-small-top">
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="right">
                                <button class="sc-button">Right</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="right-center">
                                <button class="sc-button">Right Center</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="right-bottom">
                                <button class="sc-button">Right Bottom</button>
                            </div>
                        </div>
                        <div class="uk-margin-small-top">
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="bottom">
                                <button class="sc-button">Bottom</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="bottom-center">
                                <button class="sc-button">Bottom Center</button>
                            </div>
                            <div class="sc-padding-small uk-display-inline-block sc-tour-position" data-position="bottom-right" id="last-el">
                                <button class="sc-button">Bottom Right</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
	</div>
</div>
