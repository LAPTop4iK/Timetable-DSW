//
//  CacheManager.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Combine
import Foundation

actor CacheManager {
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // MARK: - Initialization
    
    init() {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ScheduleCache")
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Public Methods
    
    func save<T: Encodable>(_ value: T, forKey key: String) async throws {
        let url = cacheDirectory.appendingPathComponent(key)
        let data = try await MainActor.run { try JSONEncoder().encode(value) }
        try data.write(to: url)
    }
    
    func load<T: Decodable>(forKey key: String) async throws -> T {
        let url = cacheDirectory.appendingPathComponent(key)
        let data = try Data(contentsOf: url)
        return try await MainActor.run { try JSONDecoder().decode(T.self, from: data) }
    }
    
    func exists(forKey key: String) -> Bool {
        let url = cacheDirectory.appendingPathComponent(key)
        return fileManager.fileExists(atPath: url.path)
    }
    
    func remove(forKey key: String) async throws {
        let url = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: url)
    }
}