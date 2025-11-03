//
//  MockUserDefaults.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

// MARK: - Mock UserDefaults

/// Mock implementation of UserDefaults for testing
/// Uses in-memory dictionary instead of persistent storage
final class MockUserDefaults: UserDefaults {

    // MARK: - Properties

    private var storage: [String: Any] = [:]
    private(set) var setCallCount: Int = 0
    private(set) var integerCallCount: Int = 0
    private(set) var objectCallCount: Int = 0
    private(set) var removeObjectCallCount: Int = 0

    // MARK: - UserDefaults Override Methods

    override func set(_ value: Any?, forKey defaultName: String) {
        setCallCount += 1
        storage[defaultName] = value
    }

    override func integer(forKey defaultName: String) -> Int {
        integerCallCount += 1
        return storage[defaultName] as? Int ?? 0
    }

    override func object(forKey defaultName: String) -> Any? {
        objectCallCount += 1
        return storage[defaultName]
    }

    override func removeObject(forKey defaultName: String) {
        removeObjectCallCount += 1
        storage.removeValue(forKey: defaultName)
    }

    // MARK: - Test Helper Methods

    func reset() {
        storage.removeAll()
        setCallCount = 0
        integerCallCount = 0
        objectCallCount = 0
        removeObjectCallCount = 0
    }

    func verifySetCalled(times: Int) -> Bool {
        setCallCount == times
    }

    func verifyStorageContains(key: String) -> Bool {
        storage[key] != nil
    }

    func getValue(forKey key: String) -> Any? {
        storage[key]
    }
}
