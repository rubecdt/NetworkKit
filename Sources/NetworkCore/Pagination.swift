//
//  Pagination.swift
//  NetworkCore
//
//  Created by rubecdt on 08/11/2024.
//

import Foundation

public extension URL {
	/// A struct that represents pagination settings for API requests.
	///
	/// This allows defining how many items per page should be requested and tracking the current page.
	/// It provides utility methods to advance or modify pagination state.
	///
	/// - Note: `Pagination` ensures that `itemsPerPage` and `page` are always greater than or equal to `1`.
	struct Pagination: Sendable {
		public let itemsPerPage: UInt
		@usableFromInline
		private(set) var page: UInt
		
		public init(itemsPerPage: UInt, page: UInt = 1) {
			self.itemsPerPage = max(itemsPerPage, 1)
			self.page = max(page, 1)
		}
		
		/// A default pagination setting with `16` items per page, starting from page `1`.
		public static let standard = Pagination(itemsPerPage: 16, page: 1)
		
		/// Creates a new `Pagination` instance by advancing the current page.
		///
		/// - Parameter pages: The number of pages to advance.
		/// - Returns: A new `Pagination` instance with the updated page count.
		@inlinable
		public func advancing(pages: UInt) -> Pagination {
			let (newPage, didOverflow) = page.addingReportingOverflow(pages)
			return Pagination(itemsPerPage: itemsPerPage, page: didOverflow ? UInt.max : newPage)
		}
		
		/// Advances the current pagination state by the given number of pages.
		///
		/// - Parameter pages: The number of pages to advance.
		public mutating func advance(by pages: UInt) {
			let (newPage, didOverflow) = page.addingReportingOverflow(pages)
			page = didOverflow ? UInt.max : newPage
		}
		
		/// Moves to the next page.
		public mutating func nextPage() {
			advance(by: 1)
		}
		
		/// Moves to the previous page, ensuring the page number never goes below `1`.
		public mutating func previousPage() {
			if page > 1 {
				page -= 1
			}
		}
	}
	
	/// Returns a new URL with pagination parameters appended as query items.
	///
	/// This method appends `page` and `per` (items per page) parameters to the URL query.
	///
	/// - Parameter pagination: The `Pagination` instance to apply (defaults to `.standard`).
	/// - Returns: A new `URL` with pagination parameters included.
	func paginated(_ pagination: Pagination = .standard) -> URL {
		if #available(macOS 13.0, iOS 16.0, *) {
			return self.appending(queryItems: [URLQueryItem(name: "page", value: pagination.page.description),
										URLQueryItem(name: "per", value: pagination.itemsPerPage.description)
									   ])
		} else {
			// Fallback for earlier versions
			var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
			var queryItems = components?.queryItems ?? []
			
			queryItems.append(URLQueryItem(name: "page", value: pagination.page.description))
			queryItems.append(URLQueryItem(name: "per", value: pagination.itemsPerPage.description))
			
			components?.queryItems = queryItems
			
			return components?.url ?? self
		}
	}
}
