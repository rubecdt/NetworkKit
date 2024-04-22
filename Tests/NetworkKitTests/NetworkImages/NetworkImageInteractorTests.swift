//
//  NetworkImageInteractorTests.swift
//  NetworkKit
//
//  Created by rubecdt on 16/02/2025.
//


import Foundation
import Testing
import enum NetworkCore.NetworkError
@testable import NetworkImages
import NetworkMocks

@Suite("NetworkImageInteractor Tests")
struct NetworkImageInteractorTests {
    
    // MARK: - Mocks
    
    private struct NetworkImageInteractorMock: NetworkImageInteractor {
        var session: URLSession
        
        init(mockResponse: Result<URLDataResponse, Error>) {
            let responder = URLStaticMockResponder(mockResponse)
            self.session = URLSession.mock(responder: responder)
        }
    }
    
    // MARK: - Helpers
    
    private let url = URL.sample
    private var request: URLRequest {
        URLRequest.get(url: url)
    }
    
    private func httpResponse(statusCode: Int) throws -> HTTPURLResponse {
        guard let response = HTTPURLResponse(url: url, statusCode: statusCode) else {
            throw URLError(.badServerResponse)
        }
        return response
    }
    
    /// 1x1 pixel PNG Image (base64 decodificado)
    private let validImageData = Data(base64Encoded:
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAukB9SIfp1IAAAAASUVORK5CYII="
    )!
    
    /// Datos que no generan una imagen válida.
    private let invalidImageData = Data("invalid".utf8)
    
    // MARK: - Tests
    
    @Test("fetchImage(from:) - Success")
    func fetchImageSuccess() async throws {
        let response = try httpResponse(statusCode: 200)
        let interactor = NetworkImageInteractorMock(mockResponse: .success((validImageData, response)))
        
        let image = try await interactor.fetchImage(from: url)
        
        #if canImport(UIKit)
        #expect(image.cgImage != nil)
        #else
        #expect(image.size != .zero)
        #endif
    }
    
    @Test("fetchImage(from:) - Invalid data causes error")
    func fetchImageInvalidData() async throws {
		let response = try httpResponse(statusCode: 200)
        let interactor = NetworkImageInteractorMock(mockResponse: .success((invalidImageData, response)))
        
        await #expect(throws: NetworkError.invalidData) {
            _ = try await interactor.fetchImage(from: url)
        }
    }
    
    @Test("fetchImage(from:) - Network error propagation")
    func fetchImageNetworkError() async {
        let error = URLError(.notConnectedToInternet)
        let interactor = NetworkImageInteractorMock(mockResponse: .failure(error))
        
        await #expect(throws: NetworkError.general(error)) {
            _ = try await interactor.fetchImage(from: url)
        }
    }
}
