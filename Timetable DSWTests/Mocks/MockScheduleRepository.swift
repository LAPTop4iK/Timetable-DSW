//
//  MockScheduleRepository.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

// MARK: - Mock Schedule Repository

/// Mock implementation of ScheduleRepository for testing
/// Provides full control over responses and behavior
@MainActor
final class MockScheduleRepository: ScheduleRepositoryProtocol {

    // MARK: - Call Tracking

    private(set) var getScheduleCallCount: Int = 0
    private(set) var getGroupsCallCount: Int = 0
    private(set) var getCachedScheduleCallCount: Int = 0
    private(set) var clearScheduleCacheCallCount: Int = 0
    private(set) var getScheduleWithRaceCallCount: Int = 0

    // MARK: - Mock Data

    private var mockedSchedule: AggregateResponse?
    private var mockedCachedSchedule: AggregateResponse?
    private var mockedGroups: [GroupInfo]?
    private var mockedCachedGroups: [GroupInfo]?
    private var mockedSemesterSchedule: GroupScheduleResponse?

    // MARK: - Error Configuration

    private var shouldFailGetSchedule: Bool = false
    private var shouldFailGetGroups: Bool = false
    private var getScheduleError: Error = NetworkError.invalidResponse
    private var getGroupsError: Error = NetworkError.invalidResponse

    // MARK: - ScheduleRepositoryProtocol Implementation

    func getSchedule(groupId: Int, from: String, to: String) async throws -> AggregateResponse {
        getScheduleCallCount += 1

        if shouldFailGetSchedule {
            throw getScheduleError
        }

        guard let schedule = mockedSchedule else {
            throw NetworkError.invalidResponse
        }

        return schedule
    }

    func getCachedSchedule() async -> AggregateResponse? {
        getCachedScheduleCallCount += 1
        return mockedCachedSchedule
    }

    func clearScheduleCache() async throws {
        clearScheduleCacheCallCount += 1
        mockedCachedSchedule = nil
    }

    func getSemesterSchedule(groupId: Int, from: String, to: String) async throws -> GroupScheduleResponse {
        guard let semesterSchedule = mockedSemesterSchedule else {
            throw NetworkError.invalidResponse
        }
        return semesterSchedule
    }

    func getCachedSemesterSchedule() async -> GroupScheduleResponse? {
        return mockedSemesterSchedule
    }

    func getScheduleWithRace(
        groupId: Int,
        from: String,
        to: String,
        existingTeachers: [Teacher],
        onSemesterSchedule: @escaping (GroupScheduleResponse) -> Void
    ) async throws -> AggregateResponse {
        getScheduleWithRaceCallCount += 1

        // Simulate calling onSemesterSchedule if data is available
        if let semesterSchedule = mockedSemesterSchedule {
            onSemesterSchedule(semesterSchedule)
        }

        if shouldFailGetSchedule {
            throw getScheduleError
        }

        guard let schedule = mockedSchedule else {
            throw NetworkError.invalidResponse
        }

        return schedule
    }

    func getGroups() async throws -> [GroupInfo] {
        getGroupsCallCount += 1

        if shouldFailGetGroups {
            throw getGroupsError
        }

        guard let groups = mockedGroups else {
            throw NetworkError.invalidResponse
        }

        return groups
    }

    func getCachedGroups() async -> [GroupInfo]? {
        return mockedCachedGroups
    }

    // MARK: - Configuration Methods

    func setMockedSchedule(_ schedule: AggregateResponse) {
        mockedSchedule = schedule
    }

    func setMockedCachedSchedule(_ schedule: AggregateResponse?) {
        mockedCachedSchedule = schedule
    }

    func setMockedGroups(_ groups: [GroupInfo]) {
        mockedGroups = groups
    }

    func setMockedCachedGroups(_ groups: [GroupInfo]?) {
        mockedCachedGroups = groups
    }

    func setMockedSemesterSchedule(_ schedule: GroupScheduleResponse) {
        mockedSemesterSchedule = schedule
    }

    func setShouldFailGetSchedule(_ shouldFail: Bool, error: Error = NetworkError.invalidResponse) {
        shouldFailGetSchedule = shouldFail
        getScheduleError = error
    }

    func setShouldFailGetGroups(_ shouldFail: Bool, error: Error = NetworkError.invalidResponse) {
        shouldFailGetGroups = shouldFail
        getGroupsError = error
    }

    func reset() {
        getScheduleCallCount = 0
        getGroupsCallCount = 0
        getCachedScheduleCallCount = 0
        clearScheduleCacheCallCount = 0
        getScheduleWithRaceCallCount = 0

        mockedSchedule = nil
        mockedCachedSchedule = nil
        mockedGroups = nil
        mockedCachedGroups = nil
        mockedSemesterSchedule = nil

        shouldFailGetSchedule = false
        shouldFailGetGroups = false
    }

    // MARK: - Verification Methods

    func verifyGetScheduleCalled(times: Int) -> Bool {
        getScheduleCallCount == times
    }

    func verifyGetGroupsCalled(times: Int) -> Bool {
        getGroupsCallCount == times
    }

    func verifyClearScheduleCacheCalled(times: Int) -> Bool {
        clearScheduleCacheCallCount == times
    }
}
