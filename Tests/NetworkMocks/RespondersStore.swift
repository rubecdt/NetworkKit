//
//  RespondersStore.swift
//  NetworkKit
//
//  Created by rubecdt on 29/01/2025.
//

import Foundation

/// A thread-safe store that manages URL mock responders associated with `URLSessionTask` instances.
///
/// This store ensures safe concurrent access to responders using a concurrent `DispatchQueue`
/// with barrier writes to prevent race conditions.
///
/// - Important: This store identifies tasks using `ObjectIdentifier`,
///   which is based on an object's memory address.
///   If a task is deallocated and another is created soon after, Swift may reuse the memory address,
///   leading to duplicate `ObjectIdentifier` values.
///   **Ensure tasks remain in memory while being tracked to avoid unintended overwrites.**
public class RespondersStore: @unchecked Sendable {
	
	static let shared = RespondersStore()
	
	/// Storage for responders, keyed by `ObjectIdentifier` of `URLSessionTask`.
	private var responders: [ObjectIdentifier: any URLMockResponder] = [:]
	/// Queue for synchronizing access to `responders`.
	private let queue = DispatchQueue(label: "com.rubecdt.ConfigStoreQueue", attributes: .concurrent)
	
	/// Initializes a new `RespondersStore` instance.
	/// - Note: This initializer is internal to enforce singleton usage via `shared`.
	internal init() {}
	
	/// Associates a mock responder with a specific `URLSessionTask`.
	///
	/// - Parameters:
	///   - config: The mock responder to be stored.
	///   - task: The task associated with the responder.
	///
	/// - Note: This method uses a barrier write to ensure **thread safety**.
	///
	/// `ObjectIdentifier` is used to track tasks, relying on their **memory address**.
	///     If tasks are deallocated and recreated, their memory may be reused,
	///     causing identifier collisions.
	///
	/// - Warning: **Ensure the task remains in memory while it has an associated responder to prevent identifier collisions.**
	func setConfig(_ config: URLMockResponder, for task: URLSessionTask) {
		let identifier = ObjectIdentifier(task)
		queue.sync(flags: .barrier) {
			self.responders[identifier] = config
		}
	}
	
	/// Retrieves the responder associated with the given `URLSessionTask`.
	///
	/// - Parameter task: The task for which to retrieve the responder.
	/// - Returns: The stored `URLMockResponder` if found, otherwise `nil`.
	///
	/// - Note: This method is thread safe.
	func config(for task: URLSessionTask) -> URLMockResponder? {
		let identifier = ObjectIdentifier(task)
		var result: URLMockResponder?
		queue.sync {
			result = self.responders[identifier]
		}
		return result
	}
	
	/// Removes the responder associated with the given `URLSessionTask`.
	///
	/// - Parameter task: The task whose responder should be removed.
	///
	/// - Note: This method uses a barrier write to ensure thread safety.
	func removeConfig(for task: URLSessionTask) {
		let identifier = ObjectIdentifier(task)
		queue.sync(flags: .barrier) {
			_ = self.responders.removeValue(forKey: identifier)
		}
	}
}


extension RespondersStore: Collection {
	public typealias Element = [ObjectIdentifier: any URLMockResponder].Element

	public var startIndex: [ObjectIdentifier: any URLMockResponder].Index { responders.startIndex }
	public var endIndex: [ObjectIdentifier: any URLMockResponder].Index { responders.endIndex }
	
	/// Retrieves or updates a responder associated with a `URLSessionTask`.
	///
	/// - Parameter key: The `URLSessionTask` whose responder should be accessed.
	/// - Returns: The associated `URLMockResponder`, or `nil` if none exists.
	///
	/// - Note:
	///   - Setting a new responder stores it in the collection.
	///   - Assigning `nil` removes the responder from storage.
	public subscript(position: [ObjectIdentifier: any URLMockResponder].Index) -> [ObjectIdentifier: any URLMockResponder].Element {
		get {
			responders[position]
		}
	}
	
	subscript(key: URLSessionTask) -> URLMockResponder? {
		get {
			config(for: key)
		}
		set {
			if let newValue {
				setConfig(newValue, for: key)
			} else {
				removeConfig(for: key)
			}
		}
	}
	
	public func index(after i: [ObjectIdentifier: any URLMockResponder].Index) -> [ObjectIdentifier: any URLMockResponder].Index {
		responders.index(after: i)
	}
}
