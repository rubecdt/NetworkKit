//
//  URLRequestExtendedHashingTests.swift
//  NetworkKit
//
//  Created by rubecdt on 22/01/2025.
//

import Testing
import Foundation
@testable import NetworkCore

fileprivate typealias ExtendedHashing = URLRequest.ExtendedHashing

@Suite("NetworkKit Hashing for URLRequest")
struct NetworkKitHashingTests {
	// MARK: - Parametrized test cases
	
	static let baseRequest = {
		var request = URLRequest.sample
		request.httpMethod = "GET"
		request.httpBody = Data([0x01, 0x02, 0x03])
		return request
	}()
	
	static let testCases: [(URLRequest, URLRequest, Bool)] = [
		// Case 1: Identical requests
		(baseRequest, baseRequest, true),
		// Case 2: Different URL
		{
			var modifiedRequest = baseRequest
			modifiedRequest.url = URL(string: "https://example.org")!
			return (baseRequest, modifiedRequest, false)
		}(),
		// Case 3: Different HTTP method
		{
			var modifiedRequest = baseRequest
			modifiedRequest.httpMethod = "POST"
			return (baseRequest, modifiedRequest, false)
		}(),
		// Case 4: Different timeoutInterval
		{
			var modifiedRequest = baseRequest
			modifiedRequest.timeoutInterval = 30
			return (baseRequest, modifiedRequest, false)
		}(),
		// Case 5: Different httpBody
		{
			var modifiedRequest = baseRequest
			modifiedRequest.httpBody = Data([0x04, 0x05, 0x06])
			return (baseRequest, modifiedRequest, false)
		}()
	]
	
	// MARK: - Tests
	
	@Test("NetworkKitHashing equality", arguments: testCases)
	func equality(lhReq: URLRequest, rhReq: URLRequest, expectedEquality: Bool) {
		let wrappedLHReq = ExtendedHashing(request: lhReq)
		let wrappedRHReq = ExtendedHashing(request: rhReq)
		
		#expect((wrappedLHReq == wrappedRHReq) == expectedEquality)
	}
	
	@Test("NetworkKitHashing hashing", arguments: testCases)
	func hashing(lhReq: URLRequest, rhReq: URLRequest, shouldHaveSameHash: Bool) {
		let wrappedRequest1 = ExtendedHashing(request: lhReq)
		let wrappedRequest2 = ExtendedHashing(request: rhReq)
		
		var hasher1 = Hasher()
		wrappedRequest1.hash(into: &hasher1)
		let hashValue1 = hasher1.finalize()
		
		var hasher2 = Hasher()
		wrappedRequest2.hash(into: &hasher2)
		let hashValue2 = hasher2.finalize()
		
		if shouldHaveSameHash {
			#expect(hashValue1 == hashValue2)
		} else {
			withKnownIssue("May be hash collision", isIntermittent: true) {
				#expect(hashValue1 != hashValue2, "May be hash collision, check if all different cases produces the same hash.")
			}
		}
	}
}


extension ExtendedHashing: CustomTestArgumentEncodable {
	public func encodeTestArgument(to encoder: some Encoder) throws {
		var container = encoder.unkeyedContainer()
		let string = """
		\(String(describing: url))\(String(describing: httpMethod))\(String(describing: httpBody))\(String(describing: timeoutInterval))\(String(describing:allHTTPHeaderFields))
		"""
		try container.encode(string)
	}
}

extension URLRequest: @retroactive CustomTestArgumentEncodable {
	public func encodeTestArgument(to encoder: some Encoder) throws {
		var container = encoder.unkeyedContainer()
		let string = """
		\(String(describing: url))\(String(describing: httpMethod))\(String(describing: httpBody))\(timeoutInterval)\(String(describing:allHTTPHeaderFields))
		"""
		try container.encode(string)
	}
}
