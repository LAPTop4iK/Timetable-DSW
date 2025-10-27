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
            provider: TimetableWidgetProvider(),
            content: { entry in
                TimetableWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) { Color.clear }
            }
        )
        .contentMarginsDisabled()                // убрали системные поля
        .containerBackgroundRemovable(true)
        .configurationDisplayName("Timetable")
        .description("View your class schedule at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct TimetableWidgetEntryView: View {
    var entry: TimetableWidgetEntry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        if entry.hasAccess {
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
        } else {
            // Show premium placeholder when user doesn't have access
            switch widgetFamily {
            case .systemSmall:
                PremiumPlaceholderWidget(size: .small, entry: entry)
            case .systemMedium:
                PremiumPlaceholderWidget(size: .medium, entry: entry)
            case .systemLarge:
                PremiumPlaceholderWidget(size: .large, entry: entry)
            default:
                PremiumPlaceholderWidget(size: .small, entry: entry)
            }
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
        configuration: nil,
        hasAccess: true,
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
        configuration: nil,
        hasAccess: true,
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
        configuration: nil,
        hasAccess: true,
    )
}

