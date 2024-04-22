//
//  NetworkInteractorTests.swift
//  NetworkKit
//
//  Created by rubecdt on 14/02/2025.
//


import Foundation
import Testing
@testable import NetworkCore
import NetworkMocks

@Suite("NetworkInteractorTests")
struct NetworkInteractorTests {
    
	// MARK: - Network Interactor Mock
    private struct NetworkInteractorMock: NetworkInteractor {
		var session: URLSession
		
		/// Initializes the mock with a predefined response.
		init(mockResponse response: Result<URLDataResponse, Error>) {
			let responder = URLStaticMockResponder(response)
			self.session = URLSession.mock(responder: responder)
		}
		
		/// A mock instance that always responds with both empty `Data` and `HTTPURLResponse`.
		static let withEmptyResponse: Self = .init(mockResponse: .success((Data(),HTTPURLResponse())))
    }
	
	// MARK: - Helpers
	/// Base URL for tests.
	private let url = URL.sample
	private var request: URLRequest {
		.init(url: url)
	}
	/// Creates an `HTTPURLResponse` instance with a predefined status code.
	private func httpResponse(statusCode: Int) throws -> HTTPURLResponse {
		try #require(HTTPURLResponse(url: url, statusCode: statusCode))
	}
	
	// MARK: - fetch(for:) tests
	
    @Test("fetch() - Success")
    func fetchSuccess() async throws {
        let expectedData = "Test Response".data(using: .utf8)!
		let response = try httpResponse(statusCode: 200)
        let interactor = NetworkInteractorMock(mockResponse: .success((expectedData, response)))
		
        let data = try await interactor.fetch(for: request)
        
        #expect(data == expectedData)
    }
    
    @Test("fetch() - Unexpected Status Code Throws Error")
    func fetchUnexpectedStatusThrowsError() async throws {
		let response = try httpResponse(statusCode: 404)
        let interactor = NetworkInteractorMock(mockResponse: .success((Data(), response)))
        
        await #expect(throws: NetworkError.status(404)) {
            try await interactor.fetch(for: request)
        }
    }
    
    @Test("fetch() - Network Error Propagation")
    func fetchWithNetworkError() async {
		let error = URLError(.notConnectedToInternet)
		let interactor = NetworkInteractorMock(mockResponse: .failure(error))
        
		await #expect(throws: NetworkError.general(error)) {
			try await interactor.fetch(for: request)
        }
    }
    
    @Test("fetch(for:transform:) - Success with Decoding")
    func fetchWithTransformSuccess() async throws {
		let model = ["message": "Hello"]
		let jsonData: Data = try JSONEncoder().encode(model)
		
		let response = try httpResponse(statusCode: 200)
        let interactor = NetworkInteractorMock(mockResponse: .success((jsonData, response)))
        
        
        let fetchedModel = try await interactor.fetch(for: request) { data throws(NetworkError) in
			do {
				return try JSONDecoder().decode([String:String].self, from: data)
			} catch {
				throw NetworkError(from: error)
			}
        }
        
		#expect(model == fetchedModel)
    }
    
    @Test("fetch(for:transform:) - Throws DecodingError on Invalid JSON")
    func fetchWithTransformThrowsDecodingError() async throws {
        let invalidJsonData = Data("invalid".utf8)
		let response = try httpResponse(statusCode: 200)
        
        let interactor = NetworkInteractorMock(mockResponse: .success((invalidJsonData, response)))
        
		await #expect(throws: NetworkError.self) {
			try await interactor.fetch(for: request) { data throws(NetworkError) in
				do {
					_ = try JSONDecoder().decode([String:String].self, from: data)
				} catch {
					throw NetworkError(from: error)
				}
            }
        }
    }
	
	// MARK: - send(request:) tests
	
	@Test("send(request:) - Success")
	func sendSuccess() async throws {
		let interactor = NetworkInteractorMock.withEmptyResponse
		try await interactor.send(request: request)
	}
	
	
	@Test("send(request:) - Failure with Unexpected Status")
	func sendFailure() async throws {
		let response = try httpResponse(statusCode: 400)
		let interactor = NetworkInteractorMock(mockResponse: .success((Data(), response)))
		
		try await #require(throws: NetworkError.status(400)) {
			try await interactor.send(request: request, expectedStatus: 200)
		}
	}
}
