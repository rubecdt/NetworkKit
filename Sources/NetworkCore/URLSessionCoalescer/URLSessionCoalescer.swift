//
//  URLSessionCoalescer.swift
//
//
//  Created by rubecdt on 24/4/24.
//
import OSLog
import Foundation

// URLSessionCoalescer, URLSessionDeduplicator, URLSessionRequestsDeduplicator
/// An actor that manages URL requests by coalescing duplicate concurrent requests,
/// ensuring that identical requests share the same task instead of executing multiple times.
///
/// - Note: This actor is cache-agnostic, set the `session` parameter
/// on initialization to configure caching behaviour.
/// @Example
/// ```swift
/// let noLoadConfiguration = URLSessionConfiguration.default
///	noLoadConfiguration.requestCachePolicy = .returnCacheDataDontLoad
///
/// let session = URLSession(configuration: noLoadConfiguration)
///
///	URLSessionCoalescer<RequestHasher>(session: session)
/// ```
public actor URLSessionCoalescer<RequestHasher: URLRequest.HashingStrategy>: NetworkInteractor {
	
	private typealias HashedRequest = RequestHasher
	private let logger = Logger()
	
	/// The `URLSession` instance used for executing network requests.
	public let session: URLSession
	
	/// Initializes a `URLSessionCoalescer`.
		/// - Parameter session: The `URLSession` instance to use. Defaults to `.shared`.
	public init(
		session: URLSession = .shared
	) {
		self.session = session
	}
	
	private var ongoingRequests: [HashedRequest: Task<Data, Error>] = [:]
	
	/// Executes a network request, ensuring duplicate concurrent requests share the same task.
		/// - Parameter request: The `URLRequest` to execute.
		/// - Returns: The response `Data`.
		/// - Throws: An error if the request fails.
	public func fetch(
		for request: URLRequest
	) async throws(NetworkError) -> Data {
		do {
			let requestKey = HashedRequest(request: request)
			if let task = ongoingRequests[requestKey] {
				do {
					return try await task.value
				} catch is CancellationError {
					remove(requestKey)
				}
			}
			
			let newTask = Task {
				defer {
					logger.debug("Task completed")
				}
				logger.debug("Task started")
				return try await session.fetch(for: request)
			}
			
			ongoingRequests[requestKey] = newTask
			
			defer {
				remove(requestKey)
			}
			
			let resource = try await newTask.value
			return resource
			
		} catch {
			throw NetworkError(from: error)
		}
	}
	
	private func remove(_ request: HashedRequest) {
		ongoingRequests.removeValue(forKey: request)
	}
	
	
	/// Cancels all ongoing requests and clears the cache.
	public func cancelAllRequests() {
		logger.debug("Cancelling all ongoing requests")
		ongoingRequests.values
			.forEach { $0.cancel() }
		ongoingRequests.removeAll()
		logger.debug("All ongoing requests cancelled")
	}
}
