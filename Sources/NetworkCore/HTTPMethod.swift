//
//  HTTPMethod.swift
//  NetworkCore
//
//  Created by rubecdt on 22/4/24.
//

import Foundation

public extension URLRequest {
	enum HTTPMethod: String, CustomStringConvertible {
		case get 	= "GET",
			 post 	= "POST",
			 patch 	= "PATCH",
			 put 	= "PUT",
			 delete = "DELETE"
		
		/// The standard (uppercased) method name
		public var description: String {
			self.rawValue
		}
	}
}
