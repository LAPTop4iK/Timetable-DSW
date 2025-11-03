//
//  MockDateService.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

// MARK: - Mock Date Service

/// Mock implementation of DateService for testing
/// Allows control over date/time behavior in tests
final class MockDateService: DateService {

    // MARK: - Properties

    private(set) var parseISO8601CallCount: Int = 0
    private(set) var greetingCallCount: Int = 0
    private(set) var formatDateCallCount: Int = 0
    private(set) var formatTimeCallCount: Int = 0

    var currentDate: Date = Date()
    var shouldFailParsing: Bool = false
    var mockedGreeting: String = "Test Greeting"

    // MARK: - DateService Protocol Implementation

    func greeting(for date: Date) -> String {
        greetingCallCount += 1
        return mockedGreeting
    }

    func formatDate(_ date: Date) -> String {
        formatDateCallCount += 1
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        formatTimeCallCount += 1
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func weekdayShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    func weekdayFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }

    func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }

    func startOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }

    func daysInWeek(startingFrom date: Date) -> [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: date)
        }
    }

    func parseISO8601(_ string: String) -> Date? {
        parseISO8601CallCount += 1

        if shouldFailParsing {
            return nil
        }

        // Use real parser for testing
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string) ?? ISO8601DateFormatter().date(from: string)
    }

    // MARK: - Test Configuration Methods

    func setCurrentDate(_ date: Date) {
        currentDate = date
    }

    func setGreeting(_ greeting: String) {
        mockedGreeting = greeting
    }

    func setShouldFailParsing(_ shouldFail: Bool) {
        shouldFailParsing = shouldFail
    }

    func reset() {
        parseISO8601CallCount = 0
        greetingCallCount = 0
        formatDateCallCount = 0
        formatTimeCallCount = 0
        currentDate = Date()
        shouldFailParsing = false
        mockedGreeting = "Test Greeting"
    }

    // MARK: - Verification Methods

    func verifyParseISO8601Called(times: Int) -> Bool {
        parseISO8601CallCount == times
    }

    func verifyGreetingCalled(times: Int) -> Bool {
        greetingCallCount == times
    }
}
