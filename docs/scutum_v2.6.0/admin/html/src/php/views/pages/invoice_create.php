<?php
$json = file_get_contents("data/pages/invoices.json");
$invoices = json_decode($json, true);
?>
<div id="sc-page-wrapper">
    <div id="sc-page-content" class="uk-height-1-1 uk-flex uk-flex-center sc-page-over-header">
        <div class="uk-width-5-6@m uk-height-1-1">
            <div class="uk-card uk-height-1-1">
                <div class="uk-grid-divider uk-grid-collapse uk-height-1-1" data-uk-grid>
                    <div class="uk-width-expand@l uk-height-1-1">
                        <div class="uk-flex uk-flex-column uk-height-1-1">
                            <div class="uk-card-body uk-flex-1">
                                <div class="uk-margin-medium-bottom sc-padding-left sc-padding-right">
                                    <p class="sc-text-semibold uk-margin-remove-bottom">Invoice number:</p>
                                    <input class="uk-input" id="f-invoice-number" type="text" placeholder="in format: xxx/xxxxxx/year" data-sc-input>
                                </div>
                                <div class="md-bg-grey-100 sc-padding">
                                    <div class="uk-grid" data-uk-grid>
                                        <div class="uk-width-1-3@l">
                                            <p class="sc-text-semibold">Issue date:</p>
                                            <input type="text" id="invoice-issueDate" class="uk-input" data-sc-input>
                                        </div>
                                        <div class="uk-width-2-3@l">
                                            <p class="sc-text-semibold">Due date:</p>
                                            <div class="uk-flex sc-padding-small-top">
                                                <span class="<?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?>">
                                                    <input type="radio" id="invoice-due-7" name="invoice-due-date" data-sc-icheck>
                                                    <label for="invoice-due-7">7 days</label>
                                                </span>
                                                <span class="<?php rtlReplace('uk-margin-right', 'uk-margin-left'); ?>">
                                                    <input type="radio" id="invoice-due-14" name="invoice-due-date" data-sc-icheck>
                                                    <label for="invoice-due-14">14 days</label>
                                                </span>
                                                <span>
                                                    <input type="radio" id="invoice-due-21" name="invoice-due-date" data-sc-icheck>
                                                    <label for="invoice-due-21">21 days</label>
                                                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="sc-padding">
                                    <div class="uk-child-width-1-2@s uk-grid-divider" data-uk-grid>
                                        <div>
                                            <p class="sc-text-semibold">From:</p>
                                            <div class="uk-margin-medium-bottom">
                                                <label class="uk-form-label" for="f-invoice-from-name">Company Name</label>
                                                <input class="uk-input" id="f-invoice-from-name" type="text" data-sc-input>
                                            </div>
                                            <div class="uk-margin-medium-bottom">
                                                <label class="uk-form-label" for="f-invoice-from-address1">Address 1</label>
                                                <input class="uk-input" id="f-invoice-from-address1" type="text" data-sc-input>
                                            </div>
                                            <div>
                                                <label class="uk-form-label" for="f-invoice-from-address2">Address 2</label>
                                                <input class="uk-input" id="f-invoice-from-address2" type="text" data-sc-input>
                                            </div>
                                        </div>
                                        <div>
                                            <p class="sc-text-semibold">To:</p>
                                            <div class="uk-margin-medium-bottom">
                                                <label class="uk-form-label" for="f-invoice-to-name">Company Name</label>
                                                <input class="uk-input" id="f-invoice-to-name" type="text" data-sc-input>
                                            </div>
                                            <div class="uk-margin-medium-bottom">
                                                <label class="uk-form-label" for="f-invoice-to-address1">Address 1</label>
                                                <input class="uk-input" id="f-invoice-to-address1" type="text" data-sc-input>
                                            </div>
                                            <div>
                                                <label class="uk-form-label" for="f-invoice-to-address2">Address 2</label>
                                                <input class="uk-input" id="f-invoice-to-address2" type="text" data-sc-input>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="sc-padding md-bg-grey-100">
                                    <p class="sc-text-semibold">Items:</p>
                                    <div id="invoice-items" data-sc-dynamic-fields="fields-template" data-sc-dynamic-fields-counter="1"></div>
                                    <script id="fields-template" type="text/x-handlebars-template">
                                        <div class="sc-form-section uk-margin-medium-top sc-padding-medium-top sc-border-top">
                                            <div class="uk-grid-match" data-uk-grid>
                                                <div class="uk-width-expand@m">
                                                    <div class="uk-flex-bottom uk-grid-small" data-uk-grid>
                                                        <div class="uk-width-2-5@l">
                                                            <label class="uk-label-small" for="f-invoice-item-{{index}}-description">Description</label>
                                                            <input class="uk-input" id="f-invoice-item-{{index}}-description" type="text" data-sc-input />
                                                        </div>
                                                        <div class="uk-width-1-5@l">
                                                            <label class="uk-label-small" for="f-invoice-item-{{index}}-quantity">Quantity</label>
                                                            <input class="uk-input sc-js-calculate-item" id="f-invoice-item-{{index}}-quantity" type="text" data-sc-input data-item="quantity">
                                                        </div>
                                                        <div class="uk-width-1-5@l">
                                                            <span class="uk-form-icon"><i class="mdi mdi-currency-usd"></i></span>
                                                            <label class="uk-label-small" for="f-invoice-item-{{index}}-rate">Rate</label>
                                                            <input class="uk-input sc-js-calculate-item" id="f-invoice-item-{{index}}-rate" type="text" data-sc-input data-item="rate">
                                                        </div>
                                                        <div class="uk-width-1-5@l">
                                                            <label class="uk-label-small" for="f-invoice-item-{{index}}-anount">Amount</label>
                                                            <input class="uk-input label-fixed" id="f-invoice-item-{{index}}-amount" type="text" data-sc-input disabled data-item="amount">
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="uk-width-auto@m uk-flex-middle">
                                                    <a href="#" class="sc-js-section-clone sc-button sc-button-icon sc-button-outline sc-button-default sc-button-outline-square"><i class="mdi mdi-plus sc-js-el-hide"></i><i class="mdi mdi-trash-can-outline sc-js-el-show md-color-red-600"></i></a>
                                                </div>
                                            </div>
                                        </div>
                                    </script>
                                </div>
                                <div class="sc-padding">
                                    <p class="sc-text-semibold">Notes:</p>
                                    <textarea class="uk-textarea" id="f-invoice-notes" type="text" placeholder="Notes - any relevant information not already covered" data-sc-input rows="3"></textarea>
                                </div>
                            </div>
                            <div class="sc-padding-medium-ends sc-padding sc-border-top">
                                <button class="sc-button sc-button-primary">Save Invoice</button>
                            </div>
                        </div>
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
                                <ul class="uk-list uk-list-divider">
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
</div>
