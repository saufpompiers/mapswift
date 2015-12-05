/*global MapSwift, describe, beforeEach, jasmine, it, expect, observable*/
describe('MapSwift.WebKitViewComponentProxy', function () {
	'use strict';
	var underTest,
		component,
		protocol,
		messageSender;
	beforeEach(function () {
		component = jasmine.createSpyObj('component', ['doIt']);
		protocol = jasmine.createSpyObj('protocol', ['message', 'applyCommandToComponent']);
		messageSender = jasmine.createSpyObj('messageSender', ['postMessage']);
		underTest = new MapSwift.WebKitViewComponentProxy('componentIdentifier', component, protocol, messageSender);
	});
	describe('sendToSwift', function () {
		beforeEach(function () {
			protocol.message.and.returnValue('hello world!');
		});
		it('should pass the arguments to the protocol to build the message', function () {
			underTest.sendToSwift('good', 'golly', 1, true, {foo: 'bar'});
			expect(protocol.message).toHaveBeenCalledWith('componentIdentifier', ['good', 'golly', 1, true, {foo: 'bar'}]);
		});
		it('should pass empty arguments array to the protocol to build the message if none supplied', function () {
			underTest.sendToSwift();
			expect(protocol.message).toHaveBeenCalledWith('componentIdentifier', []);
		});
		it('should send the message to the messageSender', function () {
			underTest.sendToSwift();
			expect(messageSender.postMessage).toHaveBeenCalledWith('hello world!');
		});
	});
	describe('sentFromSwift', function () {
		it('should apply the command to the compoonent using the protocol', function () {
			underTest.sentFromSwift({name: 'command'});
			expect(protocol.applyCommandToComponent).toHaveBeenCalledWith({name: 'command'}, component);
		});
	});
	describe('withEvents', function () {
		beforeEach(function () {
			observable(component);

		});
		it('should return the proxy', function () {
			expect(underTest.withEvents('foo')).toBe(underTest);
		});
		it('should sent a message when the event is fired', function () {
			underTest.withEvents('foo');
			protocol.message.and.returnValue('hiya!');
			component.dispatchEvent('foo', 'there', 'is');
			expect(protocol.message).toHaveBeenCalledWith('componentIdentifier', ['there', 'is']);
			expect(messageSender.postMessage).toHaveBeenCalledWith('hiya!');
		});
	});
});
