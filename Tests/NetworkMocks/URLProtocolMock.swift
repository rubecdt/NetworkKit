//
//  URLProtocolMock.swift
//  NetworkKit
//
//  Created by rubecdt on 29/01/2025.
//

import Foundation

// `@unchecked Sendable` here could be not fully secure,
//	given that URLProtocol was opted out of that conformance,
//	but it is the only way found to achieve the latency simulation.
public class URLProtocolMock: URLProtocol, @unchecked Sendable {
	class var respondersStore: RespondersStore { .shared }
	
	public override class func canInit(
		with request: URLRequest
	) -> Bool {
		return true
	}
	
	public override class func canonicalRequest(
		for request: URLRequest
	) -> URLRequest {
		return request
	}
	
	/// Notifies the client that the loading process has finished.
	/// - Parameter client: The `URLProtocolClient` to be notified.
	func notifyLoadCompletion(
		to client: (any URLProtocolClient)?
	) {
		client?.urlProtocolDidFinishLoading(self)
	}
	
	/// Forwards the received response to the client.
	/// - Parameters:
	///   - response: The `URLResponse` object to be forwarded.
	///   - client: The `URLProtocolClient` that will receive the response.
	func forward(
		_ response: URLResponse,
		to client: (any URLProtocolClient)?
	) {
		client?.urlProtocol(
			self,
			didReceive: response,
			cacheStoragePolicy: .notAllowed
		)
	}
	
	/// Reports a failure to the client by passing an error.
	/// - Parameters:
	///   - failure: The `Error` describing the failure.
	///   - client: The `URLProtocolClient` that will receive the failure notification.
	func report(
		failure: Error,
		to client: (any URLProtocolClient)?
	) {
		client?.urlProtocol(self, didFailWithError: failure)
	}
	
	/// Delivers data to the client as part of the response.
 /// - Parameters:
 ///   - data: The `Data` object containing the response body.
 ///   - client: The `URLProtocolClient` that will receive the data.
	func deliver(
		_ responseData: Data,
		to client: (any URLProtocolClient)?
	) {
		client?.urlProtocol(self, didLoad: responseData)
	}
	
	public override func startLoading() {
		guard let task = self.task,
			  let responder = Self.respondersStore[task],
			  let result = responder.response(for: request) else {
			
			defer {
				notifyLoadCompletion(to: client)
			}
			report(failure: URLError(.unsupportedURL), to: client)
			return
		}
		let simulatedLatency: TimeInterval = responder.latency
		
		Task { @MainActor in
			try await Task.sleep(for: .seconds(simulatedLatency))
			defer {
				notifyLoadCompletion(to: client)
			}
			
			do {
				let (data, response) = try result.get()
				forward(response, to: client)
				deliver(data, to: client)
			} catch {
				report(failure: error, to: client)
			}
		}
	}
	
	public override func stopLoading() {}
}
