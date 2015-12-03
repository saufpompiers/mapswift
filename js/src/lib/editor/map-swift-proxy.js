/*global MapSwift, observable, _*/
MapSwift.WebKitViewProxy = function (messageHandlers) {
	'use strict';
	var self = this,
		componentProxies = {};
	self.forComponent = function (component, identifier) {
		var proxy = componentProxies[identifier],
			wkMessageSender = messageHandlers && messageHandlers[identifier];
		if (!wkMessageSender) {
			throw 'no-sender:' + identifier;
		}
		if (!proxy) {
			proxy = new MapSwift.WebKitViewComponentProxy(identifier, component, wkMessageSender);
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

MapSwift.WebKitViewComponentProxy = function (identifier, component, wkMessageSender) {
	'use strict';
	var self = observable(this),
		baseArgs = {componentId: identifier},
		doSend = function (synchronised, callArgs) {
			var args = _.extend({}, baseArgs, { id: MapSwift.ProtocolHelpers.nextMessageId(), args: callArgs });

			wkMessageSender.postMessage(MapSwift.ProtocolHelpers.jsonSafe(args));
		};

	self.sendToSwift = function () {
		var callArgs = Array.prototype.slice.call(arguments, 0);
		doSend(false, callArgs);
	};
	self.sentFromSwift = function (command) {
		var selector = command.selector,
			result;
		if (!selector) {
			return MapSwift.wkProxyErrorResponse(command, 'no-selector');
		}
		result = component[selector].apply(component, command.args);
		return MapSwift.ProtocolHelpers.wkProxyResponse(command, result);
	};

};
