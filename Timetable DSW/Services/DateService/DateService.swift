//
//  DateService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

// MARK: - Protocol

protocol DateService {
    func greeting(for date: Date) -> String
    func formatDate(_ date: Date) -> String
    func formatTime(_ date: Date) -> String
    func weekdayShort(_ date: Date) -> String
    func weekdayFull(_ date: Date) -> String
    func dayNumber(_ date: Date) -> String
    func startOfWeek(for date: Date) -> Date
    func daysInWeek(startingFrom date: Date) -> [Date]
    func parseISO8601(_ string: String) -> Date?
}
