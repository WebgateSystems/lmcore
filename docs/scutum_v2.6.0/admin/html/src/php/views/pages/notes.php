<?php
$tags = [
	[ "Tag 1" => "md-bg-blue-400" ],
	[ "Tag 2" => "md-bg-grey-400" ],
	[ "Tag 3" => "md-bg-amber-400" ],
	[ "Tag 4" => "md-bg-red-400" ]
];
$folders = ['Work','To Do','Important','Personal']
?>
<div id="sc-page-wrapper" class="uk-flex uk-flex-column">
	<div id="sc-page-top-bar" class="sc-top-bar" data-uk-sticky="offset:48; show-on-up: true; animation: uk-animation-slide-top-medium">
		<div class="sc-top-bar-content uk-flex uk-flex-1">
			<h1 class="sc-top-bar-title uk-text-uppercase uk-flex-1">Notes</h1>
			<div class="sc-actions <?php rtlReplace('uk-margin-left', 'uk-margin-right'); ?>">
				<a href="#" class="sc-actions-icon mdi mdi-settings-outline"></a>
			</div>
		</div>
	</div>
	<div data-uk-filter="target: .sc-notes">
		<div id="sc-page-content">
			<div data-uk-grid class="sc-js-sticky-parent">
				<div class="uk-width-1-6@l uk-width-1-4@m uk-visible@m">
					<ul data-uk-accordion="multiple: true" data-sc-sticky='{ "delay": 500, "offset_top": "inPlace" }'>
						<li class="uk-open">
							<a class="uk-accordion-title" href="#"><i class="mdi mdi-folder-outline"></i>Folders</a>
							<div class="uk-accordion-content">
								<ul class="uk-list">
									<li data-uk-filter-control="filter: [data-folder]; group: folder" class="sc-js-filter-clear" >
										<a href="#">All folders</a>
									</li>
									<?php foreach($folders as $k) {  ?>
										<li data-uk-filter-control="filter: [data-folder='<?php echo strtolower( preg_replace( '/\s*/', '', $k ) ); ?>']; group: folder">
											<a href="#"><?php echo $k; ?></a>
										</li>
									<?php }; ?>
								</ul>
							</div>
						</li>
						<li class="uk-open">
							<a class="uk-accordion-title" href="#"><i class="mdi mdi-label-outline"></i>Tags</a>
							<div class="uk-accordion-content">
								<ul class="uk-list">
									<li data-uk-filter-control="filter: .sc-filter-label; group: label" class="sc-js-filter-clear">
										<a href="#"><span class="sc-color-label md-bg-white"><i class="mdi mdi-close"></i></span>All tags</a>
									</li>
									<?php for($i=0;$i<4;$i++) {foreach ( $tags[$i] as $k => $v) {$name = $k;$color = $v;} ?>
										<li data-uk-filter-control="filter: .sc-filter-label-<?php echo strtolower( preg_replace( '/\s*/', '', $name ) ); ?>; group: label">
											<a href="#"><span class="sc-color-label <?php echo $color; ?>"></span><?php echo $name; ?></a>
										</li>
									<?php }; ?>
								</ul>
							</div>
						</li>
					</ul>
				</div>
				<div class="uk-flex-1">
					<ul class="sc-notes uk-child-width-1-3@l uk-child-width-1-4@xl" data-uk-grid="masonry: true" id="sc-notes">
                        <!-- handlebars/templates/notes.hbs -->
                    </ul>
				</div>
			</div>
		</div>
	</div>
	<div class="sc-fab-page-wrapper">
		<a href="#" class="sc-fab sc-fab-large sc-fab-secondary"><i class="mdi mdi-plus"></i></a>
	</div>
</div>
<div id="sc-note-preview" class="uk-flex-top" data-uk-modal>
    <!-- handlebars/templates/note-modal.hbs -->
</div>
