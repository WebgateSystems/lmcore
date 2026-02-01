<div id="sc-page-wrapper">
	<div id="sc-page-top-bar" class="sc-top-bar" data-uk-sticky="offset:48; show-on-up: true; animation: uk-animation-slide-top-medium">
		<div class="sc-top-bar-content uk-flex uk-flex-1">
			<h1 class="sc-top-bar-title uk-text-uppercase uk-flex-1">Animations</h1>
			<div class="uk-width-1-2 uk-width-1-3@s uk-width-1-5@l">
				<select name="sc-animation-duration" id="sc-animation-duration" class="uk-form-small uk-select" data-sc-select2='{"minimumResultsForSearch": -1, "placeholder": "Select duration..."}'>
					<option value="">Select duration...</option>
					<option value="sc-animation-default">Default</option>
					<option value="sc-animation-fast">Fast</option>
					<option value="sc-animation-slow">Slow</option>
					<option value="sc-animation-very-slow">Very Slow</option>
				</select>
			</div>
		</div>
	</div>
	<div id="sc-page-content">
		<div class="uk-child-width-1-2@l" data-uk-grid>
			<div>
				<h4>Sequential show</h4>
<pre class="sc-js-highlight"><code>// available options
animation: 'uk-animation-scale-up', // animation for the sequential show
duration: '320', // animation duration in ms
delay: 0.4, // delay multiplier
target: '' // element to animate

// example
data-sc-sequence-show='{"target" : ".uk-card", "animation": "uk-animation-slide-left", "delay": 1.2, "duration": 480}'
</code></pre>
				<hr class="uk-margin">
				<a href="#" class="sc-js-repeat-animation sc-button sc-button-flat sc-button-flat-danger uk-margin-bottom">Repeat</a>
				<div class="uk-child-width-1-4@s uk-grid-medium" data-sc-sequence-show='{"target" : ".uk-card"}' data-uk-grid>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
				</div>
<pre class="sc-js-highlight"><code>&lt;div data-sc-sequence-show='{&quot;target&quot; : &quot;.uk-card&quot;}'&gt;&lt;/div&gt;
</code></pre>
				<hr class="uk-margin">
				<a href="#" class="sc-js-repeat-animation sc-button sc-button-flat sc-button-flat-danger uk-margin-bottom">Repeat</a>
				<div class="uk-child-width-1-1 uk-grid-collapse" data-sc-sequence-show='{"target" : ".uk-card", "animation": "uk-animation-slide-bottom-medium", "delay": 1.5}' data-uk-grid>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
				</div>
<pre class="sc-js-highlight"><code>&lt;div data-sc-sequence-show='{&quot;target&quot; : &quot;.uk-card&quot;, &quot;animation&quot;: &quot;uk-animation-slide-bottom-medium&quot;, &quot;delay&quot;: 1.5}'&gt;&lt;/div&gt;
</code></pre>
				<hr class="uk-margin">
				<a href="#" class="sc-js-repeat-animation sc-button sc-button-flat sc-button-flat-danger uk-margin-bottom">Repeat</a>
				<div class="uk-child-width-1-1 uk-grid-collapse" data-sc-sequence-show='{"target" : ".uk-card", "animation": "uk-animation-scale-down", "delay": 1, "duration": 240}' data-uk-grid>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
					<div><div class="uk-card sc-padding-medium">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Impedit, quae?</div></div>
				</div>
<pre class="sc-js-highlight"><code>&lt;div data-sc-sequence-show='{&quot;target&quot; : &quot;.uk-card&quot;, &quot;animation&quot;: &quot;uk-animation-scale-down&quot;, &quot;delay&quot;: 1, &quot;duration&quot;: 240}'&gt;&lt;/div&gt;
</code></pre>
			</div>
			<div>
				<h4>UIkit animations</h4>
				<div class="uk-child-width-1-2 uk-child-width-1-6@s uk-grid-match sc-js-animations-grid uk-grid-medium" data-uk-grid>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-fade">
							<p class="uk-text-center uk-text-medium">Fade</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-scale-up">
							<p class="uk-text-center uk-text-medium">Scale Up</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-scale-down">
							<p class="uk-text-center uk-text-medium">Scale Down</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-shake">
							<p class="uk-text-center uk-text-medium">Shake</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-left">
							<p class="uk-text-center uk-text-medium">Left</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-top">
							<p class="uk-text-center uk-text-medium">Top</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-bottom">
							<p class="uk-text-center uk-text-medium">Bottom</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-right">
							<p class="uk-text-center uk-text-medium">Right</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-left-small">
							<p class="uk-text-center uk-text-medium">Left Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-top-small">
							<p class="uk-text-center uk-text-medium">Top Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-bottom-small">
							<p class="uk-text-center uk-text-medium">Bottom Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-right-small">
							<p class="uk-text-center uk-text-medium">Right Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-left-medium">
							<p class="uk-text-center uk-text-medium">Left Medium</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-top-medium">
							<p class="uk-text-center uk-text-medium">Top Medium</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-bottom-medium">
							<p class="uk-text-center uk-text-medium">Bottom Medium</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-right-medium">
							<p class="uk-text-center uk-text-medium">Right Medium</p>
						</div>
					</div>
				</div>
<pre class="sc-js-highlight"><code>&lt;div class=&quot;uk-animation-fade&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-scale-up&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-scale-down&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-shake&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-left&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-top&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-bottom&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-right&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-left-small&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-top-small&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-bottom-small&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-right-small&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-left-medium&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-top-medium&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-bottom-medium&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-right-medium&quot;&gt;&lt;/div&gt;
</code></pre>
				<h5 class="uk-margin-medium-top">Reverse modifier</h5>
				<div class="uk-child-width-1-2 uk-child-width-1-6@s uk-grid-match sc-js-animations-grid uk-grid-medium" data-uk-grid>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-fade uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Fade</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-scale-up uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Scale Up</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-scale-down uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Scale Down</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-shake uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Shake</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-left uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Left</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-top uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Top</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-bottom uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Bottom</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-right uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Right</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-left-small uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Left Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-top-small uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Top Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-bottom-small uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Bottom Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-right-small uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Right Small</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-left-medium uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Left Medium</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-top-medium uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Top Medium</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-bottom-medium uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Bottom Medium</p>
						</div>
					</div>
					<div class="uk-animation-toggle">
						<div class="uk-card uk-card-body uk-flex uk-flex-middle uk-flex-center uk-animation-slide-right-medium uk-animation-reverse">
							<p class="uk-text-center uk-text-medium">Right Medium</p>
						</div>
					</div>
				</div>
<pre class="sc-js-highlight"><code>&lt;div class=&quot;uk-animation-fade uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-scale-up uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-scale-down uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-shake uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-left uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-top uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-bottom uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-right uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-left-small uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-top-small uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-bottom-small uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-right-small uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-left-medium uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-top-medium uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-bottom-medium uk-animation-reverse&quot;&gt;&lt;/div&gt;
&lt;div class=&quot;uk-animation-slide-right-medium uk-animation-reverse&quot;&gt;&lt;/div&gt;
</code></pre>
			</div>
		</div>
	</div>
</div>
