//
//  URLRequestHashingStrategy.swift
//  NetworkKit
//
//  Created by rubecdt on 27/02/2025.
//

import Foundation

public extension URLRequest {
	/// A strategy defining how `URLRequest` instances should be hashed in a custom hashing strategy.
	protocol HashingStrategy: Hashable, Sendable {
		/// Extracts relevant components from an `URLRequest` for hashing.
		init(request: URLRequest)
	}
}

extension URLRequest: URLRequest.HashingStrategy {
	/// Default hashing strategy that matches `Foundation`'s `URLRequest` hashable implementation.
	public typealias DefaultHashingStrategy = URLRequest
	
	public init(request: URLRequest) {
		self = request
	}
}

public extension URLRequest {
	/// A hashing strategy that selectively considers key properties of ``Foundation/URLRequest``.
	///
	/// The properties used for hashing are:
	/// - ``Foundation/URLRequest/url``
	/// - ``Foundation/URLRequest/httpMethod``
	/// - ``Foundation/URLRequest/timeoutInterval``
	/// - ``Foundation/URLRequest/httpBody``
	/// - ``Foundation/URLRequest/allHTTPHeaderFields``
	struct ExtendedHashing: URLRequest.HashingStrategy {
		let url: URL?
		let httpMethod: String?
		let timeoutInterval: Double?
		let httpBody: Data?
		let allHTTPHeaderFields: [String: String]?
		
		public init(request: URLRequest) {
			url = request.url
			httpMethod = request.httpMethod
			timeoutInterval = request.timeoutInterval
			httpBody = request.httpBody
			allHTTPHeaderFields = request.allHTTPHeaderFields
		}
	}
}
