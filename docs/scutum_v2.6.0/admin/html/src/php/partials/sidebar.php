<aside id="sc-sidebar-main" class="sc-sidebar-info-fixed">
    <div class="uk-offcanvas-bar">
	    <div class="sc-sidebar-main-scrollable" data-sc-scrollbar="visible-y">
	        <ul class="sc-sidebar-menu uk-nav">
	        <?php
	        $json_data = file_get_contents('./data/sidebar_menu.json');
	        $pages = json_decode($json_data, true);
	        foreach ($pages as $item) { echo PHP_EOL;
	        ?>
	            <?php if (isset($item['section_title'])) { echo PHP_EOL; ?>
	                <li class="sc-sidebar-menu-heading"><span><?php echo $item['section_title']; ?></span></li>
	                <?php echo PHP_EOL; ?>
	            <?php } else { ?>
	            <li<?php if ($page == $item['url']) { echo ' class="sc-page-active"'; }; ?> title="<?php echo $item['title']; ?>">
	                <a href="<?php if (!isset($item['submenu'])) { echo $item['dir'] . '-' .$item['url'] . '.html'; } else { echo '#'; } ?>">
	                    <?php if(isset($item['icon'])) { ?>
	                        <span class="uk-nav-icon"><i class="<?php echo $item['icon']; ?>"></i>
	                    <?php }; echo PHP_EOL; ?>
	                    </span><span class="uk-nav-title"><?php echo $item['title']; ?></span>
	                </a>
	                <?php if (isset($item['submenu'])) { echo PHP_EOL; ?>
	                    <ul class="sc-sidebar-menu-sub">
	                    <?php foreach ($item['submenu'] as $submenu_item) { ?>
	                        <?php if (isset($submenu_item['items'])) { ?>
	                            <?php if (isset($submenu_item['section_title'])) { ?>
	                                <li class="sc-sidebar-menu-heading"><span><?php echo $submenu_item['section_title']; ?></span></li>
	                                <?php foreach ($submenu_item['items'] as $section_item) { ?>
	                                    <li<?php if (isset($section_item['page']) && $page == $section_item['page']) { echo ' class="sc-page-active"'; }; ?>>
	                                    <?php if(isset($submenu_item['dir']) && isset($submenu_item['subdir'])) { ?>
	                                        <a href="<?php echo $submenu_item['dir'] . '_' . $submenu_item['subdir'] . '-' . $section_item['page']; ?>.html"><?php if(isset($section_item['icon'])) { ?><i class="<?php echo $section_item['icon']; ?>"></i><?php }; ?>
		                                        <?php if (isset($section_item['tag'])) { ?>
			                                        <span class="uk-label"><?php echo $section_item['tag'];?></span>
		                                        <?php } ?>
		                                        <?php echo $section_item['title']; ?>
	                                        </a>
	                                    <?php } else if(isset($submenu_item['dir'])) { ?>
	                                        <a href="<?php echo $submenu_item['dir'] . '-' . $section_item['page']; ?>.html"><?php if(isset($section_item['icon'])) { ?><i class="<?php echo $section_item['icon']; ?>"></i><?php }; ?>
		                                        <?php if (isset($section_item['tag'])) { ?>
			                                        <span class="uk-label"><?php echo $section_item['tag'];?></span>
		                                        <?php } ?>
		                                        <?php echo $section_item['title']; ?>
	                                        </a>
	                                    <?php } else { ?>
	                                        <a href="<?php echo $section_item['page']; ?>.html"><?php if(isset($section_item['icon'])) { ?><i class="<?php echo $section_item['icon']; ?>"></i><?php }; ?>
		                                        <?php if (isset($section_item['tag'])) { ?>
			                                        <span class="uk-label"><?php echo $section_item['tag'];?></span>
		                                        <?php } ?>
		                                        <?php echo $section_item['title']; ?>
	                                        </a>
	                                    <?php }; ?>
	                                    </li>
	                                <?php }; echo PHP_EOL; ?>
	                            <?php } else { ?>
	                                <li>
	                                    <?php if (isset($submenu_item['title'])) { ?><a href="#"><?php echo $submenu_item['title'];?></a><?php }; ?>
	                                    <ul>
	                                    <?php foreach ($submenu_item['items'] as $section_item) { ?>
	                                        <li<?php if (isset($section_item['page']) && $page == $section_item['page']) { echo ' class="sc-page-active"'; }; ?>>
	                                            <a href="<?php echo $submenu_item['dir'] . '_' . $submenu_item['subdir'] . '-'. $section_item['page']; ?>.html"><?php if(isset($submenu_item['icon'])) { ?><i class="<?php echo $submenu_item['icon']; ?>"></i><?php }; ?>
		                                            <?php if (isset($section_item['tag'])) { ?>
			                                            <span class="uk-label"><?php echo $section_item['tag'];?></span>
								                    <?php } ?>
		                                            <?php echo $section_item['title']; ?>
	                                            </a>
	                                        </li>
	                                    <?php }; echo PHP_EOL; ?>
	                                    </ul>
	                                </li>
	                            <?php };echo PHP_EOL; ?>
	                        <?php } else { echo PHP_EOL; ?>
	                        <li<?php if ($page == $submenu_item['page']) { echo ' class="sc-page-active"'; }; ?>>
	                            <?php if(isset($submenu_item['dir'])) { echo PHP_EOL; ?>
	                                <a href="<?php echo $submenu_item['dir'] . '-' . $submenu_item['page']; ?>.html"><?php if(isset($submenu_item['icon'])) { ?><i class="<?php echo $submenu_item['icon']; ?>"></i><?php }; ?>
		                                <?php if (isset($submenu_item['tag'])) { ?>
			                                <span class="uk-label"><?php echo $submenu_item['tag'];?></span>
		                                <?php } ?>
		                                <?php echo $submenu_item['title']; ?>
	                                </a>
	                            <?php } else { echo PHP_EOL; ?>
	                                <a href="<?php echo $submenu_item['page']; ?>.html"><?php if(isset($submenu_item['icon'])) { ?><i class="<?php echo $submenu_item['icon']; ?>"></i><?php }; ?>
		                                <?php if (isset($submenu_item['tag'])) { ?>
			                                <span class="uk-label"><?php echo $submenu_item['tag'];?></span>
		                                <?php } ?>
		                                <?php echo $submenu_item['title']; ?>
	                                </a>
	                            <?php };echo PHP_EOL; ?>
	                        </li>
	                        <?php };echo PHP_EOL; ?>
	                        <?php if(isset($submenu_item['separator'])) { ?>
	                            <li class="sc-sidebar-menu-separator"></li>
	                        <?php };echo PHP_EOL; ?>
	                    <?php };echo PHP_EOL; ?>
	                    </ul>
	                <?php }; ?>
	            </li>
	            <?php }; ?>
	        <?php }; ?>
	            <li title="Multi-level">
	                <a href="#">
	                    <span class="uk-nav-icon"><i class="mdi mdi-format-line-weight"></i></span><span class="uk-nav-title">Multi level</span>
	                </a>
	                <ul class="sc-sidebar-menu-sub">
	                    <li><a href="#">Submenu 1</a></li>
	                    <li class="sc-js-submenu-trigger sc-has-submenu">
	                        <a href="#">Submenu 2</a>
	                        <ul>
	                            <li><a href="#">Submenu 2.1</a></li>
	                            <li>
	                                <a href="#">Submenu 2.2</a>
	                                <ul>
	                                    <li><a href="#">Submenu 2.2.1</a></li>
	                                    <li><a href="#">Submenu 2.2.2</a></li>
	                                    <li><a href="#">Submenu 2.2.3</a></li>
	                                </ul>
	                            </li>
	                            <li><a href="#">Submenu 2.3</a></li>
	                            <li><a href="#">Submenu 2.4</a></li>
	                        </ul>
	                    </li>
	                    <li><a href="#">Submenu 3</a></li>
	                    <li>
	                        <a href="#">Submenu 4</a>
	                        <ul>
	                            <li>
	                                <a href="#">Submenu 4.1</a>
	                                <ul>
	                                    <li><a href="#">Submenu 4.1.1</a></li>
	                                    <li><a href="#">Submenu 4.1.2</a></li>
	                                    <li><a href="#">Submenu 4.1.3</a></li>
	                                </ul>
	                            </li>
	                            <li><a href="#">Submenu 4.2</a></li>
	                            <li><a href="#">Submenu 4.3</a></li>
	                        </ul>
	                    </li>
	                </ul>
	            </li>
	        </ul>

	    </div>
        <div class="sc-sidebar-info">
            version: <?php echo $app_info['version']; echo PHP_EOL; ?>
        </div>
    </div>
</aside>
