//
//  DayEventsView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import SwiftUI
import Combine

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

    // MARK: - Time state
    @State private var now: Date = Date()
    @State private var subjectSheet: Subject? = nil

    // MARK: - Dependencies
    private let dateService: DateService

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
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            content
        }
        .scrollContentBackground(.hidden)
        .contentShape(Rectangle())
        .contentMargins(.top, topScrollInset, for: .scrollContent)
        .contentMargins(.bottom, bottomScrollInset, for: .scrollContent)
        .ignoresSafeArea(.container, edges: .top)
        .background(AppColor.background.color(for: .light))
        .id(scrollIdentity) // сбрасывает состояние скролла при смене дня
        // автообновление раз в минуту, чтобы отметка "прошло" менялась сама
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { tick in
            now = tick
        }
    }

    // MARK: - Content switch
    @ViewBuilder
    private var content: some View {
        if isEmptyDay {
            emptyCentered
        } else {
            eventsList
        }
    }

    // MARK: - Views
    private var eventsList: some View {
        LazyVStack(spacing: Configuration.constants.spacing.value) {
            ForEach(eventsForThisDay) { event in
                EventCard(
                    event: event,
                    showTeacherName: showTeacherName,
                    onTeacherTap: {
                        if let teacherId = event.teacherId {
                            onTeacherTap?(teacherId)
                        }
                    },
                    onCardTap: {
                        // Собираем Subject по названию event'а
                        let title = event.title
                        let related = events.filter { $0.title == title }
                        subjectSheet = Subject(name: title, schedule: related)
                    },
                    now: now,
                    // ← передаём текущее время в карточку
                )
            }
        }
        .padding(Configuration.constants.padding.value)
        .sheet(item: $subjectSheet) { subject in
            SubjectDetailView(subject: subject)
        }
    }

    private var emptyCentered: some View {
        // центр свободной области ниже центра экрана на (top - bottom)/2
        let delta = (topScrollInset - bottomScrollInset)

        // чтобы избежать полу-пикселей
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
        .offset(y: snappedDelta) // ← сдвиг к центру свободной области
    }

    // MARK: - Helpers
    private var isEmptyDay: Bool {
        eventsForThisDay.isEmpty
    }

    private var scrollIdentity: String {
        let key = Calendar.current.startOfDay(for: date).timeIntervalSince1970
        return (isEmptyDay ? "empty-" : "events-") + String(Int(key))
    }

    // MARK: - Filtering & Sorting
    private var eventsForThisDay: [ScheduleEvent] {
        events
            .filter { event in
                guard let d = event.startDate else { return false }
                return Calendar.current.isDate(d, inSameDayAs: date)
            }
            .sorted { a, b in
                guard let d1 = a.startDate, let d2 = b.startDate else { return false }
                return d1 < d2
            }
    }
}
