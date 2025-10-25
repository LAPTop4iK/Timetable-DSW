//
//  TimetableWidgetViews.swift
//
//  TimetableWidgetViews.swift
//  TimetableWidget
//

import SwiftUI
import WidgetKit

// MARK: - Helpers

private func eventAbbreviation(from title: String) -> String {
    let words = title
        .replacingOccurrences(of: "·", with: " ")
        .replacingOccurrences(of: "—", with: " ")
        .split { $0.isWhitespace || $0.isNewline || $0.isPunctuation }
        .map(String.init)

    var result = words.compactMap { $0.first?.uppercased() }.joined()
    if result.count < 2 {
        result = title.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }
    return String(result.prefix(5))
}

// маленький дефис везде
private func timeRange(_ start: Date?, _ end: Date?) -> String {
    switch (start, end) {
    case let (s?, e?): return "\(s.formatted(date: .omitted, time: .shortened))-\(e.formatted(date: .omitted, time: .shortened))"
    case let (s?, nil): return s.formatted(date: .omitted, time: .shortened)
    case let (nil, e?): return e.formatted(date: .omitted, time: .shortened)
    default: return ""
    }
}

private func colorForType(_ type: String?, fallback: Color) -> Color {
    switch type?.lowercased() {
    case "lecture", "лекция": return Color(red: 1.0, green: 0.5, blue: 0.0)
    case "exercise", "упражнение": return Color(red: 0.1, green: 0.6, blue: 1.0)
    case "laboratory", "лабораторная": return Color(red: 0.7, green: 0.2, blue: 0.9)
    default: return fallback
    }
}

private func isOnline(_ event: ScheduleEvent) -> Bool {
    let t = (event.remarks ?? "").lowercased()
    return t.contains("online") || t.contains("distance") || t.contains("онлайн") || t.contains("zdal") || t.contains("remote")
}

// Порядок дней: Пн..Вс
private func weekdayRank(_ date: Date, calendar: Calendar = .current) -> Int {
    let wd = calendar.component(.weekday, from: date) // 1=Sun..7=Sat
    return wd == 1 ? 7 : wd - 1
}

// MARK: - SMALL

struct SmallWidgetView: View {
    let entry: TimetableWidgetEntry
    @Environment(\.colorScheme) var colorScheme
    private var theme: any Theme { ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme) }

    private let maxRowsTotal = 5

    var body: some View {
        let now = entry.date
        let events = entry.todayEvents

        // активные пары (их может быть несколько одновременно)
        let activeIdxs: [Int] = events.enumerated().compactMap { idx, ev in
            guard let s = ev.startDate, let e = ev.endDate else { return nil }
            return (now >= s && now <= e) ? idx : nil
        }

        return VStack(alignment: .leading, spacing: 5) {
            // HEADER "TODAY"
            Text(LocalizedString.commonToday.localized)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.primary, theme.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineLimit(1)

            if !activeIdxs.isEmpty {
                // 1. показываем все активные (до лимита)
                let activeToShow = Array(activeIdxs.prefix(maxRowsTotal))
                ForEach(activeToShow, id: \.self) { idx in
                    FocusEventRow(event: events[idx], theme: theme)
                }

                // 2. будущие пары после последней активной
                let lastActive = activeIdxs.max()!
                let future = Array(events.suffix(from: lastActive + 1))

                let remainingSlots = max(0, maxRowsTotal - activeToShow.count)
                let futureToShow = Array(future.prefix(remainingSlots))

                if !futureToShow.isEmpty {
                    // добавляем чуть больше воздуха между активным блоком и будущими
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(futureToShow) { ev in
                            CompactEventRow(event: ev, theme: theme)
                        }
                    }
                    .padding(.top, 3)
                }

                // 3. +N (непоместившиеся активные + непоместившиеся будущие)
                let hiddenActive = max(0, activeIdxs.count - activeToShow.count)
                let hiddenFuture = max(0, future.count - futureToShow.count)
                let hidden = hiddenActive + hiddenFuture

                if hidden > 0 {
                    Text("+\(hidden)")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                        .padding(.bottom, 4)// <- увеличили паддинг сверху, чтобы не висело прямо под последней строкой
                }

            } else {
                // нет активных прямо сейчас:
                // берём текущую (если идёт) или ближайшую будущую
                let focus = entry.currentEvent ?? events.first { ($0.startDate ?? .distantPast) >= now }

                if let f = focus {
                    FocusEventRow(event: f, theme: theme)

                    // остальные будущие после фокуса
                    if let idx = events.firstIndex(where: { $0.id == f.id }) {
                        let future = Array(events.suffix(from: idx + 1))
                        let othersToShow = Array(future.prefix(maxRowsTotal - 1))

                        if !othersToShow.isEmpty {
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(othersToShow) { ev in
                                    CompactEventRow(event: ev, theme: theme)
                                }
                            }
                            .padding(.top, 3)
                        }

                        let hidden = max(0, future.count - othersToShow.count)
                        if hidden > 0 {
                            Text("+\(hidden)")
                                .font(.system(size: 10.5, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.top, 3)
                        }
                    }

                } else {
                    // вообще нет пар
                    HStack(spacing: 6) {
                        Image(systemName: "zzz")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)

                        Text(LocalizedString.commonNoClassesToday.localized)
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
    }
}

private struct FocusEventRow: View {
    let event: ScheduleEvent
    let theme: any Theme

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Capsule()
                .fill(colorForType(event.type, fallback: theme.primary))
                .frame(width: 3, height: 25)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 1) {
                Text(eventAbbreviation(from: event.title))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)

                if isOnline(event) {
                    Image(systemName: "wifi")
                        .font(.system(size: 8))
                        .foregroundColor(theme.online)
                } else if !event.displayRoom.isEmpty {
                    Text(event.displayRoom)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                }
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 0) {
                if let s = event.startDate {
                    Text(s, style: .time)
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                }
                if let e = event.endDate {
                    Text(e, style: .time)
                        .font(.system(size: 10))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .allowsTightening(true)
                }
            }
            .frame(minWidth: 46, idealWidth: 52, maxWidth: 60, alignment: .trailing)
        }
    }
}

private struct CompactEventRow: View {
    let event: ScheduleEvent
    let theme: any Theme

    var body: some View {
        HStack(spacing: 4) {
            if isOnline(event) {
                Image(systemName: "wifi")
                    .font(.system(size: 8))
                    .foregroundColor(theme.online)
            } else {
                Circle()
                    .fill(colorForType(event.type, fallback: theme.secondary))
                    .frame(width: 4, height: 4)
            }

            Text(eventAbbreviation(from: event.title))
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .layoutPriority(1)

            Spacer(minLength: 2)

            if let s = event.startDate {
                Text(s, style: .time)
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                    .frame(minWidth: 38, alignment: .trailing)
            }
        }
    }
}

// MARK: - MEDIUM (окно из 5 пар, подсветка всех активных, скользящее окно дня)

struct MediumWidgetView: View {
    let entry: TimetableWidgetEntry
    @Environment(\.colorScheme) var colorScheme
    private var theme: any Theme { ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme) }

    // компактная палка слева у активной пары
    private let barHeight: CGFloat = 12
    private let barWidth: CGFloat = 2

    var body: some View {
        let events = entry.todayEvents
        let now = entry.date

        // активные индексы (все, кто идут прямо сейчас)
        let activeIdxs: [Int] = events.enumerated().compactMap { idx, ev in
            guard let s = ev.startDate, let e = ev.endDate else { return nil }
            return (now >= s && now <= e) ? idx : nil
        }
        let activeSet = Set(activeIdxs)

        // fallback focus (если активных нет): ближайшая будущая или последняя
        let focusIdx: Int? = {
            if !activeIdxs.isEmpty { return activeIdxs.min() }
            if let idxNext = events.firstIndex(where: { ev in
                if let s = ev.startDate { return s > now }
                return false
            }) { return idxNext }
            if !events.isEmpty { return events.count - 1 }
            return nil
        }()

        let window = computeWindowMultiActive(
            events: events,
            activeIdxs: activeIdxs,
            focusIdx: focusIdx,
            maxVisible: 5
        )

        let visible = window.visible
        let startIndex = window.startIndex

        return VStack(alignment: .leading, spacing: 5) {
            // HEADER
            HStack(spacing: 6) {
                Text(LocalizedString.commonToday.localized)
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.primary, theme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineLimit(1)

                Spacer()

                Text(entry.date, style: .date)
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            if events.isEmpty {
                noEventsView
            } else {
                VStack(alignment: .leading, spacing: 2.5) {
                    if window.hiddenBefore > 0 {
                        Text("+\(window.hiddenBefore) \(LocalizedString.commonMoreSuffix.localized)")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }

                    ForEach(Array(visible.enumerated()), id: \.offset) { offset, ev in
                        let globalIndex = startIndex + offset
                        let isHighlighted = activeSet.contains(globalIndex)
                        eventRow(ev, highlight: isHighlighted)
                    }

                    if window.hiddenAfter > 0 {
                        Text("+\(window.hiddenAfter) \(LocalizedString.commonMoreSuffix.localized)")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 6.5)
        .padding(.horizontal, 10)
    }

    /// Одна строка расписания
    private func eventRow(_ event: ScheduleEvent, highlight: Bool) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if highlight {
                Capsule()
                    .fill(colorForType(event.type, fallback: theme.primary))
                    .frame(width: barWidth, height: barHeight)
                    .fixedSize()
            } else {
                Color.clear.frame(width: barWidth, height: barHeight).fixedSize()
            }

            HStack(spacing: 4) {
                Text(timeRange(event.startDate, event.endDate))
                    .font(.system(size: 11.5, weight: .semibold))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text(eventAbbreviation(from: event.title))
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                if !event.displayRoom.isEmpty {
                    Text(event.displayRoom)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)

                if isOnline(event) {
                    Image(systemName: "wifi")
                        .font(.system(size: 9.5))
                        .foregroundColor(theme.online)
                }
            }
        }
    }

    /// Плашка "нет занятий"
    private var noEventsView: some View {
        HStack(spacing: 7) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 19))
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.primary, theme.secondary],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
            VStack(alignment: .leading, spacing: 1) {
                Text(LocalizedString.commonNoClassesToday.localized)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(LocalizedString.commonEnjoyFreeDay.localized)
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sliding window logic (multi-active aware)

    /// Окно максимум из maxVisible строк.
    /// Если есть активные — стараемся уместить **все активные**.
    /// Если спан активных длиннее окна — берём первые maxVisible из спана.
    private func computeWindowMultiActive(
        events: [ScheduleEvent],
        activeIdxs: [Int],
        focusIdx: Int?,
        maxVisible: Int
    ) -> (visible: [ScheduleEvent], startIndex: Int, hiddenBefore: Int, hiddenAfter: Int) {
        guard !events.isEmpty else { return ([], 0, 0, 0) }
        let total = events.count

        if !activeIdxs.isEmpty {
            let minA = activeIdxs.min()!
            let maxA = activeIdxs.max()!
            let spanCount = maxA - minA + 1

            var start: Int
            var endExclusive: Int

            if spanCount >= maxVisible {
                // активных больше окна — показываем первые maxVisible из спана
                start = minA
                endExclusive = min(total, start + maxVisible)
            } else {
                // хотим: [одна прошедшая] + [все активные] + [добить будущими]
                start = max(0, minA - 1)
                endExclusive = start + maxVisible

                // если активные не помещаются справа, сдвигаем окно влево
                if endExclusive < maxA + 1 {
                    start = max(0, (maxA + 1) - maxVisible)
                    endExclusive = min(total, start + maxVisible)
                }

                // если мы в самом конце дня — подтянуть окно вниз
                if endExclusive > total {
                    endExclusive = total
                    start = max(0, endExclusive - maxVisible)
                }
            }

            let vis = Array(events[start..<endExclusive])
            let hiddenBefore = max(0, start)
            let hiddenAfter = max(0, total - endExclusive)
            return (vis, start, hiddenBefore, hiddenAfter)
        } else {
            // нет активных: прежняя логика — фокус + одна прошедшая
            let focus = focusIdx ?? 0
            var start = max(0, focus - 1)
            var endExclusive = min(total, start + maxVisible)

            // если не хватает до конца — сдвигаем вниз
            if endExclusive - start < maxVisible && endExclusive < total {
                start = max(0, min(total - maxVisible, start))
                endExclusive = min(total, start + maxVisible)
            }

            let vis = Array(events[start..<endExclusive])
            let hiddenBefore = max(0, start)
            let hiddenAfter = max(0, total - endExclusive)
            return (vis, start, hiddenBefore, hiddenAfter)
        }
    }
}


// MARK: - LARGE — неделя: 2×3, ещё компактнее шрифты/отступы в колоночном режиме

// MARK: - LARGE — неделя: 2×3, ещё компактнее шрифты/отступы в колоночном режиме

struct LargeWidgetView: View {
    let entry: TimetableWidgetEntry
    @Environment(\.colorScheme) var colorScheme
    private var theme: any Theme { ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme) }

    var body: some View {
        let calendar = Calendar.current
        let orderedDays = entry.weekEvents.keys.sorted {
            weekdayRank($0, calendar: calendar) < weekdayRank($1, calendar: calendar)
        }
        let dayCount = orderedDays.count
        let eventsByDay = entry.weekEvents
        let maxPerDay = orderedDays.map { eventsByDay[$0]?.count ?? 0 }.max() ?? 0
        let useGrid = (dayCount >= 4) || (dayCount == 3 && maxPerDay >= 5)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(LocalizedString.commonThisWeek.localized)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.primary, theme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                let weekNum = calendar.component(.weekOfYear, from: entry.date)
                Text("\(LocalizedString.commonWeek.localized) \(weekNum)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            if dayCount == 0 {
                Spacer()
                Text("\(LocalizedString.commonNoClasses.localized) \(LocalizedString.commonThisWeek.localized.lowercased())")
                    .font(.system(size: 13.5))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else if useGrid {
                let splitIndex = gridSplitIndex(for: dayCount)
                let leftDays  = Array(orderedDays.prefix(splitIndex))      // например Пн / Вт / Ср
                let rightDays = Array(orderedDays.dropFirst(splitIndex))   // например Чт / Пт / Сб
                let rows = max(leftDays.count, rightDays.count)

                // рендерим ПО СТРОКАМ:
                // каждая строка — пара дней (левый + правый)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<rows, id: \.self) { i in
                        HStack(alignment: .top, spacing: 8) {
                            // левая половина строки
                            if i < leftDays.count, let evs = entry.weekEvents[leftDays[i]] {
                                DaySectionCompactView(
                                    date: leftDays[i],
                                    events: evs,
                                    theme: theme
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                // если дня нет (например правая колонка длиннее),
                                // кладём пустой блок, чтобы правая колонка не прыгала влево
                                Color.clear
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // правая половина строки
                            if i < rightDays.count, let evs = entry.weekEvents[rightDays[i]] {
                                DaySectionCompactView(
                                    date: rightDays[i],
                                    events: evs,
                                    theme: theme
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            } else {
                ForEach(orderedDays, id: \.self) { day in
                    if let events = entry.weekEvents[day] {
                        DaySectionView(date: day, events: events, theme: theme)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 9)
    }
}

private func gridSplitIndex(for daysCount: Int) -> Int {
    switch daysCount {
    case 6: return 3      // 3+3
    case 5: return 3      // 3+2
    case 4: return 2      // 2+2
    case 3: return 2      // 2+1
    case 2: return 1      // 1+1
    default:
        return Int(ceil(Double(daysCount) / 2.0))
    }
}

// Компактная секция дня для сетки
private struct DaySectionCompactView: View {
    let date: Date
    let events: [ScheduleEvent]
    let theme: any Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 2.5) {
            HStack(spacing: 4) {
                Text(date, format: .dateTime.weekday(.abbreviated))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Calendar.current.isDateInToday(date) ? theme.accent : .primary)
                Text(date, format: .dateTime.day())
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
                Spacer(minLength: 0)
            }

            ForEach(events.prefix(5)) { ev in
                HStack(spacing: 3.5) {
                    Circle()
                        .fill(colorForType(ev.type, fallback: theme.primary))
                        .frame(width: 3, height: 3)

                    // ВРЕМЯ — нельзя сжимать, всегда читабельное
                    Text(timeRange(ev.startDate, ev.endDate))
                        .font(.system(size: 10, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(1.0)   // не сжимать
                        .layoutPriority(2)         // самый высокий приоритет

                    // НАЗВАНИЕ — может немного ужаться
                    Text(eventAbbreviation(from: ev.title))
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .layoutPriority(1)

                    // АУДИТОРИЯ — самая низкая важность:
                    // маленький шрифт, может сильно ужаться
                    if !ev.displayRoom.isEmpty {
                        Text(ev.displayRoom)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .allowsTightening(true)
                            .layoutPriority(0)
                    }

                    Spacer(minLength: 0)

                    if isOnline(ev) {
                        Image(systemName: "wifi")
                            .font(.system(size: 8.5))
                            .foregroundColor(theme.online)
                    }
                }
            }

            if events.count > 5 {
                Text("+\(events.count - 5)")
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Вертикальная секция дня (≤3 дней)
private struct DaySectionView: View {
    let date: Date
    let events: [ScheduleEvent]
    let theme: any Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 5) {
                Text(date, format: .dateTime.weekday(.abbreviated))
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(Calendar.current.isDateInToday(date) ? theme.accent : .primary)
                Text(date, format: .dateTime.day())
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(events.count) \(LocalizedString.commonClasses.localized)")
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
            }

            ForEach(events.prefix(5)) { ev in
                HStack(spacing: 5) {
                    Circle()
                        .fill(colorForType(ev.type, fallback: theme.primary))
                        .frame(width: 4, height: 4)

                    // ВРЕМЯ — фиксировано читабельное
                    Text(timeRange(ev.startDate, ev.endDate))
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(1.0)   // не уменьшаем цифры
                        .layoutPriority(2)         // важнее всего

                    // НАЗВАНИЕ — средний приоритет
                    Text(eventAbbreviation(from: ev.title))
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .layoutPriority(1)

                    // АУДИТОРИЯ — можно ужать
                    if !ev.displayRoom.isEmpty {
                        Text(ev.displayRoom)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .allowsTightening(true)
                            .layoutPriority(0)
                    }

                    Spacer(minLength: 0)

                    if isOnline(ev) {
                        Image(systemName: "wifi")
                            .font(.system(size: 9.5))
                            .foregroundColor(theme.online)
                    }
                }
            }

            if events.count > 5 {
                Text("+\(events.count - 5)")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
}


//// MARK: - Превью (Large, 3×5 и 3×6)
//
//#if DEBUG
//#Preview("Large – 3 days × 5", as: .systemLarge) {
//    TimetableWidget()
//} timeline: {
//    TestData.makeEntry(days: 4, perDay: 5)
//}
//
//#Preview("Large – 3 days × 6", as: .systemLarge) {
//    TimetableWidget()
//} timeline: {
//    TestData.makeEntry(days: 4, perDay: 6)
//}
//
//// MARK: - Preview Mocks (type-checker friendly)
//
//enum TestData {
//    // Календарь/временные константы вынесены и типизированы
//    private static let cal: Calendar = {
//        var c = Calendar(identifier: .gregorian)
//        c.locale = Locale(identifier: "en_US_POSIX")
//        c.timeZone = .current
//        return c
//    }()
//
//    private static let slot: TimeInterval = 75 * 60 // 75 минут пара
//
//    // Один форматтер на все
//    private static let iso: ISO8601DateFormatter = {
//        let f = ISO8601DateFormatter()
//        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//        f.timeZone = .current
//        return f
//    }()
//
//    // Разбиваем большие литералы на батчи — так превью не «подменяет» одну огромную строку
//    private static let titles: [String] = {
//        var out: [String] = []
//        out += ["PGD", "HMWIA", "WDGS"]
//        out += ["PPP", "KP1", "UED"]
//        out += ["PR", "PPG", "PJFIP"]
//        out += ["ALG", "DB"]
//        return out
//    }()
//
//    private static let rooms: [String] = {
//        var out: [String] = []
//        out += ["S55 106", "S55 107", "S47 119"]
//        out += ["S47 216", "S47 314", "S55 308"]
//        return out
//    }()
//
//    // Понедельник текущей недели
//    private static func mondayOfCurrentWeek(_ date: Date = .now) -> Date {
//        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
//        return cal.date(from: comps) ?? date
//    }
//
//    // MARK: - Schedule factory (под твою модель)
//
//    static func buildPreviewSchedule(
//        days: Int,
//        perDay: Int,
//        startHour: Int = 8,
//        includeOnline: Bool = true
//    ) -> GroupScheduleResponse {
//        var events: [ScheduleEvent] = []
//        events.reserveCapacity(max(0, min(days, 7) * perDay))
//
//        let weekStart: Date = mondayOfCurrentWeek()
//
//        for d in 0..<min(days, 7) {
//            guard
//                let day = cal.date(byAdding: .day, value: d, to: weekStart),
//                let dayStart = cal.date(bySettingHour: startHour, minute: 0, second: 0, of: day)
//            else { continue }
//
//            for i in 0..<perDay {
//                let start: Date = dayStart.addingTimeInterval(TimeInterval(i) * slot)
//                let end: Date   = start.addingTimeInterval(slot)
//
//                let title: String = titles[(d + i) % titles.count]
//                let room: String  = rooms[(d * 2 + i) % rooms.count]
//                let type: String  = (i % 3 == 0) ? "lecture" : ((i % 3 == 1) ? "exercise" : "laboratory")
//                let online: Bool  = includeOnline && (i % 4 == 3)
//
//                // Конструктор строго под твою модель ScheduleEvent
//                let ev = ScheduleEvent(
//                    title: title,
//                    type: type,
//                    startISO: iso.string(from: start),
//                    endISO: iso.string(from: end),
//                    room: online ? "" : room,          // если online, комнаты нет
//                    grading: nil,
//                    remarks: online ? "online" : nil,  // помечаем online для иконки Wi-Fi
//                    studyTrack: nil,
//                    groups: nil,
//                    teacherId: 1,
//                    teacherName: "Dr. Novak",
//                    teacherEmail: nil,
//                    startDate: start,
//                    endDate: end
//                )
//                events.append(ev)
//            }
//        }
//
//        // Оставь ровно тот init, который есть у тебя в проекте.
//        // Если у тебя именно такой — будет работать из коробки:
//        return GroupScheduleResponse(
//            groupId: 2345,
//            from: "2025-09-01",
//            to: "2026-01-31",
//            intervalType: 1,
//            groupSchedule: events,
//            fetchedAt: "2025-10-25T00:00:00Z"
//        )
//        // Если у тебя другой init, замени на свой, но оставь events как есть.
//    }
//
//    // MARK: - Entry builder
//
//    static func makeEntry(days: Int, perDay: Int) -> TimetableWidgetEntry {
//        let schedule: GroupScheduleResponse = buildPreviewSchedule(days: days, perDay: perDay)
//        return TimetableWidgetEntry(
//            date: .now,
//            schedule: schedule,
//            selectedThemeId: "default",
//            appearanceMode: "system",
//            configuration: nil
//        )
//    }
//}
//#endif
