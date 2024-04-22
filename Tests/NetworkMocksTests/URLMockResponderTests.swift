//
//  URLMockResponderTests.swift
//  NetworkKit
//
//  Created by rubecdt on 19/02/2025.
//

import Testing
@testable import NetworkMocks
import Foundation

@Suite("URLMockResponder")
struct URLMockResponderTests {
	struct MockResponder: URLMockResponder {
		func response(
			for request: URLRequest
		) -> Result<URLDataResponse, any Error>? {
			nil
		}
	}
	
	@Test
	func testDefaultLatency() {
		struct MockResponder: URLMockResponder {
			func response(
				for request: URLRequest
			) -> Result<URLDataResponse, Error>? {
				nil
			}
		}
		
		let responder = MockResponder()
		#expect(responder.latency == 0, "Default `latency` should be zero.")
	}
	
	// MARK: URLStaticMockResponder factory methods
	
	@Test
	func staticResponderFactoryMethod() throws {
		let expectedData = Data([0x01, 0x02, 0x03])
		let expectedResponse = URLDataResponse(data: expectedData, response: URLResponse())
		let expectedResult: Result<URLDataResponse, Error> = .success(expectedResponse)
		
		let responder: URLMockResponder = .responding(expectedResult)
		
		let request = URLRequest.sample
		let actualResult = try #require(responder.response(for: request))
		
		switch (expectedResult, actualResult) {
		case (.success(let expected), .success(let actual)):
			#expect(expected.data == actual.data, "Response data must match.")
		case (.failure(let expectedError), .failure(let actualError)):
			#expect((expectedError as NSError).code == (actualError as NSError).code, "Error codes must match.")
		default:
			Issue.record("Returned response does not match expected result.")
		}
	}
	
	@Test
	func succedingStaticResponderFactoryMethod() throws {
		let response = (Data(), URLResponse())
		let responder: URLMockResponder = .succeeding(with: response)
		
		let staticResponder = try #require(responder as? URLStaticMockResponder)
		
		guard case .success(let dataResponse) = staticResponder.response(for: .sample)
		else {
			Issue.record("Expected success response, but got failure.")
			return
		}
		#expect(dataResponse == response)
	}
	
	@Test
	func failingStaticResponderFactoryMethod() throws {
		let expectedError = NSError(domain: "TestError", code: 99)
		
		let responder: URLMockResponder = .failing(with: expectedError)
		
		let request = URLRequest.sample
		let result = try #require(responder.response(for: request))
		
		guard case .failure(let actualError as NSError) = result else {
			Issue.record("Expected failure response, but got success.")
			return
		}
		
		#expect(actualError.code == expectedError.code &&
				actualError.domain == expectedError.domain,
				"Error code must match expected.")
	}
	
	// MARK: URLDynamicMockResponder factory method
	
	@Test("dynamic(responses:simulatedLatency:) should return a mock responder with predefined responses")
	func testDynamicFactoryMethod() throws {
		let url1 = URL.sample.appending(path: "success")
		let url2 = URL.sample.appending(path: "error")
		
		let expectedData = Data([0x04, 0x05, 0x06])
		let expectedResponse = URLDataResponse(data: expectedData, response: URLResponse())
		let expectedError = NSError(domain: "TestError", code: 99)
		
		let responder: URLMockResponder = .dynamic(
			responses: [
				url1: .success(expectedResponse),
				url2: .failure(expectedError)
			],
			simulatedLatency: 1.5
		)
		
		let requestSuccess = URLRequest(url: url1)
		let requestError = URLRequest(url: url2)
		
		if case .success(let response) = responder.response(for: requestSuccess) {
			#expect(response.data == expectedData, "Response data must match the expected result.")
		} else {
			Issue.record("Expected a success response, but a failure was returned.")
		}
		
		if case .failure(let error) = responder.response(for: requestError) {
			#expect((error as NSError).code == 99, "Error code must match expected.")
		} else {
			Issue.record("Expected an error response, but success was returned.")
		}
		
		#expect(responder.latency == 1.5, "Latency should match the defined simulated latency.")
	}
}

@Suite("URLStaticMockResponder")
struct URLStaticMockResponderTests {
	@Test("init(_:)",
		  arguments: [
			.success(URLDataResponse(data: Data([0x01, 0x02, 0x03]), response: URLResponse())),
			Result.failure(NSError(domain: "TestError", code: 99) as Error)
		  ]
	)
	func urlBasicMockResponder(_ response: Result<URLDataResponse, Error>) {
		let expectedData = Data([0x01, 0x02, 0x03])
		let expectedResponse = URLDataResponse(data: expectedData, response: URLResponse())
		let basicResponder = URLStaticMockResponder(response)
		
		let request = URLRequest.sample
		let result = basicResponder.response(for: request)
		
		switch (response, result) {
		case (.success(let response), .success(let response2)):
			#expect(response.data == response2.data, "Response data does not match what was expected.")
		case (.failure(let expectedError), .failure(let extractedError)):
			#expect((expectedError as NSError).code == (extractedError as NSError).code, "Error codes do not match.")
		default:
			Issue.record("Reponse does not match the expected one.")
		}
	}
	
	@Test("Succeeding responder always returns success")
	func testSucceedingResponse() throws {
		let expectedData = Data([0x04, 0x05, 0x06])
		let expectedResponse = URLDataResponse(data: expectedData, response: URLResponse())
		let responder = URLStaticMockResponder.succeeding(with: expectedResponse)
		
		let request = URLRequest.sample
		let result = try #require(responder.response(for: request))
		
		guard case .success(let actualResponse) = result else {
			Issue.record("Expected a success response, but a failure was received.")
			return
		}
		
		#expect(actualResponse.data == expectedData, "Response data must match expected.")
	}
	
	/// Verifies that `.failing(_:)` always returns a failure.
	@Test("Failing responder always returns an error")
	func testFailingResponse() throws {
		let expectedError = NSError(domain: "TestError", code: 101)
		
		let responder = URLStaticMockResponder.failing(with: expectedError)
		let request = URLRequest.sample
		let result = try #require(responder.response(for: request))
		
		guard case .failure(let actualError) = result else {
			Issue.record("Expected a failure response, but success was received.")
			return
		}
		
		#expect((actualError as NSError).code == expectedError.code, "Error code must match expected.")
	}
	
	@Test("Responding factory method returns the expected result")
	func testRespondingMethod() throws {
		let expectedData = Data([0x07, 0x08, 0x09])
		let expectedResponse = URLDataResponse(data: expectedData, response: URLResponse())
		let expectedError = NSError(domain: "TestError", code: 202)
		
		let successResponder = URLStaticMockResponder.responding(.success(expectedResponse))
		let failureResponder = URLStaticMockResponder.responding(.failure(expectedError))
		
		let request = URLRequest.sample
		
		let successResult = try #require(successResponder.response(for: request))
		let failureResult = try #require(failureResponder.response(for: request))
		
		switch successResult {
		case .success(let actualResponse):
			#expect(actualResponse.data == expectedData, "Response data must match expected.")
		case .failure:
			Issue.record("Expected a success response, but a failure was received.")
		}
		
		switch failureResult {
		case .failure(let actualError):
			#expect((actualError as NSError).code == expectedError.code, "Error code must match expected.")
		case .success:
			Issue.record("Expected a failure response, but success was received.")
		}
	}
	
	/// Ensures that `URLStaticMockResponder` **ignores the request** and always returns the same result.
	@Test("Responder ignores the request and always returns the predefined result")
	func testIgnoresRequest() throws {
		let expectedData = Data([0xAA, 0xBB, 0xCC])
		let expectedResponse = URLDataResponse(data: expectedData, response: URLResponse())
		
		let responder = URLStaticMockResponder.succeeding(with: expectedResponse)
		
		let request1 = URLRequest(url: URL(string: "https://example.com/one")!)
		let request2 = URLRequest(url: URL(string: "https://example.com/two")!)
		let request3 = URLRequest(url: URL(string: "https://example.com/three")!)
		
		let result1 = try #require(responder.response(for: request1))
		let result2 = try #require(responder.response(for: request2))
		let result3 = try #require(responder.response(for: request3))
		
		for result in [result1, result2, result3] {
			guard case .success(let actualResponse) = result1 else {
				Issue.record("Expected a success response, but a failure was received.")
				return
			}
			try #require(actualResponse.data == expectedData, "Response data must match expected.")
		}
	}
}

@Suite("URLDynamicMockResponder")
struct URLDynamicMockResponderTests {
	
	@Test("simulatedLatency")
	func simulatedLatency() {
		let latency: TimeInterval = 2.0
		let responder = URLDynamicMockResponder(responses: [:], simulatedLatency: latency)
		let newLatency: TimeInterval = 3.5
		let updatedResponder = responder.withLatency(newLatency)
		
		#expect(responder.latency == latency, "Original responder's `latency` must be \(latency)")
		#expect(updatedResponder.latency == newLatency, "Updated `latency` must be \(newLatency)")
	}
	
	@Test()
	func multipleMappedResponses() {
		let url1 = URL.sample.appending(path: "success")
		let url2 = URL.sample.appending(path: "error")
		
		let expectedData = Data([0x04, 0x05, 0x06])
		let expectedResponse = URLDataResponse(data: expectedData, response: URLResponse())
		let expectedError = NSError(domain: "TestError", code: 99)
		
		let dynamicResponder = URLDynamicMockResponder(
			responses: [
				url1: .success(expectedResponse),
				url2: .failure(expectedError)
			]
		)
		
		let requestSuccess = URLRequest(url: url1)
		let requestError = URLRequest(url: url2)

		if case .success(let response) = dynamicResponder.response(for: requestSuccess) {
			
			#expect(response.data == expectedData, "Response data must match what was expected.")
		} else {
			Issue.record("Expected successful response, but a failure was thrown.")
		}

		if case .failure(let error) = dynamicResponder.response(for: requestError) {
			#expect((error as NSError).code == 99, "Error code must match expected one.")
		} else {
			Issue.record("Expected error in response, but none was thrown.")
		}
	}

	@Test
	func dictionaryLiteralInitialization() {
		let url = URL.sample
		let expectedResponse = URLDataResponse(data: Data(), response: URLResponse())
		
		let dynamicResponder: URLDynamicMockResponder = [
			url: .success(expectedResponse)
		]
		
		let request = URLRequest(url: url)
		let result = dynamicResponder.response(for: request)
		
		if case .failure(let error) = result {
			Issue.record(error, "Response must have been successful.")
		}
	}
}
