//
//  CacheManagerProtocol.swift
//  Timetable DSW
//
//  Created by Claude on 03/11/2025.
//

import Foundation

/// Protocol for cache layer abstraction
/// Enables dependency injection and testability
protocol CacheManagerProtocol: Actor {

    /// Save encodable value to cache
    /// - Parameters:
    ///   - value: Value to cache
    ///   - key: Cache key
    /// - Throws: Error on save failure
    func save<T: Encodable>(_ value: T, forKey key: String) async throws

    /// Load decodable value from cache
    /// - Parameter key: Cache key
    /// - Returns: Cached value
    /// - Throws: Error if not found or decode fails
    func load<T: Decodable>(forKey key: String) async throws -> T

    /// Check if cache key exists
    /// - Parameter key: Cache key
    /// - Returns: True if exists
    func exists(forKey key: String) -> Bool

    /// Remove cached value
    /// - Parameter key: Cache key
    /// - Throws: Error on removal failure
    func remove(forKey key: String) async throws
}
