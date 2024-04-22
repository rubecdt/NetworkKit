//
//  URLSession.swift
//  
//
//  Created by rubecdt on 25/01/2025.
//

import Foundation

public extension URLSession {
	static func mock(
		using interface: URLProtocolMock.Type = URLProtocolMock.self,
		withConfiguration configuration: URLSessionConfiguration = .ephemeral,
		responder: any URLMockResponder
	) -> URLSession {
		configuration.protocolClasses = [interface]
		
		let sessionDelegate = MockSessionDelegate(responder: responder)
		
		return URLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: nil)
	}
}

public final class MockSessionDelegate: NSObject, URLSessionTaskDelegate {
	let responder: URLMockResponder
	
	init(responder: URLMockResponder) {
		self.responder = responder
	}
	
	// URLSessionTaskDelegate protocol method
	public func urlSession(
		_ session: URLSession,
		didCreateTask task: URLSessionTask
	) {
		RespondersStore.shared[task] = responder
	}
	
	// TODO: Consider methods for redirections, authentication, etc.
}

public func withMockedURLSession<Result>(
	using responder: URLMockResponder,
	returning: Result.Type = Result.self,
	operation: (URLSession) async throws -> Result
) async rethrows -> Result {
	let session = URLSession.mock(using: URLProtocolMock.self, responder: responder)
	// Execute test operation
	return try await operation(session)
	
	// Configuration cleaning managed automatically by RespondersStore on task references deletion.
	// TODO: Consider further cleanup
}
