//
//  NetworkJSONInteractor.swift
//  
//
//  Created by rubecdt on 24/4/24.
//

import Foundation
@_exported public import protocol NetworkCore.NetworkInteractor
@_exported public import enum NetworkCore.NetworkError

/// A protocol defining the interface for fetching and decoding JSON data over the network.
///
/// Conforming types must provide a `JSONDecoder` to handle JSON deserialization.
/// This extends `NetworkInteractor`, allowing seamless network interactions.
public protocol NetworkJSONInteractor: NetworkInteractor {
	/// The JSON decoder used for decoding responses.
	///
	/// An unmodified `JSONDecoder` instance is provided as default implementation.
	///
	/// Conforming types can override this to customize decoding behavior.
	var decoder: JSONDecoder { get }
}

public extension NetworkJSONInteractor where Self: Sendable {
	var decoder: JSONDecoder { .init() }
	
	/// Performs a network request and decodes the response into a `Decodable` type.
	///
	/// - Parameters:
	///   - request: The `URLRequest` to execute.
	///   - type: The expected `Decodable` type. Defaults to `JSON.self`.
	///
	/// - Throws:
	///   - `NetworkError` if the request fails or decoding encounters an error.
	///   - `NetworkError.json(error)` if the response cannot be decoded.
	///
	/// - Returns: The decoded JSON object of the specified type.
	func fetchJSON<JSON>(
		for request: URLRequest,
		decoding type: JSON.Type = JSON.self
	) async throws(NetworkError) -> JSON where JSON: Decodable {
		try await fetch(for: request) { data throws(NetworkError) in
			do {
				return try decoder.decode(type, from: data)
			} catch {
				throw NetworkError.json(error)
			}
		}
	}
}
