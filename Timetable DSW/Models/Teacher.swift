//
//  Teacher.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import Foundation

struct Teacher: Identifiable, Codable, Hashable, Sendable {
    let id: Int
    let name: String?
    let title: String?
    let department: String?
    let email: String?
    let phone: String?
    let aboutHTML: String?
    let schedule: [ScheduleEvent]

    var displayName: String {
        name ?? "Unknown Teacher"
    }
}
