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
window.onerror = function (msg, url, line, col, error) {
	'use strict';
	var message = JSON.stringify(['error', msg, url, line, col, error]);
	if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers['map-swift-proxy']) {
		window.webkit.messageHandlers['map-swift-proxy'].postMessage(message);
	}
};
