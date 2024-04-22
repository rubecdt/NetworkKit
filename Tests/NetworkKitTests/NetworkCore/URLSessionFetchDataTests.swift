//
//  URLSessionFetchDataTests.swift
//  NetworkKit
//
//  Created by rubecdt on 16/02/2025.
//

import Testing
@testable import NetworkCore
import Foundation
import NetworkMocks

@Suite("URLSession Tests")
struct URLSessionFetchDataTests {

	let validURL = URL.sample
    let validData = "Response Data".data(using: .utf8)!
	let validResponse = HTTPURLResponse(url: URL.sample, statusCode: 200)!
    
    // MARK: - Success Cases

    @Test
    func fetchDataFromURL_Success() async throws {
		let (data, response) = try await withMockedURLSession(
			using: URLStaticMockResponder(
				.success((validData, validResponse))
			)
		) { session in
			try await session.fetchData(from: validURL)
		}
		#expect(data == validData)
		#expect(response.statusCode == 200)
    }

    @Test
    func fetchDataForRequest_Success() async throws {
		let request = URLRequest(url: validURL)
		let (data, response) = try await withMockedURLSession(
			using: URLStaticMockResponder(
				.success((validData, validResponse))
			)
		) { session in
			try await session.fetchData(for: request)
		}
        
        #expect(data == validData)
        #expect(response.statusCode == 200)
    }

	// MARK: - Error Handling

    @Test
    func fetchData_ThrowsNonHTTPResponseError() async {
		let session = URLSession.mock(responder: URLStaticMockResponder(.success((validData, URLResponse())))) // Not an HTTP response
									  
			await #expect(throws: NetworkError.nonHTTPResponse) {
            try await session.fetchData(from: validURL)
        }
    }

    @Test
    func fetchData_ThrowsGeneralNetworkError() async {
        let networkError = URLError(.timedOut)
		let session = URLSession.mock(responder: URLStaticMockResponder(.failure(networkError)))

        await #expect(throws: NetworkError.general(networkError)) {
            try await session.fetchData(from: validURL)
        }
    }

    // MARK: - Edge Cases

    @Test
    func fetchData_HandlesEmptyResponse() async throws {
        let emptyData = Data()
		let session = URLSession.mock(
			responder: URLStaticMockResponder(
				.success((emptyData, validResponse))
			)
		)

        let (data, response) = try await session.fetchData(from: validURL)
        
        #expect(data.isEmpty)
        #expect(response.statusCode == 200)
    }

    @Test
	@MainActor
    func fetchData_DelegateIsPassedCorrectly() async throws {
		// MARK: - Mock Delegate
		final class MockURLSessionDelegate: NSObject, URLSessionTaskDelegate {
			@MainActor
			var wasCalled = false
			
			func urlSession(
				_ session: URLSession,
				task: URLSessionTask,
				didFinishCollecting metrics: URLSessionTaskMetrics
			) {
				Task { @MainActor in wasCalled = true
					print("was called = \(wasCalled)")}
			}
		}
		
        let mockDelegate = MockURLSessionDelegate()
		let session = URLSession.mock(
			responder:
				URLStaticMockResponder(.success((validData, validResponse)))
		)

        let (data, response) = try await session.fetchData(from: validURL, delegate: mockDelegate)
        
        #expect(data == validData)
        #expect(response.statusCode == 200)
		#expect(mockDelegate.wasCalled)  // Verify delegate was used
    }
}
