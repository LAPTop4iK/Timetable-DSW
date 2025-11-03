//
//  TestDataFactory.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

// MARK: - Test Data Factory

/// Factory for creating test data with sensible defaults
/// Follows the Builder pattern for flexibility
enum TestDataFactory {

    // MARK: - ScheduleEvent Factory

    struct ScheduleEventBuilder {
        private var title: String = "Test Event"
        private var type: String? = "wyk"
        private var startISO: String = .makeISO8601(year: 2025, month: 11, day: 3, hour: 10, minute: 0, second: 0)
        private var endISO: String = .makeISO8601(year: 2025, month: 11, day: 3, hour: 11, minute: 30, second: 0)
        private var room: String? = "201"
        private var grading: String? = nil
        private var remarks: String? = nil
        private var studyTrack: String? = nil
        private var groups: String? = nil
        private var teacherId: Int? = 1
        private var teacherName: String? = "Dr. Test"
        private var teacherEmail: String? = "test@example.com"

        func with(title: String) -> Self {
            var copy = self
            copy.title = title
            return copy
        }

        func with(type: String?) -> Self {
            var copy = self
            copy.type = type
            return copy
        }

        func with(startISO: String) -> Self {
            var copy = self
            copy.startISO = startISO
            return copy
        }

        func with(endISO: String) -> Self {
            var copy = self
            copy.endISO = endISO
            return copy
        }

        func with(room: String?) -> Self {
            var copy = self
            copy.room = room
            return copy
        }

        func with(remarks: String?) -> Self {
            var copy = self
            copy.remarks = remarks
            return copy
        }

        func with(teacherId: Int?) -> Self {
            var copy = self
            copy.teacherId = teacherId
            return copy
        }

        func with(teacherName: String?) -> Self {
            var copy = self
            copy.teacherName = teacherName
            return copy
        }

        func online() -> Self {
            with(remarks: "Online meeting via Teams")
        }

        func cancelled() -> Self {
            with(remarks: "zajęcia odwołane")
        }

        func asLecture() -> Self {
            with(type: "wykład")
        }

        func asExercise() -> Self {
            with(type: "ćwiczenia")
        }

        func asLaboratory() -> Self {
            with(type: "laboratorium")
        }

        func build() throws -> ScheduleEvent {
            let json = """
            {
                "title": "\(title)",
                "type": \(type.map { "\"\($0)\"" } ?? "null"),
                "startISO": "\(startISO)",
                "endISO": "\(endISO)",
                "room": \(room.map { "\"\($0)\"" } ?? "null"),
                "grading": \(grading.map { "\"\($0)\"" } ?? "null"),
                "remarks": \(remarks.map { "\"\($0)\"" } ?? "null"),
                "studyTrack": \(studyTrack.map { "\"\($0)\"" } ?? "null"),
                "groups": \(groups.map { "\"\($0)\"" } ?? "null"),
                "teacherId": \(teacherId.map { "\($0)" } ?? "null"),
                "teacherName": \(teacherName.map { "\"\($0)\"" } ?? "null"),
                "teacherEmail": \(teacherEmail.map { "\"\($0)\"" } ?? "null")
            }
            """
            return try JSONTestHelper.decode(ScheduleEvent.self, from: json)
        }
    }

    static func scheduleEvent() -> ScheduleEventBuilder {
        ScheduleEventBuilder()
    }

    // MARK: - GroupInfo Factory

    struct GroupInfoBuilder {
        private var groupId: Int = 1
        private var code: String = "CS101"
        private var name: String = "Computer Science"
        private var tracks: [TrackInfo] = []
        private var program: String = "Bachelor"
        private var faculty: String = "Engineering"

        func with(groupId: Int) -> Self {
            var copy = self
            copy.groupId = groupId
            return copy
        }

        func with(code: String) -> Self {
            var copy = self
            copy.code = code
            return copy
        }

        func with(name: String) -> Self {
            var copy = self
            copy.name = name
            return copy
        }

        func with(program: String) -> Self {
            var copy = self
            copy.program = program
            return copy
        }

        func build() throws -> GroupInfo {
            let json = """
            {
                "groupId": \(groupId),
                "code": "\(code)",
                "name": "\(name)",
                "tracks": [],
                "program": "\(program)",
                "faculty": "\(faculty)"
            }
            """
            return try JSONTestHelper.decode(GroupInfo.self, from: json)
        }
    }

    static func groupInfo() -> GroupInfoBuilder {
        GroupInfoBuilder()
    }

    // MARK: - Teacher Factory

    struct TeacherBuilder {
        private var id: Int = 1
        private var name: String? = "Dr. Smith"
        private var title: String? = "Professor"
        private var department: String? = "Computer Science"
        private var email: String? = "smith@example.com"
        private var phone: String? = nil
        private var aboutHTML: String? = nil
        private var schedule: [ScheduleEvent] = []

        func with(id: Int) -> Self {
            var copy = self
            copy.id = id
            return copy
        }

        func with(name: String?) -> Self {
            var copy = self
            copy.name = name
            return copy
        }

        func with(email: String?) -> Self {
            var copy = self
            copy.email = email
            return copy
        }

        func with(schedule: [ScheduleEvent]) -> Self {
            var copy = self
            copy.schedule = schedule
            return copy
        }

        func build() throws -> Teacher {
            // Note: Schedule needs to be encoded separately
            let scheduleJSON = try schedule.map { try JSONEncoder().encode($0) }
            let scheduleStrings = try scheduleJSON.map { data in
                String(data: data, encoding: .utf8)!
            }

            let json = """
            {
                "id": \(id),
                "name": \(name.map { "\"\($0)\"" } ?? "null"),
                "title": \(title.map { "\"\($0)\"" } ?? "null"),
                "department": \(department.map { "\"\($0)\"" } ?? "null"),
                "email": \(email.map { "\"\($0)\"" } ?? "null"),
                "phone": \(phone.map { "\"\($0)\"" } ?? "null"),
                "aboutHTML": \(aboutHTML.map { "\"\($0)\"" } ?? "null"),
                "schedule": [\(scheduleStrings.joined(separator: ","))]
            }
            """
            return try JSONTestHelper.decode(Teacher.self, from: json)
        }
    }

    static func teacher() -> TeacherBuilder {
        TeacherBuilder()
    }

    // MARK: - AggregateResponse Factory

    static func aggregateResponse(
        groupSchedule: [ScheduleEvent] = [],
        teachers: [Teacher] = []
    ) throws -> AggregateResponse {
        let json = """
        {
            "groupSchedule": [\(try groupSchedule.map { try JSONEncoder().encode($0) }.map { String(data: $0, encoding: .utf8)! }.joined(separator: ","))],
            "teachers": [\(try teachers.map { try JSONEncoder().encode($0) }.map { String(data: $0, encoding: .utf8)! }.joined(separator: ","))]
        }
        """
        return try JSONTestHelper.decode(AggregateResponse.self, from: json)
    }
}

// MARK: - Convenience Methods

extension TestDataFactory {

    /// Create a sample week of schedule events
    static func sampleWeekSchedule() throws -> [ScheduleEvent] {
        let baseDate = Date.make(year: 2025, month: 11, day: 3)

        return try (0..<5).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: baseDate)!
            let startISO = String.makeISO8601(
                year: 2025,
                month: 11,
                day: 3 + dayOffset,
                hour: 10,
                minute: 0,
                second: 0
            )
            let endISO = String.makeISO8601(
                year: 2025,
                month: 11,
                day: 3 + dayOffset,
                hour: 11,
                minute: 30,
                second: 0
            )

            return try scheduleEvent()
                .with(title: "Day \(dayOffset + 1) Event")
                .with(startISO: startISO)
                .with(endISO: endISO)
                .build()
        }
    }

    /// Create mixed online/offline events
    static func mixedOnlineOfflineEvents() throws -> [ScheduleEvent] {
        [
            try scheduleEvent().with(title: "Online Lecture").online().build(),
            try scheduleEvent().with(title: "Offline Lab").with(room: "101").build(),
            try scheduleEvent().with(title: "Cancelled Class").cancelled().build(),
        ]
    }
}
