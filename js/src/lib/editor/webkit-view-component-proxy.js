/*global MapSwift*/
MapSwift.WebKitViewComponentProxy = function (identifier, component, protocol, messageSender) {
	'use strict';
	var self = this,
		eventListeners = {};

	self.sentFromSwift = function (command) {
		return protocol.applyCommandToComponent(command, component);
	};
	self.withEvents = function () {
		var events = Array.prototype.slice.call(arguments, 0);
		events.forEach(function (eventName) {
			var oldListener = eventListeners[eventName],
				eventListener = function () {
					var callArgs = Array.prototype.slice.call(arguments, 0),
						message = protocol.message(identifier, eventName, callArgs);
					messageSender.postMessage(message);
				};
			if (oldListener) {
				component.removeEventListener(eventName, oldListener);
			}
			component.addEventListener(eventName, eventListener);
			eventListeners[eventName] = eventListener;
		});
		return self;
	};
};
