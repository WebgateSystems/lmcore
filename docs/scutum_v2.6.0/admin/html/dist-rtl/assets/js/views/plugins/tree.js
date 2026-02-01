scutum.plugins.tree = {};
scutum.plugins.tree.init = function () {
	scutum.require(['fancytree'], function () {
		// single selection
		scutum.plugins.tree.singleSelection();
		// multiple selection
		scutum.plugins.tree.multipleSelection();
		// multiple selection
		scutum.plugins.tree.dnd();
		// table
		scutum.plugins.tree.table();
	});
};
scutum.plugins.tree.multipleSelection = function () {
	$("#sc-tree-multiple-selection").fancytree({
		extensions: ["glyph"],
		checkbox: true,
		selectMode: 3,
		debugLevel: 0,
		glyph: {
			preset: 'material',
			// assets/js/vendor/jquery.fancytree.glyphMap.js
			map: scutum.fancytree.glyphMap
		},
		source: {url: "data/pages/tree_ajax_products.json", debugDelay: 1000},
		lazyLoad: function (event, data) {
			data.result = {url: "data/pages/tree_ajax_sub2.json", debugDelay: 1000};
		},
		init: function(event, data){
			if(scutum.helpers.isRTL()) {
				$(this).find(".fancytree-container").attr("DIR", "RTL").addClass("fancytree-rtl");
			}
		}
	});
};
scutum.plugins.tree.singleSelection = function () {
	$("#sc-tree-single-selection").fancytree({
		extensions: ["glyph"],
		checkbox: "radio",
		selectMode: 1,
		debugLevel: 0,
		glyph: {
			preset: 'material',
			// assets/js/vendor/jquery.fancytree.glyphMap.js
			map: scutum.fancytree.glyphMap
		},
		source: [
			{
				title: "n1",
				expanded: true,
				checkbox: "radio",
				radiogroup: true,
				children: [
					{
						title: "n1.1"
					},
					{
						title: "n1.2 (selected)",
						selected: true
					},
					{
						title: "n1.3"
					}
				]
			},
			{
				title: "n2",
				expanded: true,
				checkbox: "radio",
				radiogroup: true,
				children: [
					{
						title: "n2.1"
					},
					{
						title: "n2.2"
					},
					{
						title: "n2.3"
					}
				]
			},
			{
				title: "n3",
				expanded: true,
				checkbox: "radio",
				radiogroup: true,
				children: [
					{
						title: "n3.1"
					},
					{
						title: "n3.2"
					},
					{
						title: "n3.3"
					},
					{
						title: "n3.4"
					}
				]
			}
		],
		init: function(event, data){
			if(scutum.helpers.isRTL()) {
				$(this).find(".fancytree-container").attr("DIR", "RTL").addClass("fancytree-rtl");
			}
		}
	});
};
scutum.plugins.tree.dnd = function () {
	$("#sc-tree-dnd").fancytree({
		extensions: ["glyph", "dnd5"],
		debugLevel: 0,
		glyph: {
			preset: 'material',
			// assets/js/vendor/jquery.fancytree.glyphMap.js
			map: scutum.fancytree.glyphMap
		},
		source: {
			url: "data/pages/tree_ajax_fs.json"
		},
		dnd5: {
			dragStart: function (node, data) {
				return true;
			},
			dragDrag: function (node, data) {
				data.dataTransfer.dropEffect = "move";
			},
			dragEnd: function (node, data) {
			},
			dragEnter: function (node, data) {
				data.dataTransfer.dropEffect = "move";
				return true;
			},
			dragOver: function (node, data) {
				data.dataTransfer.dropEffect = "move";
			},
			dragLeave: function (node, data) {
			},
			dragDrop: function (node, data) {
				var transfer = data.dataTransfer;
				node.debug("drop", data);
				if (data.otherNode) {
					data.otherNode.moveTo(node, data.hitMode);
				} else if (data.otherNodeData) {
					node.addChild(data.otherNodeData, data.hitMode);
				} else {
					node.addNode({
						title: transfer.getData("text")
					}, data.hitMode);
				}
				node.setExpanded();
			}
		},
		init: function(event, data){
			if(scutum.helpers.isRTL()) {
				$(this).find(".fancytree-container").attr("DIR", "RTL").addClass("fancytree-rtl");
			}
		}
	});
};
scutum.plugins.tree.table = function () {
	var $tree = $("#sc-tree-table");
	// toggle items
	$("#sc-tree-check-all")
		.on('ifUnchecked', function () {
			$tree.fancytree("getTree").visit(function (node) {
				node.setSelected(false);
			});
		})
		.on('ifChecked', function () {
			$tree.fancytree("getTree").visit(function (node) {
				node.setSelected(true);
			});
		});
	// initialize tree
	$tree.fancytree({
		extensions: ["glyph", "table", "wide"],
		checkbox: true,
		selectMode: 3,
		glyph: {
			preset: "material",
			// assets/js/vendor/jquery.fancytree.glyphMap.js
			map: scutum.fancytree.glyphMap
		},
		table: {
			checkboxColumnIdx: 0,
			nodeColumnIdx: 1
		},
		source: {url: "data/pages/tree_ajax_books.json"},
		renderColumns: function (event, data) {
			var node = data.node;
			var _data = node.data;
			var $tdList = $(node.tr).find(">td");

			$tdList.eq(2).text(_data.author);
			$tdList.eq(3).text(_data.year);
			$tdList.eq(4).text(_data.price ? _data.price.toFixed(2) : "");
		},
		init: function(event, data){
			if(scutum.helpers.isRTL()) {
				$(this).find(".fancytree-container").attr("DIR", "RTL").addClass("fancytree-rtl");
			}
		}
	});
};
