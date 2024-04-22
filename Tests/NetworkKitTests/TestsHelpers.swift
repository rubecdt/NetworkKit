//
//  TestsHelpers.swift
//
//
//  Created by rubecdt on 13/6/24.
//

import Foundation
import Testing
@testable import NetworkCore
import NetworkMocks

fileprivate extension URL {
	static let getEmpleados: URL = URL(string: "https://example.com/getEmpleados")!
	static let forFailingRequest: URL = URL(string: "https://example.com/postOnInvalidURL")!
}

fileprivate let responder: URLDynamicMockResponder = [
	.getEmpleados: .success((Data(#"{"key":"value"}"#.utf8),
							 HTTPURLResponse(url: .getEmpleados, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type": "application/json; charset=utf-8"])!)),
	.forFailingRequest: .success((Data(), HTTPURLResponse(url: .forFailingRequest, statusCode: 400)!))
]

// Funciones de extensión para probar
extension NSError {
	func equals(to other: NSError, ignoreUserInfo: Bool = true) -> Bool {
		domain == other.domain &&
		code == other.code &&
		(ignoreUserInfo ||
			NSDictionary(dictionary: userInfo).isEqual(to: other.userInfo))
	}
}

extension Error {
	func equals(_ other: Error) -> Bool {
		guard let other = other as? Self else {
			return false
		}
//		if let self = self as? (any Error & Equatable) {
//			return self.equals(other)
//		}
		let nsSelf = self as NSError
		return nsSelf.equals(other)
	}
}

//extension Error where Self: Equatable {
//	func equals(_ other: Error) -> Bool {
//		print(Self.Type.self)
//		guard let other = other as? Self else {
//			return false
//		}
//		return self == other
//	}
//}

extension Error where Self == NSError {
	func equals(_ other: Error) -> Bool {
		guard let other = other as? Self else {
			return false
		}
		
		return equals(to: other)
	}
}
// MARK: Equatable conformance
extension NetworkError: Equatable {
	public static func ==(lhs: NetworkError, rhs: NetworkError) -> Bool {
		switch (lhs, rhs) {
		case (.general(let lhsError), .general(let rhsError)),
			 (.json(let lhsError), .json(let rhsError)):
//			"\(lhsError)" == "\(rhsError)"
			lhsError.equals(rhsError)
		case (.status(let lhsStatus), .status(let rhsStatus)):
			lhsStatus == rhsStatus
		case (.invalidData, .invalidData),
			 (.unknown, .unknown),
			 (.nonHTTPResponse, .nonHTTPResponse):
			true
		default:
			false
		}
	}
}

extension NetworkError {
	func isSimilar<each T: Equatable>(to other: NetworkError, using keypath: repeat KeyPath<NSError, each T>) -> Bool {
		switch (self, other) {
		case (.general(let lhsError), .general(let rhsError)),
			 (.json(let lhsError), .json(let rhsError)):
//			"\(lhsError)" == "\(rhsError)"
			let lNSError: NSError = lhsError as NSError
			let rNSError: NSError = rhsError as NSError
			for keypath in repeat each keypath {
				guard lNSError[keyPath: keypath] == rNSError[keyPath: keypath] else {
					return false
				}
			}
			return true
		case (.status(let lhsStatus), .status(let rhsStatus)):
			return lhsStatus == rhsStatus
		case (.invalidData, .invalidData),
			 (.unknown, .unknown),
			 (.nonHTTPResponse, .nonHTTPResponse):
			return true
		default:
			return false
		}
	}
}
