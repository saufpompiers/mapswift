/*global window, console*/
var MapSwift = MapSwift || {
	ProxyMessageSender: function (listenerName) {
		'use strict';
		var self = this,
			nextId = 0,
			nextMessageId = function () {
				return ++nextId;
			};
		self.postMessage = function (message) {
			if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers[listenerName]) {
				window.webkit.messageHandlers[listenerName].postMessage(message);
			} else if (window.webkit && window.webkit.messageHandlers && MapSwift.proxyMessageSender) {
				MapSwift.proxyMessageSender.postErrorMessage('no-listener', listenerName, message);
			} else {
				console.log('postMessage', listenerName, message);
			}
		};
		self.postStatusMessage = function () {
			var callArgs = Array.prototype.slice.call(arguments, 0),
				message = {id: nextMessageId(), eventName: 'status', componentId: listenerName, args: callArgs};

			self.postMessage(message);
		};
		self.postErrorMessage = function () {
			var callArgs = Array.prototype.slice.call(arguments, 0),
				message = {id: nextMessageId(), eventName: 'error', componentId: listenerName, args: callArgs};

			self.postMessage(message);
		};
	}
};

MapSwift.proxyMessageSender = new MapSwift.ProxyMessageSender('map-swift-proxy');

