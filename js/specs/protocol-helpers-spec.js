/*global MapSwift, describe, it, expect, beforeEach*/

describe('MapSwift.ProtocolHelpers', function () {
	'use strict';
	beforeEach(function () {
		MapSwift.ProtocolHelpers.resetCounters();
	});
	describe('jsonSafe', function () {

		it('should return a simple object', function () {
			var obj = {'foo': 'bar'};
			expect(MapSwift.ProtocolHelpers.jsonSafe(obj)).toEqual({'foo': 'bar'});
		});
		it('should remove any functions', function () {
			var obj = {'foo': 'bar', 'funcId': function () {}};
			expect(MapSwift.ProtocolHelpers.jsonSafe(obj)).toEqual({'foo': 'bar'});

		});
		it('should return arrays', function () {
			var obj = ['foo', 'bar', 1, true, false];
			expect(MapSwift.ProtocolHelpers.jsonSafe(obj)).toEqual(['foo', 'bar', 1, true, false]);
		});
		it('should return strings', function () {
			var obj = 'foo';
			expect(MapSwift.ProtocolHelpers.jsonSafe(obj)).toEqual('foo');
		});
		it('should return integers', function () {
			var obj = 1;
			expect(MapSwift.ProtocolHelpers.jsonSafe(obj)).toEqual(1);
		});
	});
	describe('wkProxyErrorResponse', function () {
		it('should return error', function () {
			expect(MapSwift.ProtocolHelpers.wkProxyErrorResponse({id: 1, componentId: 'mapmodel'}, 'reason')).toEqual({completed: false, id: 1, componentId: 'mapmodel', errors: ['reason']});
		});
		it('should return error when there is no command', function () {
			expect(MapSwift.ProtocolHelpers.wkProxyErrorResponse(undefined, 'reason')).toEqual({completed: false, errors: ['no-command', 'reason']});
		});

	});
	describe('wkProxyResponse', function () {
		it('should return a response', function () {
			expect(MapSwift.ProtocolHelpers.wkProxyResponse({id: 1, componentId: 'mapmodel', selector: 'addNode'}, {foo: 'bar'})).toEqual({completed: true, id: 1, componentId: 'mapmodel', selector: 'addNode', result: {foo: 'bar'}});
		});

	});
});
