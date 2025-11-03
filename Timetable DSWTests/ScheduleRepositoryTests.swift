//
//  ScheduleRepositoryTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import XCTest
@testable import Timetable_DSW

// MARK: - Schedule Repository Tests

@MainActor
final class ScheduleRepositoryTests: XCTestCase {

    // MARK: - Properties

    private var sut: ScheduleRepository!
    private var mockNetworkManager: MockNetworkManager!
    private var mockCacheManager: MockCacheManager!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        mockNetworkManager = MockNetworkManager()
        mockCacheManager = MockCacheManager()
        sut = ScheduleRepository(
            networkManager: mockNetworkManager,
            cacheManager: mockCacheManager
        )
    }

    override func tearDown() async throws {
        await mockNetworkManager.reset()
        await mockCacheManager.reset()
        sut = nil
        mockNetworkManager = nil
        mockCacheManager = nil

        try await super.tearDown()
    }

    // MARK: - Get Schedule Tests

    func testGetSchedule_Success() async throws {
        await step("Given mocked schedule response") {
            let mockSchedule = try TestDataFactory.aggregateResponse()
            let endpoint = "/api/groups/1/aggregate?from=2025-11-01&to=2025-11-30&type=3"
            await mockNetworkManager.setMockResponse(mockSchedule, forEndpoint: endpoint)
        }

        let result = try await step("When fetching schedule") {
            try await sut.getSchedule(groupId: 1, from: "2025-11-01", to: "2025-11-30")
        }

        await step("Then schedule should be returned and cached") {
            XCTAssertNotNil(result, "Schedule should not be nil")
            let networkCallCount = await mockNetworkManager.fetchCallCount
            XCTAssertEqual(networkCallCount, 1, "Network should be called once")

            let cacheCallCount = await mockCacheManager.saveCallCount
            XCTAssertEqual(cacheCallCount, 1, "Cache save should be called once")
        }
    }

    func testGetSchedule_NetworkFail_ReturnsCachedData() async throws {
        await step("Given cached schedule exists") {
            let cachedSchedule = try TestDataFactory.aggregateResponse()
            try await mockCacheManager.save(cachedSchedule, forKey: "schedule_cache")
        }

        await step("And network fails") {
            await mockNetworkManager.setShouldFail(true, error: NetworkError.invalidResponse)
        }

        let result = try await step("When fetching schedule") {
            try await sut.getSchedule(groupId: 1, from: "2025-11-01", to: "2025-11-30")
        }

        await step("Then cached schedule should be returned") {
            XCTAssertNotNil(result, "Should return cached schedule")
            let loadCallCount = await mockCacheManager.loadCallCount
            XCTAssertEqual(loadCallCount, 1, "Cache load should be called")
        }
    }

    func testGetSchedule_NetworkFail_NoCachedData_ThrowsError() async {
        await step("Given network fails") {
            await mockNetworkManager.setShouldFail(true, error: NetworkError.invalidResponse)
        }

        await step("And no cached data exists") {
            // Cache is empty by default
        }

        await step("When fetching schedule") { [self] in
            do {
                _ = try await sut.getSchedule(groupId: 1, from: "2025-11-01", to: "2025-11-30")
                XCTFail("Should throw error when network fails and no cache")
            } catch let error as NetworkError {
                XCTAssertEqual(error, .invalidResponse, "Should throw network error")
            } catch {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }

    // MARK: - Get Cached Schedule Tests

    func testGetCachedSchedule_WhenCacheExists() async throws {
        await step("Given cached schedule exists") {
            let cachedSchedule = try TestDataFactory.aggregateResponse()
            try await mockCacheManager.save(cachedSchedule, forKey: "schedule_cache")
        }

        let result = await step("When getting cached schedule") {
            await sut.getCachedSchedule()
        }

        await step("Then cached schedule should be returned") {
            XCTAssertNotNil(result, "Should return cached schedule")
        }
    }

    func testGetCachedSchedule_WhenCacheEmpty() async {
        await step("Given cache is empty") {
            // Cache is empty by default
        }

        let result = await step("When getting cached schedule") {
            await sut.getCachedSchedule()
        }

        await step("Then nil should be returned") {
            XCTAssertNil(result, "Should return nil when cache is empty")
        }
    }

    // MARK: - Clear Schedule Cache Tests

    func testClearScheduleCache_Success() async throws {
        await step("Given cached schedule exists") {
            let cachedSchedule = try TestDataFactory.aggregateResponse()
            try await mockCacheManager.save(cachedSchedule, forKey: "schedule_cache")
        }

        try await step("When clearing cache") {
            try await sut.clearScheduleCache()
        }

        await step("Then cache should be cleared") {
            let removeCallCount = await mockCacheManager.removeCallCount
            XCTAssertEqual(removeCallCount, 1, "Cache remove should be called")
        }
    }

    // MARK: - Get Groups Tests

    func testGetGroups_Success() async throws {
        await step("Given mocked groups response") {
            let mockGroups = [
                try TestDataFactory.groupInfo().build(),
                try TestDataFactory.groupInfo().with(groupId: 2).build()
            ]
            await mockNetworkManager.setMockResponse(mockGroups, forEndpoint: "/groups/search")
        }

        let result = try await step("When fetching groups") {
            try await sut.getGroups()
        }

        await step("Then groups should be returned and cached") {
            XCTAssertEqual(result.count, 2, "Should return 2 groups")

            let networkCallCount = await mockNetworkManager.fetchCallCount
            XCTAssertEqual(networkCallCount, 1, "Network should be called once")

            let cacheCallCount = await mockCacheManager.saveCallCount
            XCTAssertEqual(cacheCallCount, 1, "Cache save should be called once")
        }
    }

    func testGetGroups_NetworkFail_ReturnsCachedData() async throws {
        await step("Given cached groups exist") {
            let cachedGroups = [try TestDataFactory.groupInfo().build()]
            try await mockCacheManager.save(cachedGroups, forKey: "groups_cache")
        }

        await step("And network fails") {
            await mockNetworkManager.setShouldFail(true)
        }

        let result = try await step("When fetching groups") {
            try await sut.getGroups()
        }

        await step("Then cached groups should be returned") {
            XCTAssertEqual(result.count, 1, "Should return cached groups")
            let loadCallCount = await mockCacheManager.loadCallCount
            XCTAssertEqual(loadCallCount, 1, "Cache load should be called")
        }
    }

    func testGetGroups_NetworkFail_NoCachedData_ThrowsError() async {
        await step("Given network fails") {
            await mockNetworkManager.setShouldFail(true)
        }

        await step("When fetching groups") { [self] in
            do {
                _ = try await sut.getGroups()
                XCTFail("Should throw error when network fails and no cache")
            } catch {
                // Expected error
            }
        }
    }

    // MARK: - Get Cached Groups Tests

    func testGetCachedGroups_WhenCacheExists() async throws {
        await step("Given cached groups exist") {
            let cachedGroups = [try TestDataFactory.groupInfo().build()]
            try await mockCacheManager.save(cachedGroups, forKey: "groups_cache")
        }

        let result = await step("When getting cached groups") {
            await sut.getCachedGroups()
        }

        await step("Then cached groups should be returned") {
            XCTAssertNotNil(result, "Should return cached groups")
            XCTAssertEqual(result?.count, 1, "Should have 1 cached group")
        }
    }

    func testGetCachedGroups_WhenCacheEmpty() async {
        await step("Given cache is empty") {
            // Cache is empty by default
        }

        let result = await step("When getting cached groups") {
            await sut.getCachedGroups()
        }

        await step("Then nil should be returned") {
            XCTAssertNil(result, "Should return nil when cache is empty")
        }
    }

    // MARK: - Integration Tests

    func testGetSchedule_IntegrationWithCacheManager() async throws {
        await step("Given network response") {
            let mockSchedule = try TestDataFactory.aggregateResponse(
                groupSchedule: try TestDataFactory.sampleWeekSchedule()
            )
            let endpoint = "/api/groups/1/aggregate?from=2025-11-01&to=2025-11-30&type=3"
            await mockNetworkManager.setMockResponse(mockSchedule, forEndpoint: endpoint)
        }

        _ = try await step("When fetching schedule first time") {
            try await sut.getSchedule(groupId: 1, from: "2025-11-01", to: "2025-11-30")
        }

        let cachedResult = await step("Then cached version should be available") {
            await sut.getCachedSchedule()
        }

        await step("And cached data should match fetched data") {
            XCTAssertNotNil(cachedResult, "Cached schedule should exist")
            XCTAssertEqual(cachedResult?.groupSchedule.count, 5, "Should have 5 events from sample week")
        }
    }

    func testGetGroups_IntegrationWithCacheManager() async throws {
        await step("Given multiple groups") {
            let groups = [
                try TestDataFactory.groupInfo().with(code: "CS101").build(),
                try TestDataFactory.groupInfo().with(groupId: 2).with(code: "CS102").build()
            ]
            await mockNetworkManager.setMockResponse(groups, forEndpoint: "/groups/search")
        }

        let fetchedGroups = try await step("When fetching groups") {
            try await sut.getGroups()
        }

        let cachedGroups = await step("Then cached version should be available") {
            await sut.getCachedGroups()
        }

        await step("And data should match") {
            XCTAssertEqual(fetchedGroups.count, cachedGroups?.count, "Counts should match")
            XCTAssertEqual(fetchedGroups.first?.code, cachedGroups?.first?.code, "First group should match")
        }
    }
}
