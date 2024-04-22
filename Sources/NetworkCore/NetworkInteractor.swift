//
//  NetworkInteractor.swift
//  NetworkCore
//
//  Created by rubecdt on 23/4/24.
//

import Foundation

public protocol NetworkInteractor: Sendable {
	var session: URLSession { get }
	
	@inlinable
	nonisolated func fetch(
		for request: URLRequest,
		expectedStatus status: HTTPStatus
	) async throws(NetworkError) -> Data
}

public extension NetworkInteractor {
	var session: URLSession { .shared }
	
	@inlinable
	func send(
		request: URLRequest,
		expectedStatus status: HTTPStatus = 200
	) async throws(NetworkError) {
		_ = try await fetch(for: request, expectedStatus: status)
	}
	
	// TODO: Evaluate other status codes that may be valid apart from 200.
	@inlinable
	nonisolated func fetch(
		for request: URLRequest,
		expectedStatus status: HTTPStatus = 200
	) async throws(NetworkError) -> Data {
		let (data, response) = try await session.fetchData(for: request)
		guard response.statusCode == status.code else {
			throw NetworkError.status(response.statusCode)
		}
		return data
	}
}

package extension NetworkInteractor {
	@inlinable
	nonisolated func fetch<T>(
		for request: URLRequest,
		expectedStatus status: HTTPStatus = 200,
		transform: (Data) throws(NetworkError) -> T
	) async throws(NetworkError) -> T {
		let data = try await fetch(for: request)
		return try transform(data)
	}
}

extension URLSession: NetworkInteractor {
	public var session: Self { self }
}
