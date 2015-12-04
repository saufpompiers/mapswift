/*global MapSwift, window */

MapSwift.editorMain = function (/*config*/) {
	'use strict';
	var pingModel = new MapSwift.PingModel();

	window.components = {
		pingModel: pingModel
	};
	// var clipboard = new MapSwift.ClipboardModel();
};
