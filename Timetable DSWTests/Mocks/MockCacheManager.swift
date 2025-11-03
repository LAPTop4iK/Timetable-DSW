//
//  MockCacheManager.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

// MARK: - Mock Cache Manager

/// Mock implementation of CacheManager for testing
/// Uses in-memory storage instead of file system
@MainActor
final class MockCacheManager: CacheManagerProtocol {

    // MARK: - Properties

    private var storage: [String: Data] = [:]
    private(set) var saveCallCount: Int = 0
    private(set) var loadCallCount: Int = 0
    private(set) var removeCallCount: Int = 0

    private var shouldFailOnSave: Bool = false
    private var shouldFailOnLoad: Bool = false
    private var saveError: Error = CacheError.saveFailed
    private var loadError: Error = CacheError.loadFailed

    // MARK: - Public Methods

    func save<T: Encodable>(_ value: T, forKey key: String) async throws {
        saveCallCount += 1

        if shouldFailOnSave {
            throw saveError
        }

        let data = try JSONEncoder().encode(value)
        storage[key] = data
    }

    func load<T: Decodable>(forKey key: String) async throws -> T {
        loadCallCount += 1

        if shouldFailOnLoad {
            throw loadError
        }

        guard let data = storage[key] else {
            throw CacheError.notFound
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func exists(forKey key: String) -> Bool {
        storage[key] != nil
    }

    func remove(forKey key: String) async throws {
        removeCallCount += 1
        storage.removeValue(forKey: key)
    }

    // MARK: - Test Configuration Methods

    func setShouldFailOnSave(_ shouldFail: Bool, error: Error = CacheError.saveFailed) {
        shouldFailOnSave = shouldFail
        saveError = error
    }

    func setShouldFailOnLoad(_ shouldFail: Bool, error: Error = CacheError.loadFailed) {
        shouldFailOnLoad = shouldFail
        loadError = error
    }

    func reset() {
        storage.removeAll()
        saveCallCount = 0
        loadCallCount = 0
        removeCallCount = 0
        shouldFailOnSave = false
        shouldFailOnLoad = false
    }

    // MARK: - Verification Methods

    func verifySaveCalled(times: Int) -> Bool {
        saveCallCount == times
    }

    func verifyLoadCalled(times: Int) -> Bool {
        loadCallCount == times
    }

    func verifyRemoveCalled(times: Int) -> Bool {
        removeCallCount == times
    }

    func verifyStorageContains(key: String) -> Bool {
        storage[key] != nil
    }

    // MARK: - Errors

    enum CacheError: Error, Equatable {
        case saveFailed
        case loadFailed
        case notFound
    }
}
