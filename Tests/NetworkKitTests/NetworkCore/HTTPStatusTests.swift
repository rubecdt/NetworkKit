//
//  HTTPStatusTests.swift
//  NetworkKitTests
//
//  Created by rubecdt on 03/03/2025.
//

import Testing
@testable import enum NetworkCore.HTTPStatus

@Suite("HTTPStatus")
struct HTTPStatusTests {
	
	@Test("Status classification",
		  arguments: HTTPStatus.allCases)
	func statusClass(status: HTTPStatus) async throws {
		let classDigit = status.code / 100
		let expectedClass: HTTPStatus.Class = switch classDigit {
		case 1: .informational
		case 2: .success
		case 3: .redirection
		case 4: .clientError
		case 5: .serverError
		default: .unknown
		}
		#expect(status.class == expectedClass)
	}
}

extension HTTPStatus: CaseIterable {
	/// Custom HTTP status codes defined in the standard HTTP specification.
	static let standardCases: [NetworkCore.HTTPStatus] = [
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
	
	/// Custom HTTP status codes that fall outside the standard HTTP specification.
	static let customCases: [HTTPStatus] = [
		   .custom(code: 600, reasonPhrase: "Custom Client Error"),
		   .custom(code: 99, reasonPhrase: "Edge Case Status"),
		   .custom(code: 50, reasonPhrase: "Having a Nap"),
		   .custom(code: 700, reasonPhrase: "Experimental Code"),
		   .custom(code: 899, reasonPhrase: "Edge Case Status"),
		   .custom(code: 999, reasonPhrase: "Vendor-Specific Error")
	   ]

	public static let allCases: [HTTPStatus] = HTTPStatus.standardCases + HTTPStatus.customCases
}

extension HTTPStatus: CustomTestArgumentEncodable {
	public func encodeTestArgument(to encoder: some Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(description)
	}
}
