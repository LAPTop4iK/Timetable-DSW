//
//  DefaultDateService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import Foundation

final class DefaultDateService: DateService {
    // MARK: - Shared Instance

    static let shared = DefaultDateService()

    // MARK: - Properties

    private let calendar: Calendar
    
    // MARK: - Formatters
    
    private lazy var iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = .current
        return formatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private lazy var weekdayShortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private lazy var weekdayFullFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = .current
        return formatter
    }()
    
    private lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    // MARK: - Initialization
    
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }
    
    // MARK: - DateService Implementation
    
    func greeting(for date: Date) -> String {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12: return LocalizedString.greetingMorning.localized
        case 12..<17: return LocalizedString.greetingAfternoon.localized
        case 17..<22: return LocalizedString.greetingEvening.localized
        default: return LocalizedString.greetingNight.localized
        }
    }
    
    func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    func weekdayShort(_ date: Date) -> String {
        weekdayShortFormatter.string(from: date).uppercased()
    }
    
    func weekdayFull(_ date: Date) -> String {
        weekdayFullFormatter.string(from: date).capitalized
    }
    
    func dayNumber(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }
    
    func startOfWeek(for date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components) ?? date
    }
    
    func daysInWeek(startingFrom date: Date) -> [Date] {
        (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: date)
        }
    }
    
    func parseISO8601(_ string: String) -> Date? {
        iso8601Formatter.date(from: string)
    }
}
