//
//  TimetableWidgetProvider.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import WidgetKit
import SwiftUI

struct TimetableWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = WidgetConfigurationIntent
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

    func snapshot(for configuration: WidgetConfigurationIntent, in context: Context) async -> TimetableWidgetEntry {
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

    func timeline(for configuration: WidgetConfigurationIntent, in context: Context) async -> Timeline<TimetableWidgetEntry> {
        let schedule = AppGroupManager.loadSemesterSchedule()
        let themeId = AppGroupManager.loadSelectedThemeId() ?? "default"
        let appearanceMode = AppGroupManager.loadAppearanceMode() ?? "system"
        let currentDate = Date()

        var entries: [TimetableWidgetEntry] = []

        // Create entries for next 24 hours with updates at key times
        let calendar = Calendar.current

        // Entry for current time
        let currentEntry = TimetableWidgetEntry(
            date: currentDate,
            schedule: schedule,
            selectedThemeId: themeId,
            appearanceMode: appearanceMode,
            configuration: configuration
        )
        entries.append(currentEntry)

        // Get today's events
        if let events = schedule?.groupSchedule.filter({ event in
            guard let eventDate = event.startDate else { return false }
            return calendar.isDate(eventDate, inSameDayAs: currentDate)
        }).sorted(by: { ($0.startDate ?? Date.distantPast) < ($1.startDate ?? Date.distantPast) }) {

            // Add entries for start and end of each event
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

        // If no entries added, add one for tomorrow at 6 AM
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

        // Sort entries by date
        entries.sort { $0.date < $1.date }

        // Determine next update time (after last entry or 1 hour from now)
        let nextUpdate = entries.last?.date.addingTimeInterval(3600) ?? currentDate.addingTimeInterval(3600)

        return Timeline(entries: entries, policy: .after(nextUpdate))
    }
}
