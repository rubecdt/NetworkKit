//
//  Mock.swift
//
//
//  Created by rubecdt on 26/01/2025.
//

import Foundation

public extension HTTPURLResponse {
	convenience init?(url: URL, statusCode: Int, headerFields: [String: String]? = nil) {
		self.init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headerFields)
	}
}
