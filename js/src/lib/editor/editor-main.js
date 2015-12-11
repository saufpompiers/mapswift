/*global MapSwift, window */

MapSwift.editorMain = function () {
	'use strict';
	var containerProtocol = new MapSwift.WebKitProtocol(),
		containerProxy = new MapSwift.WebKitViewProxy(containerProtocol),
		pingModel = new MapSwift.PingModel();

	containerProxy.proxyComponent(pingModel, 'pingModel').withEvents('ping');

	window.components = {
		containerProxy: containerProxy,
		pingModel: pingModel
	};

	MapSwift.proxyMessageSender.postStatusMessage('map-swift-main-complete');
};

(function () {
	'use strict';
	MapSwift.proxyMessageSender.postStatusMessage('map-swift-lib-loaded');
})();


/*
MapSwift.editorMain();
components.containerProxy.sendFromSwift({componentId: 'pingModel', selector: 'echo', args: ['hello']})
components.pingModel.stop()
*/
