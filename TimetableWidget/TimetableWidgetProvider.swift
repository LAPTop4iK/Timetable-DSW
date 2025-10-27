//
//  TimetableWidgetProvider.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

struct TimetableWidgetProvider: AppIntentTimelineProvider {
    typealias Intent = ConfigurationAppIntent
    typealias Entry = TimetableWidgetEntry

    func placeholder(in context: Context) -> TimetableWidgetEntry {
        TimetableWidgetEntry(
            date: Date(),
            schedule: nil,
            selectedThemeId: "default",
            appearanceMode: "system",
            configuration: nil,
            hasAccess: true
        )
    }

    func snapshot(for configuration: Intent, in context: Context) async -> TimetableWidgetEntry {
        let allowed = AppGroupManager.loadWidgetAccessAllowed()
        let schedule = loadScheduleIf(allowed: allowed)
        let themeId = AppGroupManager.loadSelectedThemeId() ?? "default"
        let appearanceMode = AppGroupManager.loadAppearanceMode() ?? "system"

        return TimetableWidgetEntry(
            date: Date(),
            schedule: schedule,
            selectedThemeId: themeId,
            appearanceMode: appearanceMode,
            configuration: configuration,
            hasAccess: allowed
        )
    }

    func timeline(for configuration: Intent, in context: Context) async -> Timeline<TimetableWidgetEntry> {
        let allowed = AppGroupManager.loadWidgetAccessAllowed()
        let schedule = loadScheduleIf(allowed: allowed)
        let themeId = AppGroupManager.loadSelectedThemeId() ?? "default"
        let appearanceMode = AppGroupManager.loadAppearanceMode() ?? "system"
        let currentDate = Date()
        var entries: [TimetableWidgetEntry] = []

        let baseEntry = { (date: Date) in
            TimetableWidgetEntry(
                date: date,
                schedule: schedule,
                selectedThemeId: themeId,
                appearanceMode: appearanceMode,
                configuration: configuration,
                hasAccess: allowed
            )
        }

        // точка "сейчас"
        entries.append(baseEntry(currentDate))

        // добавить апдейты на старты/концы занятий:
        let calendar = Calendar.current
        if let eventsToday = schedule?.groupSchedule
            .filter({ e in
                guard !e.isCancelled(), let d = e.startDate else { return false }
                return calendar.isDate(d, inSameDayAs: currentDate)
            })
            .sorted(by: { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) })
        {
            for ev in eventsToday {
                if let st = ev.startDate, st > currentDate {
                    entries.append(baseEntry(st))
                }
                if let en = ev.endDate, en > currentDate {
                    entries.append(baseEntry(en))
                }
            }
        }

        // резерв: завтра утром
        if entries.count == 1,
           let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate),
           let tMorning = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: tomorrow) {
            entries.append(baseEntry(tMorning))
        }

        entries.sort { $0.date < $1.date }
        let nextUpdate = entries.last?.date.addingTimeInterval(3600) ?? currentDate.addingTimeInterval(3600)

        return Timeline(entries: entries, policy: .after(nextUpdate))
    }

    private func loadScheduleIf(allowed: Bool) -> GroupScheduleResponse? {
        guard allowed else { return nil }
        return AppGroupManager.loadSemesterSchedule()
    }
}
