/*global window, console*/
var MapSwift = MapSwift || {};

window.onload = function () {
	'use strict';
	try {
		if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.proxy) {
			window.webkit.messageHandlers.proxy.postMessage('page-loaded');
		}
		MapSwift.editorMain({messageHandlerNames: ['pingModel']});
	} catch (e) {
		console.log(e);
	}
};

/* ios_insert_here */
