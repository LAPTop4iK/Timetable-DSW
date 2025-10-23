//
//  GroupScheduleResponse.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import Foundation

struct GroupScheduleResponse: Equatable, Codable, Sendable {
    let groupId: Int
    let from: String
    let to: String
    let intervalType: Int
    let groupSchedule: [ScheduleEvent]
    let fetchedAt: String
}
