//
//  DurationFallbackTests.swift
//  NetworkKit
//
//  Created by rubecdt on 22/02/2025.
//

import Testing
@testable import NetworkMocks

@Suite("DurationFallbackTests")
struct DurationFallbackTests {
	
    // MARK: - Seconds
	
	@Test("Seconds factory method (Integer)",
		  arguments: [
		(-1, 0),
		(1, 1_000_000_000),
		(5, 5_000_000_000),
		(1_234, 1_234_000_000_000),
		(.max, .max)
	])
	func seconds(
		_ value: Int,
		_ expectedNanoseconds: UInt64
	) {
		let duration = DurationFallback.seconds(value)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
    }

	@Test("Seconds factory method (Double)",
		  arguments: [
		(-1, 0),
		(1, 1_000_000_000),
		(1.5, 1_500_000_000),
		(0.1, 100_000_000),
		(1.234, 1_234_000_000)
		  ])
	func secondsDouble(
		_ value: Double,
		_ expectedNanoseconds: UInt64
	) throws {
		let duration = DurationFallback.seconds(value)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
	}
	
	// MARK: - Milliseconds
	
	@Test("Milliseconds factory method (Integer)",
		  arguments: [
			(-1, 0),
			(1, 1_000_000),
			(5, 5_000_000),
			(1_234, 1_234_000_000)
		  ])
	func milliseconds(
		_ value: Int,
		_ expectedNanoseconds: UInt64
	) {
		let duration = DurationFallback.milliseconds(value)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
	}
	
	@Test("Milliseconds factory method (Double)",
		  arguments: [
			(-1.0, 0),
			(1.0, 1_000_000),
			(0.5, 500_000),
			(123.456, 123_456_000)
		  ])
	func millisecondsDouble(
		_ value: Double,
		_ expectedNanoseconds: UInt64
	) {
		let duration = DurationFallback.milliseconds(value)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
	}
	
	// MARK: - Microseconds
	
	@Test("Microseconds factory method (Integer)",
		  arguments: [
			(-1, 0),
			(1, 1_000),
			(5, 5_000),
			(1_234, 1_234_000)
		  ])
	func microseconds(
		_ value: Int,
		_ expectedNanoseconds: UInt64
	) {
		let duration = DurationFallback.microseconds(value)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
	}
	
	@Test("Microseconds factory method (Double)",
		  arguments: [
			(-1.0, 0),
			(1.0, 1_000),
			(0.5, 500),
			(123.456, 123_456)
		  ])
	func microsecondsDouble(
		_ value: Double,
		_ expectedNanoseconds: UInt64
	) {
		let duration = DurationFallback.microseconds(value)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
	}
    // MARK: - Nanoseconds

	@Test("Nanoseconds factory method",
		  arguments: [
			(0, 0),
			(123456, 123456),
			(1, 1),
			(999999999, 999999999)
		  ])
	func nanoseconds(
		_ value: UInt64,
		_ expectedNanoseconds: UInt64
	) {
		let duration = DurationFallback.nanoseconds(value)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
	}

    // MARK: - Overflow saturation

    @Test("Overflow should return UInt64.max",
		  arguments: [
		(UInt64((UInt64.max / 1_000_000_000) + 1), UInt64.max),
		(UInt64((UInt64.max / 1_000_000) + 1), UInt64.max),
		(UInt64((UInt64.max / 1_000) + 1), UInt64.max)
	])
	func testOverflowClamping(
		_ hugeValue: UInt64,
		_ expectedNanoseconds: UInt64
	) {
		let duration = DurationFallback.seconds(hugeValue)
		#expect(duration.nanoseconds == expectedNanoseconds,
				failureComment(duration, expectedNanoseconds))
		#expect(duration.nanoseconds >= 0, "Converted nanoseconds value must be positive.")
	}
}

extension DurationFallbackTests {
	fileprivate func failureComment(
		_ duration: DurationFallback,
		_ expectedNanoseconds: UInt64
	) -> Comment {
		let (value, type): (String, String) = switch duration.value {
		case .double(let value):
			(value.formatted(), String(describing: Double.self))
		case .integer(let value):
			(value.formatted(), String(describing: type(of: value).self))
		}
		return "\(value) \(duration.unit) (\(type)) should convert to \(expectedNanoseconds.formatted()) nanoseconds"
	}
}


extension DurationFallbackTests {
	// MARK: - Pruebas para seconds → Duration
	
	@Test("seconds(Integer) → Duration",
//		  .__available("iOS", introduced: (16,0,0), message: nil, sourceLocation: .__here(), {true}),
		  arguments: [
		(1, Duration.seconds(1)),
		(5, Duration.seconds(5)),
		(1_234, Duration.seconds(1_234)),
		(.max, Duration.seconds(Int64.max)) // Saturación en Duration
	])
	@available(iOS, introduced: 16)
	@available(macOS, introduced: 13)
	func secondsToDuration(
		_ value: Int,
		_ expectedDuration: Duration
	) {
		let duration = DurationFallback.seconds(value)
		#expect(duration.duration == expectedDuration,
				failureComment(duration, expectedDuration))
	}

	@Test("seconds(Double) → Duration",
		  arguments: [
		(1.0, Duration.seconds(1)),
		(1.5, Duration.seconds(1.5)),
		(0.1, Duration.seconds(0.1)),
		(1.234, Duration.seconds(1.234))
	])
	@available(iOS, introduced: 16)
	@available(macOS, introduced: 13)
	func secondsDoubleToDuration(
		_ value: Double,
		_ expectedDuration: Duration
	) {
		let duration = DurationFallback.seconds(value)
		#expect(duration.duration == expectedDuration,
				failureComment(duration, expectedDuration))
	}

	// MARK: - Pruebas para milliseconds → Duration
	
	@Test("milliseconds(Integer) → Duration",
		  arguments: [
		(1, Duration.milliseconds(1)),
		(5, Duration.milliseconds(5)),
		(1_234, Duration.milliseconds(1_234))
	])
	@available(iOS, introduced: 16)
	@available(macOS, introduced: 13)
	func millisecondsToDuration(
		_ value: Int,
		_ expectedDuration: Duration
	) {
		let duration = DurationFallback.milliseconds(value)
		#expect(duration.duration == expectedDuration,
				failureComment(duration, expectedDuration))
	}

	@Test("milliseconds(Double) → Duration",
		  arguments: [
		(1.0, Duration.milliseconds(1)),
		(0.5, Duration.milliseconds(0.5)),
		(123.456, Duration.milliseconds(123.456))
	])
	@available(iOS, introduced: 16)
	@available(macOS, introduced: 13)
	func millisecondsDoubleToDuration(
		_ value: Double,
		_ expectedDuration: Duration
	) {
		let duration = DurationFallback.milliseconds(value)
		#expect(duration.duration == expectedDuration,
				failureComment(duration, expectedDuration))
	}

	// MARK: - Pruebas para microseconds → Duration
	
	@Test("microseconds(Integer) → Duration",
		  arguments: [
		(1, Duration.microseconds(1)),
		(5, Duration.microseconds(5)),
		(1_234, Duration.microseconds(1_234))
	])
	@available(iOS, introduced: 16)
	@available(macOS, introduced: 13)
	func microsecondsToDuration(
		_ value: Int,
		_ expectedDuration: Duration
	) {
		let duration = DurationFallback.microseconds(value)
		#expect(duration.duration == expectedDuration,
				failureComment(duration, expectedDuration))
	}

	@Test("microseconds(Double) → Duration",
		  arguments: [
		(1.0, Duration.microseconds(1)),
		(0.5, Duration.microseconds(0.5)),
		(123.456, Duration.microseconds(123.456))
	])
	@available(iOS, introduced: 16)
	@available(macOS, introduced: 13)
	func microsecondsDoubleToDuration(
		_ value: Double,
		_ expectedDuration: Duration
	) {
		let duration = DurationFallback.microseconds(value)
		#expect(duration.duration == expectedDuration,
				failureComment(duration, expectedDuration))
	}

	// MARK: - Pruebas para nanoseconds → Duration

	@Test("nanoseconds → Duration",
		  arguments: [(UInt64,Duration)](arrayLiteral:
					(0, .nanoseconds(0)),
					(123456, .nanoseconds(123456)),
					(1, .nanoseconds(1)),
					(999999999, .nanoseconds(999999999)))
	)
	@available(iOS, introduced: 16)
	@available(macOS, introduced: 13)
	func nanosecondsToDuration(
		_ value: UInt64,
		_ expectedDuration: Duration
	) {
		let duration = DurationFallback.nanoseconds(value)
		#expect(duration.duration == expectedDuration,
				failureComment(duration, expectedDuration))
	}
}

@available(iOS, introduced: 16)
@available(macOS, introduced: 13)
extension DurationFallbackTests {
	private func failureComment(
		_ duration: DurationFallback,
		_ expectedDuration: Duration
	) -> Comment {
		let (value, type): (String, String) = switch duration.value {
		case .double(let value):
			(value.formatted(), String(describing: Double.self))
		case .integer(let value):
			(value.formatted(), String(describing: type(of: value).self))
		}
		return "\(value) \(duration.unit) (\(type)) should convert to \(expectedDuration)"
	}
}
