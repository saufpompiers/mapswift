/*global MapSwift*/
MapSwift.WebKitViewProxy = function (protocol) {
	'use strict';
	var self = this,
		componentProxies = {};
	self.proxyComponent = function (component, identifier) {
		var proxy = componentProxies[identifier],
			messageSender = new MapSwift.ProxyMessageSender(identifier);

		if (!proxy) {
			proxy = new MapSwift.WebKitViewComponentProxy(identifier, component, protocol, messageSender);
			componentProxies[identifier] = proxy;
		} else {
			throw new Error(identifier + ' already-proxied');
		}
		return proxy;
	};
	self.forComponentIdentier = function (identifier) {
		return componentProxies[identifier];
	};
	self.sendFromSwift = function (command) {
		var identifier = protocol.componentIdForCommand(command),
			componentProxy = identifier && componentProxies[identifier];
		if (componentProxy) {
			return componentProxy.sentFromSwift(command);
		} else {
			return protocol.errorResponse(command, 'no-component-found');
		}
	};

};

