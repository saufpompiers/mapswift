/*global MapSwift*/
MapSwift.WebKitViewComponentProxy = function (identifier, component, protocol, messageSender) {
	'use strict';
	var self = this;

	self.sendToSwift = function () {
		var callArgs = Array.prototype.slice.call(arguments, 0),
			message = protocol.message(identifier, callArgs);
		messageSender.postMessage(message);
	};
	self.sentFromSwift = function (command) {
		return protocol.applyCommandToComponent(command, component);
	};
	self.withEvents = function () {
		var events = Array.prototype.slice.call(arguments, 0);
		events.forEach(function (eventName) {
			component.removeEventListener(eventName, self.sendToSwift);
			component.addEventListener(eventName, self.sendToSwift);
		});
		return self;
	};
};
