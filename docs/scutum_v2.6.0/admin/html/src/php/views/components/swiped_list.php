<div id="sc-page-wrapper">
    <div id="sc-page-content">

        <div class="uk-alert uk-alert-warning">Note: swiped list works only on touch devices.</div>

        <div class="uk-card">
            <p class="sc-padding-medium uk-margin-remove">Single swipe action</p>
            <ul class="list1 uk-list uk-list-divider uk-list-large swiped-list">
                <?php for ($i = 1; $i < 5; $i++) { ?>
                <li>
                    <div class="swiped-element uk-flex-important uk-flex-middle">
                        <i class="mdi mdi-arrow-left uk-margin-medium-right"></i>
                        <span>swipe to delete</span>
                    </div>
                </li>
                <?php } ?>
            </ul>
        </div>
        <div class="uk-card uk-margin-top">
            <p class="sc-padding-medium uk-margin-remove">Swipe right</p>
            <ul class="list2 uk-list uk-list-divider uk-list-large uk-margin-remove swiped-list swiped-left-3">
                <?php for ($i = 1; $i < 6; $i++) { ?>
                    <li>
                        <div class="actions actions-left" style="z-index: 10">
                            <a href="#"><i class="mdi mdi-thumb-up md-color-green-500"></i></a>
                            <a href="#"><i class="mdi mdi-thumb-down md-color-red-500"></i></a>
                            <a href="#"><i class="mdi mdi-emoticon-happy-outline md-color-red-500"></i></a>
                        </div>
                        <div class="swiped-element">
                            <span class="sc-text-semibold">
                                <?php echo $faker->firstName . ' '. $faker->lastName ?> (<?php echo $faker->email ?>)
                            </span>
                            <p class="uk-margin-remove">
                                <?php echo $faker->sentence(5); ?>
                            </p>
                        </div>
                    </li>
                <?php } ?>
            </ul>
        </div>
        <div class="uk-card uk-margin-top">
            <p class="sc-padding-medium uk-margin-remove">Swipe right/left</p>
            <ul class="list3 uk-list uk-list-large uk-list-divider swiped-list swiped-left-1 swiped-right-2">
                <?php for ($i = 1; $i < 6; $i++) { ?>
                    <li>
                        <div class="actions actions-left">
                            <a href="#"><i class="mdi mdi-thumb-up md-color-green-500"></i></a>
                        </div>
                        <div class="actions actions-right">
                            <a href="#"><i class="mdi mdi-delete md-color-red-500"></i></a>
                            <a href="#"><i class="mdi mdi-archive"></i></a>
                        </div>
                        <div class="swiped-element">
                            <span class="sc-text-semibold">
                                <?php echo $faker->firstName . ' '. $faker->lastName ?> (<?php echo $faker->email ?>)
                            </span>
                            <p class="uk-margin-remove">
                                <?php echo $faker->sentence(5); ?>
                            </p>
                        </div>
                    </li>
                <?php } ?>
            </ul>
        </div>

    </div>
</div>
