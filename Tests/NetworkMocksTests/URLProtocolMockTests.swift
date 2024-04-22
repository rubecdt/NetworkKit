//
//  Test.swift
//  NetworkKit
//
//  Created by rubecdt on 19/02/2025.
//

import Testing
@testable import NetworkMocks
import Foundation

@MainActor
@Suite("URLProtocolMock")
struct URLProtocolMockTests {

    @Test("Request processed unchanged")
	func canonicalRquest() {
		let request = URLRequest.sample
		let protocolRequest = URLProtocolMock.canonicalRequest(for: request)
		#expect(request == protocolRequest)
	}
	
	@Test("Mock protocol processes all responses")
	func canInit() {
		let request = URLRequest.sample
		#expect(URLProtocolMock.canInit(with: request))
	}

	/// Creates an instance of `URLProtocolMock` configured with the given request, client, and task.
	private func createProtocolMock(
		with request: URLRequest,
		client: MockURLProtocolClient,
		task: MockURLSessionTask
	) -> URLProtocolMock {
		let protocolMock = URLProtocolMock(request: request, cachedResponse: nil, client: client)
		protocolMock.setValue(task, forKey: "task")
		return protocolMock
	}
	
	/// Verifies that if no responder is assigned to the task, a `URLError(.unsupportedURL)` error is reported.
	@Test("No responder provided")
	func testNoResponderProvided() async throws {
		let request = URLRequest.sample
		let client = MockURLProtocolClient()
		let mockTask = MockURLSessionTask()
		let protocolMock = createProtocolMock(with: request, client: client, task: mockTask)
		
		URLProtocolMock.respondersStore.removeConfig(for: mockTask)
		
		protocolMock.startLoading()
		
		try await Task.sleep(for: .seconds(0.1))
		
		#expect(client.receivedError != nil, "An error was expected when no responder is provided.")
		if let error = client.receivedError as? URLError {
			#expect(error.code == .unsupportedURL)
		} else {
			Issue.record("The received error is not a `URLError`.")
			return
		}
		#expect(client.didFinishLoadingCalled, "Load completion should be notified.")
	}
	
	/// Verifies that given a successful responder, the correct data and response are returned.
	@Test("Success Response")
	func testSuccessResponse() async throws {
		let request = URLRequest(url: .sample.appending(path: "success"))
		let client = MockURLProtocolClient()
		let mockTask = MockURLSessionTask()
		let protocolMock = createProtocolMock(with: request, client: client, task: mockTask)
		
		let data = "Hello".data(using: .utf8)!
		let response = URLResponse(url: request.url!, mimeType: "text/plain", expectedContentLength: data.count, textEncodingName: "utf-8")
		let urlDataResponse = URLDataResponse(data: data, response: response)
		let responder = URLStaticMockResponder.succeeding(with: urlDataResponse)
		
		URLProtocolMock.respondersStore.setConfig(responder, for: mockTask)
		
		protocolMock.startLoading()
		
		try await Task.sleep(for: .seconds(0.15))
		
		#expect(client.receivedError == nil, "Unexpected error received in response.")
		#expect(client.receivedResponse != nil, "A response was expected but none was provided.")
		#expect(client.receivedData == data, "Received data does not match the expected one.")
		#expect(client.didFinishLoadingCalled, "Load completion was not notified.")
	}
	
	/// Verifies that when using a failing responder, the corresponding error is reported.
	@Test("Failure Response")
	func testFailureResponse() async throws {
		let request = URLRequest(url: .sample.appending(path: "error"))
		let client = MockURLProtocolClient()
		let mockTask = MockURLSessionTask()
		let protocolMock = createProtocolMock(with: request, client: client, task: mockTask)
		
		let testError = NSError(domain: "TestError", code: 123)
		let responder = URLStaticMockResponder.failing(with: testError)
		
		URLProtocolMock.respondersStore.setConfig(responder, for: mockTask)
		
		protocolMock.startLoading()
		
		try await Task.sleep(for: .seconds(0.15))
		
		#expect(client.receivedError != nil, "An error was expected.")
		let nsError = client.receivedError as NSError?
		#expect(nsError?.code == testError.code, "The error code must match the expected one.")
		#expect(client.didFinishLoadingCalled, "Load completion should be notified.")
	}
}



fileprivate final class MockRespondersStore: RespondersStore, @unchecked Sendable {
	fileprivate static let testsSingleton = MockRespondersStore()
}

fileprivate final class MockProtocol: URLProtocolMock, @unchecked Sendable {
	fileprivate override class var respondersStore: RespondersStore { MockRespondersStore.testsSingleton }
}

// MARK: - Mocks

fileprivate final class MockURLProtocolClient: NSObject, URLProtocolClient, @unchecked Sendable {
	
	var receivedResponse: URLResponse?
	var receivedData: Data?
	var receivedError: Error?
	var didFinishLoadingCalled = false

	func urlProtocol(_ protocol: URLProtocol, didReceive response: URLResponse, cacheStoragePolicy policy: URLCache.StoragePolicy) {
		receivedResponse = response
	}

	func urlProtocol(_ protocol: URLProtocol, didLoad data: Data) {
		receivedData = (receivedData ?? Data()) + data
	}

	func urlProtocolDidFinishLoading(_ protocol: URLProtocol) {
		didFinishLoadingCalled = true
	}

	func urlProtocol(_ protocol: URLProtocol, didFailWithError error: Error) {
		receivedError = error
	}
}

@available(*, unavailable, message: "Not necessary for testing")
extension MockURLProtocolClient {
	func urlProtocol(_ protocol: URLProtocol, wasRedirectedTo request: URLRequest, redirectResponse: URLResponse) {}
	
	func urlProtocol(_ protocol: URLProtocol, cachedResponseIsValid cachedResponse: CachedURLResponse) {}
	
	func urlProtocol(_ protocol: URLProtocol, didReceive challenge: URLAuthenticationChallenge) {}
	
	func urlProtocol(_ protocol: URLProtocol, didCancel challenge: URLAuthenticationChallenge) {}
}
