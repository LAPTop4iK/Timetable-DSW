//
//  TimetableLiveActivity.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

//
//  TimetableLiveActivity.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimetableLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var eventTitle: String
        var eventType: String?
        var room: String?
        var startTime: Date
        var endTime: Date
        var teacherName: String?
        var isOnline: Bool
        var progress: Double
    }
    var groupId: Int
    var themeId: String
}

struct TimetableLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimetableLiveActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    eventIcon(for: context.state.eventType, isOnline: context.state.isOnline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timeRemaining(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.eventTitle)
                            .font(.headline)
                            .lineLimit(1)

                        if let room = context.state.room, !room.isEmpty {
                            Label(room, systemImage: "location.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if let teacher = context.state.teacherName {
                            Text(teacher)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    progressBar(progress: context.state.progress)
                }
            } compactLeading: {
                eventIcon(for: context.state.eventType, isOnline: context.state.isOnline)
            } compactTrailing: {
                Text(timerInterval: context.state.startTime...context.state.endTime, countsDown: false)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 50)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                eventIcon(for: context.state.eventType, isOnline: context.state.isOnline)
            }
        }
    }

    private func eventIcon(for type: String?, isOnline: Bool) -> some View {
        ZStack {
            Circle()
                .fill(eventColor(for: type).gradient)
                .frame(width: 30, height: 30)
            Image(systemName: isOnline ? "wifi" : eventSymbol(for: type))
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
    }

    private func timeRemaining(context: ActivityViewContext<TimetableLiveActivityAttributes>) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(LocalizedString.liveEnds.localized)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(context.state.endTime, style: .time)
                .font(.caption.bold())
                .monospacedDigit()
        }
    }

    private func progressBar(progress: Double) -> some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 4)
                    Capsule()
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geometry.size.width * max(0, min(1, progress)), height: 4)
                }
            }
            .frame(height: 4)

            HStack {
                Text("\(Int(progress * 100))% \(LocalizedString.livePercentCompleteSuffix.localized)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }

    private func eventColor(for type: String?) -> Color {
        switch type?.lowercased() {
        case "lecture", "лекция": return Color(red: 1.0, green: 0.5, blue: 0.0)
        case "exercise", "упражнение": return Color(red: 0.1, green: 0.6, blue: 1.0)
        case "laboratory", "лабораторная": return Color(red: 0.7, green: 0.2, blue: 0.9)
        default: return .blue
        }
    }

    private func eventSymbol(for type: String?) -> String {
        switch type?.lowercased() {
        case "lecture", "лекция": return "book.fill"
        case "exercise", "упражнение": return "pencil"
        case "laboratory", "лабораторная": return "flask.fill"
        default: return "calendar"
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TimetableLiveActivityAttributes>
    @Environment(\.colorScheme) var colorScheme
    private var theme: any Theme { ThemeFactory.theme(withId: context.attributes.themeId, for: colorScheme) }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                eventIcon(for: context.state.eventType, isOnline: context.state.isOnline)

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.eventTitle)
                        .font(.headline)
                        .lineLimit(1)
                    if let room = context.state.room, !room.isEmpty {
                        Label(room, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(LocalizedString.liveEnds.localized)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(context.state.endTime, style: .time)
                        .font(.caption.bold())
                        .monospacedDigit()
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.secondary.opacity(0.3)).frame(height: 6)
                    Capsule().fill(LinearGradient(colors: [theme.primary, theme.secondary],
                                                  startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * max(0, min(1, context.state.progress)), height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                if let teacher = context.state.teacherName {
                    Text(teacher).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text("\(Int(context.state.progress * 100))% \(LocalizedString.livePercentCompleteSuffix.localized)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func eventIcon(for type: String?, isOnline: Bool) -> some View {
        ZStack {
            Circle().fill(eventColor(for: type).gradient).frame(width: 36, height: 36)
            Image(systemName: isOnline ? "wifi" : eventSymbol(for: type))
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
    }

    private func eventColor(for type: String?) -> Color {
        switch type?.lowercased() {
        case "lecture", "лекция": return Color(red: 1.0, green: 0.5, blue: 0.0)
        case "exercise", "упражнение": return Color(red: 0.1, green: 0.6, blue: 1.0)
        case "laboratory", "лабораторная": return Color(red: 0.7, green: 0.2, blue: 0.9)
        default: return theme.primary
        }
    }

    private func eventSymbol(for type: String?) -> String {
        switch type?.lowercased() {
        case "lecture", "лекция": return "book.fill"
        case "exercise", "упражнение": return "pencil"
        case "laboratory", "лабораторная": return "flask.fill"
        default: return "calendar"
        }
    }
}


//#Preview(
//    "Live Activity — compact",
//    as: .dynamicIsland(.minimal),
//    using: TimetableLiveActivityAttributes(groupId: 1, themeId: "default")
//) {
//    TimetableLiveActivity()
//} contentStates: {
//    TimetableLiveActivityAttributes.ContentState(
//        eventTitle: "Discrete Math",
//        eventType: "lecture",
//        room: "A-201",
//        startTime: .now,
//        endTime: .now.addingTimeInterval(5400),
//        teacherName: "Dr. Kowalski",
//        isOnline: false,
//        progress: 0.35
//    )
//}

//#Preview(
//    "Live Activity — expanded",
//    as: .dynamicIsland(.expanded),
//    using: TimetableLiveActivityAttributes(groupId: 1, themeId: "default")
//) {
//    TimetableLiveActivity()
//} contentStates: {
//    TimetableLiveActivityAttributes.ContentState(
//        eventTitle: "Discrete Math",
//        eventType: "lecture",
//        room: "A-201",
//        startTime: .now,
//        endTime: .now.addingTimeInterval(5400),
//        teacherName: "Dr. Kowalski",
//        isOnline: false,
//        progress: 0.7
//    )
//}

