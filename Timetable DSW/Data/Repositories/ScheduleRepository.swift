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
        }
        
        struct Endpoint {
            static func aggregate(groupId: Int, from: String, to: String) -> String {
                "/api/groups/\(groupId)/aggregate?from=\(from)&to=\(to)&type=3"
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