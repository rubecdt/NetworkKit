//
//  Test.swift
//  NetworkKit
//
//  Created by rubecdt on 19/02/2025.
//

import Testing
@testable import NetworkMocks
import Foundation

@Suite("ResponderStore")
struct ResponderStoreTests {
	@Test
	func testSingletonInstance() {
		let instance1 = RespondersStore.shared
		let instance2 = RespondersStore.shared
		#expect(instance1 === instance2, "RespondersStore should be a singleton.")
	}
	
	@Test("setConfig(_:for:) - config(for:)")
	func testSetAndRetrieveConfig() throws {
		let store = RespondersStore()
		
		let task = URLSession.shared.dataTask(with: URL.sample)
		let responder = MockURLMockResponder()
		
		store.setConfig(responder, for: task)
		let retrievedResponder = try #require(store.config(for: task) as? MockURLMockResponder)
		#expect(retrievedResponder === responder, "The stored responder must match the retrieved one.")
	}
	
	@Test("Remove configuration - removeConfig(for:)")
	func removeConfig() {
		let store = RespondersStore()
		let task = MockURLSessionTask()
		let responder = MockURLMockResponder()
		
		store.setConfig(responder, for: task)
		store.removeConfig(for: task)
		
		let retrievedResponder =
		store.first(where: { key, value in
			ObjectIdentifier(task) == key
		})?.value as? MockURLMockResponder
		#expect(retrievedResponder == nil, "The responder should have been removed.")
	}
	
	@Test("subscript getter and setter")
	func subscriptGetterSetter() throws{
		let store = RespondersStore()
		let task = MockURLSessionTask()
		let responder = MockURLMockResponder()
		
		store[task] = responder
		let extractedResponder = try #require(store[task] as? MockURLMockResponder)
		#expect(extractedResponder === responder, "Responder must be assignable and retrievable via subscript.")
		
		store[task] = nil
		#expect(store[task] == nil, "The subscript must allow removing the configuration by setting it to nil.")
	}
	
	@Test
	func concurrentWritesTest() async throws {
		let store = RespondersStore()
		let numberOfTasks = 100
		let enumeratedTasks = (0..<numberOfTasks).map {
			($0, MockURLSessionTask())
		}
		
		await withTaskGroup(of: Void.self) { group in
			for (index, task) in enumeratedTasks {
				group.addTask {
					store.setConfig(MockURLMockResponder(value: index), for: task)
				}
			}
		}
		
		// Reading via config(for:), all barrier tasks should be completed.
		for (index, task) in enumeratedTasks {
			if let responder = store.config(for: task) as? MockURLMockResponder {
				#expect(responder.value == index)
			} else {
				Issue.record("Configuration for task \(index) must not be nil.")
			}
		}
	}
	
	@Test
	func asyncReadWhileWriting() async throws {
		let store = RespondersStore.shared
		let task = MockURLSessionTask()

		let responder1 = MockURLMockResponder(value: 1)
		let responder2 = MockURLMockResponder(value: 2)

		store.setConfig(responder1, for: task)
		
		// Concurrent reads
		await withTaskGroup(of: Void.self) { group in
			
			// Concurrent writes
			group.addTask {
				store.setConfig(responder1, for: task)
			}
			group.addTask {
				store.setConfig(responder2, for: task)
			}
			for _ in 0..<10 {
				group.addTask {
					let responder = store.config(for: task)
					#expect(responder != nil, "A responder should be retrieved during concurrent reading, but none was.")
				}
			}
		}
	}
	
	@Test
	func collectionConformance() {
		let store = RespondersStore()
		let task1 = MockURLSessionTask()
		let task2 = MockURLSessionTask()
		let responder1 = MockURLMockResponder()
		let responder2 = MockURLMockResponder()
		
		store.setConfig(responder1, for: task1)
		store.setConfig(responder2, for: task2)
		
		let allKeys = store.map { $0.key }
		#expect(allKeys.contains(ObjectIdentifier(task1)), "Store should contain the key for the first element.")
		#expect(allKeys.contains(ObjectIdentifier(task2)), "Store should contain the key for second element.")
	}
	
	@Test(
		arguments: [
			1,
			2,
			10
		]
	)
	func collectionIndexing(respondersCount: Int) {
		let store = RespondersStore()
		
		addMockResponders(count: respondersCount, to: store)
		
		let startIndex = store.startIndex
		let endIndex = store.endIndex
		
		#expect(startIndex != endIndex, "There should be at least one item in the collection")
		#expect(store.index(startIndex, offsetBy: respondersCount) == endIndex, "There should be exactly one item in the collection")
	}
	
	@Test(
		arguments: [
			0,
			1,
			2,
			10
		]
	)
	func collectionCount(respondersCount: Int) {
		let store = RespondersStore()
		
		addMockResponders(count: respondersCount, to: store)
		
		#expect(store.count == respondersCount, "The 'count' property should reflect number of elements in the collection")
	}
}

extension ResponderStoreTests {
	private func addMockResponders(count: Int, to store: RespondersStore) {
		// We must keep all tasks in memory simultaneously
		// because ObjectIdentifier generates
		// identifiers based on memory addresses.
		// If tasks are instantiated in a temporary scope,
		// such that any instance is deallocated before all
		// other instances are created, Swift may reuse
		// its memory address, producing the same
		// ObjectIdentifier.
		// This can cause overwrites in `ResponderStore`.
		_ = (0..<count).map { i in
			let task = MockURLSessionTask()
			let responder = MockURLMockResponder()
			store.setConfig(responder, for: task)
			return (task, responder)
		}
	}
}

// MARK: - Mocks

final class MockURLSessionTask: URLSessionTask, @unchecked Sendable {
}

final class MockURLMockResponder: URLMockResponder {
	let value: Int
	
	func response(for request: URLRequest) -> Result<NetworkMocks.URLDataResponse, any Error>? {
		.failure(URLError(.unknown))
	}
	
	init(value: Int = 0) {
		self.value = value
	}
}
