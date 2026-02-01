<?php
$photos = [
	'ray-hennessy-763310-unsplash', 'daria-kopylova-766667-unsplash', 'casey-horner-768005-unsplash', 'urban-sanden-768851-unsplash', 'steve-roe-763192-unsplash',
	'wynand-van-poortvliet-761831-unsplash', 'rodion-kutsaev-760882-unsplash', 'san-fermin-pamplona-navarra-768251-unsplash', 'shane-young-768821-unsplash',
	'avantgarde-concept-763896-unsplash', 'eiliv-aceron-765897-unsplash', 'pietro-mattia-764559-unsplash', 'rachel-park-366508-unsplash',
	'alex-guillaume-769172-unsplash', 'ciaran-o-brien-769402-unsplash', 'paula-brustur-766878-unsplash', 'briana-tozour-756151-unsplash'
];
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">

		<div class="uk-child-width-1-2@s uk-child-width-1-3@l uk-child-width-1-4@xl uk-grid-medium uk-position-relative" data-uk-lightbox="animation: scale" id="sc-gallery-grid">
<?php foreach ($photos as $value) { ?>
			<div>
				<div class="uk-card">
					<div class="uk-card-body sc-padding-remove" >
						<a href="assets/img/photos/<?php echo $value; ?>.jpg" class="uk-display-block" data-caption="<?php echo $faker->sentence(6); ?>">
							<img src="assets/img/photos/<?php echo $value; ?>_md.jpg" class="sc-round-top uk-width-1-1" alt="">
						</a>
						<div class="sc-padding-medium">
							<div class="uk-flex uk-flex-middle">
								<div class="uk-flex-1">
									<p class="uk-margin-remove sc-text-semibold"><?php echo $faker->sentence(6); ?></p>
								</div>
								<div class="sc-flex-no-shrink <?php rtlReplace('uk-margin-left', 'uk-margin-right'); ?>">
									<i class="mdi mdi-heart-outline md-color-red-600"></i>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
<?php }; ?>
		</div>

	</div>
</div>
