//
//  AppGroupManager.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import Foundation

struct AppGroupManager {
    // ВАЖНО: Замените на свой App Group ID из Xcode
    static let appGroupIdentifier = "org.laptenok.Timetable-DSW.rl"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    // Keys для хранения данных
    struct Keys {
        static let semesterSchedule = "widget_semester_schedule"
        static let selectedGroupId = "widget_selected_group_id"
        static let selectedThemeId = "widget_selected_theme_id"
        static let appearanceMode = "widget_appearance_mode"
        static let lastUpdated = "widget_last_updated"
    }

    // MARK: - Save Methods

    static func saveSemesterSchedule(_ schedule: GroupScheduleResponse) {
        guard let data = try? JSONEncoder().encode(schedule) else { return }
        sharedDefaults?.set(data, forKey: Keys.semesterSchedule)
    }

    static func saveSelectedGroupId(_ groupId: Int) {
        sharedDefaults?.set(groupId, forKey: Keys.selectedGroupId)
    }

    static func saveSelectedTheme(id: String, appearanceMode: String) {
        sharedDefaults?.set(id, forKey: Keys.selectedThemeId)
        sharedDefaults?.set(appearanceMode, forKey: Keys.appearanceMode)
    }

    static func saveLastUpdated(_ date: Date) {
        sharedDefaults?.set(date, forKey: Keys.lastUpdated)
    }

    // MARK: - Load Methods

    static func loadSemesterSchedule() -> GroupScheduleResponse? {
        guard let data = sharedDefaults?.data(forKey: Keys.semesterSchedule),
              let schedule = try? JSONDecoder().decode(GroupScheduleResponse.self, from: data) else {
            return nil
        }
        return schedule
    }

    static func loadSelectedGroupId() -> Int? {
        guard let groupId = sharedDefaults?.integer(forKey: Keys.selectedGroupId), groupId > 0 else {
            return nil
        }
        return groupId
    }

    static func loadSelectedThemeId() -> String? {
        sharedDefaults?.string(forKey: Keys.selectedThemeId)
    }

    static func loadAppearanceMode() -> String? {
        sharedDefaults?.string(forKey: Keys.appearanceMode)
    }

    static func loadLastUpdated() -> Date? {
        sharedDefaults?.object(forKey: Keys.lastUpdated) as? Date
    }
}
