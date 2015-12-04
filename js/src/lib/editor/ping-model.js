/*global MapSwift*/
MapSwift.PingModel = function () {
	'use strict';
	var self = this;

	self.echo = function (identifier) {
		return {identifier: identifier, received: new Date().getTime()};
	};
};
