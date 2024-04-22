//
//  TaskSleep.swift
//  NetworkKit
//
//  Created by rubecdt on 22/02/2025.
//

public extension Task where Never == Success, Never == Failure {
	
	@available(iOS, introduced: 15, deprecated: 16, message: "Use 'Duration' API on iOS 16 or later.")
	@available(macOS, introduced: 12, deprecated: 13, message: "Use 'Duration' API on macOS 13 or later.")
	@_disfavoredOverload
	static func sleep(for duration: DurationFallback) async throws {
		if #available(iOS 16, macOS 13, *) {
			let duration = duration.duration
			try await Task.sleep(for: duration, tolerance: nil) // ✅ New API
		} else {
			let nanoseconds = UInt64(duration.nanoseconds)
			try await Task.sleep(nanoseconds: nanoseconds) // ✅ Legacy API
		}
	}
}

