//
//  ScheduleEvent.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

struct ScheduleEvent: Identifiable, Codable, Hashable, Sendable {
    let title: String
    let type: String?
    let startISO: String
    let endISO: String
    let room: String?
    let grading: String?
    let remarks: String?
    let studyTrack: String?
    let groups: String?
    let teacherId: Int?
    let teacherName: String?
    let teacherEmail: String?

    private static let dateService = DefaultDateService.shared

    var id: String {
        "\(startISO)_\(title)_\(teacherId ?? 0)"
    }

    var displayRoom: String {
//        guard let room = room, !room.isEmpty, room != "Brak" else {
//            return "online"
//        }
        return room ?? ""
    }

    var startDate: Date? {
        ScheduleEvent.dateService.parseISO8601(startISO)
    }

    var endDate: Date? {
        ScheduleEvent.dateService.parseISO8601(endISO)
    }
}
