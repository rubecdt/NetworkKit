//
//  NetworkJSONInteractorTests.swift
//  NetworkKit
//
//  Created by rubecdt on 18/02/2025.
//


import Foundation
import Testing
@testable import NetworkJSON
import NetworkMocks

@Suite("NetworkJSONInteractorTests")
struct NetworkJSONInteractorTests {
    // MARK: - Helpers
    
    /// URL base para las pruebas.
    private let url = URL.sample
    private var request: URLRequest { URLRequest(url: url) }
    
    /// Modelo de ejemplo para decodificar JSON.
    struct TestModel: Codable, Equatable {
        let message: String
    }
    
    /// Mock que conforma a NetworkJSONInteractor y Sendable.
    struct NetworkJSONInteractorMock: NetworkJSONInteractor, Sendable {
        var session: URLSession
        
        /// Inicializa el mock inyectando una respuesta simulada.
        init(mockResponse response: Result<URLDataResponse, Error>) {
            let responder = URLStaticMockResponder(response)
            self.session = URLSession.mock(responder: responder)
        }
    }
    
    /// Crea un HTTPURLResponse con un status code especificado.
    private func httpResponse(statusCode: Int = 200) throws -> HTTPURLResponse {
		try .with(url: url, statusCode: statusCode)
    }
    
    // MARK: - Tests para NetworkJSONInteractor
    
    @Test("fetchJSON(for:decoding:) - Success")
    func testFetchJSONSuccess() async throws {
        // Modelo esperado y sus datos JSON
        let model = TestModel(message: "Hello, World!")
        let jsonData = try JSONEncoder().encode(model)
        let response = try httpResponse(statusCode: 200)
        
        // Crear el interactor mock con una respuesta exitosa
        let interactor = NetworkJSONInteractorMock(mockResponse: .success((jsonData, response)))
        
        // Llamada al método fetchJSON y verificación del resultado
        let fetchedModel: TestModel = try await interactor.fetchJSON(for: request, decoding: TestModel.self)
        #expect(fetchedModel == model)
    }
    
    @Test("fetchJSON(for:decoding:) - Invalid JSON Throws Error")
    func testFetchJSONInvalidJSON() async {
        // Datos que no conforman un JSON válido
        let invalidData = Data("invalid json".utf8)
        let response = try! httpResponse(statusCode: 200)
        let interactor = NetworkJSONInteractorMock(mockResponse: .success((invalidData, response)))
        
        // Se espera que al intentar decodificar lance un error de NetworkError.json
        await #expect(throws: NetworkError.self) {
            try await interactor.fetchJSON(for: request, decoding: TestModel.self)
        }
    }
    
    @Test("fetchJSON(for:decoding:) - Propagates Network Error")
    func testFetchJSONNetworkError() async {
        // Simula un error de red, por ejemplo, no conectado a Internet.
        let error = URLError(.notConnectedToInternet)
        let interactor = NetworkJSONInteractorMock(mockResponse: .failure(error))
        
        // Se espera que se propague el error convertido a NetworkError.general
        await #expect(throws: NetworkError.general(error)) {
			try await interactor.fetchJSON(for: request, decoding: TestModel.self)
        }
    }
}
