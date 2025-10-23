//
//  WidgetConfigurationIntent.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Widget"
    static var description: IntentDescription = IntentDescription("Choose widget display options")

    @Parameter(title: "View Type", default: .today)
    var viewType: WidgetViewType

    @Parameter(title: "Show Online Status", default: true)
    var showOnlineStatus: Bool
}

enum WidgetViewType: String, AppEnum {
    case today
    case week

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "View Type")
    static var caseDisplayRepresentations: [WidgetViewType: DisplayRepresentation] = [
        .today: "Today's Schedule",
        .week: "Weekly Schedule"
    ]
}
