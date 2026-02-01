<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div class="uk-child-width-1-2@l" data-uk-grid>
			<div>
				<div class="uk-card">
					<h3 class="uk-card-title">Images</h3>
					<div class="uk-card-body">

						<div class="uk-child-width-auto@s uk-flex-middle" data-uk-grid>
							<div>
								<?php avatar(5); ?>
							</div>
							<div>
								<?php avatar(5,null,'_md'); ?>
							</div>
							<div>
								<?php avatar(5,null,'_lg'); ?>
							</div>
							<div>
								<?php avatar(5,null,''); ?>
							</div>
						</div>
<pre class="sc-js-highlight"><code>&lt;img src=&quot;assets/img/avatars/avatar_05_sm.png&quot; class=&quot;sc-avatar&quot; alt=&quot;&quot;&gt;
&lt;img src=&quot;assets/img/avatars/avatar_05_md.png&quot; class=&quot;sc-avatar&quot; alt=&quot;&quot;&gt;
&lt;img src=&quot;assets/img/avatars/avatar_05_lg.png&quot; class=&quot;sc-avatar&quot; alt=&quot;&quot;&gt;
&lt;img src=&quot;assets/img/avatars/avatar_05.png&quot; class=&quot;sc-avatar&quot; alt=&quot;&quot;&gt;
</code></pre>
						<hr>
						<div class="uk-child-width-auto@s uk-flex-middle" data-uk-grid>
							<div>
								<div class="sc-avatar-wrapper">
									<span class="sc-user-status online"></span>
									<?php avatar(8); ?>
								</div>
							</div>
							<div>
								<div class="sc-avatar-wrapper sc-avatar-wrapper-md">
									<span class="sc-user-status away"></span>
									<?php avatar(8,null,'_md'); ?>
								</div>
							</div>
							<div>
								<div class="sc-avatar-wrapper sc-avatar-wrapper-lg">
									<span class="sc-user-status busy"></span>
									<?php avatar(8,null,''); ?>
								</div>
							</div>
						</div>
<pre class="sc-js-highlight"><code>&lt;div class=&quot;sc-avatar-wrapper sc-avatar-wrapper-sm&quot;&gt;
	&lt;span class=&quot;sc-user-status online&quot;&gt;&lt;/span&gt;
	&lt;img src=&quot;assets/img/avatars/avatar_08_sm.png&quot; class=&quot;sc-avatar&quot; alt=&quot;&quot;&gt;
&lt;/div&gt;
&lt;div class=&quot;sc-avatar-wrapper sc-avatar-wrapper-md&quot;&gt;
	&lt;span class=&quot;sc-user-status away&quot;&gt;&lt;/span&gt;
	&lt;img src=&quot;assets/img/avatars/avatar_08_md.png&quot; class=&quot;sc-avatar&quot; alt=&quot;&quot;&gt;
&lt;/div&gt;
&lt;div class=&quot;sc-avatar-wrapper&quot;&gt;
	&lt;span class=&quot;sc-user-status busy&quot;&gt;&lt;/span&gt;
	&lt;img src=&quot;assets/img/avatars/avatar_08_lg.png&quot; class=&quot;sc-avatar&quot; alt=&quot;&quot;&gt;
&lt;/div&gt;
</code></pre>

					</div>
				</div>
			</div>
			<div>
				<div class="uk-card">
					<h3 class="uk-card-title">Initials</h3>
					<div class="uk-card-body">
						<div class="uk-child-width-auto uk-flex-middle uk-grid-medium" data-uk-grid>
							<div>
								<?php avatarInitials('MR')?>
							</div>
							<div>
								<?php avatarInitials('LO','md-bg-yellow-200')?>
							</div>
							<div>
								<?php avatarInitials('KT','md-bg-red-500 md-color-white')?>
							</div>
							<div>
								<?php avatarInitials('GW','md-bg-light-green-500 md-color-white')?>
							</div>
							<div>
								<?php avatarInitials('SB','md-bg-light-blue-500 md-color-white')?>
							</div>
						</div>
<pre class="sc-js-highlight"><code>&lt;span class=&quot;sc-avatar-initials md-bg-grey-100&quot; title=&quot;&quot;&gt;MR&lt;/span&gt;
&lt;span class=&quot;sc-avatar-initials md-bg-yellow-200&quot; title=&quot;&quot;&gt;LO&lt;/span&gt;
&lt;span class=&quot;sc-avatar-initials md-bg-red-500 md-color-white&quot; title=&quot;&quot;&gt;KT&lt;/span&gt;
&lt;span class=&quot;sc-avatar-initials md-bg-light-green-500 md-color-white&quot; title=&quot;&quot;&gt;GW&lt;/span&gt;
&lt;span class=&quot;sc-avatar-initials md-bg-light-blue-500 md-color-white&quot; title=&quot;&quot;&gt;SB&lt;/span&gt;
</code></pre>
						<hr>
						<div class="uk-child-width-auto@s uk-flex-middle" data-uk-grid>
							<div>
								<?php avatarInitials('MR','md-bg-blue-grey-100')?>
							</div>
							<div>
								<?php avatarInitials('LO','md-bg-teal-600 md-color-white','','md')?>
							</div>
							<div>
								<?php avatarInitials('KT','md-bg-purple-500 md-color-white','','lg')?>
							</div>
						</div>
<pre class="sc-js-highlight"><code>&lt;span class=&quot;sc-avatar-initials md-bg-blue-grey-100&quot; title=&quot;&quot;&gt;MR&lt;/span&gt;
&lt;span class=&quot;sc-avatar-initials md-bg-teal-600 md-color-white sc-avatar-initials-md&quot; title=&quot;&quot;&gt;LO&lt;/span&gt;
&lt;span class=&quot;sc-avatar-initials md-bg-purple-500 md-color-white sc-avatar-initials-lg&quot; title=&quot;&quot;&gt;KT&lt;/span&gt;
</code></pre>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
