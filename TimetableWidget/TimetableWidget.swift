//
//  TimetableWidget.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

struct TimetableWidget: Widget {
    let kind: String = "TimetableWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: TimetableWidgetProvider.Intent.self,
            provider: TimetableWidgetProvider()
        ) { entry in
            TimetableWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Timetable")
        .description("View your class schedule at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TimetableWidgetEntryView: View {
    var entry: TimetableWidgetEntry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    TimetableWidget()
} timeline: {
    TimetableWidgetEntry(
        date: .now,
        schedule: nil,
        selectedThemeId: "default",
        appearanceMode: "system",
        configuration: nil
    )
}

#Preview(as: .systemMedium) {
    TimetableWidget()
} timeline: {
    TimetableWidgetEntry(
        date: .now,
        schedule: nil,
        selectedThemeId: "default",
        appearanceMode: "system",
        configuration: nil
    )
}

#Preview(as: .systemLarge) {
    TimetableWidget()
} timeline: {
    TimetableWidgetEntry(
        date: .now,
        schedule: nil,
        selectedThemeId: "default",
        appearanceMode: "system",
        configuration: nil
    )
}

