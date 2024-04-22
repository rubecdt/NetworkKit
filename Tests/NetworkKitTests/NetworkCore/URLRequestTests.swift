//
//  URLRequestTests.swift
//  NetworkKit
//
//  Created by rubecdt on 16/02/2025.
//

import Foundation
import Testing
@testable import NetworkCore

@Suite("URLRequest Tests")
struct URLRequestTests {
    // MARK: - GET Request Tests

    @Test
    func getRequest() async throws {
		let url = URL.sample
        let request = URLRequest.get(url: url)

        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "accept") == "application/json")
    }

    @Test
    func getRequestWithAuthentication() async throws {
        let url = URL.sample
        let request = URLRequest.get(url: url, authentication: .token("abcd1234"))

        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "authorization") == "Bearer abcd1234")
    }

    // MARK: - POST Request Tests

    struct SampleData: Codable {
        let message: String
    }

    @Test
    func postRequest() async throws {
        let url = URL.sample
        let sampleData = SampleData(message: "Hello, world!")
        let request = URLRequest.post(url: url, data: sampleData)

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "content-type") == "application/json; charset=utf8")
        #expect(request.value(forHTTPHeaderField: "accept") == "application/json")
        #expect(request.httpBody != nil)
    }

    @Test
    func postRequestWithDifferentMethod() async throws {
        let url = URL.sample
        let sampleData = SampleData(message: "Updated data")
        let request = URLRequest.post(url: url, data: sampleData, method: .put)

        #expect(request.httpMethod == "PUT")
    }

    // MARK: - Authentication Header Tests

    @Test
    func authenticationWithBasicCredentials() async throws {
        let userCredentials = UserCredentials(account: "user", password: "password")
		let request = URLRequest.get(url: .sample)
            .addingAuthentication(.credentials( userCredentials))

        let expectedAuthHeader = "Basic " + Data("user:password".utf8).base64EncodedString()
        #expect(request.value(forHTTPHeaderField: "authorization") == expectedAuthHeader)
    }

    @Test
    func authenticationWithToken() async throws {
		let request = URLRequest.get(url: .sample)
            .addingAuthentication(.token("my-secret-token"))

        #expect(request.value(forHTTPHeaderField: "authorization") == "Bearer my-secret-token")
    }

    @Test
    func authenticationWithAPIKey() async throws {
		let request = URLRequest.get(url: .sample)
            .addingAuthentication(.apiKey("my-api-key"))

        #expect(request.value(forHTTPHeaderField: "x-api-key") == "my-api-key")
    }

    @Test
    func authenticationWithCustomHeader() async throws {
        let request = URLRequest.get(url: .sample)
            .addingAuthentication(.custom(headerField: "X-Custom-Header", value: "custom-value"))

        #expect(request.value(forHTTPHeaderField: "X-Custom-Header") == "custom-value")
    }

    // MARK: - Header Handling Tests

    @Test
    func multipleAuthenticationHeaders() async throws {
        let request = URLRequest.get(url: .sample)
            .addingAuthentication(.token("token-123"), .apiKey("api-987"))

        #expect(request.value(forHTTPHeaderField: "authorization") == "Bearer token-123")
        #expect(request.value(forHTTPHeaderField: "x-api-key") == "api-987")
    }
}
