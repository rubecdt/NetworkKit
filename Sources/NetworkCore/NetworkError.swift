//
//  NetworkError.swift
//  NetworkCore
//
//  Created by rubecdt on 15/11/23.
//

import Foundation

/// Represents errors that occur during network operations.
public enum NetworkError: LocalizedError, CustomDebugStringConvertible {
	/// A general error wrapping any underlying error not covered by other cases.
	case general(Error)
	/// A non-success HTTP status code.
	case status(HTTPStatus)
	/// The received data is invalid.
	case invalidData
	/// An error occurred during JSON processing.
	case json(Error)
	/// An unknown error occurred.
	case unknown
	/// The response is not a valid HTTP response.
	case nonHTTPResponse
	
	@inlinable
	public static func status(_ code: Int) -> NetworkError {
		.status(HTTPStatus(statusCode: code))
	}
    
    public var errorDescription: String? {
        switch self {
        case .general(let error):
            "Error: \(error.localizedDescription)"
        case .status(let httpStatus):
			"Unexpected HTTP status: \(httpStatus)"
        case .invalidData:
            "Content does not match expectation"
        case .unknown:
            "Unknown error"
        case .nonHTTPResponse:
			"The given response is not HTTP"
        case let .json(error):
			error.localizedDescription
		}
    }
	
	public var debugDescription: String {
		switch self {
		case .general(let error):
			"Error: \(error)"
		case .status(let httpStatus):
			"Unexpected HTTP status: \(httpStatus)"
		case .invalidData:
			"Content does not match expectation"
		case .json(let error):
			"JSON error: \(error)"
		case .unknown:
			"Unknown error"
		case .nonHTTPResponse:
			"The given response is not HTTP"
		}
	}
}

extension NetworkError {
	public init(from error: Error) {
		self = switch error {
		case let error as NetworkError:
			error
		case let error as DecodingError:
			NetworkError.json(error)
		default:
			NetworkError.general(error)
		}
	}
}
