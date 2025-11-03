//
//  ModelsTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Testing
@testable import Timetable_DSW
import Foundation

// MARK: - Schedule Event Tests

@Suite("ScheduleEvent Tests")
struct ScheduleEventTests {

    @Test("Decode ScheduleEvent with all fields")
    func decodingWithAllFields() throws {
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
        #expect(event.title == "Software Engineering")
        #expect(event.type == "wyk")
        #expect(event.startISO == "2025-11-03T10:00:00.000Z")
        #expect(event.endISO == "2025-11-03T11:30:00.000Z")
        #expect(event.room == "201")
        #expect(event.grading == "exam")
        #expect(event.remarks == "Bring your laptop")
        #expect(event.studyTrack == "Computer Science")
        #expect(event.groups == "Group A")
        #expect(event.teacherId == 123)
        #expect(event.teacherName == "Dr. Smith")
        #expect(event.teacherEmail == "smith@example.com")
    }

    @Test("Decode ScheduleEvent with only required fields")
    func decodingWithOptionalFields() throws {
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
        #expect(event.title == "Software Engineering")
        #expect(event.type == nil)
        #expect(event.room == nil)
        #expect(event.grading == nil)
        #expect(event.remarks == nil)
        #expect(event.studyTrack == nil)
        #expect(event.groups == nil)
        #expect(event.teacherId == nil)
        #expect(event.teacherName == nil)
        #expect(event.teacherEmail == nil)
    }

    @Test("Encode and decode ScheduleEvent maintains data integrity")
    func encodingAndDecoding() throws {
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
        #expect(originalEvent.title == decodedEvent.title)
        #expect(originalEvent.type == decodedEvent.type)
        #expect(originalEvent.startISO == decodedEvent.startISO)
        #expect(originalEvent.endISO == decodedEvent.endISO)
        #expect(originalEvent.room == decodedEvent.room)
        #expect(originalEvent.teacherId == decodedEvent.teacherId)
    }

    @Test("ScheduleEvent ID generation", arguments: [
        (123, "2025-11-03T10:00:00.000Z_Software Engineering_123"),
        (nil, "2025-11-03T10:00:00.000Z_Software Engineering_0")
    ])
    func eventIDGeneration(teacherId: Int?, expectedID: String) throws {
        // Given
        let teacherIdString = teacherId.map { String($0) } ?? ""
        let teacherJSON = teacherId != nil ? ",\"teacherId\": \(teacherId!)" : ""
        let json = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z"\(teacherJSON)
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // When
        let id = event.id

        // Then
        #expect(id == expectedID)
    }

    @Test("ScheduleEvent displayRoom", arguments: [
        ("201", "201"),
        (nil, "")
    ])
    func displayRoom(room: String?, expectedDisplay: String) throws {
        // Given
        let roomJSON = room.map { ",\"room\": \"\($0)\"" } ?? ""
        let json = """
        {
            "title": "Software Engineering",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z"\(roomJSON)
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // When
        let display = event.displayRoom

        // Then
        #expect(display == expectedDisplay)
    }

    @Test("ScheduleEvent parses dates correctly")
    func dateParsing() throws {
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
        #expect(event.startDate != nil)
        #expect(event.endDate != nil)
    }

    @Test("ScheduleEvent is Hashable")
    func hashableConformance() throws {
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
        #expect(set.count == 1)
    }
}

// MARK: - GroupInfo Tests

@Suite("GroupInfo Tests")
struct GroupInfoTests {

    @Test("Decode GroupInfo with all fields")
    func decodingWithAllFields() throws {
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
        #expect(group.groupId == 1)
        #expect(group.code == "CS101")
        #expect(group.name == "Computer Science")
        #expect(group.program == "Bachelor")
        #expect(group.faculty == "Engineering")
    }

    @Test("GroupInfo displayName format")
    func displayName() throws {
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
        #expect(displayName == "CS101 - Computer Science")
    }

    @Test("GroupInfo id matches groupId")
    func idProperty() throws {
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
        #expect(id == 123)
    }

    @Test("Encode and decode GroupInfo maintains data integrity")
    func encodingAndDecoding() throws {
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
        #expect(originalGroup.groupId == decodedGroup.groupId)
        #expect(originalGroup.code == decodedGroup.code)
        #expect(originalGroup.name == decodedGroup.name)
        #expect(originalGroup.program == decodedGroup.program)
        #expect(originalGroup.faculty == decodedGroup.faculty)
    }
}

// MARK: - Teacher Tests

@Suite("Teacher Tests")
struct TeacherTests {

    @Test("Decode Teacher with all fields")
    func decodingWithAllFields() throws {
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
        #expect(teacher.id == 1)
        #expect(teacher.name == "Dr. Smith")
        #expect(teacher.title == "Professor")
        #expect(teacher.department == "Computer Science")
        #expect(teacher.email == "smith@example.com")
        #expect(teacher.phone == "+1234567890")
        #expect(teacher.aboutHTML == "<p>Bio</p>")
    }

    @Test("Decode Teacher with only required fields")
    func decodingWithOptionalFields() throws {
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
        #expect(teacher.id == 1)
        #expect(teacher.name == nil)
        #expect(teacher.title == nil)
        #expect(teacher.department == nil)
        #expect(teacher.email == nil)
        #expect(teacher.phone == nil)
        #expect(teacher.aboutHTML == nil)
    }

    @Test("Teacher displayName", arguments: [
        ("Dr. Smith", "Dr. Smith"),
        (nil, "Unknown Teacher")
    ])
    func displayName(name: String?, expectedDisplay: String) throws {
        // Given
        let nameJSON = name.map { ",\"name\": \"\($0)\"" } ?? ""
        let json = """
        {
            "id": 1,
            "schedule": []\(nameJSON)
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let teacher = try decoder.decode(Teacher.self, from: json)

        // When
        let displayName = teacher.displayName

        // Then
        #expect(displayName == expectedDisplay)
    }

    @Test("Encode and decode Teacher maintains data integrity")
    func encodingAndDecoding() throws {
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
        #expect(originalTeacher.id == decodedTeacher.id)
        #expect(originalTeacher.name == decodedTeacher.name)
        #expect(originalTeacher.email == decodedTeacher.email)
    }
}
