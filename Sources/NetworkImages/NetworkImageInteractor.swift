//
//  NetworkImageInteractor.swift
//	NetworkImages
//
//  Created by rubecdt on 24/4/24.
//

#if canImport(UIKit)
public import UIKit
public typealias PlatformImage = UIImage
#else
public import AppKit
public typealias PlatformImage = NSImage
#endif
public import NetworkCore

/// A protocol defining the interface for fetching images over the network.
///
/// This protocol extends `NetworkInteractor` and provides an asynchronous method
/// for downloading images while ensuring type safety with `PlatformImage`.
public protocol NetworkImageInteractor: NetworkInteractor {
	nonisolated func fetchImage(from url: URL) async throws/*(NetworkError)*/ -> sending PlatformImage
}

public extension NetworkImageInteractor {
	/// Default implementation of `fetchImage(from:)`, providing a generic way to download images.
	///
	/// This method uses `fetch(for:_:)` from `NetworkInteractor` to make a GET request to the given URL
	/// and attempts to convert the downloaded `Data` into a `PlatformImage`.
	///
	/// - Parameter url: The URL of the image to fetch.
	/// - Throws:
	///   - `NetworkError.invalidData` if the response data is not a valid image.
	///   - Any error thrown by `fetch(for:_:)`.
	/// - Returns: The downloaded `PlatformImage`.
	func fetchImage(from url: URL) async throws/*(NetworkError)*/ -> sending PlatformImage {
		try await fetch(for: .get(url: url)) { data throws(NetworkError) in
			guard let image = PlatformImage(data: data) else {
				throw NetworkError.invalidData
			}
			return image
		}
	}
}
