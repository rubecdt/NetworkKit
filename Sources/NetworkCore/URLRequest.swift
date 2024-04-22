//
//  URLRequest.swift
//  NetworkCore
//
//  Created by rubecdt on 15/11/23.
//

import Foundation

public extension URLRequest {
	/// Creates a **GET** request with default parameters: timeout of 60 seconds, etc.
	/// as defined in ``Foundation/URLRequest``.
	/// - Parameters:
	///		- url: The url to retrieve data from.
	///		- authentication: An optional authentication method.
	/// - Returns: The **GET** request
	static func get(url: URL, authentication: Authentication? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
		
		return if let authentication {
			request.addingAuthenticationHeaders(for: authentication)
		} else {
			request
		}
    }
	
	/// Creates a **POST** request with a JSON body and optional authentication.
	/// - Parameters:
	///   - url: The URL to send data to.
	///   - body: The data to be encoded as JSON.
	///   - method: The HTTP method (e.g., **POST**, **PUT**).
	///   - authentication: An optional authentication method.
	/// - Returns: A configured request with a JSON body.
	static func post<JSON>(
		url: URL,
		data: JSON,
		encoder: JSONEncoder = .init(),
		method: HTTPMethod = .post,
		authentication: Authentication? = nil
	) -> URLRequest where JSON: Codable {
		var request = URLRequest.post(
			url: url,
			method: method,
			authentication: authentication
		)
		request.httpBody = try? encoder.encode(data)
		
		return request
	}
	
	/// Creates a request without a body, useful for **DELETE** or **HEAD** methods with JSON Accept header.
	/// - Parameters:
	///   - url: The URL for the request.
	///   - method: The HTTP method (e.g., **DELETE**, **HEAD**).
	///   - authentication: Optional authentication method.
	/// - Returns: A configured request without a body.
	static func post(
		url: URL,
		method: HTTPMethod = .post,
		authentication: Authentication? = nil
	) -> URLRequest {
		var request = URLRequest(url: url)
		request.timeoutInterval = 60
		request.httpMethod = method.rawValue
		request.setValue("application/json; charset=utf8", forHTTPHeaderField: "content-type")
		request.setValue("application/json", forHTTPHeaderField: "accept")
		
		return if let authentication {
			request.addingAuthenticationHeaders(for: authentication)
		} else {
			request
		}
	}
	
	func addingAuthentication(_ authentication: Authentication...) -> Self {
		addingAuthenticationHeaders(for: authentication)
	}
}

public protocol UserCredentialsProvider: Sendable {
	var account: String { get }
	var password: String { get }
}

public struct UserCredentials: UserCredentialsProvider {
	public var username: String { account }
	
	public let account, password: String
	
	public init(account: String, password: String) {
		self.account = account
		self.password = password
	}
}

public extension URLRequest {
	/// Represents different authentication methods for a request.
	enum Authentication: Sendable {
		/// Uses a custom header field for authentication.
		case custom(headerField: String, value: String)
		/// Authentication via a bearer token.
		case token(String)
		/// Authentication using user credentials (e.g., username and password).
		case credentials(any UserCredentialsProvider)
		/// Authentication via an API key.
		case apiKey(String)
	}
}

fileprivate extension URLRequest.Authentication {
	func addingHeader(to headers: [String: String] = [:]) -> [String: String] {
		var headers = headers
		switch self {
			case .custom(let header, let value):
				headers[header] = value
			case .token(let value):
				headers["authorization"] = "Bearer \(value)"
			case .credentials(let user):
				let loginString = "\(user.account):\(user.password)"
				let loginData = Data(loginString.utf8)
				let base64LoginString = loginData.base64EncodedString()
				headers["authorization"] = "Basic \(base64LoginString)"
			case .apiKey(let key):
				headers["x-api-key"] = key
		}
		return headers
	}
}
	
fileprivate extension URLRequest {
	func addingAuthenticationHeaders(for authentication: Authentication...) -> URLRequest {
		let headers = authentication.reduce([:]) { partialResult, authentication in
			authentication.addingHeader(to: partialResult)
		}
		
		return self.setHTTPHeaders(headers)
	}
	
	func addingAuthenticationHeaders(for authentications: [Authentication]) -> URLRequest {
		let headers = authentications.reduce([:]) { partialResult, authentication in
			authentication.addingHeader(to: partialResult)
		}
		
		return self.setHTTPHeaders(headers)
	}
	
	func setHTTPHeaders(_ headers: [String: String]) -> URLRequest {
		var request = self
		headers.forEach {
			request.setValue($0.value, forHTTPHeaderField: $0.key)
		}
		return request
	}
}
