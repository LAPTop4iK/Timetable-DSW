//
//  CacheManagerTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Testing
@testable import Timetable_DSW

@Suite("CacheManager Tests")
struct CacheManagerTests {

    let sut: CacheManager

    init() async {
        self.sut = CacheManager()
    }

    // MARK: - Save and Load Tests

    @Test("Save and load String")
    func saveAndLoadString() async throws {
        // Given
        let key = "test_key_\(UUID().uuidString)"
        let value = "Test Value"

        // When
        try await sut.save(value, forKey: key)
        let loaded: String = try await sut.load(forKey: key)

        // Then
        #expect(loaded == value)

        // Cleanup
        try? await sut.remove(forKey: key)
    }

    @Test("Save and load ScheduleEvent")
    func saveAndLoadScheduleEvent() async throws {
        // Given
        let key = "test_event_\(UUID().uuidString)"
        let event = try TestDataFactory.scheduleEvent()
            .with(title: "Software Engineering")
            .with(room: "201")
            .build()

        // When
        try await sut.save(event, forKey: key)
        let loaded: ScheduleEvent = try await sut.load(forKey: key)

        // Then
        #expect(loaded.title == event.title)
        #expect(loaded.room == event.room)

        // Cleanup
        try? await sut.remove(forKey: key)
    }

    @Test("Save and load GroupInfo")
    func saveAndLoadGroupInfo() async throws {
        // Given
        let key = "test_group_\(UUID().uuidString)"
        let group = try TestDataFactory.groupInfo().build()

        // When
        try await sut.save(group, forKey: key)
        let loaded: GroupInfo = try await sut.load(forKey: key)

        // Then
        #expect(loaded.groupId == group.groupId)
        #expect(loaded.code == group.code)

        // Cleanup
        try? await sut.remove(forKey: key)
    }

    @Test("Save and load array of Teachers")
    func saveAndLoadArray() async throws {
        // Given
        let key = "test_teachers_\(UUID().uuidString)"
        let teachers = [
            try TestDataFactory.teacher().with(id: 1).with(name: "Dr. Smith").build(),
            try TestDataFactory.teacher().with(id: 2).with(name: "Dr. Jones").build()
        ]

        // When
        try await sut.save(teachers, forKey: key)
        let loaded: [Teacher] = try await sut.load(forKey: key)

        // Then
        #expect(loaded.count == teachers.count)
        #expect(loaded[0].id == teachers[0].id)
        #expect(loaded[1].name == teachers[1].name)

        // Cleanup
        try? await sut.remove(forKey: key)
    }

    // MARK: - Exists Tests

    @Test("File exists after save")
    func fileExistsAfterSave() async throws {
        // Given
        let key = "test_key_\(UUID().uuidString)"
        let value = "Test Value"

        // When
        try await sut.save(value, forKey: key)
        let exists = await sut.exists(forKey: key)

        // Then
        #expect(exists == true)

        // Cleanup
        try? await sut.remove(forKey: key)
    }

    @Test("File does not exist when not saved")
    func fileDoesNotExist() async {
        // Given
        let key = "non_existent_key_\(UUID().uuidString)"

        // When
        let exists = await sut.exists(forKey: key)

        // Then
        #expect(exists == false)
    }

    // MARK: - Remove Tests

    @Test("Remove existing file")
    func removeExistingFile() async throws {
        // Given
        let key = "test_key_\(UUID().uuidString)"
        try await sut.save("Test Value", forKey: key)
        #expect(await sut.exists(forKey: key) == true)

        // When
        try await sut.remove(forKey: key)

        // Then
        #expect(await sut.exists(forKey: key) == false)
    }

    @Test("Remove non-existing file does not throw")
    func removeNonExistingFile() async throws {
        // Given
        let key = "non_existent_key_\(UUID().uuidString)"

        // When & Then - should not throw
        try await sut.remove(forKey: key)
    }

    // MARK: - Error Tests

    @Test("Load throws error when file does not exist")
    func loadThrowsErrorWhenFileDoesNotExist() async {
        // Given
        let key = "non_existent_key_\(UUID().uuidString)"

        // When & Then
        await #expect(throws: Error.self) {
            let _: String = try await sut.load(forKey: key)
        }
    }

    @Test("Load throws error when decoding fails")
    func loadThrowsErrorWhenDecodingFails() async throws {
        // Given
        let key = "test_key_\(UUID().uuidString)"
        let invalidJSON = "not a valid json for ScheduleEvent"
        try await sut.save(invalidJSON, forKey: key)

        // When & Then
        await #expect(throws: Error.self) {
            let _: ScheduleEvent = try await sut.load(forKey: key)
        }

        // Cleanup
        try? await sut.remove(forKey: key)
    }

    // MARK: - Overwrite Tests

    @Test("Save overwrites existing file")
    func saveOverwritesExistingFile() async throws {
        // Given
        let key = "test_key_\(UUID().uuidString)"
        let value1 = "First Value"
        let value2 = "Second Value"

        // When
        try await sut.save(value1, forKey: key)
        let loaded1: String = try await sut.load(forKey: key)

        try await sut.save(value2, forKey: key)
        let loaded2: String = try await sut.load(forKey: key)

        // Then
        #expect(loaded1 == value1)
        #expect(loaded2 == value2)
        #expect(loaded1 != loaded2)

        // Cleanup
        try? await sut.remove(forKey: key)
    }

    // MARK: - Concurrency Tests

    @Test("Concurrent saves succeed")
    func concurrentSaves() async throws {
        // Given
        let keys = (0..<10).map { "test_key_\(UUID().uuidString)_\($0)" }

        // When - parallel saves
        await withTaskGroup(of: Void.self) { group in
            for (index, key) in keys.enumerated() {
                group.addTask {
                    try? await self.sut.save("Value \(index)", forKey: key)
                }
            }
        }

        // Then - all should be saved
        for (index, key) in keys.enumerated() {
            let loaded: String = try await sut.load(forKey: key)
            #expect(loaded == "Value \(index)")
        }

        // Cleanup
        for key in keys {
            try? await sut.remove(forKey: key)
        }
    }
}
