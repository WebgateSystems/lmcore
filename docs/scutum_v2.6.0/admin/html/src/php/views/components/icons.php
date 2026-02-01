<?php
$data_icons = file_get_contents('./data/pages/uikit-icons.json');
$json_icons = json_decode($data_icons, TRUE);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">

		<div class="uk-card" id="nav-mdi">
			<h2 class="uk-card-title">Material Design Icons</h2>
			<div class="uk-card-body">
				<div class="uk-grid-divider" data-uk-grid>
					<div class="uk-width-1-3@l">
						<h5>Usage</h5>
						<div class="uk-child-width-auto" data-uk-grid>
							<i class="mdi mdi-monitor-dashboard"></i>
							<i class="mdi mdi-account"></i>
							<i class="mdi mdi-book-open-variant"></i>
							<i class="mdi mdi-comment-processing-outline"></i>
						</div>
<pre class="sc-js-highlight"><code>&lt;i class=&quot;mdi mdi-monitor-dashboard&quot;&gt;&lt;&#x2F;i&gt;
&lt;i class=&quot;mdi mdi-account&quot;&gt;&lt;&#x2F;i&gt;
&lt;i class=&quot;mdi mdi-book-open-variant&quot;&gt;&lt;&#x2F;i&gt;
&lt;i class=&quot;mdi mdi-comment-processing-outline&quot;&gt;&lt;&#x2F;i&gt;
</code></pre>
						<hr>
						<h5>Colors</h5>
						<div class="uk-child-width-auto" data-uk-grid>
							<i class="mdi mdi-monitor-dashboard md-color-red-600"></i>
							<i class="mdi mdi-account md-color-light-green-600"></i>
							<i class="mdi mdi-book-open-variant md-color-indigo-600"></i>
							<i class="mdi mdi-comment-processing-outline md-color-cyan-600"></i>
						</div>
						<pre class="sc-js-highlight"><code>&lt;i class=&quot;mdi mdi-monitor-dashboard md-color-red-600&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-account md-color-light-green-600&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-book-open-variant md-color-indigo-600&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-comment-processing-outline md-color-cyan-600&quot;&gt;&lt;/i&gt;</code></pre>
					</div>
					<div class="uk-width-2-3@l">
						<h5>Sizes</h5>
						<div class="uk-child-width-auto@s uk-flex-middle" data-uk-grid>
							<i class="mdi mdi-heart-outline sc-icon-18"></i>
							<i class="mdi mdi-heart-outline sc-icon-20"></i>
							<i class="mdi mdi-heart-outline sc-icon-22"></i>
							<i class="mdi mdi-heart-outline sc-icon-24"></i>
							<i class="mdi mdi-heart-outline sc-icon-28"></i>
							<i class="mdi mdi-heart-outline sc-icon-32"></i>
							<i class="mdi mdi-heart-outline sc-icon-36"></i>
							<i class="mdi mdi-heart-outline sc-icon-48"></i>
						</div>
<pre class="sc-js-highlight"><code>&lt;i class=&quot;mdi mdi-heart-outline sc-icon-18&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-heart-outline sc-icon-20&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-heart-outline sc-icon-22&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-heart-outline sc-icon-24&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-heart-outline sc-icon-28&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-heart-outline sc-icon-32&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-heart-outline sc-icon-36&quot;&gt;&lt;/i&gt;
&lt;i class=&quot;mdi mdi-heart-outline sc-icon-48&quot;&gt;&lt;/i&gt;</code></pre>
                        <hr>
                        <h5>Modifiers</h5>
                        <div class="uk-child-width-auto@s uk-grid-small" data-uk-grid>
                            <i class="mdi mdi-loading mdi-spin"></i>
                            <i class="mdi mdi-account-alert-outline"></i>
                            <i class="mdi mdi-account-alert-outline mdi-flip-h"></i>
                            <i class="mdi mdi-account-alert-outline mdi-flip-v"></i>
                            <i class="mdi mdi-account-alert-outline mdi-rotate-90"></i>
                            <i class="mdi mdi-account-alert-outline mdi-rotate-225"></i>
                        </div>
					</div>
				</div>
				<hr>
				<div>
					<div class="uk-flex-middle uk-margin" data-uk-grid>
						<div class="uk-flex-1">
							<h5 class="uk-margin-remove">Icons<span class="sc-sub-heading">Click on icon to get HTML code</span></h5>
						</div>
						<div class="uk-width-1-2@s">
							<i class="mdi mdi-magnify uk-form-icon"></i>
							<i class="mdi mdi-close uk-form-icon uk-form-icon-flip sc-js-input-clear"></i>
							<input id="sc-js-icons-search" class="uk-input" type="search" placeholder="Search... (min. 3 char.)" data-sc-input="outline">
						</div>
					</div>
					<div class="uk-child-width-auto uk-flex uk-flex-wrap sc-js-search-list" id="sc-js-mdi-dynamic-load"></div>
					<script id="mdiTemplate" type="text/x-handlebars-template">
						{{#each icons }}
						<div class="sc-js-mdi-code sc-el-clickable sc-el-hoverable sc-padding-medium uk-border-rounded" title="{{ name }} {{ hex }}" data-icon-name={{ name }}>
							<i class="mdi mdi-{{ name }}"></i>
						</div>
						{{/each}}
					</script>
				</div>
			</div>
		</div>
		<div class="uk-card uk-margin" id="nav-uikitIcons">
			<h2 class="uk-card-title">UIKit icons</h2>
			<div class="uk-card-body">
				<h5>Usage</h5>
				<div class="uk-child-width-1-2@l uk-grid-divider" data-uk-grid>
					<div>
						<div class="uk-child-width-auto" data-uk-grid>
							<span data-uk-icon="icon: image"></span>
							<span data-uk-icon="icon: image; ratio: 1.5"></span>
							<span data-uk-icon="icon: image; ratio: 2"></span>
							<span data-uk-icon="icon: image; ratio: 3"></span>
							<span data-uk-icon="icon: image; ratio: 4"></span>
						</div>
<pre class="sc-js-highlight"><code>&lt;span uk-icon=&quot;icon: image&quot;&gt;&lt;/span&gt;
&lt;span uk-icon=&quot;icon: image; ratio: 1.5&quot;&gt;&lt;/span&gt;
&lt;span uk-icon=&quot;icon: image; ratio: 2&quot;&gt;&lt;/span&gt;
&lt;span uk-icon=&quot;icon: image; ratio: 3&quot;&gt;&lt;/span&gt;
&lt;span uk-icon=&quot;icon: image; ratio: 4&quot;&gt;&lt;/span&gt;</code></pre>
					</div>
					<div>
						<a href="#" class="uk-icon-link" data-uk-icon="icon: copy; ratio: 1.5"></a>
						<a href="#" class="uk-icon-link" data-uk-icon="icon: file-edit; ratio: 1.5"></a>
						<a href="#" class="uk-icon-link" data-uk-icon="icon: trash; ratio: 1.5"></a>
<pre class="sc-js-highlight"><code>&lt;a href=&quot;#&quot; class=&quot;uk-icon-link-right&quot; uk-icon=&quot;icon: copy; ratio: 1.5&quot;&gt;&lt;/a&gt;
&lt;a href=&quot;#&quot; class=&quot;uk-icon-link-right&quot; uk-icon=&quot;icon: file-edit; ratio: 1.5&quot;&gt;&lt;/a&gt;
&lt;a href=&quot;#&quot; class=&quot;uk-icon-link&quot; uk-icon=&quot;icon: trash; ratio: 1.5&quot;&gt;&lt;/a&gt;</code></pre>
					</div>
				</div>
				<hr>
				<h5>Icons<span class="sc-sub-heading">Click on icon to get HTML code</span></h5>
				<div class="uk-child-width-auto uk-flex uk-flex-wrap" data-uk-grid>
<?php foreach ($json_icons as $value) {?>
					<div>
						<div class="sc-padding-small sc-js-uikit-code sc-el-clickable sc-el-hoverable uk-border-rounded"><span data-uk-icon="icon: <?php echo $value['name']; ?>; ratio: 1.4"></span></div>
					</div>
<?php }; ?>
				</div>
			</div>
		</div>

	</div>
</div>