//
//  HTTPStatus.swift
//  NetworkKit
//
//  Derived by rubecdt on 10/02/2025.
//
//  Based on code from HTTPTypes.swift,
//	part of the SwiftNIO open source project.
//
//	The license for the original work is reproduced below.
//	See NOTICES.txt for details.
//
//	//===----------------------------------------------------------------------===//
//	//
//	// This source file is part of the SwiftNIO open source project
//	//
//	// Copyright (c) 2017-2021 Apple Inc. and the SwiftNIO project authors
//	// Licensed under Apache License v2.0
//	//
//	// See LICENSE.txt for license information
//	// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//	//
//	// SPDX-License-Identifier: Apache-2.0
//	//
//	//===----------------------------------------------------------------------===//

/// A HTTP response status code.
public enum HTTPStatus: Sendable {
	/// Use custom if you want to use a non-standard response code or
	/// have it available in a (UInt, String) pair from a higher-level web framework.
	case custom(code: UInt, reasonPhrase: String)

	// all the codes from http://www.iana.org/assignments/http-status-codes

	// 1xx
	case `continue`
	case switchingProtocols
	case processing
	case earlyHints

	// 2xx
	case ok
	case created
	case accepted
	case nonAuthoritativeInformation
	case noContent
	case resetContent
	case partialContent
	case multiStatus
	case alreadyReported
	case imUsed

	// 3xx
	case multipleChoices
	case movedPermanently
	case found
	case seeOther
	case notModified
	case useProxy
	case temporaryRedirect
	case permanentRedirect

	// 4xx
	case badRequest
	case unauthorized
	case paymentRequired
	case forbidden
	case notFound
	case methodNotAllowed
	case notAcceptable
	case proxyAuthenticationRequired
	case requestTimeout
	case conflict
	case gone
	case lengthRequired
	case preconditionFailed
	case payloadTooLarge
	case uriTooLong
	case unsupportedMediaType
	case rangeNotSatisfiable
	case expectationFailed
	case imATeapot
	case misdirectedRequest
	case unprocessableEntity
	case locked
	case failedDependency
	case upgradeRequired
	case preconditionRequired
	case tooManyRequests
	case requestHeaderFieldsTooLarge
	case unavailableForLegalReasons

	// 5xx
	case internalServerError
	case notImplemented
	case badGateway
	case serviceUnavailable
	case gatewayTimeout
	case httpVersionNotSupported
	case variantAlsoNegotiates
	case insufficientStorage
	case loopDetected
	case notExtended
	case networkAuthenticationRequired

	/// Initialize a `HTTPResponseStatus` from a given status and reason.
	///
	/// - Parameter statusCode: The integer value of the HTTP response status code
	/// - Parameter reasonPhrase: The textual reason phrase from the response. This will be
	///     discarded in favor of the default if the `statusCode` matches one defined by the standard.
	public init(statusCode: Int, reasonPhrase: String = "") {
		self = switch statusCode {
		case 100:
			.`continue`
		case 101:
			.switchingProtocols
		case 102:
			.processing
		case 103:
			.earlyHints
		case 200:
			.ok
		case 201:
			.created
		case 202:
			.accepted
		case 203:
			.nonAuthoritativeInformation
		case 204:
			.noContent
		case 205:
			.resetContent
		case 206:
			.partialContent
		case 207:
			.multiStatus
		case 208:
			.alreadyReported
		case 226:
			.imUsed
		case 300:
			.multipleChoices
		case 301:
			.movedPermanently
		case 302:
			.found
		case 303:
			.seeOther
		case 304:
			.notModified
		case 305:
			.useProxy
		case 307:
			.temporaryRedirect
		case 308:
			.permanentRedirect
		case 400:
			.badRequest
		case 401:
			.unauthorized
		case 402:
			.paymentRequired
		case 403:
			.forbidden
		case 404:
			.notFound
		case 405:
			.methodNotAllowed
		case 406:
			.notAcceptable
		case 407:
			.proxyAuthenticationRequired
		case 408:
			.requestTimeout
		case 409:
			.conflict
		case 410:
			.gone
		case 411:
			.lengthRequired
		case 412:
			.preconditionFailed
		case 413:
			.payloadTooLarge
		case 414:
			.uriTooLong
		case 415:
			.unsupportedMediaType
		case 416:
			.rangeNotSatisfiable
		case 417:
			.expectationFailed
		case 418:
			.imATeapot
		case 421:
			.misdirectedRequest
		case 422:
			.unprocessableEntity
		case 423:
			.locked
		case 424:
			.failedDependency
		case 426:
			.upgradeRequired
		case 428:
			.preconditionRequired
		case 429:
			.tooManyRequests
		case 431:
			.requestHeaderFieldsTooLarge
		case 451:
			.unavailableForLegalReasons
		case 500:
			.internalServerError
		case 501:
			.notImplemented
		case 502:
			.badGateway
		case 503:
			.serviceUnavailable
		case 504:
			.gatewayTimeout
		case 505:
			.httpVersionNotSupported
		case 506:
			.variantAlsoNegotiates
		case 507:
			.insufficientStorage
		case 508:
			.loopDetected
		case 510:
			.notExtended
		case 511:
			.networkAuthenticationRequired
		default:
			.custom(code: UInt(statusCode), reasonPhrase: reasonPhrase)
		}
	}
}

public extension HTTPStatus {
	/// The numerical status code for a given HTTP response status.
	var code: UInt {
		get {
			switch self {
			case .continue:
				100
			case .switchingProtocols:
				101
			case .processing:
				102
			case .earlyHints:
				103
			case .ok:
				200
			case .created:
				201
			case .accepted:
				202
			case .nonAuthoritativeInformation:
				203
			case .noContent:
				204
			case .resetContent:
				205
			case .partialContent:
				206
			case .multiStatus:
				207
			case .alreadyReported:
				208
			case .imUsed:
				226
			case .multipleChoices:
				300
			case .movedPermanently:
				301
			case .found:
				302
			case .seeOther:
				303
			case .notModified:
				304
			case .useProxy:
				305
			case .temporaryRedirect:
				307
			case .permanentRedirect:
				308
			case .badRequest:
				400
			case .unauthorized:
				401
			case .paymentRequired:
				402
			case .forbidden:
				403
			case .notFound:
				404
			case .methodNotAllowed:
				405
			case .notAcceptable:
				406
			case .proxyAuthenticationRequired:
				407
			case .requestTimeout:
				408
			case .conflict:
				409
			case .gone:
				410
			case .lengthRequired:
				411
			case .preconditionFailed:
				412
			case .payloadTooLarge:
				413
			case .uriTooLong:
				414
			case .unsupportedMediaType:
				415
			case .rangeNotSatisfiable:
				416
			case .expectationFailed:
				417
			case .imATeapot:
				418
			case .misdirectedRequest:
				421
			case .unprocessableEntity:
				422
			case .locked:
				423
			case .failedDependency:
				424
			case .upgradeRequired:
				426
			case .preconditionRequired:
				428
			case .tooManyRequests:
				429
			case .requestHeaderFieldsTooLarge:
				431
			case .unavailableForLegalReasons:
				451
			case .internalServerError:
				500
			case .notImplemented:
				501
			case .badGateway:
				502
			case .serviceUnavailable:
				503
			case .gatewayTimeout:
				504
			case .httpVersionNotSupported:
				505
			case .variantAlsoNegotiates:
				506
			case .insufficientStorage:
				507
			case .loopDetected:
				508
			case .notExtended:
				510
			case .networkAuthenticationRequired:
				511
			case .custom(let code, reasonPhrase: _):
				code
			}
		}
	}

	/// The string reason phrase for a given HTTP response status.
	var reasonPhrase: String {
		get {
			switch self {
			case .continue:
				"Continue"
			case .switchingProtocols:
				"Switching Protocols"
			case .processing:
				"Processing"
			case .earlyHints:
				"Early Hints"
			case .ok:
				"OK"
			case .created:
				"Created"
			case .accepted:
				"Accepted"
			case .nonAuthoritativeInformation:
				"Non-Authoritative Information"
			case .noContent:
				"No Content"
			case .resetContent:
				"Reset Content"
			case .partialContent:
				"Partial Content"
			case .multiStatus:
				"Multi-Status"
			case .alreadyReported:
				"Already Reported"
			case .imUsed:
				"IM Used"
			case .multipleChoices:
				"Multiple Choices"
			case .movedPermanently:
				"Moved Permanently"
			case .found:
				"Found"
			case .seeOther:
				"See Other"
			case .notModified:
				"Not Modified"
			case .useProxy:
				"Use Proxy"
			case .temporaryRedirect:
				"Temporary Redirect"
			case .permanentRedirect:
				"Permanent Redirect"
			case .badRequest:
				"Bad Request"
			case .unauthorized:
				"Unauthorized"
			case .paymentRequired:
				"Payment Required"
			case .forbidden:
				"Forbidden"
			case .notFound:
				"Not Found"
			case .methodNotAllowed:
				"Method Not Allowed"
			case .notAcceptable:
				"Not Acceptable"
			case .proxyAuthenticationRequired:
				"Proxy Authentication Required"
			case .requestTimeout:
				"Request Timeout"
			case .conflict:
				"Conflict"
			case .gone:
				"Gone"
			case .lengthRequired:
				"Length Required"
			case .preconditionFailed:
				"Precondition Failed"
			case .payloadTooLarge:
				"Payload Too Large"
			case .uriTooLong:
				"URI Too Long"
			case .unsupportedMediaType:
				"Unsupported Media Type"
			case .rangeNotSatisfiable:
				"Range Not Satisfiable"
			case .expectationFailed:
				"Expectation Failed"
			case .imATeapot:
				"I'm a teapot"
			case .misdirectedRequest:
				"Misdirected Request"
			case .unprocessableEntity:
				"Unprocessable Entity"
			case .locked:
				"Locked"
			case .failedDependency:
				"Failed Dependency"
			case .upgradeRequired:
				"Upgrade Required"
			case .preconditionRequired:
				"Precondition Required"
			case .tooManyRequests:
				"Too Many Requests"
			case .requestHeaderFieldsTooLarge:
				"Request Header Fields Too Large"
			case .unavailableForLegalReasons:
				"Unavailable For Legal Reasons"
			case .internalServerError:
				"Internal Server Error"
			case .notImplemented:
				"Not Implemented"
			case .badGateway:
				"Bad Gateway"
			case .serviceUnavailable:
				"Service Unavailable"
			case .gatewayTimeout:
				"Gateway Timeout"
			case .httpVersionNotSupported:
				"HTTP Version Not Supported"
			case .variantAlsoNegotiates:
				"Variant Also Negotiates"
			case .insufficientStorage:
				"Insufficient Storage"
			case .loopDetected:
				"Loop Detected"
			case .notExtended:
				"Not Extended"
			case .networkAuthenticationRequired:
				"Network Authentication Required"
			case .custom(code: _, reasonPhrase: let phrase):
				phrase
			}
		}
	}
}

extension HTTPStatus: Hashable {}

extension HTTPStatus: CustomStringConvertible {
	/// A description following
	/// "XXX Reason Phrase" format, where XXX is the status code.
	public var description: String {
		"\(code) \(reasonPhrase)"
	}
}

extension HTTPStatus: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self.init(statusCode: value)
	}
}
