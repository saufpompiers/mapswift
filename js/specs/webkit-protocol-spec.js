/*global MapSwift, describe, it, expect, beforeEach, jasmine*/

describe('MapSwift.WebKitProtocol', function () {
	'use strict';
	var underTest,
		component;
	beforeEach(function () {
		underTest = new MapSwift.WebKitProtocol();
		component = jasmine.createSpyObj('component', ['foo', 'bar']);
	});
	describe('errorResponse', function () {
		it('should return error', function () {
			expect(underTest.errorResponse({id: 1, componentId: 'mapmodel'}, 'reason')).toEqual({completed: false, id: 1, componentId: 'mapmodel', errors: ['reason']});
		});
		it('should return error when there is no command', function () {
			expect(underTest.errorResponse(undefined, 'reason')).toEqual({completed: false, errors: ['no-command', 'reason']});
		});

	});
	describe('applyCommandToComponent', function () {
		beforeEach(function () {
			component.foo.and.returnValue({foo: 'bar'});
		});
		it('should call the correct function on the component, passing the arguments', function () {
			underTest.applyCommandToComponent({id: 1, componentId: 'mapmodel', selector: 'bar', args: ['an', 'argument', 'list']}, component);
			expect(component.bar).toHaveBeenCalledWith('an', 'argument', 'list');
			expect(component.foo).not.toHaveBeenCalled();
		});
		it('should call the correct function on the component, passing no arguments', function () {
			underTest.applyCommandToComponent({id: 1, componentId: 'mapmodel', selector: 'bar', args: []}, component);
			expect(component.bar).toHaveBeenCalledWith();
		});
		it('should call the correct function on the component, passing undefined arguments', function () {
			underTest.applyCommandToComponent({id: 1, componentId: 'mapmodel', selector: 'bar'}, component);
			expect(component.bar).toHaveBeenCalledWith();
		});
		it('should call the correct function on the component, passing an object argument', function () {
			underTest.applyCommandToComponent({id: 1, componentId: 'mapmodel', selector: 'bar', args: ['an', {object: true}]}, component);
			expect(component.bar).toHaveBeenCalledWith('an', {object: true});
		});
		it('should return a response', function () {
			var command = {id: 1, componentId: 'mapmodel', selector: 'foo', args: ['one']},
				response = underTest.applyCommandToComponent(command, component);

			expect(response).toEqual({completed: true, id: 1, componentId: 'mapmodel', selector: 'foo', result: {foo: 'bar'}});
		});
		it('should return a response from a nil return value', function () {
			var response = underTest.applyCommandToComponent({id: 1, componentId: 'mapmodel', selector: 'bar', args: ['an', 'argument', 'list']}, component);

			expect(response).toEqual({completed: true, id: 1, componentId: 'mapmodel', selector: 'bar', result: false});
		});

	});
	describe('message', function () {
		it('should return a message object', function () {
			expect(underTest.message('comp', 'eventName1', ['1', 2, true, {foo: 'bar'}])).toEqual({componentId: 'comp', id: 1, eventName: 'eventName1', args: ['1', 2, true, {foo: 'bar'}]});
		});
		it('should increment a the call id', function () {
			expect(underTest.message('comp', 'ev', ['1'])).toEqual({componentId: 'comp', id: 1, eventName: 'ev', args: ['1']});
			expect(underTest.message('comp', 'ev', ['1'])).toEqual({componentId: 'comp', id: 2, eventName: 'ev', args: ['1']});
			expect(underTest.message('comp', 'ev', ['1'])).toEqual({componentId: 'comp', id: 3, eventName: 'ev', args: ['1']});
			expect(underTest.message('comp', 'ev', ['1'])).toEqual({componentId: 'comp', id: 4, eventName: 'ev', args: ['1']});
		});
	});
	describe('componentIdForCommand', function () {
		it('should return the componentId if the command contains it', function () {
			expect(underTest.componentIdForCommand({componentId: 'comp', id: 1, args: ['1']})).toEqual('comp');
		});
		it('should be falsy if command is undefined', function () {
			expect(underTest.componentIdForCommand()).toBeFalsy();
		});
		it('should be falsy if command invalid', function () {
			expect(underTest.componentIdForCommand('foo')).toBeFalsy();
		});
		it('should be falsy if command has no commandId', function () {
			expect(underTest.componentIdForCommand({name: 'foo'})).toBeFalsy();
		});
	});
});
