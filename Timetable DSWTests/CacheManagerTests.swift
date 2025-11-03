//
//  CacheManagerTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import XCTest
@testable import Timetable_DSW

final class CacheManagerTests: XCTestCase {

    var sut: CacheManager!

    override func setUp() async throws {
        try await super.setUp()
        sut = CacheManager()
    }

    override func tearDown() async throws {
        // Clean up all test data
        let testKeys = ["test_key", "test_event", "test_group", "test_teachers"]
        for key in testKeys {
            try? await sut.remove(forKey: key)
        }
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Save and Load Tests

    func testSaveAndLoadString() async throws {
        // Given
        let key = "test_key"
        let value = "Test Value"

        // When
        try await sut.save(value, forKey: key)
        let loaded: String = try await sut.load(forKey: key)

        // Then
        XCTAssertEqual(loaded, value)
    }

    func testSaveAndLoadScheduleEvent() async throws {
        // Given
        let key = "test_event"
        let json = """
        {
            "title": "Software Engineering",
            "type": "wyk",
            "startISO": "2025-11-03T10:00:00.000Z",
            "endISO": "2025-11-03T11:30:00.000Z",
            "room": "201"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let event = try decoder.decode(ScheduleEvent.self, from: json)

        // When
        try await sut.save(event, forKey: key)
        let loaded: ScheduleEvent = try await sut.load(forKey: key)

        // Then
        XCTAssertEqual(loaded.title, event.title)
        XCTAssertEqual(loaded.type, event.type)
        XCTAssertEqual(loaded.startISO, event.startISO)
        XCTAssertEqual(loaded.endISO, event.endISO)
        XCTAssertEqual(loaded.room, event.room)
    }

    func testSaveAndLoadGroupInfo() async throws {
        // Given
        let key = "test_group"
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
        try await sut.save(group, forKey: key)
        let loaded: GroupInfo = try await sut.load(forKey: key)

        // Then
        XCTAssertEqual(loaded.groupId, group.groupId)
        XCTAssertEqual(loaded.code, group.code)
        XCTAssertEqual(loaded.name, group.name)
    }

    func testSaveAndLoadArray() async throws {
        // Given
        let key = "test_teachers"
        let teachers = [
            createTestTeacher(id: 1, name: "Dr. Smith"),
            createTestTeacher(id: 2, name: "Dr. Jones")
        ]

        // When
        try await sut.save(teachers, forKey: key)
        let loaded: [Teacher] = try await sut.load(forKey: key)

        // Then
        XCTAssertEqual(loaded.count, teachers.count)
        XCTAssertEqual(loaded[0].id, teachers[0].id)
        XCTAssertEqual(loaded[0].name, teachers[0].name)
        XCTAssertEqual(loaded[1].id, teachers[1].id)
        XCTAssertEqual(loaded[1].name, teachers[1].name)
    }

    // MARK: - Exists Tests

    func testExists_WhenFileExists() async throws {
        // Given
        let key = "test_key"
        let value = "Test Value"
        try await sut.save(value, forKey: key)

        // When
        let exists = await sut.exists(forKey: key)

        // Then
        XCTAssertTrue(exists)
    }

    func testExists_WhenFileDoesNotExist() async {
        // Given
        let key = "non_existent_key"

        // When
        let exists = await sut.exists(forKey: key)

        // Then
        XCTAssertFalse(exists)
    }

    // MARK: - Remove Tests

    func testRemove_ExistingFile() async throws {
        // Given
        let key = "test_key"
        let value = "Test Value"
        try await sut.save(value, forKey: key)
        XCTAssertTrue(await sut.exists(forKey: key))

        // When
        try await sut.remove(forKey: key)

        // Then
        XCTAssertFalse(await sut.exists(forKey: key))
    }

    func testRemove_NonExistingFile() async throws {
        // Given
        let key = "non_existent_key"

        // When & Then - не должно бросать исключение
        try await sut.remove(forKey: key)
    }

    // MARK: - Error Tests

    func testLoad_ThrowsErrorWhenFileDoesNotExist() async {
        // Given
        let key = "non_existent_key"

        // When & Then
        do {
            let _: String = try await sut.load(forKey: key)
            XCTFail("Should throw error when file does not exist")
        } catch {
            // Expected error
        }
    }

    func testLoad_ThrowsErrorWhenDecodingFails() async throws {
        // Given
        let key = "test_key"
        let invalidJSON = "not a valid json for ScheduleEvent"
        try await sut.save(invalidJSON, forKey: key)

        // When & Then
        do {
            let _: ScheduleEvent = try await sut.load(forKey: key)
            XCTFail("Should throw error when decoding fails")
        } catch {
            // Expected error
        }
    }

    // MARK: - Overwrite Tests

    func testSave_OverwritesExistingFile() async throws {
        // Given
        let key = "test_key"
        let value1 = "First Value"
        let value2 = "Second Value"

        // When
        try await sut.save(value1, forKey: key)
        let loaded1: String = try await sut.load(forKey: key)

        try await sut.save(value2, forKey: key)
        let loaded2: String = try await sut.load(forKey: key)

        // Then
        XCTAssertEqual(loaded1, value1)
        XCTAssertEqual(loaded2, value2)
        XCTAssertNotEqual(loaded1, loaded2)
    }

    // MARK: - Concurrency Tests

    func testConcurrentSaves() async throws {
        // Given
        let keys = (0..<10).map { "test_key_\($0)" }

        // When - параллельные сохранения
        await withTaskGroup(of: Void.self) { group in
            for (index, key) in keys.enumerated() {
                group.addTask {
                    try? await self.sut.save("Value \(index)", forKey: key)
                }
            }
        }

        // Then - все должны быть сохранены
        for (index, key) in keys.enumerated() {
            let loaded: String = try await sut.load(forKey: key)
            XCTAssertEqual(loaded, "Value \(index)")
        }

        // Cleanup
        for key in keys {
            try? await sut.remove(forKey: key)
        }
    }

    func testConcurrentReadsAndWrites() async throws {
        // Given
        let key = "test_key"
        try await sut.save("Initial Value", forKey: key)

        // When - параллельные чтения и записи
        async let read1: String = sut.load(forKey: key)
        async let write1: Void = sut.save("Updated Value", forKey: key)
        async let read2: String = sut.load(forKey: key)

        // Then - не должно быть крэшей
        let _ = try await read1
        let _ = try await write1
        let _ = try await read2
    }

    // MARK: - Helper Methods

    private func createTestTeacher(id: Int, name: String) -> Teacher {
        let json = """
        {
            "id": \(id),
            "name": "\(name)",
            "schedule": []
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        return try! decoder.decode(Teacher.self, from: json)
    }
}
