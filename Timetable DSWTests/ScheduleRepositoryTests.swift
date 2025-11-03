//
//  ScheduleRepositoryTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Testing
@testable import Timetable_DSW

@MainActor
@Suite("ScheduleRepository Tests")
struct ScheduleRepositoryTests {

    let sut: ScheduleRepository
    let mockNetworkManager: MockNetworkManager
    let mockCacheManager: MockCacheManager

    init() async {
        self.mockNetworkManager = MockNetworkManager()
        self.mockCacheManager = MockCacheManager()
        self.sut = ScheduleRepository(
            networkManager: mockNetworkManager,
            cacheManager: mockCacheManager
        )
    }

    // MARK: - Get Schedule Tests

    @Test("Get schedule - network success")
    func getScheduleSuccess() async throws {
        try await step("Given mocked schedule response") {
            let mockSchedule = try TestDataFactory.aggregateResponse()
            let endpoint = "/api/groups/1/aggregate?from=2025-11-01&to=2025-11-30&type=3"
            await mockNetworkManager.setMockResponse(mockSchedule, forEndpoint: endpoint)
        }

        let result = try await step("When fetching schedule") {
            try await sut.getSchedule(groupId: 1, from: "2025-11-01", to: "2025-11-30")
        }

        await step("Then schedule should be returned and cached") {
            #expect(result != nil)
            let networkCallCount = await mockNetworkManager.fetchCallCount
            #expect(networkCallCount == 1)

            let cacheCallCount = await mockCacheManager.saveCallCount
            #expect(cacheCallCount == 1)
        }
    }

    @Test("Get schedule - network fails, returns cached data")
    func getScheduleNetworkFailReturnsCached() async throws {
        try await step("Given cached schedule exists") {
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
            #expect(result != nil)
            let loadCallCount = await mockCacheManager.loadCallCount
            #expect(loadCallCount == 1)
        }
    }

    @Test("Get schedule - network fails with no cache throws error")
    func getScheduleNetworkFailNoCacheThrows() async {
        await step("Given network fails") {
            await mockNetworkManager.setShouldFail(true, error: NetworkError.invalidResponse)
        }

        await step("When fetching schedule") {
            await #expect(throws: NetworkError.self) {
                try await sut.getSchedule(groupId: 1, from: "2025-11-01", to: "2025-11-30")
            }
        }
    }

    // MARK: - Get Cached Schedule Tests

    @Test("Get cached schedule when cache exists")
    func getCachedScheduleWhenExists() async throws {
       try await step("Given cached schedule exists") {
            let cachedSchedule = try TestDataFactory.aggregateResponse()
            try await mockCacheManager.save(cachedSchedule, forKey: "schedule_cache")
        }

        let result = await step("When getting cached schedule") {
            await sut.getCachedSchedule()
        }

        await step("Then cached schedule should be returned") {
            #expect(result != nil)
        }
    }

    @Test("Get cached schedule when cache empty returns nil")
    func getCachedScheduleWhenEmpty() async {
        let result = await step("When getting cached schedule") {
            await sut.getCachedSchedule()
        }

        await step("Then nil should be returned") {
            #expect(result == nil)
        }
    }

    // MARK: - Clear Schedule Cache Tests

    @Test("Clear schedule cache successfully")
    func clearScheduleCacheSuccess() async throws {
       try await step("Given cached schedule exists") {
            let cachedSchedule = try TestDataFactory.aggregateResponse()
            try await mockCacheManager.save(cachedSchedule, forKey: "schedule_cache")
        }

        try await step("When clearing cache") {
            try await sut.clearScheduleCache()
        }

        await step("Then cache should be cleared") {
            let removeCallCount = await mockCacheManager.removeCallCount
            #expect(removeCallCount == 1)
        }
    }

    // MARK: - Get Groups Tests

    @Test("Get groups - network success")
    func getGroupsSuccess() async throws {
       try await step("Given mocked groups response") {
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
            #expect(result.count == 2)

            let networkCallCount = await mockNetworkManager.fetchCallCount
            #expect(networkCallCount == 1)

            let cacheCallCount = await mockCacheManager.saveCallCount
            #expect(cacheCallCount == 1)
        }
    }

    @Test("Get groups - network fails, returns cached data")
    func getGroupsNetworkFailReturnsCached() async throws {
       try await step("Given cached groups exist") {
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
            #expect(result.count == 1)
            let loadCallCount = await mockCacheManager.loadCallCount
            #expect(loadCallCount == 1)
        }
    }

    @Test("Get groups - network fails with no cache throws error")
    func getGroupsNetworkFailNoCacheThrows() async {
        await step("Given network fails") {
            await mockNetworkManager.setShouldFail(true)
        }

        await step("When fetching groups") {
            await #expect(throws: Error.self) {
                try await sut.getGroups()
            }
        }
    }

    // MARK: - Get Cached Groups Tests

    @Test("Get cached groups when cache exists")
    func getCachedGroupsWhenExists() async throws {
       try await step("Given cached groups exist") {
            let cachedGroups = [try TestDataFactory.groupInfo().build()]
            try await mockCacheManager.save(cachedGroups, forKey: "groups_cache")
        }

        let result = await step("When getting cached groups") {
            await sut.getCachedGroups()
        }

        await step("Then cached groups should be returned") {
            #expect(result != nil)
            #expect(result?.count == 1)
        }
    }

    @Test("Get cached groups when cache empty returns nil")
    func getCachedGroupsWhenEmpty() async {
        let result = await step("When getting cached groups") {
            await sut.getCachedGroups()
        }

        await step("Then nil should be returned") {
            #expect(result == nil)
        }
    }

    // MARK: - Integration Tests

    @Test("Get schedule integrates with cache manager")
    func getScheduleIntegrationWithCache() async throws {
       try await step("Given network response") {
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
            #expect(cachedResult != nil)
            #expect(cachedResult?.groupSchedule.count == 5)
        }
    }

    @Test("Get groups integrates with cache manager")
    func getGroupsIntegrationWithCache() async throws {
       try await step("Given multiple groups") {
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
            #expect(fetchedGroups.count == cachedGroups?.count)
            #expect(fetchedGroups.first?.code == cachedGroups?.first?.code)
        }
    }
}
