//
//  TimetableWidgetEntry.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

// Отмена занятия — общая проверка
fileprivate extension ScheduleEvent {
    var isCancelled: Bool {
        let t = (remarks ?? "").lowercased()
        return t.contains("zajęcia odwołane")
            || t.contains("odwołane")
            || t.contains("cancelled")
            || t.contains("canceled")
            || t.contains("отмен")
    }
}

struct TimetableWidgetEntry: TimelineEntry {
    let date: Date
    let schedule: GroupScheduleResponse?
    let selectedThemeId: String
    let appearanceMode: String
    let configuration: (any WidgetConfigurationIntent)?

    var todayEvents: [ScheduleEvent] {
        guard let schedule = schedule else { return [] }
        return schedule.groupSchedule
            .filter { event in
                guard !event.isCancelled, let eventDate = event.startDate else { return false }
                return Calendar.current.isDate(eventDate, inSameDayAs: date)
            }
            .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
    }

    var weekEvents: [Date: [ScheduleEvent]] {
        guard let schedule = schedule else { return [:] }
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!

        var result: [Date: [ScheduleEvent]] = [:]
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }
            let dayEvents = schedule.groupSchedule
                .filter { event in
                    guard !event.isCancelled, let eventDate = event.startDate else { return false }
                    return calendar.isDate(eventDate, inSameDayAs: day)
                }
                .sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }
            if !dayEvents.isEmpty { result[day] = dayEvents }
        }
        return result
    }

    var currentEvent: ScheduleEvent? {
        todayEvents.first { ev in
            guard let s = ev.startDate, let e = ev.endDate else { return false }
            return date >= s && date <= e
        }
    }

    var nextEvent: ScheduleEvent? {
        todayEvents.first { ev in
            guard let s = ev.startDate else { return false }
            return s > date
        }
    }
}
