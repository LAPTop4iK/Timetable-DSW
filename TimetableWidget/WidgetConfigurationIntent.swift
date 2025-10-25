//
//  WidgetConfigurationIntent.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent { // fixnik
    static var title: LocalizedStringResource = "Timetable"
    static var description: IntentDescription = IntentDescription("Configure your timetable widget")

//    @Parameter(title: "View", default: .today)
//    var viewType: WidgetViewType

    @Parameter(title: "Show online status", default: true)
        var showOnlineStatus: Bool
}

//enum WidgetViewType: String, AppEnum {
//    case today
//    case week
//
//    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "View")
//
//    static var caseDisplayRepresentations: [WidgetViewType: DisplayRepresentation] = [
//        .today: DisplayRepresentation(title: "Today"),
//        .week:  DisplayRepresentation(title: "Week")
//    ]
//}
