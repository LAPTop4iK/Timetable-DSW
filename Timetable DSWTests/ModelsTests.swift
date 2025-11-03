//
//  ModelsTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import XCTest
@testable import Timetable_DSW

final class ModelsTests: XCTestCase {

    // MARK: - ScheduleEvent Tests

    func testScheduleEvent_Codable() throws {
        // Given
        let json = """
        {
            "title": "Software Engineering",
            "type": "wyk",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z",
            "room": "201",
            "grading": "exam",
            "remarks": "Bring your laptop",
            "studyTrack": "Computer Science",
            "groups": "Group A",
            "teacherId": 123,
            "teacherName": "Dr. Smith",
            "teacherEmail": "smith@example.com"
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // Then
        XCTAssertEqual(event.title, "Software Engineering")
        XCTAssertEqual(event.type, "wyk")
        XCTAssertEqual(event.startISO, "2025-11-03T10:00:00.000Z")
        XCTAssertEqual(event.endISO, "2025-11-03T11:30:00.000Z")
        XCTAssertEqual(event.room, "201")
        XCTAssertEqual(event.grading, "exam")
        XCTAssertEqual(event.remarks, "Bring your laptop")
        XCTAssertEqual(event.studyTrack, "Computer Science")
        XCTAssertEqual(event.groups, "Group A")
        XCTAssertEqual(event.teacherId, 123)
        XCTAssertEqual(event.teacherName, "Dr. Smith")
        XCTAssertEqual(event.teacherEmail, "smith@example.com")
    }

    func testScheduleEvent_CodableWithOptionalFields() throws {
        // Given
        let json = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z"
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // Then
        XCTAssertEqual(event.title, "Software Engineering")
        XCTAssertNil(event.type)
        XCTAssertNil(event.room)
        XCTAssertNil(event.grading)
        XCTAssertNil(event.remarks)
        XCTAssertNil(event.studyTrack)
        XCTAssertNil(event.groups)
        XCTAssertNil(event.teacherId)
        XCTAssertNil(event.teacherName)
        XCTAssertNil(event.teacherEmail)
    }

    func testScheduleEvent_EncodeDecode() throws {
        // Given
        let json = """
        {
            "title": "Software Engineering",
            "type": "wyk",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z",
            "room": "201",
            "teacherId": 123
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let originalEvent = try decoder.decode(ScheduleEvent.self, from: json)

        // When
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalEvent)
        let decodedEvent = try decoder.decode(ScheduleEvent.self, from: encodedData)

        // Then
        XCTAssertEqual(originalEvent.title, decodedEvent.title)
        XCTAssertEqual(originalEvent.type, decodedEvent.type)
        XCTAssertEqual(originalEvent.startISO, decodedEvent.startISO)
        XCTAssertEqual(originalEvent.endISO, decodedEvent.endISO)
        XCTAssertEqual(originalEvent.room, decodedEvent.room)
        XCTAssertEqual(originalEvent.teacherId, decodedEvent.teacherId)
    }

    func testScheduleEvent_ID() throws {
        // Given
        let json = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z",
            "teacherId": 123
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // When
        let id = event.id

        // Then
        XCTAssertEqual(id, "2025-11-03T10:00:00.000Z_Software Engineering_123")
    }

    func testScheduleEvent_IDWithNilTeacher() throws {
        // Given
        let json = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // When
        let id = event.id

        // Then
        XCTAssertEqual(id, "2025-11-03T10:00:00.000Z_Software Engineering_0")
    }

    func testScheduleEvent_DisplayRoom() throws {
        // Given
        let jsonWithRoom = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z",
            "room": "201"
        }
        """.data(using: .utf8)!

        let jsonWithoutRoom = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        // When
        let eventWithRoom = try decoder.decode(ScheduleEvent.self, from: jsonWithRoom)
        let eventWithoutRoom = try decoder.decode(ScheduleEvent.self, from: jsonWithoutRoom)

        // Then
        XCTAssertEqual(eventWithRoom.displayRoom, "201")
        XCTAssertEqual(eventWithoutRoom.displayRoom, "")
    }

    func testScheduleEvent_DateParsing() throws {
        // Given
        let json = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        // When
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // Then
        XCTAssertNotNil(event.startDate, "startDate should be parsed")
        XCTAssertNotNil(event.endDate, "endDate should be parsed")
    }

    func testScheduleEvent_Hashable() throws {
        // Given
        let json = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z",
            "teacherId": 123
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let event1 = try decoder.decode(ScheduleEvent.self, from: json)
        let event2 = try decoder.decode(ScheduleEvent.self, from: json)

        // When
        let set = Set([event1, event2])

        // Then
        XCTAssertEqual(set.count, 1, "Identical events should be treated as same in Set")
    }

    // MARK: - GroupInfo Tests

    func testGroupInfo_Codable() throws {
        // Given
        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let group = try decoder.decode(GroupInfo.self, from: json)

        // Then
        XCTAssertEqual(group.groupId, 1)
        XCTAssertEqual(group.code, "CS101")
        XCTAssertEqual(group.name, "Computer Science")
        XCTAssertEqual(group.program, "Bachelor")
        XCTAssertEqual(group.faculty, "Engineering")
    }

    func testGroupInfo_DisplayName() throws {
        // Given
        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let group = try decoder.decode(GroupInfo.self, from: json)

        // When
        let displayName = group.displayName

        // Then
        XCTAssertEqual(displayName, "CS101 - Computer Science")
    }

    func testGroupInfo_ID() throws {
        // Given
        let json = """
        {
            "groupId": 123,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let group = try decoder.decode(GroupInfo.self, from: json)

        // When
        let id = group.id

        // Then
        XCTAssertEqual(id, 123)
    }

    func testGroupInfo_EncodeDecode() throws {
        // Given
        let json = """
        {
            "groupId": 1,
            "code": "CS101",
            "name": "Computer Science",
            "tracks": [],
            "program": "Bachelor",
            "faculty": "Engineering"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let originalGroup = try decoder.decode(GroupInfo.self, from: json)

        // When
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalGroup)
        let decodedGroup = try decoder.decode(GroupInfo.self, from: encodedData)

        // Then
        XCTAssertEqual(originalGroup.groupId, decodedGroup.groupId)
        XCTAssertEqual(originalGroup.code, decodedGroup.code)
        XCTAssertEqual(originalGroup.name, decodedGroup.name)
        XCTAssertEqual(originalGroup.program, decodedGroup.program)
        XCTAssertEqual(originalGroup.faculty, decodedGroup.faculty)
    }

    // MARK: - Teacher Tests

    func testTeacher_Codable() throws {
        // Given
        let json = """
        {
            "id": 1,
            "name": "Dr. Smith",
            "title": "Professor",
            "department": "Computer Science",
            "email": "smith@example.com",
            "phone": "+1234567890",
            "aboutHTML": "<p>Bio</p>",
            "schedule": []
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let teacher = try decoder.decode(Teacher.self, from: json)

        // Then
        XCTAssertEqual(teacher.id, 1)
        XCTAssertEqual(teacher.name, "Dr. Smith")
        XCTAssertEqual(teacher.title, "Professor")
        XCTAssertEqual(teacher.department, "Computer Science")
        XCTAssertEqual(teacher.email, "smith@example.com")
        XCTAssertEqual(teacher.phone, "+1234567890")
        XCTAssertEqual(teacher.aboutHTML, "<p>Bio</p>")
    }

    func testTeacher_CodableWithOptionalFields() throws {
        // Given
        let json = """
        {
            "id": 1,
            "schedule": []
        }
        """.data(using: .utf8)!

        // When
        let decoder = JSONDecoder()
        let teacher = try decoder.decode(Teacher.self, from: json)

        // Then
        XCTAssertEqual(teacher.id, 1)
        XCTAssertNil(teacher.name)
        XCTAssertNil(teacher.title)
        XCTAssertNil(teacher.department)
        XCTAssertNil(teacher.email)
        XCTAssertNil(teacher.phone)
        XCTAssertNil(teacher.aboutHTML)
    }

    func testTeacher_DisplayName() throws {
        // Given
        let jsonWithName = """
        {
            "id": 1,
            "name": "Dr. Smith",
            "schedule": []
        }
        """.data(using: .utf8)!

        let jsonWithoutName = """
        {
            "id": 1,
            "schedule": []
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        // When
        let teacherWithName = try decoder.decode(Teacher.self, from: jsonWithName)
        let teacherWithoutName = try decoder.decode(Teacher.self, from: jsonWithoutName)

        // Then
        XCTAssertEqual(teacherWithName.displayName, "Dr. Smith")
        XCTAssertEqual(teacherWithoutName.displayName, "Unknown Teacher")
    }

    func testTeacher_EncodeDecode() throws {
        // Given
        let json = """
        {
            "id": 1,
            "name": "Dr. Smith",
            "email": "smith@example.com",
            "schedule": []
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let originalTeacher = try decoder.decode(Teacher.self, from: json)

        // When
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalTeacher)
        let decodedTeacher = try decoder.decode(Teacher.self, from: encodedData)

        // Then
        XCTAssertEqual(originalTeacher.id, decodedTeacher.id)
        XCTAssertEqual(originalTeacher.name, decodedTeacher.name)
        XCTAssertEqual(originalTeacher.email, decodedTeacher.email)
    }
}
