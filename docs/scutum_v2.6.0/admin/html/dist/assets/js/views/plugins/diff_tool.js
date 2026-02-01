var $panelA = $('#sc-diff-panel-a');
var $panelB = $('#sc-diff-panel-b');
var $result = $('#sc-diff-result');
scutum.plugins.diffTool = {};
scutum.plugins.diffTool.init = function () {
	scutum.require(['diff-tool'], function () {
		$panelA.on('change', function () {
			scutum.plugins.diffTool.compare();
		});
		$panelB.on('change', function () {
			scutum.plugins.diffTool.compare();
		});
		$("input[name='sc-diff']").on('ifChecked', function () {
			scutum.plugins.diffTool.compare($(this).val());
		});
		// initial compare
		scutum.plugins.diffTool.compare();
		// update textareas
		autosize.update($('.sc-js-autosize'));
	});
};
scutum.plugins.diffTool.compare = function (type) {
	var panelA_val = $panelA.val();
	var panelB_val = $panelB.val();
	var	diff = Diff[type || 'diffLines'](panelA_val, panelB_val);

	$result.html('');

	diff.forEach(function (part) {
		var color = part.added ? 'md-bg-light-green-100' : part.removed ? 'md-bg-red-50 sc-text-line-through' : '';
		var span = $('<span/>');
		span.addClass(color)
			.text(part.value);
		$result.append(span);
	});
};
