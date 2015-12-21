/*global MapSwift, window, MAPJS */

MapSwift.editorMain = function () {
	'use strict';
	var containerProtocol = new MapSwift.WebKitProtocol(),
		containerProxy = new MapSwift.WebKitViewProxy(containerProtocol),
		pingModel = new MapSwift.PingModel(),
		mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []);

	containerProxy.proxyComponent(pingModel, 'pingModel').withEvents('ping');
	containerProxy.proxyComponent(mapModel, 'mapModel').withEvents('layoutChangeStarting', 'layoutChangeComplete');
	window.components = {
		containerProxy: containerProxy,
		pingModel: pingModel,
		mapModel: mapModel
	};

	MapSwift.proxyMessageSender.postStatusMessage('map-swift-main-complete');
};

(function () {
	'use strict';
	MapSwift.proxyMessageSender.postStatusMessage('map-swift-lib-loaded');
})();

MapSwift.log('MapSwift Libraries loaded', 'Call MapSwift.editorMain(); to start MapSwift');
/*
MapSwift.editorMain();
components.containerProxy.sendFromSwift({componentId: 'pingModel', selector: 'echo', args: ['hello']})
components.pingModel.stop()
*/
