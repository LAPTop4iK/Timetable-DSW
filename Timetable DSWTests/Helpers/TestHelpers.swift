//
//  TestHelpers.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
import XCTest

// MARK: - Test Timeout Constants

enum TestTimeout {
    static let short: TimeInterval = 1.0
    static let normal: TimeInterval = 2.0
    static let long: TimeInterval = 5.0
    static let veryLong: TimeInterval = 10.0
}

// MARK: - Test Step Execution

/// Executes a test step with a descriptive message
/// - Parameters:
///   - description: Human-readable description of the step
///   - file: Source file (auto-captured)
///   - line: Source line (auto-captured)
///   - action: The test action to perform
func step<T>(
    _ description: String,
    file: StaticString = #file,
    line: UInt = #line,
    action: () throws -> T
) rethrows -> T {
    print("📋 Step: \(description)")
    return try action()
}

/// Async version of step execution
func step<T>(
    _ description: String,
    file: StaticString = #file,
    line: UInt = #line,
    action: () async throws -> T
) async rethrows -> T {
    print("📋 Step: \(description)")
    return try await action()
}

// MARK: - XCTestCase Extensions

extension XCTestCase {

    /// Wait for an async condition to be satisfied
    func wait(
        for condition: @escaping () async -> Bool,
        timeout: TimeInterval = TestTimeout.normal,
        description: String = "Condition",
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        let startTime = Date()
        while !await condition() {
            if Date().timeIntervalSince(startTime) > timeout {
                XCTFail("\(description) not satisfied within \(timeout) seconds", file: file, line: line)
                return
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
    }

    /// Assert that an async operation throws a specific error
    func assertThrowsError<T, E: Error & Equatable>(
        _ expression: @autoclosure () async throws -> T,
        expectedError: E,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error \(expectedError) but no error was thrown", file: file, line: line)
        } catch let error as E {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail("Expected error \(expectedError) but got \(error)", file: file, line: line)
        }
    }

    /// Assert that an async operation throws any error
    func assertThrowsAnyError<T>(
        _ expression: @autoclosure () async throws -> T,
        file: StaticString = #file,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected an error to be thrown", file: file, line: line)
        } catch {
            // Success - error was thrown
        }
    }
}

// MARK: - Assertion Helpers

extension XCTestCase {

    /// Assert collection is not empty
    func assertNotEmpty<T: Collection>(
        _ collection: T,
        _ message: String = "Collection should not be empty",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertFalse(collection.isEmpty, message, file: file, line: line)
    }

    /// Assert collection has expected count
    func assertCount<T: Collection>(
        _ collection: T,
        equals expected: Int,
        _ message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let actualMessage = message ?? "Expected collection count to be \(expected), got \(collection.count)"
        XCTAssertEqual(collection.count, expected, actualMessage, file: file, line: line)
    }

    /// Assert optional value is not nil
    func assertNotNil<T>(
        _ value: T?,
        _ message: String = "Value should not be nil",
        file: StaticString = #file,
        line: UInt = #line
    ) -> T {
        guard let unwrapped = value else {
            XCTFail(message, file: file, line: line)
            fatalError("Assertion failed")
        }
        return unwrapped
    }
}

// MARK: - Date Helpers

extension Date {

    /// Create a date from components for testing
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
    func isEqual(to other: Date, withTolerance tolerance: TimeInterval = 1.0) -> Bool {
        abs(timeIntervalSince(other)) < tolerance
    }
}

// MARK: - String Helpers for Testing

extension String {

    /// Create an ISO8601 string for testing
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
    static func decode<T: Decodable>(_ type: T.Type, from jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw TestError.invalidJSON
        }
        return try JSONDecoder().decode(type, from: data)
    }

    /// Encode model to JSON string
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
