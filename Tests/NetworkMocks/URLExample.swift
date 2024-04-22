//
//  URLExample.swift
//  NetworkKit
//
//  Created by rubecdt on 19/02/2025.
//

import Foundation

public extension URL {
	/// A mock URL intended for testing.
	static let sample = URL(string: "https://swifty.fly")!
}

public extension URLRequest {
	/// A mock URLRequest intended for testing.
	static let sample = URLRequest(url: .sample)
}
