//
//  TimetableWidgetEntry.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import WidgetKit
import SwiftUI

struct TimetableWidgetEntry: TimelineEntry {
    let date: Date
    let schedule: GroupScheduleResponse?
    let selectedThemeId: String
    let appearanceMode: String
    let configuration: WidgetConfigurationIntent?

    var todayEvents: [ScheduleEvent] {
        guard let schedule = schedule else { return [] }

        return schedule.groupSchedule.filter { event in
            guard let eventDate = event.startDate else { return false }
            return Calendar.current.isDate(eventDate, inSameDayAs: date)
        }.sorted { ($0.startDate ?? Date.distantPast) < ($1.startDate ?? Date.distantPast) }
    }

    var weekEvents: [Date: [ScheduleEvent]] {
        guard let schedule = schedule else { return [:] }

        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!

        var events: [Date: [ScheduleEvent]] = [:]

        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }

            let dayEvents = schedule.groupSchedule.filter { event in
                guard let eventDate = event.startDate else { return false }
                return calendar.isDate(eventDate, inSameDayAs: day)
            }.sorted { ($0.startDate ?? Date.distantPast) < ($1.startDate ?? Date.distantPast) }

            if !dayEvents.isEmpty {
                events[day] = dayEvents
            }
        }

        return events
    }

    var currentEvent: ScheduleEvent? {
        todayEvents.first { event in
            guard let start = event.startDate, let end = event.endDate else { return false }
            return date >= start && date <= end
        }
    }

    var nextEvent: ScheduleEvent? {
        todayEvents.first { event in
            guard let start = event.startDate else { return false }
            return start > date
        }
    }
}
