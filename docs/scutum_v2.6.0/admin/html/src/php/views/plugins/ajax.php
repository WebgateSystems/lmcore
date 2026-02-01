<div id="sc-page-wrapper">
	<div id="sc-page-content">
		<div data-uk-grid>
		    <div class="uk-width-1-3@l">
                <div class="uk-card">
                    <div class="uk-card-body">
                        <p class="sc-text-semibold uk-text-uppercase uk-heading-line"><span>Click To Edit</span></p>
                        <div id="sc-contact-edit" class="sc-ajax-slide"></div>
                        <script id="sc-contact-edit-form" type="text/x-handlebars-template">
                            <form data-ic-put-to="/contact/1" data-ic-target="#sc-contact-edit">
                                <div class="sc-round sc-border uk-margin sc-padding">
                                    <div class="uk-margin">
                                        <label>First Name</label>
                                        <input type="text" class="uk-input" name="firstName" value="{{ firstName }}" data-sc-input>
                                    </div>
                                    <div class="uk-margin">
                                        <label>Last Name</label>
                                        <input type="text" class="uk-input" name="lastName" value="{{ lastName }}" data-sc-input>
                                    </div>
                                    <div class="uk-margin">
                                        <label>Email address</label>
                                        <input type="email" class="uk-input" name="email" value="{{ email }}" data-sc-input>
                                    </div>
                                    <div class="uk-margin">
                                        <label>Company</label>
                                        <input type="text" class="uk-input" name="company" value="{{ company }}" data-sc-input>
                                    </div>
                                    <div class="uk-margin">
                                        {{#ifCond userActive '==' true}}
                                        <input type="checkbox" name="userActive" id="user-status" checked>
                                        {{else}}
                                        <input type="checkbox" name="userActive" id="user-status">
                                        {{/ifCond}}
                                        <label for="user-status" class="<?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">User active</label>
                                    </div>
                                </div>
                                <div class="uk-flex uk-flex-middle">
                                    <button class="sc-button sc-button-primary">Save</button>
                                    <button data-ic-get-from="/contact/1" data-ic-target="#sc-contact-edit" class="sc-button sc-button-flat-danger sc-button-flat <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>">Cancel </button>
                                    <span class="sc-spinner sc-spinner-small data-ic-indicator <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>" style="display: none"></span>
                                </div>
                            </form>
                        </script>
                        <script id="sc-contact-edit-template" type="text/x-handlebars-template">
                            <div class="sc-round sc-border uk-margin sc-padding">
                                <div class="uk-margin-small"><strong>First Name</strong>: {{ firstName }}</div>
                                <div class="uk-margin-small"><strong>Last Name</strong>: {{ lastName }}</div>
                                <div class="uk-margin-small"><strong>Email</strong>: {{ email }}</div>
                                <div class="uk-margin-small"><strong>Company</strong>: {{ company }}</div>
                                {{#ifCond userActive '==' true}}
                                <div><span class="uk-label uk-label-success">Active</span></div>
                                {{else}}
                                <div><span class="uk-label md-bg-grey-500">Inactive</span></div>
                                {{/ifCond}}
                            </div>
                            <div class="uk-margin uk-flex uk-flex-middle">
                                <button data-ic-target="#sc-contact-edit" data-ic-get-from="/contact/1/edit" class="sc-button sc-button-primary sc-button-flex uk-flex-middle">
                                    Edit User
                                </button>
                                <span class="sc-spinner sc-spinner-small data-ic-indicator <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>" style="display: none"></span>
                            </div>
                        </script>
                    </div>
                </div>
                <div class="uk-card uk-margin">
                    <div class="uk-card-body">
                        <p class="sc-text-semibold uk-text-uppercase uk-heading-line"><span>Lazy loading</span></p>
                        <div id="sc-lazy-load" class="sc-ajax-scale uk-text-center"></div>
                        <div class="uk-margin uk-flex uk-flex-middle">
                            <button data-ic-get-from="/lazy-load" data-ic-target="#sc-lazy-load" class="sc-button sc-button-primary">Load Random Image</button>
                            <span class="sc-spinner sc-spinner-small ic-indicator <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>" style="display: none"></span>
                        </div>
                    </div>
                </div>
                <div class="uk-card uk-margin">
                    <div class="uk-card-body">
                        <div class="uk-flex uk-flex-middle uk-margin-medium-bottom">
                            <div class="uk-flex-1">
                                <p class="sc-text-semibold uk-text-uppercase uk-heading-line uk-margin-remove sc-padding-small-ends"><span>Sortable List save order</span></p>
                            </div>
                            <div class="uk-flex uk-flex-middle">
                                <span class="sc-spinner sc-spinner-small <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>" id="sc-list-spinner" style="display: none"></span>
                            </div>
                        </div>
                        <form>
                            <div data-uk-sortable data-ic-put-to="/sortable-list" data-ic-trigger-on="stop" data-ic-indicator="#sc-list-spinner">
                                <div class="uk-margin-small sc-round">
                                    <div class="sc-padding-small md-bg-blue-50 md-color-blue-800 sc-round">
                                        1. Lorem ipsum dolor sit amet.
                                        <input type="hidden" name="sortable-list-items[]" value="item-1">
                                    </div>
                                </div>
                                <div class="uk-margin-small sc-round">
                                    <div class="sc-padding-small md-bg-blue-50 md-color-blue-800 sc-round">
                                        2. Lorem ipsum dolor sit amet.
                                        <input type="hidden" name="sortable-list-items[]" value="item-2">
                                    </div>
                                </div>
                                <div class="uk-margin-small sc-round">
                                    <div class="sc-padding-small md-bg-blue-50 md-color-blue-800 sc-round">
                                        3. Lorem ipsum dolor sit amet.
                                        <input type="hidden" name="sortable-list-items[]" value="item-3">
                                    </div>
                                </div>
                                <div class="uk-margin-small sc-round">
                                    <div class="sc-padding-small md-bg-blue-50 md-color-blue-800 sc-round">
                                        4. Lorem ipsum dolor sit amet.
                                        <input type="hidden" name="sortable-list-items[]" value="item-4">
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
		    <div class="uk-width-2-3@l">
                <div class="uk-card">
                    <div class="uk-card-body">
                        <p class="sc-text-semibold uk-text-uppercase uk-heading-line"><span>Deleting A Table Row</span></p>
                        <div class="uk-overflow-auto">
                            <table class="uk-table uk-table-striped">
                                <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Status</th>
                                    <th></th>
                                </tr>
                                </thead>
                                <tbody data-ic-target="closest tr" class="sc-ajax-slide-right uk-table-middle">
<?php $status = ['Active', 'Inactive'];?>
<?php for($i=0;$i<6;$i++) { ?>
                                    <tr id="row-<?php echo $i; ?>">
                                        <td class="uk-text-nowrap"><?php echo $faker->name; ?></td>
                                        <td><?php echo $faker->email; ?></td>
                                        <td><?php echo $status[array_rand($status)];?></td>
                                        <td class="uk-table-shrink">
                                            <div class="uk-flex uk-flex-middle">
                                                <a href="#" class="mdi mdi-trash-can-outline sc-icon-square sc-js-user-delete" data-ic-delete-from="/users/<?php echo $i; ?>" data-ic-trigger-on="confirmed-by-user"></a>
                                                <span class="sc-spinner sc-spinner-small ic-indicator <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>" style="display: none"></span>
                                            </div>
                                        </td>
                                    </tr>
<?php } ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="uk-card uk-margin">
                    <div class="uk-card-body">
                        <p class="sc-text-semibold uk-text-uppercase uk-heading-line"><span>Click To Load</span></p>
                        <div class="uk-overflow-auto">
                            <table class="uk-table uk-table-divider">
                                <thead>
                                <tr>
                                    <th class="uk-table-shrink"></th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Company</th>
                                    <th>SSN</th>
                                </tr>
                                </thead>
                                <tbody id="sc-table-load"></tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan="5">
                                            <div class="uk-flex uk-flex-middle">
                                                <button class="sc-button sc-button-primary" data-ic-get-from="/contacts/?page=2" data-ic-target="#sc-table-load">
                                                    Load More Users &hellip;
                                                </button>
                                                <span class="sc-spinner sc-spinner-small ic-indicator <?php rtlReplace('uk-margin-small-left', 'uk-margin-small-right'); ?>" style="display: none"></span>
                                            </div>
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                        <script id="sc-table-load-template" type="text/x-handlebars-template">
                            <tr>
                                <td>{{ key }}</td>
                                <td class="uk-text-nowrap">{{ name }}</td>
                                <td>{{ email }}</td>
                                <td class="uk-text-nowrap">{{ company }}</td>
                                <td class="uk-text-nowrap">{{ ssn }}</td>
                            </tr>
                        </script>
                    </div>
                </div>
            </div>
		</div>
	</div>
</div>
