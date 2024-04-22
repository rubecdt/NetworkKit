//
//  ImageDownloaderTests.swift
//  NetworkKit
//
//  Created by rubecdt on 16/02/2025.
//


import Foundation
import Testing
import enum NetworkCore.NetworkError
@testable import NetworkImages
import NetworkMocks

let imageResult: Result<Data,Error> = {
	Result {
		let imageURL = try #require(Bundle.module.urlForImageResource("swifty.png"))
		return try Data(contentsOf: imageURL)
	}
}()

extension HTTPURLResponse {
	/// Crea un `HTTPURLResponse` con el status code indicado.
	static func with(url: URL, statusCode: Int = 200) throws -> HTTPURLResponse {
		guard let response = HTTPURLResponse(
			url: url,
			statusCode: statusCode
		)
		else {
			throw URLError(.badServerResponse)
		}
		return response
	}
}

@Suite("ImageDownloaderTests")
struct ImageDownloaderTests {
    // MARK: - Helpers
    
    let url = URL.sample
    
    /// Crea un `HTTPURLResponse` con el status code indicado.
    private func httpResponse(statusCode: Int = 200) throws -> HTTPURLResponse {
		try .with(url: url, statusCode: statusCode)
    }
    
    /// Imagen de 1x1 pixel en PNG (base64 decodificado).
//    private let validImageData = Data(base64Encoded:
//        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAukB9SIfp1IAAAAASUVORK5CYII="
//    )!
	
	var validImageData: Data {
		get throws {
			try imageResult.get()
		}
	}
	
    /// Datos que no generan una imagen válida.
    private let invalidImageData = Data("invalid".utf8)
    
    // MARK: - Tests
    
    @Test("fetchImage(from:) - Éxito")
    func testFetchImageSuccess() async throws {
		print(URL.currentDirectory())
        let response = try httpResponse(statusCode: 200)
		let imageURL = try #require(Bundle.module.urlForImageResource("swifty.png"))
		let imageData = try validImageData
        let responder = URLStaticMockResponder(.success((imageData, response)))
        let session = URLSession.mock(responder: responder)
        let downloader = ImageDownloader(session: session)
        
        let image = try await downloader.fetchImage(from: url)
        #if canImport(UIKit)
        #expect(image.cgImage != nil)
        #else
        // Para AppKit se verifica que la imagen copiada tenga tamaño mayor a cero.
        #expect(image.size.width > 0)
        #endif
    }
    
    @Test("fetchImage(from:) - Caching")
	@MainActor
    func testFetchImageCaching() async throws {
		@MainActor
		class URLCallCountResponder: URLMockResponder {
			nonisolated func response(for request: URLRequest) -> Result<URLDataResponse, any Error>? {
				Task {
					guard let url = request.url else {
						return
					}
					await registerCall(with: url)
				}
				return Result {
					let validImageData = try imageResult.get()
					return (validImageData, try HTTPURLResponse.with(url: request.url ?? .sample, statusCode: 200))
				}
			}
			
			private func registerCall(with url: URL) {
				urlCallCount[url, default: 0] += 1
			}
			
			func callCount(for url: URL) -> Int {
				urlCallCount[url] ?? 0
			}
			
			private var urlCallCount: [URL: Int] = [:]
		}
		let responder = URLCallCountResponder()
        let session = URLSession.mock(responder: responder)
        let downloader = ImageDownloader(session: session)
        
        // Primera llamada: debería ejecutar el request.
        let image1 = try await downloader.fetchImage(from: url)
        // Segunda llamada: se usa el caché.
        let image2 = try await downloader.fetchImage(from: url)
        
		let callCount = responder.callCount(for: url)
        #expect(callCount == 1)
        #if canImport(UIKit)
        // Comparación básica: ambas imágenes deben tener un CGImage.
        #expect(image1.cgImage != nil && image2.cgImage != nil)
        #else
		#expect(image1.size == image2.size)
		#expect(image1.tiffRepresentation == image2.tiffRepresentation)
        #endif
    }
    
    @Test("fetchImage(from:) - Datos Inválidos Lanza Error")
    func testFetchImageInvalidData() async throws {
        let response = try httpResponse(statusCode: 200)
        let responder = URLStaticMockResponder(.success((invalidImageData, response)))
        let session = URLSession.mock(responder: responder)
        let downloader = ImageDownloader(session: session)
        
        await #expect(throws: NetworkError.invalidData) {
            _ = try await downloader.fetchImage(from: url)
        }
    }
    
    @Test("fetchImage(from:) - Propagación de Error de Red")
    func testFetchImageNetworkError() async {
        let error = URLError(.notConnectedToInternet)
        let responder = URLStaticMockResponder(.failure(error))
        let session = URLSession.mock(responder: responder)
        let downloader = ImageDownloader(session: session)
        
        await #expect(throws: NetworkError.general(error)) {
            _ = try await downloader.fetchImage(from: url)
        }
    }
}
