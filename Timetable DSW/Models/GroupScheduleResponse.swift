//
//  GroupScheduleResponse.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import Foundation

struct GroupScheduleResponse: Equatable, Codable, Sendable {
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case groupId
        case from
        case to
        case intervalType
        case groupSchedule
        case fetchedAt
    }
    
    static func == (lhs: GroupScheduleResponse, rhs: GroupScheduleResponse) -> Bool {
        lhs.groupId == rhs.groupId
    }
    
    let groupId: Int
    let from: String
    let to: String
    let intervalType: Int
    let groupSchedule: [ScheduleEvent]
    let fetchedAt: String

    // Explicit Codable to avoid synthesis issues when dependent types fail to resolve in some targets
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.groupId = try container.decode(Int.self, forKey: .groupId)
        self.from = try container.decode(String.self, forKey: .from)
        self.to = try container.decode(String.self, forKey: .to)
        self.intervalType = try container.decode(Int.self, forKey: .intervalType)
        self.groupSchedule = try container.decode([ScheduleEvent].self, forKey: .groupSchedule)
        self.fetchedAt = try container.decode(String.self, forKey: .fetchedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(groupId, forKey: .groupId)
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(intervalType, forKey: .intervalType)
        try container.encode(groupSchedule, forKey: .groupSchedule)
        try container.encode(fetchedAt, forKey: .fetchedAt)
    }
}
