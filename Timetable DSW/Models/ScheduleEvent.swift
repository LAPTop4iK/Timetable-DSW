//
//  ScheduleEvent.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

struct ScheduleEvent: Identifiable, Hashable, Sendable {
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

    // Даты парсятся один раз при декодировании вместо каждого обращения
    let startDate: Date?
    let endDate: Date?

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
}

// MARK: - Codable

extension ScheduleEvent: Codable {
    enum CodingKeys: String, CodingKey {
        case title, type, startISO, endISO, room, grading, remarks, studyTrack, groups
        case teacherId, teacherName, teacherEmail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        startISO = try container.decode(String.self, forKey: .startISO)
        endISO = try container.decode(String.self, forKey: .endISO)
        room = try container.decodeIfPresent(String.self, forKey: .room)
        grading = try container.decodeIfPresent(String.self, forKey: .grading)
        remarks = try container.decodeIfPresent(String.self, forKey: .remarks)
        studyTrack = try container.decodeIfPresent(String.self, forKey: .studyTrack)
        groups = try container.decodeIfPresent(String.self, forKey: .groups)
        teacherId = try container.decodeIfPresent(Int.self, forKey: .teacherId)
        teacherName = try container.decodeIfPresent(String.self, forKey: .teacherName)
        teacherEmail = try container.decodeIfPresent(String.self, forKey: .teacherEmail)

        // Парсим даты один раз при декодировании
        startDate = ScheduleEvent.dateService.parseISO8601(startISO)
        endDate = ScheduleEvent.dateService.parseISO8601(endISO)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encode(startISO, forKey: .startISO)
        try container.encode(endISO, forKey: .endISO)
        try container.encodeIfPresent(room, forKey: .room)
        try container.encodeIfPresent(grading, forKey: .grading)
        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(studyTrack, forKey: .studyTrack)
        try container.encodeIfPresent(groups, forKey: .groups)
        try container.encodeIfPresent(teacherId, forKey: .teacherId)
        try container.encodeIfPresent(teacherName, forKey: .teacherName)
        try container.encodeIfPresent(teacherEmail, forKey: .teacherEmail)
        // startDate и endDate не кодируются - они вычисляются из ISO строк
    }
}

extension ScheduleEvent {
    func presentationInfo(detector: EventTypeDetector = DefaultEventTypeDetector()) -> EventPresentationInfo {
        EventPresentationInfo(event: self, detector: detector)
    }

    func isOnline(detector: EventTypeDetector = DefaultEventTypeDetector()) -> Bool {
        presentationInfo(detector: detector).isOnline
    }

    func isCancelled(detector: EventTypeDetector = DefaultEventTypeDetector()) -> Bool {
        presentationInfo(detector: detector).isCancelled
    }

    func eventType(detector: EventTypeDetector = DefaultEventTypeDetector()) -> EventType {
        presentationInfo(detector: detector).kind
    }
}
