<?php
$json = file_get_contents("data/pages/invoices.json");
$invoices = json_decode($json, true);
?>
<div id="sc-page-wrapper">
	<div id="sc-page-content" class="uk-height-1-1 uk-flex uk-flex-center sc-page-over-header">
		<div class="uk-width-5-6@m uk-height-1-1">
			<div class="uk-card uk-height-1-1">
				<div class="uk-grid-divider uk-grid-collapse uk-height-1-1" data-uk-grid>
					<div class="uk-width-expand@l uk-height-1-1" id="sc-js-invoice">
						<h5 class="uk-flex uk-flex-middle md-color-grey-500 uk-height-1-1 uk-flex-center">Open invoice from the list.</h5>
					</div>
					<div class="uk-width-1-4@m uk-height-1-1 sc-js-column uk-visible@l">
						<div class="uk-flex uk-flex-column uk-height-1-1" id="sc-js-invoices-list">
							<div class="uk-card-header md-bg-grey-200">
								<div class="uk-flex uk-flex-middle uk-flex-center">
									<div class="sc-js-el-hide <?php rtlReplace('uk-margin-medium-right', 'uk-margin-medium-left'); ?> uk-flex-1">
										<input type="text" class="uk-input sc-js-list-search sc-js-search uk-form-small" placeholder="Find invoice...">
									</div>
									<div>
										<a href="#" class="sc-actions-icon mdi mdi-arrow-collapse-horizontal sc-js-el-hide sc-js-column-collapse" data-uk-tooltip title="Hide list"></a>
										<a href="#" class="sc-actions-icon mdi mdi-receipt sc-js-el-show sc-js-column-expand" data-uk-tooltip title="Show list"></a>
									</div>
								</div>
							</div>
							<hr class="uk-margin-remove">
							<div class="uk-card-body sc-js-el-hide uk-flex-1" data-sc-scrollbar="visible-y">
								<ul class="uk-list uk-list-divider sc-list-clickable">
<?php foreach ($invoices as $key => $value) { ?>
									<li data-invoice-id="<?php echo $value['id']; ?>">
										<div class="uk-flex-1 uk-text-truncate">
											<span class="sc-text-semibold sc-js-list-number"><?php echo $value['number']; ?> <?php if($value['currency'] == 'EUR') {?><span class="md-color-light-blue-500">(<?php echo $value['currency']; ?>)</span><?php };?></span>
											<p class="uk-margin-remove sc-list-secondary-text sc-js-list-company"><span class="uk-text-muted uk-text-small">To:</span> <?php echo $value['to_company']; ?></p>
											<p class="uk-margin-remove sc-list-secondary-text"><span class="uk-text-muted uk-text-small">Date:</span> <?php echo $value['date']; ?></p>
										</div>
<?php if($key == '3' || $key == '11' || $key == '17') {;?>
										<span class="uk-label md-bg-red-500 sc-flex-no-shrink <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Unpaid</span>
<?php }; ?>
									</li>
<?php }; ?>
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="sc-fab-page-wrapper">
		<a href="pages-invoice_create.html" class="sc-fab sc-fab-large sc-fab-primary"><i class="mdi mdi-plus"></i></a>
	</div>
</div>
<div id="sc-offcanvas" data-uk-offcanvas="flip: true">
    <div class="uk-offcanvas-bar">
        <ul class="uk-list uk-list-divider sc-list-clickable">
		    <?php foreach ($invoices as $key => $value) { PHP_EOL; ?>
                <li data-invoice-id="<?php echo $value['id']; ?>">
                    <div class="uk-flex-1 uk-text-truncate">
                        <span class="sc-text-semibold sc-js-list-number"><?php echo $value['number']; ?> <?php if($value['currency'] == 'EUR') {?><span class="md-color-light-blue-500">(<?php echo $value['currency']; ?>)</span><?php };?></span>
                        <p class="uk-margin-remove sc-list-secondary-text sc-js-list-company"><span class="uk-text-muted uk-text-small">To:</span> <?php echo $value['to_company']; ?></p>
                        <p class="uk-margin-remove sc-list-secondary-text"><span class="uk-text-muted uk-text-small">Date:</span> <?php echo $value['date']; ?></p>
                    </div>
				    <?php if($key == '3' || $key == '11' || $key == '17') {;?>
                        <span class="uk-label md-bg-red-500 sc-flex-no-shrink <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Unpaid</span>
				    <?php }; PHP_EOL; ?>
                </li>
		    <?php }; PHP_EOL; ?>
        </ul>
    </div>
</div>
