/*global MapSwift, window, console */

MapSwift.ConsoleMessageHandlers = function (listenerNames) {
	'use strict';
	var self = this;
	listenerNames.forEach(function (listenerName) {
		self[listenerName] = {
			postMessage: function (message) {
				console.log('postMessage', listenerName, message);
			}
		};
	});
};
MapSwift.editorMain = function (config) {
	'use strict';
	var containerProtocol = new MapSwift.WebKitProtocol(),
		messageHandlers = (window.webkit && window.webkit.messageHandlers) || new MapSwift.ConsoleMessageHandlers(config.messageHandlerNames),
		containerProxy = new MapSwift.WebKitViewProxy(messageHandlers, containerProtocol),
		pingModel = new MapSwift.PingModel();

	window.containerProxies = {
		pingModel: containerProxy.proxyComponent(pingModel, 'pingModel').withEvents('ping')
	};

	window.components = {
		pingModel: pingModel
	};
};
/*
MapSwift.editorMain({messageHandlerNames:['pingModel']})
containerProxies.pingModel.sentFromSwift({componentId: 'pingModel', selector: 'echo', args: ['hello']})

*/
