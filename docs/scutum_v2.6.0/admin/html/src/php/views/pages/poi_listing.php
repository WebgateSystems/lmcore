<?php
$json = file_get_contents("data/pages/poi.json");
$poi = json_decode($json, true);
?>

<div id="sc-page-wrapper" class="uk-flex uk-flex-column uk-height-1-1">
	<div id="sc-page-top-bar" class="sc-top-bar">
		<div class="sc-top-bar-content uk-flex uk-flex-1">
			<h1 class="sc-top-bar-title uk-text-uppercase uk-flex-1">Tourist Attractions in Rome</h1>
			<div class="<?php rtlReplace('uk-margin-left', 'uk-margin-right'); ?> uk-visible@m">
				<a href="#" class="sc-button sc-button-icon sc-button-secondary sc-button-small"><i class="mdi mdi-plus sc-icon-18"></i> Add POI</a>
			</div>
		</div>
	</div>
	<div id="sc-page-wrapper-inner" class="uk-flex">
		<div id="sc-page-aside" class="md-bg-white">
			<div class="sc-page-aside-body sc-padding-medium">
				<ul class="uk-list uk-list-divider sc-list-clickable sc-js-poi-list">
<?php foreach($poi as $key => $value) { ?>
					<li data-poi-id="<?php echo $value['id']; ?>" class="uk-flex-column sc-flex-items-left">
						<?php if ( isset( $value['main'] ) ) { ?>
							<span class="sc-text-semibold md-color-red-600"><?php echo $value['title']; ?></span>
						<?php } else { ?>
							<p class="sc-text-semibold uk-margin-remove uk-text-truncate" title="<?php echo $value['title']; ?>"><?php echo $value['title']; ?></p>
							<p class="sc-color-secondary uk-text-truncate uk-margin-remove" title="<?php echo $value['address']; ?>"><?php echo $value['address']; ?></p>
						<?php } ?>
					</li>
<?php }; ?>
				</ul>
			</div>
		</div>
		<div id="sc-page-content" class="sc-padding-remove">
			<div id="sc-js-poi-map" class="uk-height-1-1"></div>
		</div>
	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar">
        <ul class="uk-list uk-list-divider sc-list-clickable sc-js-poi-list">
		    <?php foreach($poi as $key => $value) { ?>
                <li data-poi-id="<?php echo $value['id']; ?>" class="uk-flex-column sc-flex-items-left">
				    <?php if ( isset( $value['main'] ) ) { ?>
                        <span class="sc-text-semibold md-color-red-600"><?php echo $value['title']; ?></span>
				    <?php } else { ?>
                        <p class="sc-text-semibold uk-margin-remove uk-text-truncate" title="<?php echo $value['title']; ?>"><?php echo $value['title']; ?></p>
                        <p class="sc-color-secondary uk-text-truncate uk-margin-remove" title="<?php echo $value['address']; ?>"><?php echo $value['address']; ?></p>
				    <?php } ?>
                </li>
		    <?php }; ?>
        </ul>
    </div>
</div>
