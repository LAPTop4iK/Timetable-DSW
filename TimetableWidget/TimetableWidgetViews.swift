//
//  TimetableWidgetViews.swift
//
//  TimetableWidgetViews.swift
//  TimetableWidget
//

import SwiftUI
import WidgetKit

// MARK: - Helpers

/// Создаёт короткую аббревиатуру дисциплины (до 5 символов)
private func eventAbbreviation(from title: String) -> String {
    let words = title
        .replacingOccurrences(of: "·", with: " ")
        .replacingOccurrences(of: "—", with: " ")
        .split { $0.isWhitespace || $0.isNewline || $0.isPunctuation }
        .map(String.init)

    var result = words.compactMap { $0.first?.uppercased() }.joined()
    if result.count < 2 {
        result = title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
    }
    return String(result.prefix(5))
}

/// Время в формате "HH:mm-HH:mm" с коротким дефисом
private func timeRange(_ start: Date?, _ end: Date?) -> String {
    switch (start, end) {
    case let (s?, e?):
        return "\(s.formatted(date: .omitted, time: .shortened))-\(e.formatted(date: .omitted, time: .shortened))"
    case let (s?, nil):
        return s.formatted(date: .omitted, time: .shortened)
    case let (nil, e?):
        return e.formatted(date: .omitted, time: .shortened)
    default:
        return ""
    }
}

/// Цвет акцента для пары.
/// Вместо хардкода используем цвета текущей темы:
///  - lecture  → theme.lectureStart
///  - exercise → theme.exerciseStart
///  - lab      → theme.laboratoryStart
///  - other    → theme.primary (фоллбэк)
private func eventAccentColor(for event: ScheduleEvent, theme: any Theme) -> Color {
    switch event.eventType() {
    case .lecture:
        return theme.lectureStart
    case .exercise:
        return theme.exerciseStart
    case .laboratory:
        return theme.laboratoryStart
    case .other:
        return theme.primary
    }
}

/// Для упорядочивания дней недели (Пн=1 ... Вс=7)
private func weekdayRank(_ date: Date, calendar: Calendar = .current) -> Int {
    let wd = calendar.component(.weekday, from: date) // 1=Sun..7=Sat
    return wd == 1 ? 7 : wd - 1
}

// MARK: - SMALL

struct SmallWidgetView: View {
    let entry: TimetableWidgetEntry

    @Environment(\.colorScheme) var colorScheme
    private var theme: any Theme {
        ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme)
    }

    private let maxRowsTotal = 5

    var body: some View {
        let now = entry.date

        // фильтруем отменённые пары через общую логику
        let events = entry.todayEvents.filter { !$0.isCancelled() }

        // индексы всех активных пар (могут идти одновременно)
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
                    FocusEventRow(
                        event: events[idx],
                        theme: theme,
                        showOnline: entry.shouldShowOnline
                    )
                }

                // 2. будущие пары после последней активной
                let lastActive = activeIdxs.max()!
                let future = Array(events.suffix(from: lastActive + 1))

                let remainingSlots = max(0, maxRowsTotal - activeToShow.count)
                let futureToShow = Array(future.prefix(remainingSlots))

                if !futureToShow.isEmpty {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(futureToShow) { ev in
                            CompactEventRow(
                                event: ev,
                                theme: theme,
                                showOnline: entry.shouldShowOnline
                            )
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
                        .padding(.bottom, 4)
                }

            } else {
                // нет активных прямо сейчас:
                // берём текущую (если идёт) или ближайшую будущую
                let focus = entry.currentEvent ?? events.first { ev in
                    (ev.startDate ?? .distantPast) >= now
                }

                if let f = focus {
                    FocusEventRow(
                        event: f,
                        theme: theme,
                        showOnline: entry.shouldShowOnline
                    )

                    // остальные будущие после фокуса
                    if let idx = events.firstIndex(where: { $0.id == f.id }) {
                        let future = Array(events.suffix(from: idx + 1))
                        let othersToShow = Array(future.prefix(maxRowsTotal - 1))

                        if !othersToShow.isEmpty {
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(othersToShow) { ev in
                                    CompactEventRow(
                                        event: ev,
                                        theme: theme,
                                        showOnline: entry.shouldShowOnline
                                    )
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

/// Активная пара (подсветка слева вертикальной палкой цвета типа пары)
private struct FocusEventRow: View {
    let event: ScheduleEvent
    let theme: any Theme
    let showOnline: Bool

    var body: some View {
        let barColor = eventAccentColor(for: event, theme: theme)

        HStack(alignment: .top, spacing: 6) {
            // палка слева
            Capsule()
                .fill(barColor)
                .frame(width: 3, height: 25)
                .padding(.top, 2)

            // инфо слева (аббревиатура + аудитория или wifi)
            VStack(alignment: .leading, spacing: 1) {
                Text(eventAbbreviation(from: event.title))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)

                if showOnline && event.isOnline() {
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

            // время справа
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

/// Небольшая строка будущей пары
private struct CompactEventRow: View {
    let event: ScheduleEvent
    let theme: any Theme
    let showOnline: Bool

    var body: some View {
        let dotColor = eventAccentColor(for: event, theme: theme)

        HStack(spacing: 4) {
            if showOnline && event.isOnline() {
                Image(systemName: "wifi")
                    .font(.system(size: 8))
                    .foregroundColor(theme.online)
            } else {
                Circle()
                    .fill(dotColor)
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

// MARK: - MEDIUM

/// Medium: окно из максимум 5 строк.
/// Если есть несколько активных пар → все активные подсвечиваются.
/// Старые пары схлопываются вверх в "+N", будущие хвосты — вниз в "+N".
struct MediumWidgetView: View {
    let entry: TimetableWidgetEntry

    @Environment(\.colorScheme) var colorScheme
    private var theme: any Theme {
        ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme)
    }

    // компактная палка слева у выделенных пар
    private let barHeight: CGFloat = 12
    private let barWidth: CGFloat = 2

    var body: some View {
        // 1. убираем отменённые пары
        let eventsAll = entry.todayEvents.filter { !$0.isCancelled() }
        let now = entry.date

        // 2. пары, которые ИДУТ прямо сейчас (now внутри [start,end])
        let activeNowIdxs: [Int] = eventsAll.enumerated().compactMap { idx, ev in
            guard let s = ev.startDate, let e = ev.endDate else { return nil }
            return (now >= s && now <= e) ? idx : nil
        }

        // 3. пары, которые ЕЩЁ НЕ начались (start > now)
        //    найдём ближайшее будущее start и возьмём все пары с таким же start
        let futureIdxsByStart: [Int] = {
            // соберём (idx, start) только для будущих
            let futurePairs: [(Int, Date)] = eventsAll.enumerated().compactMap { idx, ev in
                guard let s = ev.startDate else { return nil }
                return (s > now) ? (idx, s) : nil
            }

            guard !futurePairs.isEmpty else { return [] }

            // самое раннее будущее время старта
            let earliestStart = futurePairs.map { $0.1 }.min()!

            // все пары, которые стартуют ровно в earliestStart
            let sameSlotIdxs = futurePairs
                .filter { $0.1 == earliestStart }
                .map { $0.0 }

            return sameSlotIdxs.sorted()
        }()

        // 4. кого будем ПОДСВЕЧИВАТЬ (activeSet):
        //    - если прямо сейчас есть пары -> их
        //    - иначе если сейчас перемена, но есть будущие пары -> ближайший слот (все пары с earliestStart)
        //    - иначе (день кончился) -> никого
        let highlightedIdxs: [Int] = {
            if !activeNowIdxs.isEmpty {
                return activeNowIdxs.sorted()
            } else if !futureIdxsByStart.isEmpty {
                return futureIdxsByStart
            } else {
                return []
            }
        }()
        let activeSet = Set(highlightedIdxs)

        // 5. какой индекс считать "фокусом" для окна:
        //    - если кого-то подсвечиваем → минимальный из них
        //    - иначе день уже прошёл → последняя пара дня (если есть)
        let focusIdx: Int? = {
            if let firstHighlighted = highlightedIdxs.min() {
                return firstHighlighted
            } else if !eventsAll.isEmpty {
                // день закончился, подсветки не будет,
                // но окно хотим прижать к концу дня
                return eventsAll.count - 1
            } else {
                return nil
            }
        }()

        // 6. рассчитываем "окно" (макс 5 строк) вокруг фокуса / выделенных
        //    важно: в computeWindowMultiActive мы передаём highlightedIdxs,
        //    НЕ activeNowIdxs, чтобы во время перемены окно центрировалось
        //    вокруг ближайшего будущего слота.
        let window = computeWindowMultiActive(
            events: eventsAll,
            activeIdxs: highlightedIdxs,
            focusIdx: focusIdx,
            maxVisible: 5
        )

        let visibleEvents = window.visible
        let startIndex    = window.startIndex

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

            if eventsAll.isEmpty {
                noEventsView
            } else {
                VStack(alignment: .leading, spacing: 2.5) {

                    // +N сверху, если мы порезали прошедшие пары
                    if window.hiddenBefore > 0 {
                        Text("+\(window.hiddenBefore) \(LocalizedString.commonMoreSuffix.localized)")
                            .font(.system(size: 9.5))
                            .foregroundColor(.secondary)
                    }

                    // сами пары
                    ForEach(Array(visibleEvents.enumerated()), id: \.offset) { offset, ev in
                        let globalIndex = startIndex + offset
                        let isHighlighted = activeSet.contains(globalIndex)

                        eventRow(ev, highlight: isHighlighted)
                    }

                    // +N снизу, если мы порезали хвост
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

    // MARK: - Рендер строки пары

    private func eventRow(_ event: ScheduleEvent, highlight: Bool) -> some View {
        let barColor = eventAccentColor(for: event, theme: theme)

        return HStack(alignment: .center, spacing: 5) {
            // палка слева, если выделено (активно сейчас или ближайший слот в перемене)
            if highlight {
                Capsule()
                    .fill(barColor)
                    .frame(width: barWidth, height: barHeight)
                    .fixedSize()
            } else {
                Color.clear
                    .frame(width: barWidth, height: barHeight)
                    .fixedSize()
            }

            HStack(spacing: 4) {
                // время (start-end)
                Text(timeRange(event.startDate, event.endDate))
                    .font(.system(size: 11.5, weight: .semibold))
                    .monospacedDigit()
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                // аббревиатура дисциплины
                Text(eventAbbreviation(from: event.title))
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                // аудитория, если оффлайн
                if !event.displayRoom.isEmpty {
                    Text(event.displayRoom)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)

                // Wi-Fi если пара онлайн и пользователь не выключил
                if entry.shouldShowOnline && event.isOnline() {
                    Image(systemName: "wifi")
                        .font(.system(size: 9.5))
                        .foregroundColor(theme.online)
                }
            }
        }
    }

    // MARK: - "Нет занятий"
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

    // MARK: - Окно показа (как и раньше)

    private func computeWindowMultiActive(
        events: [ScheduleEvent],
        activeIdxs: [Int],
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

        if !activeIdxs.isEmpty {
            // у нас есть набор индексов, которые хотим держать в кадре (либо реально активные, либо ближайший слот после перемены)
            let minA = activeIdxs.min()!
            let maxA = activeIdxs.max()!
            let spanCount = maxA - minA + 1

            var start: Int
            var endExclusive: Int

            if spanCount >= maxVisible {
                // сам диапазон не влезает целиком → обрезаем его с головы
                start = minA
                endExclusive = min(total, start + maxVisible)
            } else {
                // пробуем показать одну предыдущую пару (если есть) + наш диапазон + добить будущими
                start = max(0, minA - 1)
                endExclusive = start + maxVisible

                // если в это окно не помещается весь span → сдвигаем старт так, чтобы поместился хвост
                if endExclusive < maxA + 1 {
                    start = max(0, (maxA + 1) - maxVisible)
                    endExclusive = min(total, start + maxVisible)
                }

                // если уехали слишком вниз, корректируем
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
            // день уже закончился: нет активных сейчас и нет будущих
            // просто показываем хвост дня вокруг focusIdx (который = последняя пара)
            let focus = focusIdx ?? 0
            var start = max(0, focus - 1)
            var endExclusive = min(total, start + maxVisible)

            if (endExclusive - start) < maxVisible && endExclusive < total {
                start = max(0, total - maxVisible)
                endExclusive = min(total, start + maxVisible)
            }

            let vis = Array(events[start..<endExclusive])
            let hiddenBefore = max(0, start)
            let hiddenAfter = max(0, total - endExclusive)
            return (vis, start, hiddenBefore, hiddenAfter)
        }
    }
}

// MARK: - LARGE (неделя)

/// Large: неделя.
/// Если дней >=4 (или 3 дня, но перегружены) — рисуем двухколоночную сетку:
/// каждая строка = два дня слева/справа, выравниваем по верху.
/// Внутри дня:
///  - время не сжимается,
///  - название может сжаться,
///  - аудитория может сжаться сильнее,
///  - Wi-Fi для онлайна.
/// Пары с isCancelled() вообще не показываем.
struct LargeWidgetView: View {
    let entry: TimetableWidgetEntry

    @Environment(\.colorScheme) var colorScheme
    private var theme: any Theme {
        ThemeFactory.theme(withId: entry.selectedThemeId, for: colorScheme)
    }

    var body: some View {
        let calendar = Calendar.current

        // сортируем дни недели
        let orderedDays = entry.weekEvents.keys.sorted {
            weekdayRank($0, calendar: calendar) < weekdayRank($1, calendar: calendar)
        }

        let dayCount = orderedDays.count
        let eventsByDay = entry.weekEvents

        // максимум пар в дне
        let maxPerDay = orderedDays
            .map { (eventsByDay[$0]?.count ?? 0) }
            .max() ?? 0

        // решаем, нужен ли двухколоночный режим
        let useGrid = (dayCount >= 4) || (dayCount == 3 && maxPerDay >= 5)

        return VStack(alignment: .leading, spacing: 6) {

            // HEADER недели
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
                // Неделя пустая
                Spacer()
                Text("\(LocalizedString.commonNoClasses.localized) \(LocalizedString.commonThisWeek.localized.lowercased())")
                    .font(.system(size: 13.5))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()

            } else if useGrid {
                // Двухколоночный режим
                let splitIndex = gridSplitIndex(for: dayCount)
                let leftDays  = Array(orderedDays.prefix(splitIndex))
                let rightDays = Array(orderedDays.dropFirst(splitIndex))
                let rows = max(leftDays.count, rightDays.count)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(0..<rows, id: \.self) { i in
                        HStack(alignment: .top, spacing: 8) {
                            // левая колонка
                            if i < leftDays.count,
                               let evs = entry.weekEvents[leftDays[i]] {
                                DaySectionCompactView(
                                    date: leftDays[i],
                                    events: evs,
                                    theme: theme,
                                    showOnline: entry.shouldShowOnline
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            // правая колонка
                            if i < rightDays.count,
                               let evs = entry.weekEvents[rightDays[i]] {
                                DaySectionCompactView(
                                    date: rightDays[i],
                                    events: evs,
                                    theme: theme,
                                    showOnline: entry.shouldShowOnline
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
                // Вертикальный режим (мало учебных дней)
                ForEach(orderedDays, id: \.self) { day in
                    if let events = entry.weekEvents[day] {
                        DaySectionView(
                            date: day,
                            events: events,
                            theme: theme,
                            showOnline: entry.shouldShowOnline
                        )
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 9)
    }
}

/// как разделить дни на левую/правую колонну
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

/// Компактный блок дня для сетки (2 колонки)
private struct DaySectionCompactView: View {
    let date: Date
    let events: [ScheduleEvent]
    let theme: any Theme
    let showOnline: Bool

    var body: some View {
        // не показываем отменённые пары
        let filtered = events.filter { !$0.isCancelled() }

        return VStack(alignment: .leading, spacing: 2.5) {
            // заголовок дня
            HStack(spacing: 4) {
                Text(date, format: .dateTime.weekday(.abbreviated))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(
                        Calendar.current.isDateInToday(date)
                        ? theme.accent
                        : .primary
                    )

                Text(date, format: .dateTime.day())
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)

                Spacer(minLength: 0)
            }

            // максимум 5 пар
            ForEach(filtered.prefix(5)) { ev in
                let color = eventAccentColor(for: ev, theme: theme)

                HStack(spacing: 3.5) {
                    // точка по цвету типа пары
                    Circle()
                        .fill(color)
                        .frame(width: 3, height: 3)

                    // ВРЕМЯ — не сжимать
                    Text(timeRange(ev.startDate, ev.endDate))
                        .font(.system(size: 10, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(1.0)
                        .layoutPriority(2)

                    // НАЗВАНИЕ — можно ужать
                    Text(eventAbbreviation(from: ev.title))
                        .font(.system(size: 10))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .allowsTightening(true)
                        .layoutPriority(1)

                    // АУДИТОРИЯ — самая низкая важность (сжимается сильнее)
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

                    // Wi-Fi если онлайн
                    if showOnline && ev.isOnline() {
                        Image(systemName: "wifi")
                            .font(.system(size: 8.5))
                            .foregroundColor(theme.online)
                    }
                }
            }

            if filtered.count > 5 {
                Text("+\(filtered.count - 5)")
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// Вертикальная секция дня, если дней <=3 (не сетка)
private struct DaySectionView: View {
    let date: Date
    let events: [ScheduleEvent]
    let theme: any Theme
    let showOnline: Bool

    var body: some View {
        let filtered = events.filter { !$0.isCancelled() }

        return VStack(alignment: .leading, spacing: 4) {

            // заголовок дня
            HStack(spacing: 5) {
                Text(date, format: .dateTime.weekday(.abbreviated))
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(
                        Calendar.current.isDateInToday(date)
                        ? theme.accent
                        : .primary
                    )

                Text(date, format: .dateTime.day())
                    .font(.system(size: 10.5))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(filtered.count) \(LocalizedString.commonClasses.localized)")
                    .font(.system(size: 9.5))
                    .foregroundColor(.secondary)
            }

            // максимум 5 пар
            ForEach(filtered.prefix(5)) { ev in
                let color = eventAccentColor(for: ev, theme: theme)

                HStack(spacing: 5) {
                    Circle()
                        .fill(color)
                        .frame(width: 4, height: 4)

                    // ВРЕМЯ — фиксировано читаемое, не сжимать
                    Text(timeRange(ev.startDate, ev.endDate))
                        .font(.system(size: 11, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(1.0)
                        .layoutPriority(2)

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

                    if ev.isOnline() {
                        Image(systemName: "wifi")
                            .font(.system(size: 9.5))
                            .foregroundColor(theme.online)
                    }
                }
            }

            if filtered.count > 5 {
                Text("+\(filtered.count - 5)")
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
