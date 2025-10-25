//
//  TimetableControlWidget.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct TimetableControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.timetable.control") {
            ControlWidgetButton(action: OpenTimetableIntent()) { 
                Label(LocalizedString.controlOpenScheduleLabel.localized, systemImage: "calendar")
            }
        }
        .displayName(LocalizedString.controlOpenScheduleDisplayName.resource)
        .description(LocalizedString.controlOpenScheduleDescription.resource)
    }
}

@available(iOS 18.0, *)
struct TimetableToggleControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: "com.timetable.toggle",
            provider: TimetableToggleProvider()
        ) { value in
            ControlWidgetToggle(
                isOn: value.hasClasses,
                action: RefreshScheduleIntent()
            ) { 
                Label(LocalizedString.controlToggleLabel.localized, systemImage: "calendar")
            } valueLabel: { isOn in
                Text(isOn ? LocalizedString.statusActive.localized : LocalizedString.statusNoClasses.localized)
            }
        }
        .displayName(LocalizedString.controlToggleDisplayName.resource)
        .description(LocalizedString.controlToggleDescription.resource)
    }
}

@available(iOS 18.0, *)
struct TimetableControlValue {
    var hasClasses: Bool
    var status: String { hasClasses ? "ON" : "OFF" }
}

@available(iOS 18.0, *)
struct TimetableToggleProvider: AppIntentControlValueProvider {
    typealias Value = TimetableControlValue
    typealias Configuration = ConfigurationIntent

    func currentValue(configuration: Configuration) async throws -> Value {
        let schedule = AppGroupManager.loadSemesterSchedule()
        let today = Date()
        let hasClasses = schedule?.groupSchedule.contains {
            guard let d = $0.startDate else { return false }
            return Calendar.current.isDate(d, inSameDayAs: today)
        } ?? false
        return TimetableControlValue(hasClasses: hasClasses)
    }

    func previewValue(configuration: Configuration) -> Value {
        TimetableControlValue(hasClasses: true)
    }
}

// MARK: - App Intents

struct OpenTimetableIntent: AppIntent { // fixnik locale
    static var title: LocalizedStringResource = "Open Timetable"
    static var description: IntentDescription = IntentDescription("Open the timetable")
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult { .result() }
}

struct ShowTodayScheduleIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Today's Schedule"
    static var description: IntentDescription = IntentDescription("Open today's schedule")
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult { .result() }
}

struct ShowNextClassIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Next Class"
    static var description: IntentDescription = IntentDescription("Open the next class")
    static var openAppWhenRun: Bool = true
    func perform() async throws -> some IntentResult { .result() }
}

@available(iOS 18.0, *)
struct RefreshScheduleIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Refresh Schedule"

    @Parameter(title: "Enabled")
    var value: Bool

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

@available(iOS 18.0, *)
struct ConfigurationIntent: ControlConfigurationIntent {
    static var title: LocalizedStringResource = "Timetable Controls"
}
