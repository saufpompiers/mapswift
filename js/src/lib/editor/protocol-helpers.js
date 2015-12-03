/*global MapSwift*/
MapSwift.ProtocolHelpers = (function () {
	'use strict';
	var self = {},
		nextId = 0;
	self.resetCounters = function () {
		nextId = 0;
	};
	self.wkProxyErrorResponse = function (command, error) {
		if (command) {
			return {completed: false, id: command.id, componentId: command.componentId, errors: [error]};
		} else {
			return {completed: false, errors: ['no-command', error]};
		}
	};
	self.wkProxyResponse = function (command, result) {
		return {
			completed: true,
			id: command.id,
			componentId: command.componentId,
			selector: command.selector,
			result: self.jsonSafe(result)};
	};
	self.jsonSafe = function (obj) {
		return JSON.parse(JSON.stringify(obj));
	};
	self.nextMessageId = function () {
		return ++nextId;
	};
	return self;
}());
