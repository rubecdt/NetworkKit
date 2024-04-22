//
//  DurationFallback.swift
//  NetworkKit
//
//  Created by rubecdt on 22/02/2025.
//

import Foundation

//#if swift(<5.7)
@available(iOS, introduced: 15, deprecated: 16, message: "Use 'Duration' API on iOS 16 or later.")
@available(macOS, introduced: 12, deprecated: 13, message: "Use 'Duration' API on macOS 13 or later.")
public struct DurationFallback {
	let value: Value
	let unit: Unit
	
	public enum Value {
		case integer(any BinaryInteger)
		case double(Double)
	}
	
	public enum Unit: Sendable {
		case seconds
		case milliseconds
		case microseconds
		case nanoseconds
		
		fileprivate var nanosecondsEquivalence: UInt64 {
			switch self {
			case .seconds: 		1_000_000_000
			case .milliseconds: 	1_000_000
			case .microseconds: 		1_000
			case .nanoseconds: 				1
			}
		}
	}

	public static func seconds<Integer: BinaryInteger>(_ value: Integer) -> DurationFallback {
		DurationFallback(.integer(value), unit: .seconds)
	}
	
	public static func seconds(_ value: Double) -> DurationFallback {
		DurationFallback(.double(value), unit: .seconds)
	}
	
	public static func milliseconds(_ value: Double) -> DurationFallback {
		DurationFallback(.double(value), unit: .milliseconds)
	}
	
	public static func milliseconds<Integer: BinaryInteger>(_ value: Integer) -> DurationFallback {
		DurationFallback(.integer(value), unit: .milliseconds)
	}
	
	public static func microseconds(_ value: Double) -> DurationFallback {
		DurationFallback(.double(value), unit: .microseconds)
	}
	
	public static func microseconds<Integer: BinaryInteger>(_ value: Integer) -> DurationFallback {
		DurationFallback(.integer(value), unit: .microseconds)
	}
	
	public static func nanoseconds(_ value: UInt64) -> DurationFallback {
		DurationFallback(.integer(value), unit: .nanoseconds)
	}
	
	@available(iOS, introduced: 15, deprecated: 16)
	@available(macOS, introduced: 12, deprecated: 13)
	var nanoseconds: UInt64 {
		let factor = unit.nanosecondsEquivalence
		switch value {
		case .integer(let intValue):
			let clamped = UInt64(clamping: intValue)
			let (result, overflow) = clamped.multipliedReportingOverflow(by: factor)
			return overflow ? UInt64.max : result
		case .double(let value):
			guard value > 0 else {
				return 0
			}
			// Minimize rounding errors, splitting integer and fractional part
			let (integerPart, fractionalPart) = modf(value)
			let (integerNanoseconds, integerDidOverflow) = UInt64(integerPart).multipliedReportingOverflow(by: factor)
			guard !integerDidOverflow else { return UInt64.max }
			let (fractionalNanoseconds) = UInt64((fractionalPart * Double(factor)).rounded())
			let (total, sumDidOverflow) = integerNanoseconds.addingReportingOverflow(fractionalNanoseconds)
			guard !sumDidOverflow else { return UInt64.max }
			return total
		}
	}
	
	@available(iOS 16, macOS 13.0, *)
	var duration: Duration {
		switch (value, unit) {
		case (.integer(let value), .nanoseconds):
			.nanoseconds(value)
		case (.integer(let value), .microseconds):
			.microseconds(value)
		case (.double(let value), .microseconds):
			.microseconds(value)
		case (.integer(let value), .milliseconds):
			.milliseconds(value)
		case (.double(let value), .milliseconds):
			.milliseconds(value)
		case (.double(let value), .seconds):
			.seconds(value)
		case (.integer(let value), .seconds):
			.seconds(value)
		case (.double(let value), .nanoseconds):
			.nanoseconds(UInt64(value))
		}
	}
	
	private init(
		_ value: Value,
		unit: Unit
	) {
		self.value = value
		self.unit = unit
	}
}
//#endif

#if !canImport(_Concurrency)
let a = 0
#endif
