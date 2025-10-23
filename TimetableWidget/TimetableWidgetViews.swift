//
//  TimetableWidgetViews.swift
//  TimetableWidget
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI
import WidgetKit

// MARK: - Small Widget (Compact)

struct SmallWidgetView: View {
    let entry: TimetableWidgetEntry
    @Environment(\.colorScheme) var colorScheme

    private var theme: any Theme {
        ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme)
    }

    var body: some View {
        ZStack {
            // Liquid glass background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay {
                    LinearGradient(
                        colors: [
                            theme.primary.opacity(0.3),
                            theme.secondary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: 10)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }

            if let currentEvent = entry.currentEvent {
                currentEventView(currentEvent)
            } else if let nextEvent = entry.nextEvent {
                nextEventView(nextEvent)
            } else {
                noEventsView
            }
        }
    }

    private func currentEventView(_ event: ScheduleEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Circle()
                    .fill(theme.online)
                    .frame(width: 8, height: 8)
                Text("NOW")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(theme.online)
            }

            Text(event.title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
                .foregroundColor(.primary)

            if !event.displayRoom.isEmpty {
                let room = event.displayRoom
                Label(room, systemImage: "location.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            if let end = event.endDate {
                Text("Until \(end, style: .time)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private func nextEventView(_ event: ScheduleEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NEXT")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(theme.accent)

            Text(event.title)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(2)
                .foregroundColor(.primary)

            if let start = event.startDate {
                Text(start, style: .time)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(theme.primary)
            }

            if !event.displayRoom.isEmpty {
                let room = event.displayRoom
                Label(room, systemImage: "location.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private var noEventsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.primary, theme.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("No classes")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Medium Widget (Day Schedule)

struct MediumWidgetView: View {
    let entry: TimetableWidgetEntry
    @Environment(\.colorScheme) var colorScheme

    private var theme: any Theme {
        ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme)
    }

    var body: some View {
        ZStack {
            // Liquid glass background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay {
                    LinearGradient(
                        colors: [
                            theme.primary.opacity(0.2),
                            theme.secondary.opacity(0.15),
                            theme.tertiary.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: 15)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }

            if entry.todayEvents.isEmpty {
                noEventsView
            } else {
                todayScheduleView
            }
        }
    }

    private var todayScheduleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Today")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.primary, theme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Spacer()

                Text(entry.date, style: .date)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // Events list
            ForEach(entry.todayEvents.prefix(3)) { event in
                eventRow(event)
            }

            if entry.todayEvents.count > 3 {
                Text("+\(entry.todayEvents.count - 3) more")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }

    private func eventRow(_ event: ScheduleEvent) -> some View {
        HStack(spacing: 8) {
            // Time
            if let start = event.startDate {
                Text(start, style: .time)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(theme.accent)
                    .frame(width: 45, alignment: .leading)
            }

            // Event card
            HStack(spacing: 6) {
                Rectangle()
                    .fill(eventColor(for: event.type))
                    .frame(width: 3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(.primary)

                    if !event.displayRoom.isEmpty {
                        let room = event.displayRoom
                        Text(room)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if let remarks = event.remarks, remarks.lowercased().contains("online") {
                    Image(systemName: "wifi")
                        .font(.system(size: 10))
                        .foregroundColor(theme.online)
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                    }
            }
        }
    }

    private func eventColor(for type: String?) -> Color {
        switch type?.lowercased() {
        case "lecture", "лекция":
            return Color(red: 1.0, green: 0.5, blue: 0.0)
        case "exercise", "упражнение":
            return Color(red: 0.1, green: 0.6, blue: 1.0)
        case "laboratory", "лабораторная":
            return Color(red: 0.7, green: 0.2, blue: 0.9)
        default:
            return theme.primary
        }
    }

    private var noEventsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.primary, theme.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("No classes today")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)

            Text("Enjoy your free day!")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Large Widget (Week Schedule)

struct LargeWidgetView: View {
    let entry: TimetableWidgetEntry
    @Environment(\.colorScheme) var colorScheme

    private var theme: any Theme {
        ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme)
    }

    var body: some View {
        ZStack {
            // Liquid glass background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay {
                    LinearGradient(
                        colors: [
                            theme.primary.opacity(0.25),
                            theme.secondary.opacity(0.2),
                            theme.tertiary.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: 20)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }

            weekScheduleView
        }
    }

    private var weekScheduleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("This Week")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.primary, theme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Spacer()

                Text("Week \(Calendar.current.component(.weekOfYear, from: entry.date))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            // Days grid
            let weekEvents = entry.weekEvents
            ForEach(Array(weekEvents.keys.sorted()), id: \.self) { day in
                if let events = weekEvents[day], !events.isEmpty {
                    dayRow(date: day, events: events)
                }
            }

            if weekEvents.isEmpty {
                Spacer()
                Text("No classes this week")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
        }
        .padding()
    }

    private func dayRow(date: Date, events: [ScheduleEvent]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            // Day header
            HStack {
                Text(date, format: .dateTime.weekday(.abbreviated))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Calendar.current.isDateInToday(date) ? theme.accent : .primary)

                Text(date, format: .dateTime.day())
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(events.count) classes")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            // Events
            HStack(spacing: 4) {
                ForEach(events.prefix(4)) { event in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(eventColor(for: event.type))
                        .frame(height: 20)
                        .overlay {
                            if events.count <= 2 {
                                Text(event.title)
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .padding(.horizontal, 2)
                            }
                        }
                }

                if events.count > 4 {
                    Text("+\(events.count - 4)")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                }
        }
    }

    private func eventColor(for type: String?) -> Color {
        switch type?.lowercased() {
        case "lecture", "лекция":
            return Color(red: 1.0, green: 0.5, blue: 0.0)
        case "exercise", "упражнение":
            return Color(red: 0.1, green: 0.6, blue: 1.0)
        case "laboratory", "лабораторная":
            return Color(red: 0.7, green: 0.2, blue: 0.9)
        default:
            return theme.primary
        }
    }
}
