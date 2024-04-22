//
//  ImageDownloader.swift
//  NetworkImages
//
//  Created by rubecdt on 24/4/24.
//

import enum NetworkCore.NetworkError

#if canImport(UIKit)
public import UIKit
typealias ImageContainer = UIImage
#else
public import AppKit

/// A wrapper around `NSImage` to support safe concurrent access.
actor NSImageWrapper {
	private let storage: NSImage
	
	init(nsImage: NSImage) {
		self.storage = nsImage
	}
	
	/// Creates and returns a copy of the stored `NSImage` to ensure thread safety.
	/// - Throws: `NetworkError.invalidData` if the copy operation fails.
	/// - Returns: A thread-safe copy of the `NSImage`.
	func imageCopy() throws -> sending NSImage {
		try storage.copied()
	}
}

fileprivate extension NSImage {
	/// Creates a copy of the `NSImage` to prevent race conditions in concurrent access.
	/// - Throws: `NetworkError.invalidData` if the image cannot be copied.
	/// - Returns: A new copy of the image.
	func copied() throws -> sending NSImage {
		guard let tiffRepresentation,
			  let copy = NSImage(data: tiffRepresentation)
		else {
			throw NetworkError.invalidData
		}
		
		return copy
	}
}

/// Represents an image container for **macOS**, using `NSImageWrapper`.
typealias ImageContainer = NSImageWrapper
#endif

/// An actor responsible for downloading and caching images from remote sources.
///
/// This class manages network requests for images while ensuring thread safety through actor-based isolation.
/// It also caches downloaded images to prevent redundant network requests.
public actor ImageDownloader: NetworkImageInteractor {
	/// The session used for fetching images.
	public let session: URLSession
	
	public static let shared = ImageDownloader()
	
	/// Creates an `ImageDownloader` with a given session.
	/// - Parameter session: The `URLSession` to use for network requests (defaults to `.shared`).
	public init(session: URLSession = .shared) {
		self.session = session
	}
	
	private enum ImageStatus {
		case downloading(_ task: Task<ImageContainer, Error>)
		case downloaded(_ image: PlatformImage)
	}
	
	private var cache: [URL: ImageStatus] = [:]
	
	/// Fetches an image from a given URL while ensuring safe concurrent access.
	///
	/// If the image is already being downloaded, this method waits for the existing task to complete.
	/// If the image has already been downloaded, it returns the cached version.
	///
	/// - Parameter url: The URL of the image to fetch.
	/// - Throws: An error if the download fails.
	/// - Returns: The fetched image as `PlatformImage`.
	public nonisolated func fetchImage(from url: URL) async throws -> sending PlatformImage {
		try await isolatedFetchImage(from: url)
	}
	
	/// Handles the actual fetching of an image, with caching and task management.
	///
	/// - Parameter url: The URL of the image.
	/// - Throws: `NetworkError` if the image fetch fails.
	/// - Returns: A `PlatformImage` (either `UIImage` or `NSImageWrapper`).
	func isolatedFetchImage(from url: URL) async throws -> sending PlatformImage {
		if let imageStatus = cache[url] {
			switch imageStatus {
			case .downloading(let task):
				return try await task.value
				#if !canImport(UIKit)
					.imageCopy()
				#endif
			case .downloaded(let image):
			#if canImport(UIKit)
				return image
			#else
				return try image.copied()
			#endif
			}
		}
		
		let task = Task {
			#if canImport(UIKit)
			try await session.fetchImage(from: url)
			#else
			try await NSImageWrapper(nsImage: session.fetchImage(from: url))
			#endif
		}
		
		cache[url] = .downloading(task)
		
		do {
			#if canImport(UIKit)
			let image = try await task.value
			cache[url] = .downloaded(image)
			return image
			#else
			let image = try await task.value.imageCopy()
			cache[url] = .downloaded(image)
			return try image.copied()
			#endif
		} catch {
			cache.removeValue(forKey: url)
			throw error
		}
	}
}

extension URLSession: NetworkImageInteractor {}
