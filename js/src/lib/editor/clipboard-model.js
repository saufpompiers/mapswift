/*global MapSwift, _ */

MapSwift.ClipboardModel = function (storage, key, alertModel, resourceManager) {
	'use strict';
	var self = this,
			deepClone = function (objectToClone) {
				return JSON.parse(JSON.stringify(objectToClone));
			},
			processResources = function (object, predicate) {
				var result;
				if (!object) {
					return object;
				}
				if (_.isArray(object)) {
					return _.map(object, function (item) {
						return processResources(item, predicate);
					});
				}
				result = deepClone(object);
				if (object.attr && object.attr.icon && object.attr.icon.url) {
					result.attr.icon.url = predicate(object.attr.icon.url);
				}
				if (object.ideas) {
					result.ideas = {};
					_.each(object.ideas, function (v, k) {
						result.ideas[k] = processResources(v, predicate);
					});
				}
				return result;
			};
	self.get = function (skipResourceTranslation) {
		if (skipResourceTranslation) {
			return storage.getItem(key);
		}
		return processResources(storage.getItem(key), resourceManager.storeResource);
	};
	self.put = function (c) {
		try {
			storage.setItem(key, processResources(c, resourceManager.getResource));
		} catch (e) {
			alertModel.send('error', 'clipboard', 'insufficient-space');
		}
	};
};
