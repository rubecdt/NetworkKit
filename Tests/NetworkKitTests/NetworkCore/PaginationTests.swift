//
//  Test.swift
//  NetworkKit
//
//  Created by rubecdt on 15/02/2025.
//

import Foundation
import Testing
@testable import NetworkCore

@Suite("Pagination Tests")
struct PaginationTests {
	
	@Test(arguments: [
		0,
		5,
		.max
	],[
		0,
		10,
		.max
	])
	func initialization(itemsPerPage: UInt, page: UInt) async throws {
		let pagination = URL.Pagination(itemsPerPage: itemsPerPage, page: page)
		
		try #require(pagination.page != 0)
		try #require(pagination.itemsPerPage != 0)
		
		#expect(pagination.itemsPerPage == max(itemsPerPage,1))
		#expect(pagination.page == max(page,1))
    }
	
	@Test(arguments: [
		0,
		UInt.random(in: 1..<UInt.max)
	])
	func pageIncrement(by increment: UInt) async throws {
		let initialPage: UInt = 1
		var pagination = URL.Pagination(itemsPerPage: 10, page: initialPage)
		
		pagination.advance(by: increment)
		
		#expect(pagination.page == initialPage &+ increment)
	}
	
	@Test
	func pageIncrementOverflow() async throws {
		let increment: UInt = UInt.max
		var pagination = URL.Pagination(itemsPerPage: 15)
		pagination.advance(by: increment)
		#expect(pagination.page == UInt.max)
	}
	
	@Test
	func advancingReturnsNewInstance() async throws {
		let pagination = URL.Pagination(itemsPerPage: 10, page: 5)
		let newPagination = pagination.advancing(pages: 3)
		
		#expect(newPagination.page == 8)
		// Original should remain unchanged
		#expect(pagination.page == 5)
	}
	
	@Test(arguments: [
		0,
		UInt.random(in: 1..<UInt.max)
	])
	func advancing(by increment: UInt) async throws {
		let initialPage: UInt = 1
		let pagination = URL.Pagination(itemsPerPage: 10, page: initialPage).advancing(pages: increment)
		
		#expect(pagination.page == initialPage &+ increment)
	}
	
	@Test
	func advancingWithOverflow() async throws {
		let pagination = URL.Pagination(itemsPerPage: 10, page: UInt.max - 1)
		let newPagination = pagination.advancing(pages: 2)
		
		#expect(newPagination.page == UInt.max)
		#expect(pagination.page == UInt.max - 1)  // Original should not change
	}
	
	@Test
	func previousPage() async throws {
		let page: UInt = UInt.random(in: 1...UInt.max)
		var pagination = URL.Pagination(itemsPerPage: 10, page: page)
		pagination.previousPage()
		#expect(pagination.page == page-1)
	}
	
	@Test(arguments: [
		0,
		1
	])
	func previousPageOverflow(for page: UInt) async throws {
		var pagination = URL.Pagination(itemsPerPage: 10, page: page)
		pagination.previousPage()
		#expect(pagination.page == 1)
	}
	
	@Test
	func nextPage() async throws {
		let page = UInt.random(in: 1..<UInt.max)
		var pagination = URL.Pagination(itemsPerPage: 10, page: page)
		pagination.nextPage()
		#expect(pagination.page == page+1)
	}
	
	@Test
	func nextPageOverflow() async throws {
		let page = UInt.max
		var pagination = URL.Pagination(itemsPerPage: 10, page: page)
		pagination.nextPage()
		#expect(pagination.page == UInt.max)
	}
	
	
	@Test(arguments: [
		5,
		20,
		.max
	],[
		1,
		1045,
		.max
	])
	func customPagination(per: UInt, page: UInt) async throws {
		let url = URL.sample
		let paginatedURL = url.paginated(URL.Pagination(itemsPerPage: per, page: page))
		
		let expectedURL = url.appending(
			queryItems: [.init(name: "page", value: "\(page)"),
						 .init(name: "per", value: "\(per)")]
		)
		
		#expect(paginatedURL == expectedURL)
	}
}
