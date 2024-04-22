//
//  MockURLSession.swift
//  NetworkKit
//
//  Created by rubecdt on 24/01/2025.
//

import Foundation
import Testing
@testable import NetworkKit
import NetworkMocks

fileprivate extension HTTPURLResponse {
	static let succesful = HTTPURLResponse(
		url: .sample, statusCode: 200)!
	static let failing = HTTPURLResponse(
		url: .sample, statusCode: 200)!
}

fileprivate typealias SessionCoalescer = URLSessionCoalescer<URLRequest.ExtendedHashing>

@Suite("URLSessionCoalescer")
struct URLSessionCoalescerTests {
	
	@Test
	func testPerformRequestSuccess() async throws {
		let request = URLRequest.sample
		let expectedData = Data("Test response".utf8)
		
		let responder: URLDynamicMockResponder = [
			.sample: .success((expectedData, HTTPURLResponse.succesful))
		]
		
		try await withMockedURLSession(using: responder) { session in
			let handler = SessionCoalescer(session: session)
			let data = try await handler.fetch(for: request)
			
			#expect(data == expectedData, "Returned data must match the expected mock data")
		}
	}
	
	// Test to verify ongoing request reuse
	@Test
	func testPerformRequestCaching() async throws {
		let request = URLRequest.sample
		let expectedData = Data("Test response".utf8)
		
		let responder: URLDynamicMockResponder = [
			.sample: .success((expectedData, HTTPURLResponse.succesful))
		]
		
		try await withMockedURLSession(using: responder) { mockSession in
			let handler = SessionCoalescer(session: mockSession)
			
			async let firstCall = handler.fetch(for: request)
			async let secondCall = handler.fetch(for: request)
			
			let (firstData, secondData) = try await (firstCall, secondCall)
			#expect(firstData == expectedData, "First call should return the expected data")
			#expect(secondData == expectedData, "Second call should return the expected data")
		}
	}
	
	// Test to verify error handling in requests
	@Test
	func testPerformRequestFailure() async throws {
		let request = URLRequest.sample
		
		let injectedError: URLError = URLError(.notConnectedToInternet)
		
		let responder: URLDynamicMockResponder = [
			.sample: .failure(injectedError)
		]
		
		await withMockedURLSession(using: responder) { session in
			let handler = SessionCoalescer(session: session)
			await #expect("Thrown error should match the injected error") {
				try await handler.fetch(for: request)
			} `throws`: { error in
				guard let error = error as? NetworkError,
					  case .general(let innerError) = error,
					  let urlError = innerError as? URLError
				else {
					return false
				}
				return injectedError.code == urlError.code
			}
		}
	}
	
	// Test to verify the cancellation of all ongoing requests
	@Test
	func testCancelAllRequests() async throws {
		let request = URLRequest.sample
		let expectedData = Data("Test response".utf8)
		
		let responder = URLDynamicMockResponder(responses: [
				.sample: .success((expectedData, HTTPURLResponse.succesful))
			],
			simulatedLatency: 0.5)
		
		try await withMockedURLSession(using: responder) { mockSession in
			let handler = SessionCoalescer(session: mockSession)
			
			let firstCall = Task {
				try await handler.fetch(for: request)
			}
			let secondCall = Task {
				try await handler.fetch(for: request)
			}
			
			try await Task.sleep(for: .milliseconds(150))
			await handler.cancelAllRequests()
			
			await #expect(throws: NetworkError.self, "Expected the first request to be cancelled", performing: {
				try await firstCall.value
			})
			await #expect(throws: NetworkError.self, "Expected the second request to be cancelled", performing: {
				try await secondCall.value
			})
		}
	}
}
