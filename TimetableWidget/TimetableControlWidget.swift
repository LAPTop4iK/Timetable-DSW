//
//  TimetableControlWidget.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import AppIntents
import SwiftUI
import WidgetKit

// Control Widgets require iOS 18+
@available(iOS 18.0, *)
struct TimetableControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.timetable.control"
        ) {
            ControlWidgetButton(action: OpenTimetableIntent()) {
                Label("Schedule", systemImage: "calendar")
            }
        }
        .displayName("Quick Schedule")
        .description("Open your timetable quickly")
    }
}

// MARK: - App Intents

struct OpenTimetableIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Timetable"
    static var description = IntentDescription("Opens the timetable app")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Intent to open main app
        return .result()
    }
}

struct ShowTodayScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Today's Schedule"
    static var description = IntentDescription("View today's classes")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Could pass specific deep link to today's schedule
        return .result()
    }
}

struct ShowNextClassIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Class"
    static var description = IntentDescription("View next class information")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        return .result()
    }
}