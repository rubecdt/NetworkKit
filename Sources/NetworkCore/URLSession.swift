//
//  URLSession.swift
//  NetworkCore
//
//  Created by rubecdt on 15/11/23.
//

import Foundation

public extension URLSession {
	/// Fetches data from the specified URL using a `URLRequest`.
	///
	/// - Parameters:
	///   - url: The `URL` to fetch data from.
	///   - delegate: An optional delegate for handling session-related events.
	/// - Throws: A `NetworkError` if the request fails or the response is invalid.
	/// - Returns: A tuple containing the response `Data` and an `HTTPURLResponse`.
	func fetchData(
		from url: URL,
		delegate: (URLSessionTaskDelegate)? = nil
	) async throws(NetworkError) -> (Data, HTTPURLResponse) {
		try await fetchData(for: URLRequest(url: url), delegate: delegate)
    }
    
	/// Fetches data for the given `URLRequest`, ensuring an HTTP response.
	///
	/// - Parameters:
	///   - request: The `URLRequest` to be executed.
	///   - delegate: An optional delegate for handling session-related events.
	/// - Throws:
	///   - `NetworkError.nonHTTPResponse` if the response is not an `HTTPURLResponse`.
	///   - `NetworkError.general` if another error occurs.
	/// - Returns: A tuple containing the response `Data` and an `HTTPURLResponse`.
	func fetchData(
		for request: URLRequest,
		delegate: (URLSessionTaskDelegate)? = nil
	) async throws(NetworkError) -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await data(for: request, delegate: delegate)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.nonHTTPResponse
            }
            return (data, response)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.general(error)
        }
    }
}
