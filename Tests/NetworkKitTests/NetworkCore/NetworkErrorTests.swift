//
//  NetworkErrorTest.swift
//  NetworkKitTests
//
//  Created by rubecdt on 14/02/2025.
//

import Foundation
import Testing
import enum NetworkCore.HTTPStatus
@testable import enum NetworkCore.NetworkError

@Suite("NetworkError")
struct NetworkErrorTests {
	@Test("Status static method",
		  arguments: HTTPStatus.allCases)
	func statusStaticMethod(status: HTTPStatus) {
		let code = Int(status.code)
		#expect(NetworkError.status(code) == NetworkError.status(status))
	}
	
	@Test("Self wrapping",
		  arguments: NetworkError.allCases)
	func networkErrorWrappingItself(error: NetworkError) {
		let networkError = NetworkError(from: error)
		#expect(networkError == error)
	}
	
	@Test("DecodingError wrapping")
	func networkErrorWrappingDecodingError() {
		let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Test JSON"))
		let jsonError = NetworkError(from: decodingError)
		#expect(jsonError == .json(decodingError))
	}
	
	@Test("any Error wrapping",
		arguments: NetworkError.allCases
	)
	func networkErrorWrappingAnyError(error: NetworkError) {
		let nsError = NSError(domain: "Test", code: 42, userInfo: nil)
		let generalError = NetworkError(from: nsError)
		#expect(generalError == .general(nsError))
	}
	
	@Test(arguments: HTTPStatus.allCases)
	func errorDescription(status: HTTPStatus) async throws {
		let error = NetworkError.status(status)
		#expect(error.localizedDescription.range(of: status.description) != nil)
	}
}

extension HTTPStatus: CaseIterable {
	public static let allCases: [NetworkCore.HTTPStatus] = [
		// 1xx
		.`continue`,
		.switchingProtocols,
		.processing,
		.earlyHints,
		// 2xx
		.ok,
		.created,
		.accepted,
		.nonAuthoritativeInformation,
		.noContent,
		.resetContent,
		.partialContent,
		.multiStatus,
		.alreadyReported,
		.imUsed,
		// 3xx
		.multipleChoices,
		.movedPermanently,
		.found,
		.seeOther,
		.notModified,
		.useProxy,
		.temporaryRedirect,
		.permanentRedirect,
		// 4xx
		.badRequest,
		.unauthorized,
		.paymentRequired,
		.forbidden,
		.notFound,
		.methodNotAllowed,
		.notAcceptable,
		.proxyAuthenticationRequired,
		.requestTimeout,
		.conflict,
		.gone,
		.lengthRequired,
		.preconditionFailed,
		.payloadTooLarge,
		.uriTooLong,
		.unsupportedMediaType,
		.rangeNotSatisfiable,
		.expectationFailed,
		.imATeapot,
		.misdirectedRequest,
		.unprocessableEntity,
		.locked,
		.failedDependency,
		.upgradeRequired,
		.preconditionRequired,
		.tooManyRequests,
		.requestHeaderFieldsTooLarge,
		.unavailableForLegalReasons,
		// 5xx
		.internalServerError,
		.notImplemented,
		.badGateway,
		.serviceUnavailable,
		.gatewayTimeout,
		.httpVersionNotSupported,
		.variantAlsoNegotiates,
		.insufficientStorage,
		.loopDetected,
		.notExtended,
		.networkAuthenticationRequired,
	]
}

extension NetworkError: CaseIterable {
	public static let allCases: [NetworkCore.NetworkError] = [
		.general(URLError(.dataNotAllowed)),
		.invalidData,
		.json(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Severe corruption, Help!"))),
		.nonHTTPResponse,
		.status(.imATeapot),
		.unknown
	]
}
