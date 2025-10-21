//
//  AggregateResponse.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import Foundation

struct AggregateResponse: Equatable, Codable, Sendable {
    let groupId: Int
    let from: String
    let to: String
    let intervalType: Int
    let groupSchedule: [ScheduleEvent]
    let teachers: [Teacher]
    let fetchedAt: String
}
