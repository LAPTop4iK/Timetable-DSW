//
//  Subject.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 19/10/2025.
//


import Foundation

struct Subject: Identifiable, Hashable, Sendable {
    var id: String { normalizedName }
    let name: String
    let normalizedName: String
    let schedule: [ScheduleEvent]

    init(name: String, schedule: [ScheduleEvent]) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.normalizedName = Self.normalize(self.name)
        self.schedule = schedule.sorted { (lhs, rhs) in
            guard let l = lhs.startDate, let r = rhs.startDate else { return false }
            return l < r
        }
    }

    var count: Int { schedule.count }

    private static func normalize(_ s: String) -> String {
        s.lowercased()
         .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}