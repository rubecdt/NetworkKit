//
//  URLMockResponder.swift
//  NetworkKit
//
//  Created by rubecdt on 29/01/2025.
//

import Foundation

public protocol URLMockResponder: Sendable {
	var latency: TimeInterval { get }
	func response(for request: URLRequest) -> Result<URLDataResponse, Error>?
}

public extension URLMockResponder {
	var latency: TimeInterval { 0 }
}

/// A mock URL responder that returns a predefined result, regardless of the request.
public struct URLStaticMockResponder: URLMockResponder {
	/// The predefined response or error returned for every request.
	let result: Result<URLDataResponse, Error>
	
	/// Returns the predefined `result`, regardless of the request.
	public func response(for request: URLRequest) -> Result<URLDataResponse, any Error>? {
		result
	}
	
	/// Creates a responder that returns the given result for any request
	/// - Parameter result: The response or error to return for any request.
	public init(_ result: Result<URLDataResponse, Error>) {
		self.result = result
	}
	
	/// Creates a responder that **always fails** with the given error.
	/// - Parameter error: The error to return for any request.
	public static func failing(with error: Error) -> Self {
		.init(.failure(error))
	}
	
	/// Creates a responder that **always succeeds** with the given response.
	/// - Parameter response: The response to return for any request.
	public static func succeeding(with response: URLDataResponse) -> Self {
		.init(.success(response))
	}
}

// MARK: - Convenience Factory Methods for URLMockResponder
public extension URLMockResponder where Self == URLStaticMockResponder {
	/// Returns a responder that **always** provides the given result.
	/// - Parameter result: The response or error to return for any request.
	/// - Returns: A `URLStaticMockResponder` instance.
	static func responding(_ result: Result<URLDataResponse, Error>) -> URLStaticMockResponder {
		.init(result)
	}
	
	/// Returns a responder that **always fails** with the given error.
	/// - Parameter error: The error to return for any request.
	/// - Returns: A `URLStaticMockResponder` instance.
	static func failing(with error: Error) -> URLStaticMockResponder {
		.failing(with: error)
	}
	
	/// Returns a responder that **always succeeds** with the given response.
	/// - Parameter response: The response to return for any request.
	/// - Returns: A `URLStaticMockResponder` instance.
	static func succeeding(with response: URLDataResponse) -> URLStaticMockResponder {
		.succeeding(with: response)
	}
}

/// A dynamic mock responder that returns predefined responses based on the request URL.
/// Supports dictionary literal initialization and optional response latency simulation.
public struct URLDynamicMockResponder: URLMockResponder, ExpressibleByDictionaryLiteral {
	/// The simulated network latency before returning a response.
	public let latency: TimeInterval
	/// A dictionary mapping URLs to their corresponding mock responses.
	let responses: [URL: Result<URLDataResponse, Error>]
	
	/// Creates a mock responder that returns responses based on predefined URL mappings.
	/// - Parameters:
	///   - responses: A dictionary mapping URLs to `Result<URLDataResponse, Error>`.
	///   - simulatedLatency: The delay before returning the response (default: `0`).
	public init(
		responses: [URL: Result<URLDataResponse, Error>],
		simulatedLatency: TimeInterval = 0
	) {
		self.responses = responses
		self.latency = simulatedLatency
	}
	
	/// Allows the responder to be initialized using a dictionary literal.
	/// - Parameter elements: A variadic list of `(URL, Result<URLDataResponse, Error>)` tuples.
	public init(dictionaryLiteral elements: (URL, Result<URLDataResponse, any Error>)...) {
		responses = Dictionary(uniqueKeysWithValues: elements)
		latency = 0
	}
	
	/// Retrieves the predefined response for the given request.
	/// - Parameter request: The URL request.
	/// - Returns: The predefined result for the request's URL, or `nil` if no match is found.
	public func response(for request: URLRequest) -> Result<URLDataResponse, Error>? {
		guard let url = request.url else { return nil }
		return responses[url]
	}
	
	/// Returns a new instance of the responder with a modified simulated latency.
	/// - Parameter latency: The new simulated latency.
	/// - Returns: A new `URLDynamicMockResponder` with the same responses but updated latency.
	public func withLatency(_ latency: TimeInterval) -> Self {
		.init(responses: responses, simulatedLatency: latency)
	}
}

// MARK: - Convenience Factory Methods for URLMockResponder
public extension URLMockResponder where Self == URLDynamicMockResponder {
	/// Creates a dynamic responder with predefined URL mappings.
	/// - Parameters:
	///   - responses: A dictionary mapping URLs to `Result<URLDataResponse, Error>`.
	///   - simulatedLatency: The delay before returning the response (default: `0`).
	/// - Returns: A `URLDynamicMockResponder` instance.
	static func dynamic(
		responses: [URL: Result<URLDataResponse, Error>],
		simulatedLatency: TimeInterval = 0
	) -> URLDynamicMockResponder {
		.init(responses: responses, simulatedLatency: simulatedLatency)
	}
}
