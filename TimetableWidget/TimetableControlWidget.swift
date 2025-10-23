//
//  TimetableControlWidget.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Control Widget

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

// MARK: - Toggle Control (Advanced)

struct TimetableToggleControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: "com.timetable.toggle",
            provider: TimetableToggleProvider()
        ) { value in
            ControlWidgetToggle(
                isOn: value.hasClasses,
                action: RefreshScheduleIntent(),
                label: { _ in
                    Label("Classes Today", systemImage: "calendar")
                },
                valueLabel: { isOn in
                    Text(isOn ? "Active" : "No Classes")
                }
            )
        }
        .displayName("Classes Status")
        .description("Shows if you have classes today")
    }
}

struct TimetableControlValue: ControlValueProvider {
    var hasClasses: Bool

    var status: ControlStatus {
        hasClasses ? .enabled : .disabled
    }
}

struct TimetableToggleProvider: AppIntentControlValueProvider {
    func currentValue(configuration: ConfigurationIntent) async throws -> TimetableControlValue {
        // Load today's schedule from App Group
        let schedule = AppGroupManager.loadSemesterSchedule()
        let today = Date()

        let hasClasses = schedule?.groupSchedule.contains { event in
            guard let eventDate = event.startDate else { return false }
            return Calendar.current.isDate(eventDate, inSameDayAs: today)
        } ?? false

        return TimetableControlValue(hasClasses: hasClasses)
    }

    func previewValue(configuration: ConfigurationIntent) -> TimetableControlValue {
        TimetableControlValue(hasClasses: true)
    }
}

struct RefreshScheduleIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Refresh Schedule"

    @Parameter(title: "Enabled")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Trigger app to refresh schedule
        return .result()
    }
}

struct ConfigurationIntent: ControlConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
}
