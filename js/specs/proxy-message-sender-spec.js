/*global describe, MapSwift, beforeEach, afterEach, window, jasmine, spyOn, expect, it*/
describe('MapSwift.ProxyMessageSender', function () {
	'use strict';
	var underTest,
		webkitOri;
	beforeEach(function () {
		webkitOri = window.webkit;
		window.webkit = {
			messageHandlers: {
				'my-listener': jasmine.createSpyObj('my-listener', ['postMessage']),
				'map-swift-proxy': jasmine.createSpyObj('map-swift-proxy', ['postMessage'])
			}
		};
		spyOn(window.console, 'log').and.callThrough();
		underTest = new MapSwift.ProxyMessageSender('my-listener');
	});
	afterEach(function () {
		window.webkit = webkitOri;
	});
	describe('postMessage', function () {
		it('should use webkit to post message if available', function () {
			underTest.postMessage('hello');
			expect(window.webkit.messageHandlers['my-listener'].postMessage).toHaveBeenCalledWith('hello');
		});
		it('should use map-swift-proxy to send error message if webkit is available but no listener is defined', function () {
			delete window.webkit.messageHandlers['my-listener'];
			underTest.postMessage('hello');
			expect(window.webkit.messageHandlers['map-swift-proxy'].postMessage).toHaveBeenCalledWith(jasmine.objectContaining({eventName: 'error', args: ['no-listener', 'my-listener', 'hello']}));
		});
		it('should use console to log message if webkit.messageHandlers is not available', function () {
			window.webkit.messageHandlers = undefined;
			underTest.postMessage('hello');
			expect(window.console.log).toHaveBeenCalledWith('postMessage', 'my-listener', 'hello');
		});
		it('should use console to log message if webkit is not available', function () {
			window.webkit = undefined;
			underTest.postMessage('hello');
			expect(window.console.log).toHaveBeenCalledWith('postMessage', 'my-listener', 'hello');
		});
	});
	['Status', 'Error', 'Log'].forEach(function (messageType) {
		var messageTypeLower = messageType.toLocaleLowerCase(),
			selector = 'post' + messageType + 'Message';
		describe('post' + messageType +  'Message', function () {
			it('should create a ' + messageTypeLower + ' message to post', function () {
				underTest[selector]('hello', 'there');
				expect(window.webkit.messageHandlers['my-listener'].postMessage).toHaveBeenCalledWith({
					eventName: messageTypeLower,
					id: 1,
					componentId: 'my-listener',
					args: ['hello', 'there']
				});
			});
			it('should increment the message id', function () {
				underTest[selector]('hello', 'there');
				underTest[selector]('goodbye', 'there');
				expect(window.webkit.messageHandlers['my-listener'].postMessage).toHaveBeenCalledWith({
					eventName: messageTypeLower,
					id: 2,
					componentId: 'my-listener',
					args: ['goodbye', 'there']
				});
			});
		});

	});
});
