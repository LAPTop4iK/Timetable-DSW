//
//  DateServiceTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import XCTest
@testable import Timetable_DSW

final class DateServiceTests: XCTestCase {

    var sut: DefaultDateService!
    var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        sut = DefaultDateService(calendar: calendar)
    }

    override func tearDown() {
        sut = nil
        calendar = nil
        super.tearDown()
    }

    // MARK: - ISO8601 Parsing Tests

    func testParseISO8601_StandardFormatWithMilliseconds() {
        // Given
        let isoString = "2025-10-31T10:00:00.000Z"

        // When
        let result = sut.parseISO8601(isoString)

        // Then
        XCTAssertNotNil(result, "Should parse standard ISO8601 with milliseconds")
        if let date = result {
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 10)
            XCTAssertEqual(components.day, 31)
            XCTAssertEqual(components.hour, 10)
            XCTAssertEqual(components.minute, 0)
            XCTAssertEqual(components.second, 0)
        }
    }

    func testParseISO8601_StandardFormatWithoutMilliseconds() {
        // Given
        let isoString = "2025-10-31T10:00:00Z"

        // When
        let result = sut.parseISO8601(isoString)

        // Then
        XCTAssertNotNil(result, "Should parse standard ISO8601 without milliseconds")
        if let date = result {
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 10)
            XCTAssertEqual(components.day, 31)
            XCTAssertEqual(components.hour, 10)
            XCTAssertEqual(components.minute, 0)
            XCTAssertEqual(components.second, 0)
        }
    }

    func testParseISO8601_WithPositiveTimezoneOffset() {
        // Given
        let isoString = "2025-10-31T13:00:00.000+03:00"

        // When
        let result = sut.parseISO8601(isoString)

        // Then
        XCTAssertNotNil(result, "Should parse ISO8601 with positive timezone offset")
        if let date = result {
            // Конвертируем в UTC для проверки
            var utcCalendar = Calendar(identifier: .gregorian)
            utcCalendar.timeZone = TimeZone(identifier: "UTC")!
            let components = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 10)
            XCTAssertEqual(components.day, 31)
            XCTAssertEqual(components.hour, 10) // 13:00 +03:00 = 10:00 UTC
            XCTAssertEqual(components.minute, 0)
            XCTAssertEqual(components.second, 0)
        }
    }

    func testParseISO8601_WithNegativeTimezoneOffset() {
        // Given
        let isoString = "2025-10-31T05:00:00.000-05:00"

        // When
        let result = sut.parseISO8601(isoString)

        // Then
        XCTAssertNotNil(result, "Should parse ISO8601 with negative timezone offset")
        if let date = result {
            var utcCalendar = Calendar(identifier: .gregorian)
            utcCalendar.timeZone = TimeZone(identifier: "UTC")!
            let components = utcCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            XCTAssertEqual(components.year, 2025)
            XCTAssertEqual(components.month, 10)
            XCTAssertEqual(components.day, 31)
            XCTAssertEqual(components.hour, 10) // 05:00 -05:00 = 10:00 UTC
            XCTAssertEqual(components.minute, 0)
            XCTAssertEqual(components.second, 0)
        }
    }

    func testParseISO8601_WithVariousMillisecondPrecisions() {
        // Given
        let strings = [
            "2025-10-31T10:00:00.1Z",     // 1 digit
            "2025-10-31T10:00:00.12Z",    // 2 digits
            "2025-10-31T10:00:00.123Z",   // 3 digits
            "2025-10-31T10:00:00.1234Z"   // 4 digits
        ]

        // When & Then
        for isoString in strings {
            let result = sut.parseISO8601(isoString)
            XCTAssertNotNil(result, "Should parse ISO8601 with various millisecond precisions: \(isoString)")
        }
    }

    func testParseISO8601_InvalidFormat() {
        // Given
        let invalidStrings = [
            "2025-31-10T10:00:00Z",     // Invalid date order
            "2025-10-31 10:00:00Z",      // Space instead of T
            "2025-10-31",                 // Missing time
            "not a date",                 // Random string
            ""                            // Empty string
        ]

        // When & Then
        for invalidString in invalidStrings {
            let result = sut.parseISO8601(invalidString)
            XCTAssertNil(result, "Should return nil for invalid format: \(invalidString)")
        }
    }

    func testParseISO8601_EdgeCases() {
        // Given
        let edgeCases = [
            "2025-01-01T00:00:00.000Z",   // Start of year
            "2025-12-31T23:59:59.999Z",   // End of year
            "2025-02-28T12:00:00.000Z",   // Non-leap year Feb 28
            "2024-02-29T12:00:00.000Z"    // Leap year Feb 29
        ]

        // When & Then
        for isoString in edgeCases {
            let result = sut.parseISO8601(isoString)
            XCTAssertNotNil(result, "Should parse edge case: \(isoString)")
        }
    }

    // MARK: - Greeting Tests

    func testGreeting_Morning() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3
        components.hour = 8
        components.minute = 0
        let date = calendar.date(from: components)!

        // When
        let greeting = sut.greeting(for: date)

        // Then
        XCTAssertEqual(greeting, LocalizedString.greetingMorning.localized)
    }

    func testGreeting_Afternoon() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3
        components.hour = 14
        components.minute = 0
        let date = calendar.date(from: components)!

        // When
        let greeting = sut.greeting(for: date)

        // Then
        XCTAssertEqual(greeting, LocalizedString.greetingAfternoon.localized)
    }

    func testGreeting_Evening() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3
        components.hour = 19
        components.minute = 0
        let date = calendar.date(from: components)!

        // When
        let greeting = sut.greeting(for: date)

        // Then
        XCTAssertEqual(greeting, LocalizedString.greetingEvening.localized)
    }

    func testGreeting_Night() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3
        components.hour = 2
        components.minute = 0
        let date = calendar.date(from: components)!

        // When
        let greeting = sut.greeting(for: date)

        // Then
        XCTAssertEqual(greeting, LocalizedString.greetingNight.localized)
    }

    // MARK: - Date Formatting Tests

    func testFormatTime() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3
        components.hour = 14
        components.minute = 30
        let date = calendar.date(from: components)!

        // When
        let formattedTime = sut.formatTime(date)

        // Then
        XCTAssertEqual(formattedTime, "14:30")
    }

    func testWeekdayShort() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3 // Monday
        let date = calendar.date(from: components)!

        // When
        let weekday = sut.weekdayShort(date)

        // Then
        XCTAssertFalse(weekday.isEmpty, "Should return non-empty weekday")
        XCTAssertEqual(weekday, weekday.uppercased(), "Should be uppercase")
    }

    func testDayNumber() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3
        let date = calendar.date(from: components)!

        // When
        let day = sut.dayNumber(date)

        // Then
        XCTAssertEqual(day, "03")
    }

    func testDayNumber_SingleDigit() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 5
        let date = calendar.date(from: components)!

        // When
        let day = sut.dayNumber(date)

        // Then
        XCTAssertEqual(day, "05", "Should pad single digit with zero")
    }

    // MARK: - Week Calculation Tests

    func testStartOfWeek() {
        // Given - любой день недели
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 5 // Wednesday
        let date = calendar.date(from: components)!

        // When
        let startOfWeek = sut.startOfWeek(for: date)

        // Then
        let weekday = calendar.component(.weekday, from: startOfWeek)
        // Weekday 1 = Sunday (в Gregorian календаре)
        XCTAssertTrue([1, 2].contains(weekday), "Start of week should be Sunday or Monday")
    }

    func testDaysInWeek() {
        // Given
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 3
        let date = calendar.date(from: components)!

        // When
        let days = sut.daysInWeek(startingFrom: date)

        // Then
        XCTAssertEqual(days.count, 7, "Should return 7 days")

        // Проверяем что каждый следующий день на 1 больше
        for i in 0..<6 {
            let currentDay = calendar.component(.day, from: days[i])
            let nextDay = calendar.component(.day, from: days[i + 1])

            // Учитываем переход месяца
            if currentDay < 28 {
                XCTAssertEqual(nextDay, currentDay + 1, "Days should be consecutive")
            }
        }
    }

    // MARK: - Performance Tests

    func testParseISO8601_Performance() {
        // Given
        let isoString = "2025-10-31T10:00:00.000Z"

        // When & Then
        measure {
            for _ in 0..<1000 {
                _ = sut.parseISO8601(isoString)
            }
        }
    }

    func testParseISO8601_FastParserVsFallback() {
        // Given
        let standardFormat = "2025-10-31T10:00:00.000Z"

        // When
        let date1 = sut.parseISO8601(standardFormat)

        // Then
        XCTAssertNotNil(date1, "Fast parser should handle standard format")
    }
}
