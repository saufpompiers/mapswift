/*global window, console*/
window.onload = function () {
	'use strict';
	try {
		if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers['map-swift-proxy']) {
			window.webkit.messageHandlers['map-swift-proxy'].postMessage('map-swift-page-loaded');
		}
	} catch (e) {
		console.log(e);
	}
};
