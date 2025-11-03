//
//  NetworkManagerProtocol.swift
//  Timetable DSW
//
//  Created by Claude on 03/11/2025.
//

import Foundation

/// Protocol for network layer abstraction
/// Enables dependency injection and testability
protocol NetworkManagerProtocol {

    /// Fetch and decode data from endpoint
    /// - Parameter endpoint: API endpoint path
    /// - Returns: Decoded response
    /// - Throws: NetworkError on failure
    func fetch<T: Decodable>(endpoint: String) async throws -> T
}
