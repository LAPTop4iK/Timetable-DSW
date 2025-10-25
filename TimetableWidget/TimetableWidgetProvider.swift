//
//  TimetableWidgetProvider.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

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

struct TimetableWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = ConfigurationAppIntent
    typealias Entry = TimetableWidgetEntry

    func placeholder(in context: Context) -> TimetableWidgetEntry {
        TimetableWidgetEntry(
            date: Date(),
            schedule: nil,
            selectedThemeId: "default",
            appearanceMode: "system",
            configuration: nil
        )
    }

    func snapshot(for configuration: Intent, in context: Context) async -> TimetableWidgetEntry {
        let schedule = AppGroupManager.loadSemesterSchedule()
        let themeId = AppGroupManager.loadSelectedThemeId() ?? "default"
        let appearanceMode = AppGroupManager.loadAppearanceMode() ?? "system"

        return TimetableWidgetEntry(
            date: Date(),
            schedule: schedule,
            selectedThemeId: themeId,
            appearanceMode: appearanceMode,
            configuration: configuration
        )
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<TimetableWidgetEntry> {
        let schedule = AppGroupManager.loadSemesterSchedule()
        let themeId = AppGroupManager.loadSelectedThemeId() ?? "default"
        let appearanceMode = AppGroupManager.loadAppearanceMode() ?? "system"
        let currentDate = Date()

        var entries: [TimetableWidgetEntry] = []

        // Текущая точка
        let currentEntry = TimetableWidgetEntry(
            date: currentDate,
            schedule: schedule,
            selectedThemeId: themeId,
            appearanceMode: appearanceMode,
            configuration: configuration
        )
        entries.append(currentEntry)

        let calendar = Calendar.current

        // События сегодня (без отменённых)
        if let events = schedule?.groupSchedule
            .filter({ event in
                guard !event.isCancelled, let eventDate = event.startDate else { return false }
                return calendar.isDate(eventDate, inSameDayAs: currentDate)
            })
            .sorted(by: { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) })
        {
            // Обновления на старты/финиши
            for event in events {
                if let startDate = event.startDate, startDate > currentDate {
                    entries.append(TimetableWidgetEntry(
                        date: startDate,
                        schedule: schedule,
                        selectedThemeId: themeId,
                        appearanceMode: appearanceMode,
                        configuration: configuration
                    ))
                }
                if let endDate = event.endDate, endDate > currentDate {
                    entries.append(TimetableWidgetEntry(
                        date: endDate,
                        schedule: schedule,
                        selectedThemeId: themeId,
                        appearanceMode: appearanceMode,
                        configuration: configuration
                    ))
                }
            }
        }

        // Резервная точка — завтра 6:00
        if entries.count == 1 {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate),
               let tomorrowMorning = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: tomorrow) {
                entries.append(TimetableWidgetEntry(
                    date: tomorrowMorning,
                    schedule: schedule,
                    selectedThemeId: themeId,
                    appearanceMode: appearanceMode,
                    configuration: configuration
                ))
            }
        }

        entries.sort { $0.date < $1.date }
        let nextUpdate = entries.last?.date.addingTimeInterval(3600) ?? currentDate.addingTimeInterval(3600)
        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
}
