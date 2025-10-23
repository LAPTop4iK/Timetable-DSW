//
//  DayEventsView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import SwiftUI
import Combine

/// Экран списка событий за выбранный день.
/// Оптимизация:
/// - Полный отказ от `Calendar.autoupdatingCurrent` в рантайме рендера (дорогие DST-переходы).
/// - Предвычисление дневного диапазона в `init` (start/end) и повторное использование.
/// - Единичная фильтрация/сортировка за рендер, без повторных проходов и аллокаций.
/// - Таймер тикает только для «сегодня».
struct DayEventsView: View {

    // MARK: - Configuration

    struct Configuration: ComponentConfiguration {
        struct Constants {
            let spacing: AppSpacing = .medium
            let padding: AppSpacing = .large
        }
        static let constants = Constants()
    }

    // MARK: - Input

    let date: Date
    let events: [ScheduleEvent]
    let showTeacherName: Bool
    let onTeacherTap: ((Int) -> Void)?

    /// Вертикальные отступы скролла (под хедер/табы/нижнюю панель)
    let topScrollInset: CGFloat
    let bottomScrollInset: CGFloat

    // MARK: - State

    @State private var now: Date = Date()
    @State private var subjectSheet: Subject? = nil

    // MARK: - Dependencies

    private let dateService: DateService

    // MARK: - Calendar & Day Interval (предвычислено)

    /// Фиксированный календарь (без автоподстановки) — убираем лишние проверки DST при каждом доступе.
    private static let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale.current
        cal.timeZone = TimeZone.current
        return cal
    }()

    /// Начало дня (локальной даты)
    private let dayStart: Date
    /// Начало следующего дня
    private let nextDayStart: Date
    /// Флаг «сегодня»
    private let isToday: Bool

    // MARK: - Init

    init(
        date: Date,
        events: [ScheduleEvent],
        showTeacherName: Bool,
        onTeacherTap: ((Int) -> Void)?,
        topScrollInset: CGFloat,
        bottomScrollInset: CGFloat,
        dateService: DateService = DefaultDateService.shared
    ) {
        self.date = date
        self.events = events
        self.showTeacherName = showTeacherName
        self.onTeacherTap = onTeacherTap
        self.topScrollInset = topScrollInset
        self.bottomScrollInset = bottomScrollInset
        self.dateService = dateService

        // Предвычисляем границы дня ровно один раз.
        let cal = Self.calendar
        let start = cal.startOfDay(for: date)
        self.dayStart = start
        self.nextDayStart = cal.date(byAdding: .day, value: 1, to: start)!
        self.isToday = cal.isDateInToday(date)
    }

    // MARK: - Body

    var body: some View {
        // Фиксируем вычисления на фазу рендера.
        let todaysEvents = filteredAndSortedEvents(dayStart: dayStart, nextDayStart: nextDayStart)

        ScrollView {
            if todaysEvents.isEmpty {
                emptyCentered
            } else {
                eventsList(todaysEvents)
            }
        }
        .scrollContentBackground(.hidden)
        .contentShape(Rectangle())
        .contentMargins(.top, topScrollInset, for: .scrollContent)
        .contentMargins(.bottom, bottomScrollInset, for: .scrollContent)
        .ignoresSafeArea(.container, edges: .top)
        .background(AppColor.background.color(for: .light))
        .id(scrollIdentity(hasEvents: !todaysEvents.isEmpty)) // сбрасывает положение только при смене дня/пустоты
        .onReceive(minuteTickerIfToday) { tick in
            now = tick
        }
    }

    // MARK: - Views

    private func eventsList(_ todaysEvents: [ScheduleEvent]) -> some View {
        // Индекс по заголовку строим один раз и только когда он нужен.
        let titleIndex = Dictionary(grouping: todaysEvents, by: { $0.title })

        return LazyVStack(spacing: Configuration.constants.spacing.value) {
            ForEach(todaysEvents) { event in
                EventCard(
                    event: event,
                    showTeacherName: showTeacherName,
                    onTeacherTap: {
                        if let id = event.teacherId { onTeacherTap?(id) }
                    },
                    onCardTap: {
                        let related = titleIndex[event.title] ?? []
                        subjectSheet = Subject(name: event.title, schedule: related)
                    },
                    now: now
                )
            }
        }
        .padding(Configuration.constants.padding.value)
        .sheet(item: $subjectSheet) { subject in
            SubjectDetailView(subject: subject)
        }
    }

    private var emptyCentered: some View {
        // Центрируем с учётом insets и избегаем полу-пикселей
        let delta = (topScrollInset - bottomScrollInset)
        let scale = UIScreen.main.scale
        let snappedDelta = (delta * scale).rounded() / scale

        return VStack {
            Spacer(minLength: 0)
            EmptyDayView(date: date, dateService: dateService)
                .padding(Configuration.constants.padding.value)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity, alignment: .center)
        .offset(y: snappedDelta)
    }

    // MARK: - Data processing

    /// Отфильтровать по [dayStart, nextDayStart) и отсортировать по startDate.
    /// Все границы переданы параметрами, чтобы исключить повторный доступ к Calendar.
    private func filteredAndSortedEvents(dayStart: Date, nextDayStart: Date) -> [ScheduleEvent] {
        // Один проход + сортировка.
        var result = [ScheduleEvent]()
        result.reserveCapacity(events.count)

        for e in events {
            if let d = e.startDate, d >= dayStart, d < nextDayStart {
                result.append(e)
            }
        }

        result.sort { (a, b) in
            guard let d1 = a.startDate, let d2 = b.startDate else { return false }
            return d1 < d2
        }
        return result
    }

    // MARK: - Helpers

    /// Ключ для сброса позиции скролла зависит только от календарного дня и факта пустоты/наличия событий.
    private func scrollIdentity(hasEvents: Bool) -> String {
        let key = Int(dayStart.timeIntervalSince1970)
        return (hasEvents ? "events-" : "empty-") + String(key)
    }

    /// Таймер тикает раз в минуту только для текущего дня (не создаём никаких паблишеров для прошлых/будущих дат).
    private var minuteTickerIfToday: AnyPublisher<Date, Never> {
        guard isToday else {
            return Empty<Date, Never>(completeImmediately: false).eraseToAnyPublisher()
        }
        return Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
    }
}
