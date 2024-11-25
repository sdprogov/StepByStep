//
//  MockURLProtocol.swift
//  StepByStep
//
//  Created by Stefan Progovac on 11/24/24.
//

import Foundation

/// `MockURLProtocol` stubs a `URLRequest`with a mock response
class MockURLProtocol: URLProtocol {
	static var mockResponses: [URL: Data] = [:]

	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}

	override func startLoading() {
		guard let url = request.url, let data = MockURLProtocol.mockResponses[url] else {
			return
		}

		let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		client?.urlProtocol(self, didLoad: data)
		client?.urlProtocolDidFinishLoading(self)
	}

	override func stopLoading() {
		// Handle any cleanup if necessary
	}
}

