function isRTL () {
	var dir = document.getElementsByTagName("html")[0].getAttribute("dir");
	return dir === 'rtl'
}

scutum.fancytree = {};
scutum.fancytree.glyphMap = {
	_addClass: "mdi",
	checkbox: "mdi-checkbox-blank-outline",
	checkboxSelected: "mdi-checkbox-marked",
	checkboxUnknown: "mdi-minus-box",
	dragHelper: "mdi-play",
	dropMarker: "mdi-arrow-right",
	error: "mdi-alert-outline md-color-red-500",
	expanderClosed: isRTL () ? "mdi-chevron-left" : "mdi-chevron-right",
	expanderLazy: isRTL () ? "mdi-chevron-double-left" : "mdi-chevron-double-right",
	expanderOpen: "mdi-chevron-down",
	loading: "mdi-loading mdi-spin",
	nodata: "mdi-emoticon-neutral",
	noExpander: "",
	radio: "mdi-radiobox-blank",
	radioSelected: "mdi-radiobox-marked",
	radioUnknown: "mdi-radiobox-marked md-color-grey-500",
	// Default node icons.
	// (Use tree.options.icon callback to define custom icons based on node data)
	doc: "mdi-file-outline",
	docOpen: "mdi-file-document-outline",
	folder: "mdi-folder",
	folderOpen: "mdi-folder-open"
};
