//
//  SubjectStats.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 19/10/2025.
//


import Foundation
import Combine

struct SubjectStats: Sendable {
    let total: Int
    let past: Int
    let upcoming: Int
    let lectures: Int
    let exercises: Int
    let laboratories: Int
    let other: Int
}

@MainActor
final class SubjectDetailViewModel: ObservableObject {
    let subject: Subject
    let dateService: DateService
    private let eventTypeDetector: EventTypeDetector

    // Cached computed properties for performance
    @Published private(set) var stats: SubjectStats
    @Published private(set) var sections: [(date: Date, items: [ScheduleEvent])]

    init(
        subject: Subject,
        dateService: DateService = DefaultDateService.shared,
        eventTypeDetector: EventTypeDetector = DefaultEventTypeDetector()
    ) {
        self.subject = subject
        self.dateService = dateService
        self.eventTypeDetector = eventTypeDetector

        // Initialize cached properties once
        self.stats = Self.computeStats(for: subject, using: eventTypeDetector)
        self.sections = Self.computeSections(for: subject)
    }

    // MARK: - Private Static Helpers

    private static func computeStats(for subject: Subject, using detector: EventTypeDetector) -> SubjectStats {
        let total = subject.schedule.count
        let now = Date()
        let past = subject.schedule.filter { ($0.endDate ?? .distantPast) < now }.count
        let upcoming = total - past

        var lectures = 0, exercises = 0, laboratories = 0, other = 0
        for ev in subject.schedule {
            switch detector.detectEventType(from: ev.type) {
            case .lecture: lectures += 1
            case .exercise: exercises += 1
            case .laboratory: laboratories += 1
            case .other: other += 1
            }
        }

        return SubjectStats(
            total: total, past: past, upcoming: upcoming,
            lectures: lectures, exercises: exercises, laboratories: laboratories, other: other
        )
    }

    private static func computeSections(for subject: Subject) -> [(date: Date, items: [ScheduleEvent])] {
        let grouped = Dictionary(grouping: subject.schedule) { (ev: ScheduleEvent) -> Date in
            (ev.startDate ?? .distantPast).onlyYMD()
        }

        let mapped: [(date: Date, items: [ScheduleEvent])] = grouped.map { (key: Date, value: [ScheduleEvent]) in
            let sortedItems: [ScheduleEvent] = value.sorted(by: { (a: ScheduleEvent, b: ScheduleEvent) in
                (a.startDate ?? .distantPast) < (b.startDate ?? .distantPast)
            })
            return (date: key, items: sortedItems)
        }

        return mapped.sorted(by: { (lhs: (date: Date, items: [ScheduleEvent]), rhs: (date: Date, items: [ScheduleEvent])) in
            lhs.date < rhs.date
        })
    }
}

private extension Date {
    func onlyYMD() -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year,.month,.day], from: self)
        return cal.date(from: comps) ?? self
    }
}
