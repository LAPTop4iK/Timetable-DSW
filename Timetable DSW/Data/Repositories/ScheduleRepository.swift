//
//  ScheduleRepository.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

actor ScheduleRepository {
    // MARK: - Configuration
    
    struct Configuration {
        struct CacheKey {
            static let schedule = "schedule_cache"
            static let groups = "groups_cache"
            static let semesterSchedule = "semester_schedule_cache"
        }

        struct Endpoint {
            static func aggregate(groupId: Int, from: String, to: String) -> String {
                "/api/groups/\(groupId)/aggregate?from=\(from)&to=\(to)&type=3"
            }

            static func semesterSchedule(groupId: Int, from: String, to: String) -> String {
                "/api/groups/\(groupId)/schedule?from=\(from)&to=\(to)&type=3"
            }

            static let groupsSearch = "/groups/search"
        }
    }
    
    // MARK: - Properties
    
    private let networkManager: NetworkManager
    private let cacheManager: CacheManager
    
    // MARK: - Initialization
    
    init(networkManager: NetworkManager, cacheManager: CacheManager) {
        self.networkManager = networkManager
        self.cacheManager = cacheManager
    }
    
    // MARK: - Schedule Methods
    
    @MainActor func getSchedule(groupId: Int, from: String, to: String) async throws -> AggregateResponse {
        do {
            let fresh: AggregateResponse = try await networkManager.fetch(
                endpoint: Configuration.Endpoint.aggregate(groupId: groupId, from: from, to: to)
            )
            try await cacheManager.save(fresh, forKey: Configuration.CacheKey.schedule)
            return fresh
        } catch {
            if let cached: AggregateResponse = try? await cacheManager.load(forKey: Configuration.CacheKey.schedule) {
                return cached
            }
            throw error
        }
    }
    
    @MainActor func getCachedSchedule() async -> AggregateResponse? {
        try? await cacheManager.load(forKey: Configuration.CacheKey.schedule)
    }
    
    func clearScheduleCache() async throws {
        try await cacheManager.remove(forKey: Configuration.CacheKey.schedule)
    }

    // MARK: - Semester Schedule Methods

    @MainActor func getSemesterSchedule(groupId: Int, from: String, to: String) async throws -> GroupScheduleResponse {
        let response: GroupScheduleResponse = try await networkManager.fetch(
            endpoint: Configuration.Endpoint.semesterSchedule(groupId: groupId, from: from, to: to)
        )
        try await cacheManager.save(response, forKey: Configuration.CacheKey.semesterSchedule)
        return response
    }

    @MainActor func getCachedSemesterSchedule() async -> GroupScheduleResponse? {
        try? await cacheManager.load(forKey: Configuration.CacheKey.semesterSchedule)
    }

    // MARK: - Parallel Loading Methods

    @MainActor func getScheduleWithRace(groupId: Int, from: String, to: String, existingTeachers: [Teacher], onSemesterSchedule: @escaping (GroupScheduleResponse) -> Void) async throws -> AggregateResponse {
        // Launch semester schedule request in parallel task
        Task { @MainActor in
            if let semesterSchedule = try? await self.getSemesterSchedule(groupId: groupId, from: from, to: to) {
                // Call callback immediately when semester data arrives
                let aggregate = AggregateResponse(from: semesterSchedule, teachers: existingTeachers)
                try await cacheManager.save(aggregate, forKey: Configuration.CacheKey.schedule)
                onSemesterSchedule(semesterSchedule)
            }
        }

        // Meanwhile, fetch aggregate (this is the main flow)
        do {
            let aggregate: AggregateResponse = try await networkManager.fetch(
                endpoint: Configuration.Endpoint.aggregate(groupId: groupId, from: from, to: to)
            )
            // Save aggregate to cache
            try await cacheManager.save(aggregate, forKey: Configuration.CacheKey.schedule)
            return aggregate
        } catch {
            // If aggregate fails, try cached version
            if let cached: AggregateResponse = try? await cacheManager.load(forKey: Configuration.CacheKey.schedule) {
                return cached
            }
            throw error
        }
    }

    // MARK: - Groups Methods
    
    @MainActor func getGroups() async throws -> [GroupInfo] {
        do {
            let fresh: [GroupInfo] = try await networkManager.fetch(endpoint: Configuration.Endpoint.groupsSearch)
            try await cacheManager.save(fresh, forKey: Configuration.CacheKey.groups)
            return fresh
        } catch {
            if let cached: [GroupInfo] = try? await cacheManager.load(forKey: Configuration.CacheKey.groups),
               !cached.isEmpty {
                return cached
            }
            throw error
        }
    }
    
    @MainActor func getCachedGroups() async -> [GroupInfo]? {
        try? await cacheManager.load(forKey: Configuration.CacheKey.groups)
    }
}
