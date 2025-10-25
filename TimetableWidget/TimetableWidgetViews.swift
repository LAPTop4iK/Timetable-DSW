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
    let t = event.remarks?.lowercased() ?? ""
    return t.contains("distance") || t.contains("онлайн") || t.contains("zdal") || t.contains("remote")
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

    var body: some View {
        let now = entry.date
        let events = entry.todayEvents
        let focus = entry.currentEvent ?? events.first { ($0.startDate ?? .distantPast) >= now }
        let others: [ScheduleEvent] = {
            guard let f = focus,
                  let idx = events.firstIndex(where: { $0.title == f.title && $0.startDate == f.startDate }) else { return [] }
            return Array(events.suffix(from: events.index(after: idx)))
        }()

        return VStack(alignment: .leading, spacing: 5) {
            Text(LocalizedString.commonToday.localized.uppercased())
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [theme.primary, theme.secondary],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .lineLimit(1)

            if let f = focus { FocusEventRow(event: f, theme: theme) }
            else {
                HStack(spacing: 6) {
                    Image(systemName: "zzz").font(.system(size: 14, weight: .semibold)).foregroundColor(.secondary)
                    Text(LocalizedString.commonNoClassesToday.localized)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(2).minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach(others.prefix(4)) { CompactEventRow(event: $0, theme: theme) }

            let rest = max(0, others.count - 4)
            if rest > 0 {
                Text("+\(rest)").font(.system(size: 10.5, weight: .semibold)).foregroundColor(.secondary).padding(.top, 1)
            }
        }
        .padding(.vertical, 8).padding(.horizontal, 10)
    }
}

private struct FocusEventRow: View {
    let event: ScheduleEvent
    let theme: any Theme
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Capsule().fill(colorForType(event.type, fallback: theme.primary)).frame(width: 3, height: 22).padding(.top, 2)

            VStack(alignment: .leading, spacing: 1) {
                Text(eventAbbreviation(from: event.title))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1).minimumScaleFactor(0.6).allowsTightening(true)

                if isOnline(event) {
                    // ↓ поменьше, чтобы не давило на аббревиатуру
                    Image(systemName: "wifi").font(.system(size: 8))
                        .foregroundColor(theme.online)
                } else if !event.displayRoom.isEmpty {
                    Text(event.displayRoom)
                        .font(.system(size: 10)).foregroundColor(.secondary)
                        .lineLimit(1).minimumScaleFactor(0.6).allowsTightening(true)
                }
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 0) {
                if let s = event.startDate {
                    Text(s, style: .time)
                        .font(.system(size: 13, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1).minimumScaleFactor(0.7).allowsTightening(true)
                }
                if let e = event.endDate {
                    Text(e, style: .time)
                        .font(.system(size: 10))
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                        .lineLimit(1).minimumScaleFactor(0.7).allowsTightening(true)
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
                Image(systemName: "wifi").font(.system(size: 8)).foregroundColor(theme.online)
            } else {
                Circle().fill(colorForType(event.type, fallback: theme.secondary)).frame(width: 4, height: 4)
            }

            Text(eventAbbreviation(from: event.title))
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1).minimumScaleFactor(0.6).allowsTightening(true)
                .layoutPriority(1)

            Spacer(minLength: 2)

            if let s = event.startDate {
                Text(s, style: .time)
                    .font(.system(size: 11, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .lineLimit(1).minimumScaleFactor(0.7).allowsTightening(true)
                    .frame(minWidth: 38, alignment: .trailing)
            }
        }
    }
}

// MARK: - MEDIUM (окно из 5 пар, подсветка только текущей, скользящее окно дня)

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

        // 1. фокусная пара:
        //    - если сейчас идёт -> она
        //    - иначе ближайшая будущая
        //    - иначе последняя в дне
        let focusIdx: Int? = {
            if let idxNow = events.firstIndex(where: { ev in
                if let s = ev.startDate, let e = ev.endDate {
                    return now >= s && now <= e
                }
                return false
            }) {
                return idxNow
            }
            if let idxNext = events.firstIndex(where: { ev in
                if let s = ev.startDate {
                    return s > now
                }
                return false
            }) {
                return idxNext
            }
            if !events.isEmpty {
                return events.count - 1
            }
            return nil
        }()

        // 2. окно максимум из 5 строк, с логикой "оставь предыдущую, но не держи весь день"
        let windowInfo = computeWindow(
            events: events,
            focusIdx: focusIdx,
            maxVisible: 5
        )

        let visibleEvents     = windowInfo.visible
        let startIndex        = windowInfo.startIndex
        let hiddenBeforeCount = windowInfo.hiddenBefore
        let hiddenAfterCount  = windowInfo.hiddenAfter

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
                // 3. список видимых пар + "+N" сверху/снизу
                VStack(alignment: .leading, spacing: 2.5) {

                    // +N СВЕРХУ, если мы уже срезали старые пары сверху
                    if hiddenBeforeCount > 0 {
                        Text("+\(hiddenBeforeCount) \(LocalizedString.commonMoreSuffix.localized)")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }

                    // сами пары
                    ForEach(Array(visibleEvents.enumerated()), id: \.offset) { offset, ev in
                        let globalIndex = startIndex + offset
                        let isFocused = (globalIndex == focusIdx)
                        eventRow(ev, highlight: isFocused)
                    }

                    // +N СНИЗУ, если мы ещё не показали хвост (будущие пары)
                    if hiddenAfterCount > 0 {
                        Text("+\(hiddenAfterCount) \(LocalizedString.commonMoreSuffix.localized)")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 6.5)
        .padding(.horizontal, 10)
    }

    /// Одна строка расписания.
    /// highlight == true → рисуем цветную палку слева
    /// highlight == false → прозрачный placeholder той же ширины, чтобы текст не прыгал
    private func eventRow(_ event: ScheduleEvent, highlight: Bool) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if highlight {
                Capsule()
                    .fill(colorForType(event.type, fallback: theme.primary))
                    .frame(width: barWidth, height: barHeight)
                    .fixedSize()
            } else {
                // выравнивание слева (та же ширина/высота, но невидимо)
                Color.clear
                    .frame(width: barWidth, height: barHeight)
                    .fixedSize()
            }

            HStack(spacing: 4) {
                // Время (start-end, через короткий дефис)
                Text(timeRange(event.startDate, event.endDate))
                    .font(.system(size: 11.5, weight: .semibold))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                // Аббревиатура предмета
                Text(eventAbbreviation(from: event.title))
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                // Аудитория / кабинет (если не онлайн)
                if !event.displayRoom.isEmpty {
                    Text(event.displayRoom)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)

                // Значок Wi-Fi для онлайна
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
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
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

    // MARK: - Sliding window logic

    /// Возвращает окно максимум из maxVisible событий плюс метаданные:
    ///  - visible: какие пары реально показываем
    ///  - startIndex: индекс первой пары в общем массиве
    ///  - hiddenBefore: сколько пар мы скрыли СВЕРХУ (уже прошли)
    ///  - hiddenAfter: сколько пар мы скрыли СНИЗУ (ещё будут)
    ///
    /// Алгоритм:
    ///  - хотим держать текущую/ближайшую пару (focusIdx) и одну предыдущую, если она есть
    ///  - но не больше 5 строк
    ///  - ближе к концу дня окно сдвигается вниз, поэтому верх уже урезан → тут hiddenBefore > 0
    ///  - ближе к началу дня наоборот урезан хвост → hiddenAfter > 0
    private func computeWindow(
        events: [ScheduleEvent],
        focusIdx: Int?,
        maxVisible: Int
    ) -> (
        visible: [ScheduleEvent],
        startIndex: Int,
        hiddenBefore: Int,
        hiddenAfter: Int
    ) {
        guard !events.isEmpty else {
            return ([], 0, 0, 0)
        }

        let total = events.count
        let focus = focusIdx ?? 0

        // шаг 1: пробуем показать "фокусную" + одну предыдущую
        var startIndex = max(0, focus - 1)

        // сколько останется от startIndex до конца
        var remainingFromStart = total - startIndex

        // если до конца меньше чем maxVisible → двигаем окно в самый низ,
        // так чтобы последние maxVisible пар тоже влезли
        if remainingFromStart < maxVisible {
            startIndex = max(0, total - maxVisible)
            remainingFromStart = total - startIndex
        }

        // сколько реально показываем в окне
        let countToShow = min(maxVisible, remainingFromStart)
        let endExclusive = startIndex + countToShow

        // видимые пары
        let slice = Array(events[startIndex..<endExclusive])

        // сколько мы скрыли СВЕРХУ (прошедшие пары, которые выпали за окно)
        let hiddenBefore = max(0, startIndex)

        // сколько мы скрыли СНИЗУ (будущие пары, которые не влезли после окна)
        let hiddenAfter = max(0, total - endExclusive)

        return (slice, startIndex, hiddenBefore, hiddenAfter)
    }
}


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
                    .foregroundStyle(LinearGradient(colors: [theme.primary, theme.secondary], startPoint: .leading, endPoint: .trailing))
                Spacer()
                let weekNum = calendar.component(.weekOfYear, from: entry.date)
                Text("\(LocalizedString.commonWeek.localized) \(weekNum)")
                    .font(.system(size: 11)).foregroundColor(.secondary)
            }

            if dayCount == 0 {
                Spacer()
                Text("\(LocalizedString.commonNoClasses.localized) \(LocalizedString.commonThisWeek.localized.lowercased())")
                    .font(.system(size: 13.5)).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else if useGrid {
                // пары строк: [Пн,Вт,Ср] / [Чт,Пт,Сб]
                let splitIndex = gridSplitIndex(for: dayCount)
                let leftDays = Array(orderedDays.prefix(splitIndex))
                let rightDays = Array(orderedDays.dropFirst(splitIndex))
                let rows = max(leftDays.count, rightDays.count)

                let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
                LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
                    ForEach(0..<rows, id: \.self) { i in
                        if i < leftDays.count, let evs = entry.weekEvents[leftDays[i]] {
                            DaySectionCompactView(date: leftDays[i], events: evs, theme: theme) // ↓ компактный режим
                        } else { Color.clear.frame(height: 0) }

                        if i < rightDays.count, let evs = entry.weekEvents[rightDays[i]] {
                            DaySectionCompactView(date: rightDays[i], events: evs, theme: theme)
                        } else { Color.clear.frame(height: 0) }
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
        .padding(.vertical, 8).padding(.horizontal, 9)
    }
}

private func gridSplitIndex(for daysCount: Int) -> Int {
    switch daysCount {
    case 6: return 3      // 3+3  (Пн-Ср | Чт-Сб)
    case 5: return 3      // 3+2
    case 4: return 2      // 2+2
    case 3: return 2      // 2+1 (новое правило для плотного дня)
    case 2: return 1      // 1+1
    default:
        // 7 или иные — балансно: ceil(n/2)
        return Int(ceil(Double(daysCount) / 2.0))
    }
}

// Компактная секция дня для сетки — ЕЩЁ меньше
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
                    .font(.system(size: 9.5)).foregroundColor(.secondary)
                Spacer(minLength: 0)
            }

            ForEach(events.prefix(5)) { ev in
                HStack(spacing: 3.5) {
                    Circle().fill(colorForType(ev.type, fallback: theme.primary)).frame(width: 3, height: 3)

                    Text(timeRange(ev.startDate, ev.endDate))
                        .font(.system(size: 10, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(eventAbbreviation(from: ev.title))
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)

                    if !ev.displayRoom.isEmpty {
                        Text(ev.displayRoom)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }

                    Spacer(minLength: 0)

                    if isOnline(ev) {
                        Image(systemName: "wifi").font(.system(size: 8.5)).foregroundColor(theme.online)
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
                    .font(.system(size: 10.5)).foregroundColor(.secondary)
                Spacer()
                Text("\(events.count) \(LocalizedString.commonClasses.localized)")
                    .font(.system(size: 9.5)).foregroundColor(.secondary)
            }

            ForEach(events.prefix(5)) { ev in
                HStack(spacing: 5) {
                    Circle().fill(colorForType(ev.type, fallback: theme.primary)).frame(width: 4, height: 4)

                    Text(timeRange(ev.startDate, ev.endDate))
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(eventAbbreviation(from: ev.title))
                        .font(.system(size: 11))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    if !ev.displayRoom.isEmpty {
                        Text(ev.displayRoom)
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }

                    Spacer(minLength: 0)

                    if isOnline(ev) {
                        Image(systemName: "wifi").font(.system(size: 9.5)).foregroundColor(theme.online)
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
