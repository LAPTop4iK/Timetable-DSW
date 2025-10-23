//
//  WidgetConfigurationIntent.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import AppIntents
import WidgetKit

struct WidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Widget"
    static var description = IntentDescription("Choose widget display options")

    @Parameter(title: "View Type")
    var viewType: WidgetViewType

    @Parameter(title: "Show Online Status")
    var showOnlineStatus: Bool

    init() {
        self.viewType = .today
        self.showOnlineStatus = true
    }

    init(viewType: WidgetViewType, showOnlineStatus: Bool) {
        self.viewType = viewType
        self.showOnlineStatus = showOnlineStatus
    }
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
