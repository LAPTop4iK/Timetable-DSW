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
    let currentPeriodTeachers: [Teacher]?
    let fetchedAt: String

    init(groupId: Int, from: String, to: String, intervalType: Int, groupSchedule: [ScheduleEvent], teachers: [Teacher], currentPeriodTeachers: [Teacher]? = nil, fetchedAt: String) {
        self.groupId = groupId
        self.from = from
        self.to = to
        self.intervalType = intervalType
        self.groupSchedule = groupSchedule
        self.teachers = teachers
        self.currentPeriodTeachers = currentPeriodTeachers
        self.fetchedAt = fetchedAt
    }

    init(from groupSchedule: GroupScheduleResponse, teachers: [Teacher] = [], currentPeriodTeachers: [Teacher]? = nil) {
        self.groupId = groupSchedule.groupId
        self.from = groupSchedule.from
        self.to = groupSchedule.to
        self.intervalType = groupSchedule.intervalType
        self.groupSchedule = groupSchedule.groupSchedule
        self.teachers = teachers
        self.currentPeriodTeachers = currentPeriodTeachers
        self.fetchedAt = groupSchedule.fetchedAt
    }
}
