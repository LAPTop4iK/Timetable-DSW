//
//  DateServiceTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Testing
import Foundation
@testable import Timetable_DSW

@Suite("DateService Tests")
struct DateServiceTests {

    let sut: DefaultDateService
    let calendar: Calendar

    init() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        self.calendar = calendar
        self.sut = DefaultDateService(calendar: calendar)
    }

    // MARK: - ISO8601 Parsing Tests

    @Suite("ISO8601 Parsing")
    struct ISO8601ParsingTests {
        let sut: DefaultDateService
        let calendar: Calendar

        init() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            self.calendar = calendar
            self.sut = DefaultDateService(calendar: calendar)
        }

        @Test("Parse standard ISO8601 formats", arguments: [
            ("2025-10-31T10:00:00.000Z", 2025, 10, 31, 10, 0, 0),
            ("2025-10-31T10:00:00Z", 2025, 10, 31, 10, 0, 0)
        ])
        func parseStandardFormats(
            isoString: String,
            year: Int, month: Int, day: Int,
            hour: Int, minute: Int, second: Int
        ) {
            // When
            let result = sut.parseISO8601(isoString)

            // Then
            #expect(result != nil)
            if let date = result {
                let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                #expect(components.year == year)
                #expect(components.month == month)
                #expect(components.day == day)
                #expect(components.hour == hour)
                #expect(components.minute == minute)
                #expect(components.second == second)
            }
        }

        @Test("Parse ISO8601 with timezone offsets", arguments: [
            "2025-10-31T13:00:00.000+03:00",  // Positive offset
            "2025-10-31T05:00:00.000-05:00"   // Negative offset
        ])
        func parseWithTimezoneOffsets(isoString: String) {
            // When
            let result = sut.parseISO8601(isoString)

            // Then
            #expect(result != nil)
            if let date = result {
                var utcCalendar = Calendar(identifier: .gregorian)
                utcCalendar.timeZone = TimeZone(identifier: "UTC")!
                let components = utcCalendar.dateComponents([.year, .month, .day, .hour], from: date)
                // Both should convert to 10:00 UTC
                #expect(components.hour == 10)
            }
        }

        @Test("Parse ISO8601 with various millisecond precisions", arguments: [
            "2025-10-31T10:00:00.1Z",
            "2025-10-31T10:00:00.12Z",
            "2025-10-31T10:00:00.123Z",
            "2025-10-31T10:00:00.1234Z"
        ])
        func parseVariousMillisecondPrecisions(isoString: String) {
            // When
            let result = sut.parseISO8601(isoString)

            // Then
            #expect(result != nil)
        }

        @Test("Reject invalid ISO8601 formats", arguments: [
            "2025-31-10T10:00:00Z",     // Invalid date order
            "2025-10-31 10:00:00Z",     // Space instead of T
            "2025-10-31",                // Missing time
            "not a date",                // Random string
            ""                           // Empty string
        ])
        func rejectInvalidFormats(invalidString: String) {
            // When
            let result = sut.parseISO8601(invalidString)

            // Then
            #expect(result == nil)
        }

        @Test("Parse edge case dates", arguments: [
            "2025-01-01T00:00:00.000Z",   // Start of year
            "2025-12-31T23:59:59.999Z",   // End of year
            "2025-02-28T12:00:00.000Z",   // Non-leap year Feb 28
            "2024-02-29T12:00:00.000Z"    // Leap year Feb 29
        ])
        func parseEdgeCases(isoString: String) {
            // When
            let result = sut.parseISO8601(isoString)

            // Then
            #expect(result != nil)
        }

        @Test("Fast parser handles standard format")
        func fastParserVsFallback() {
            // Given
            let standardFormat = "2025-10-31T10:00:00.000Z"

            // When
            let date = sut.parseISO8601(standardFormat)

            // Then
            #expect(date != nil)
        }

        @Test("ISO8601 parsing performance", .timeLimit(.minutes(1)))
        func parsingPerformance() {
            // Given
            let isoString = "2025-10-31T10:00:00.000Z"

            // When & Then - should parse 1000 times quickly
            for _ in 0..<1000 {
                _ = sut.parseISO8601(isoString)
            }
        }
    }

    // MARK: - Greeting Tests

    @Suite("Greeting Generation")
    struct GreetingTests {
        let sut: DefaultDateService
        let calendar: Calendar

        init() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            self.calendar = calendar
            self.sut = DefaultDateService(calendar: calendar)
        }

        @Test("Generate greetings based on time of day", arguments: [
            (8, LocalizedString.greetingMorning.localized),    // Morning
            (14, LocalizedString.greetingAfternoon.localized), // Afternoon
            (19, LocalizedString.greetingEvening.localized),   // Evening
            (2, LocalizedString.greetingNight.localized)       // Night
        ])
        func greetingForTimeOfDay(hour: Int, expected: String) {
            // Given
            var components = DateComponents()
            components.year = 2025
            components.month = 11
            components.day = 3
            components.hour = hour
            components.minute = 0
            let date = calendar.date(from: components)!

            // When
            let greeting = sut.greeting(for: date)

            // Then
            #expect(greeting == expected)
        }
    }

    // MARK: - Date Formatting Tests

    @Suite("Date Formatting")
    struct DateFormattingTests {
        let sut: DefaultDateService
        let calendar: Calendar

        init() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            self.calendar = calendar
            self.sut = DefaultDateService(calendar: calendar)
        }

        @Test("Format time as HH:mm")
        func formatTime() {
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
            #expect(formattedTime == "14:30")
        }

        @Test("Get short weekday name")
        func weekdayShort() {
            // Given
            var components = DateComponents()
            components.year = 2025
            components.month = 11
            components.day = 3 // Monday
            let date = calendar.date(from: components)!

            // When
            let weekday = sut.weekdayShort(date)

            // Then
            #expect(!weekday.isEmpty)
            #expect(weekday == weekday.uppercased())
        }

        @Test("Format day number with padding", arguments: [
            (3, "03"),
            (5, "05"),
            (15, "15"),
            (28, "28")
        ])
        func dayNumberWithPadding(day: Int, expected: String) {
            // Given
            var components = DateComponents()
            components.year = 2025
            components.month = 11
            components.day = day
            let date = calendar.date(from: components)!

            // When
            let result = sut.dayNumber(date)

            // Then
            #expect(result == expected)
        }
    }

    // MARK: - Week Calculation Tests

    @Suite("Week Calculations")
    struct WeekCalculationTests {
        let sut: DefaultDateService
        let calendar: Calendar

        init() {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            self.calendar = calendar
            self.sut = DefaultDateService(calendar: calendar)
        }

        @Test("Calculate start of week")
        func startOfWeek() {
            // Given - Wednesday
            var components = DateComponents()
            components.year = 2025
            components.month = 11
            components.day = 5
            let date = calendar.date(from: components)!

            // When
            let startOfWeek = sut.startOfWeek(for: date)

            // Then
            let weekday = calendar.component(.weekday, from: startOfWeek)
            // Weekday 1 = Sunday, 2 = Monday (in Gregorian calendar)
            #expect([1, 2].contains(weekday))
        }

        @Test("Generate 7 consecutive days in week")
        func daysInWeek() {
            // Given
            var components = DateComponents()
            components.year = 2025
            components.month = 11
            components.day = 3
            let date = calendar.date(from: components)!

            // When
            let days = sut.daysInWeek(startingFrom: date)

            // Then
            #expect(days.count == 7)

            // Verify days are consecutive
            for i in 0..<6 {
                let currentDay = calendar.component(.day, from: days[i])
                let nextDay = calendar.component(.day, from: days[i + 1])

                // Account for month transitions
                if currentDay < 28 {
                    #expect(nextDay == currentDay + 1)
                }
            }
        }
    }
}
