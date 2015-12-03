/*global MapSwift, describe, beforeEach, jasmine, it, expect*/
describe('MapSwift.WebKitViewProxy', function () {
	'use strict';
	var underTest,
		messageSenders,
		components,
		protocol;
	beforeEach(function () {
		components = {
			component1: jasmine.createSpyObj('component1', ['foo']),
			component2: jasmine.createSpyObj('component1', ['bar'])
		};
		messageSenders = {
			component1: jasmine.createSpyObj('component1', ['postMessage']),
			component2: jasmine.createSpyObj('component1', ['postMessage'])
		};
		protocol = jasmine.createSpyObj('protocol', ['componentIdForCommand', 'errorResponse', 'applyCommandToComponent', 'message']);
		underTest = new MapSwift.WebKitViewProxy(messageSenders, protocol);
	});
	describe('sendFromSwift', function () {
		beforeEach(function () {
			underTest.proxyComponent(components.component1, 'component1');
			underTest.proxyComponent(components.component2, 'component2');
			protocol.errorResponse.and.returnValue('Uh oh');
			protocol.applyCommandToComponent.and.returnValue('AOK');
		});
		it('should pass the command to the correct component', function () {
			protocol.componentIdForCommand.and.returnValue('component2');
			expect(underTest.sendFromSwift({foo: 'bar'})).toEqual('AOK');
			expect(protocol.applyCommandToComponent).toHaveBeenCalledWith({foo: 'bar'}, components.component2);
		});
		it('should return an error response if no component found', function () {
			protocol.componentIdForCommand.and.returnValue('component3');
			expect(underTest.sendFromSwift({foo: 'bar'})).toEqual('Uh oh');
		});
	});
});
