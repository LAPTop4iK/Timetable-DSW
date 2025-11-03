//
//  ScheduleRepositoryProtocol.swift
//  Timetable DSW
//
//  Created by Claude on 03/11/2025.
//

import Foundation

/// Protocol for schedule repository abstraction
/// Enables dependency injection and testability
protocol ScheduleRepositoryProtocol: Actor {

    // MARK: - Schedule Methods

    /// Fetch schedule for a group
    /// - Parameters:
    ///   - groupId: Group identifier
    ///   - from: Start date (ISO8601)
    ///   - to: End date (ISO8601)
    /// - Returns: Aggregate response with schedule
    /// - Throws: Error on fetch failure
    @MainActor
    func getSchedule(groupId: Int, from: String, to: String) async throws -> AggregateResponse

    /// Get cached schedule if available
    /// - Returns: Cached schedule or nil
    @MainActor
    func getCachedSchedule() async -> AggregateResponse?

    /// Clear schedule cache
    /// - Throws: Error on clear failure
    func clearScheduleCache() async throws

    // MARK: - Semester Schedule Methods

    /// Fetch semester schedule
    /// - Parameters:
    ///   - groupId: Group identifier
    ///   - from: Start date (ISO8601)
    ///   - to: End date (ISO8601)
    /// - Returns: Group schedule response
    /// - Throws: Error on fetch failure
    @MainActor
    func getSemesterSchedule(groupId: Int, from: String, to: String) async throws -> GroupScheduleResponse

    /// Get cached semester schedule
    /// - Returns: Cached semester schedule or nil
    @MainActor
    func getCachedSemesterSchedule() async -> GroupScheduleResponse?

    // MARK: - Parallel Loading Methods

    /// Fetch schedule with parallel semester data loading
    /// - Parameters:
    ///   - groupId: Group identifier
    ///   - from: Start date (ISO8601)
    ///   - to: End date (ISO8601)
    ///   - existingTeachers: Existing teachers data
    ///   - onSemesterSchedule: Callback for semester data
    /// - Returns: Aggregate response
    /// - Throws: Error on fetch failure
    @MainActor
    func getScheduleWithRace(
        groupId: Int,
        from: String,
        to: String,
        existingTeachers: [Teacher],
        onSemesterSchedule: @escaping (GroupScheduleResponse) -> Void
    ) async throws -> AggregateResponse

    // MARK: - Groups Methods

    /// Fetch list of groups
    /// - Returns: Array of group info
    /// - Throws: Error on fetch failure
    @MainActor
    func getGroups() async throws -> [GroupInfo]

    /// Get cached groups
    /// - Returns: Cached groups or nil
    @MainActor
    func getCachedGroups() async -> [GroupInfo]?
}
