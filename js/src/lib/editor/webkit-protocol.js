/*global MapSwift, _*/
MapSwift.WebKitProtocol = function () {
	'use strict';
	var self = this,
		nextId = 0,
		nextMessageId = function () {
			return ++nextId;
		},
		jsonSafe = function (obj) {
			if (!obj) {
				return false;
			}
			return JSON.parse(JSON.stringify(obj));
		},
		commandResponse = function (command, result) {
			return {
				completed: true,
				id: command.id,
				componentId: command.componentId,
				selector: command.selector,
				result: jsonSafe(result)
			};
		};

	self.errorResponse = function (command, error) {
		if (command) {
			return {completed: false, id: command.id, componentId: command.componentId, errors: [error]};
		} else {
			return {completed: false, errors: ['no-command', error]};
		}
	};

	self.message = function (componentId, callArgs) {
		return _.extend({componentId: componentId}, { id: nextMessageId(), args: callArgs });
	};

	self.applyCommandToComponent = function (command, component) {
		var selector = command.selector,
			result;
		if (!selector) {
			return self.errorResponse(command, 'no-selector');
		}
		result = component[selector].apply(component, command.args);
		return commandResponse(command, result);
	};
};
