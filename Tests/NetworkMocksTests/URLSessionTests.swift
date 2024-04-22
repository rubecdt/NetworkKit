//
//  Test.swift
//  NetworkKit
//
//  Created by rubecdt on 19/02/2025.
//

import Testing
@testable import NetworkMocks
import Foundation

@Suite("URLSession utilities")
struct URLSessionTests {
	
	@Test("withMockedURLSession(using:returning:operation:) return")
	func withMockedURLSessionResult() async throws {
		let dummyData = Data("dummy".utf8)
		let dummyURL = URL.sample
		let dummyResponse = HTTPURLResponse(url: dummyURL, statusCode: 200)!
		let dummyURLDataResponse = URLDataResponse(data: dummyData, response: dummyResponse)
		let responder = URLStaticMockResponder.succeeding(with: dummyURLDataResponse)
		
		let result = await withMockedURLSession(using: responder) { session in
			// Optionally, we could inspect session.configuration.protocolClasses here.
			// For simplicity, we return a simple value.
			return "Operation Completed"
		}
		
		#expect(result == "Operation Completed", "withMockedURLSession should return the operation result.")
	}
	
	@Test("withMockedURLSession(using:returning:operation:) - Mocked Session usage")
	func withMockedURLSessionMockUsage() async throws {
		let dummyData = Data("dummy".utf8)
		let dummyURL = URL.sample
		let dummyResponse = HTTPURLResponse(url: dummyURL, statusCode: 200)!
		let dummyURLDataResponse = URLDataResponse(data: dummyData, response: dummyResponse)
		let responder = URLStaticMockResponder.succeeding(with: dummyURLDataResponse)
		
		let (data, response) = try await withMockedURLSession(using: responder) { session in
			try await session.data(from: dummyURL)
		}
		
		#expect(data == dummyData)
		let httpResponse = try #require(response as? HTTPURLResponse)
		#expect(httpResponse.url == dummyResponse.url)
		#expect(httpResponse.statusCode == dummyResponse.statusCode)
	}
	
	@Test("mock(using:forConfiguration:responder:)")
	func mock() async throws {
		// Create a dummy responder.
		let dummyData = Data("dummy".utf8)
		let dummyURL = URL.sample
		let dummyResponse = HTTPURLResponse(url: dummyURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
		let dummyURLDataResponse = URLDataResponse(data: dummyData, response: dummyResponse)
		let responder = URLStaticMockResponder.succeeding(with: dummyURLDataResponse)
		
		// Create a session using the mock() factory method.
		let session = URLSession.mock(using: URLProtocolMock.self, responder: responder)
		
		// Verify that the session configuration includes the URLProtocolMock class.
		if let protocolClasses = session.configuration.protocolClasses,
		   protocolClasses.contains(where: { $0 == URLProtocolMock.self }) {
			#expect(true, "Session configuration contains URLProtocolMock.")
		} else {
			Issue.record("URLProtocolMock not found in session configuration.")
		}
	}
}

@Suite("Mock Delegate")
struct MockSessionDelegateTests {
	
	struct Responder: URLMockResponder {
		let id = UUID()
		func response(for request: URLRequest) -> Result<NetworkMocks.URLDataResponse, any Error>? {
			let response = HTTPURLResponse(url: .sample, statusCode: 200)!
			return .success((Data(), response))
		}
	}
	
	@Test
	func urlSession() async throws {
		let delegate = MockSessionDelegate(responder: Responder())
		delegate.urlSession(URLSession.shared, didCreateTask: URLSessionTask())
				
		// Use a mock URLSessionTask. (Assuming MockURLSessionTask is defined in your test utilities.)
		let task = MockURLSessionTask()
		delegate.urlSession(URLSession.shared, didCreateTask: task)
				
		// Check that the responder was registered for this task.
		let storedResponder = RespondersStore.shared.config(for: task)
		#expect(storedResponder != nil, "Responder should be registered in RespondersStore.")
	}
	
	@Test
	func instanceCreation() async throws {
		let responder = Responder()
		let delegate = MockSessionDelegate(responder: responder)
		
		let extractedResponder = try #require(
			delegate.responder as? Self.Responder
		)
		#expect(extractedResponder.id == responder.id)
	}
}
