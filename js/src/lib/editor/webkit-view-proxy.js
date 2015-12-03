/*global MapSwift*/
MapSwift.WebKitViewProxy = function (messageSenders, protocol) {
	'use strict';
	var self = this,
		componentProxies = {};
	self.forComponent = function (component, identifier) {
		var proxy = componentProxies[identifier],
			messageSender = messageSenders && messageSenders[identifier];
		if (!messageSenders) {
			throw 'no-sender:' + identifier;
		}
		if (!proxy) {
			proxy = new MapSwift.WebKitViewComponentProxy(identifier, component, protocol, messageSender);
			componentProxies[identifier] = component;
		}
		return proxy;
	};
	self.sendFromSwift = function (command) {
		var componentProxy = command && componentProxies[command.componentId];
		if (componentProxy) {
			return componentProxy.sentFromSwift(command);
		} else {
			return MapSwift.ProtocolHelpers.wkProxyErrorResponse(command, 'no-component-for-id');
		}
	};

};

