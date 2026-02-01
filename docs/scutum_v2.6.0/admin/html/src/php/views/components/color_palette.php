<?php
$color_variant = [
	'50','100','200','300','400','500','600','700','800','900','a100','a200','a400','a700'
];
$color_array = [
	array('red',array('1','2','3','4','11')),
	array('pink',array('1','2','3','11')),
	array('purple',array('1','2','3','11')),
	array('deep-purple',array('1','2','3','11')),
	array('indigo',array('1','2','3','11')),
	array('blue',array('1','2','3','4','5','11')),
	array('light-blue',array('1','2','3','4','5','6','11','12','13')),
	array('cyan',array('1','2','3','4','5','6','7','11','12','13','14')),
	array('teal',array('1','2','3','4','5','11','12','13','14')),
	array('green',array('1','2','3','4','5','6','11','12','13','14')),
	array('light-green',array('1','2','3','4','5','6','7','11','12','13','14')),
	array('lime',array('1','2','3','4','5','6','7','8','9','11','12','13','14')),
	array('yellow',array('1','2','3','4','5','6','7','8','9','10','11','12','13','14')),
	array('amber',array('1','2','3','4','5','6','7','8','9','10','11','12','13','14')),
	array('orange',array('1','2','3','4','5','6','7','8','11','12','13','14')),
	array('deep-orange',array('1','2','3','4','5','11','12')),
	array('brown',array('1','2','3'),10),
	array('grey',array('1','2','3','4','5','6'),10),
	array('blue-grey',array('1','2','3','4'),10)
];
$colors_length = count($color_array);
$variants_length_accent = count($color_variant);
$variants_length_no_accent = count($color_variant)-4;
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div data-uk-grid>
			<?php for($i=0;$i<$colors_length;$i++) { ?>
				<div class="uk-width-1-4@l uk-width-1-3@m uk-width-1-2@s">
					<div class="uk-card">
						<div class="uk-card-body">
							<h5><?php echo $color_array[$i][0]; ?></h5>
							<?php if($i<16) { $variants_length = $variants_length_accent; } else { $variants_length = $variants_length_no_accent; } ?>
							<?php for($j=0;$j<$variants_length;$j++) { ?>
								<div class="md-bg-<?php echo $color_array[$i][0].'-'.$color_variant[$j]; if(!in_array($j+1,$color_array[$i][1])) echo ' md-color-white' ?>" style="padding:12px 8px;"><small>.md-bg-<?php echo $color_array[$i][0].'-'.$color_variant[$j]?></small>
									<br><small>.md-color-<?php echo $color_array[$i][0].'-'.$color_variant[$j]?></small></div>
							<?php } ?>
						</div>
					</div>
				</div>
			<?php } ?>
		</div>
	</div>
</div>
