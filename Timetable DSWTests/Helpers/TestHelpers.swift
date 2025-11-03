//
//  TestHelpers.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation

// MARK: - Test Timeout Constants

enum TestTimeout {
    static let short: TimeInterval = 1.0
    static let normal: TimeInterval = 2.0
    static let long: TimeInterval = 5.0
    static let veryLong: TimeInterval = 10.0
}

// MARK: - Test Step Execution (BDD-style)

/// Executes a test step with a descriptive message (Given/When/Then style)
/// - Parameters:
///   - description: Human-readable description of the step (e.g., "Given user is logged in")
///   - file: Source file (auto-captured)
///   - line: Source line (auto-captured)
///   - action: The test action to perform
/// - Returns: The result of the action
func step<T>(
    _ description: String,
    file: StaticString = #file,
    line: UInt = #line,
    action: () throws -> T
) rethrows -> T {
    print("📋 Step: \(description)")
    return try action()
}

/// Async version of step execution for async test operations
/// - Parameters:
///   - description: Human-readable description of the step
///   - file: Source file (auto-captured)
///   - line: Source line (auto-captured)
///   - action: The async test action to perform
/// - Returns: The result of the action
func step<T>(
    _ description: String,
    file: StaticString = #file,
    line: UInt = #line,
    action: () async throws -> T
) async rethrows -> T {
    print("📋 Step: \(description)")
    return try await action()
}

/// Version without return value for side-effect steps
/// - Parameters:
///   - description: Human-readable description of the step
///   - file: Source file (auto-captured)
///   - line: Source line (auto-captured)
///   - action: The test action to perform
func step(
    _ description: String,
    file: StaticString = #file,
    line: UInt = #line,
    action: () throws -> Void
) rethrows {
    print("📋 Step: \(description)")
    try action()
}

/// Async version without return value
/// - Parameters:
///   - description: Human-readable description of the step
///   - file: Source file (auto-captured)
///   - line: Source line (auto-captured)
///   - action: The async test action to perform
func step(
    _ description: String,
    file: StaticString = #file,
    line: UInt = #line,
    action: () async throws -> Void
) async rethrows {
    print("📋 Step: \(description)")
    try await action()
}

// MARK: - Date Helpers

extension Date {

    /// Create a date from components for testing
    /// - Parameters:
    ///   - year: Year component
    ///   - month: Month component (1-12)
    ///   - day: Day component (1-31)
    ///   - hour: Hour component (0-23), default 0
    ///   - minute: Minute component (0-59), default 0
    ///   - second: Second component (0-59), default 0
    ///   - calendar: Calendar to use, default .current
    /// - Returns: Date created from components
    static func make(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        calendar: Calendar = .current
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second

        return calendar.date(from: components)!
    }

    /// Check if two dates are equal within tolerance
    /// - Parameters:
    ///   - other: Date to compare with
    ///   - tolerance: Tolerance in seconds, default 1.0
    /// - Returns: true if dates are within tolerance
    func isEqual(to other: Date, withTolerance tolerance: TimeInterval = 1.0) -> Bool {
        abs(timeIntervalSince(other)) < tolerance
    }
}

// MARK: - String Helpers for Testing

extension String {

    /// Create an ISO8601 string for testing
    /// - Parameters:
    ///   - year: Year (e.g., 2025)
    ///   - month: Month (1-12)
    ///   - day: Day (1-31)
    ///   - hour: Hour (0-23)
    ///   - minute: Minute (0-59)
    ///   - second: Second (0-59)
    ///   - milliseconds: Milliseconds (0-999), default 0
    ///   - timezone: Timezone string (e.g., "Z", "+03:00"), default "Z"
    /// - Returns: ISO8601 formatted string
    static func makeISO8601(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        milliseconds: Int = 0,
        timezone: String = "Z"
    ) -> String {
        String(format: "%04d-%02d-%02dT%02d:%02d:%02d.%03d%@",
               year, month, day, hour, minute, second, milliseconds, timezone)
    }
}

// MARK: - JSON Helpers

enum JSONTestHelper {

    /// Decode JSON string to model
    /// - Parameters:
    ///   - type: The Decodable type to decode to
    ///   - jsonString: JSON string to decode
    /// - Returns: Decoded model instance
    /// - Throws: TestError or DecodingError
    static func decode<T: Decodable>(_ type: T.Type, from jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw TestError.invalidJSON
        }
        return try JSONDecoder().decode(type, from: data)
    }

    /// Encode model to JSON string
    /// - Parameter value: The Encodable value to encode
    /// - Returns: Pretty-printed JSON string
    /// - Throws: TestError or EncodingError
    static func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(value)
        guard let string = String(data: data, encoding: .utf8) else {
            throw TestError.encodingFailed
        }
        return string
    }

    enum TestError: Error {
        case invalidJSON
        case encodingFailed
    }
}

// MARK: - Async Wait Helper

/// Wait for an async condition to be satisfied (useful in Swift Testing)
/// - Parameters:
///   - condition: Async closure returning Bool
///   - timeout: Maximum time to wait in seconds, default TestTimeout.normal
///   - description: Description for debugging, default "Condition"
/// - Returns: true if condition was satisfied, false if timed out
func waitFor(
    condition: @escaping () async -> Bool,
    timeout: TimeInterval = TestTimeout.normal,
    description: String = "Condition"
) async -> Bool {
    let startTime = Date()
    while !await condition() {
        if Date().timeIntervalSince(startTime) > timeout {
            print("⚠️ \(description) not satisfied within \(timeout) seconds")
            return false
        }
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
    }
    return true
}
