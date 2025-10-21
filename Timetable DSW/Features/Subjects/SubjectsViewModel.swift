//
//  SubjectsViewModel.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 19/10/2025.
//

import Foundation
import Combine

@MainActor
final class SubjectsViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var allSubjects: [Subject] = []

    // Сборка из агрегата
    func rebuild(from aggregate: AggregateResponse) {
        let grouped = Dictionary(grouping: aggregate.groupSchedule) { (ev: ScheduleEvent) in
            (ev.title ?? "—").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        self.allSubjects = grouped
            .map { Subject(name: $0.key,
                           schedule: $0.value.sorted { ($0.startDate ?? .distantPast) < ($1.startDate ?? .distantPast) }) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    // Отфильтрованный + отсортированный список: сначала по остаткам (меньше — выше), потом по имени
    var filteredSubjects: [Subject] {
        let base: [Subject]
        if searchText.isEmpty {
            base = allSubjects
        } else {
            base = allSubjects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        let now = Date()
        return base.sorted { lhs, rhs in
            let l = upcomingCount(for: lhs, now: now)
            let r = upcomingCount(for: rhs, now: now)
            if l != r { return l < r }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    // Сколько занятий осталось у предмета (включая идущие сейчас)
    func upcomingCount(for subject: Subject, now: Date = Date()) -> Int {
        subject.schedule.reduce(into: 0) { acc, ev in
            if let end = ev.endDate {
                if end >= now { acc += 1 }
            } else if let start = ev.startDate {
                if start >= now { acc += 1 }
            }
        }
    }
}
