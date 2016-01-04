/*global window, console, MapSwift*/
window.addEventListener('load', function () {
	'use strict';
	try {
		MapSwift.proxyMessageSender.postStatusMessage('map-swift-page-loaded');
	} catch (e) {
		console.log(e);
	}
});
window.onerror = function (msg, url, line, col, error) {
	'use strict';
	try {
		MapSwift.proxyMessageSender.postErrorMessage(msg, url, line, col, error);
	} catch (e) {
		console.log(e);
	}
};
