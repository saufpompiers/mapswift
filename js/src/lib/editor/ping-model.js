/*global MapSwift, window, observable*/
MapSwift.PingModel = function () {
	'use strict';
	var self = observable(this),
		intervalId = false;

	self.echo = function (identifier) {
		return {identifier: identifier, received: new Date().getTime()};
	};

	self.start = function (identifier, interval) {
		var sendPing = function () {
				self.dispatchEvent('ping', identifier, new Date().getTime());
			};
		self.stop();
		interval = interval || 1000;
		identifier = identifier || 'ping';
		intervalId = window.setInterval(sendPing, interval);
		return self.echo(identifier);
	};
	self.stop = function () {
		if (intervalId) {
			window.clearInterval(intervalId);
			intervalId = false;
		}
		return true;
	};
};
