//
//  AppViewModelTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Testing
import Combine
import Foundation
@testable import Timetable_DSW

@MainActor
@Suite("AppViewModel Tests")
struct AppViewModelTests {

    // MARK: - Initialization Tests

    @MainActor
    @Suite("Initialization")
    struct InitializationTests {

        @Test("Default state is correct on initialization")
        func defaultState() async {
            // Given
            let mockRepository = MockScheduleRepository()
            let mockUserDefaults = MockUserDefaults()
            let mockEventTypeDetector = MockEventTypeDetector()

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: mockUserDefaults,
                eventTypeDetector: mockEventTypeDetector
            )

            // Then
            #expect(sut.isLoading == false)
            #expect(sut.isLoadingTeachers == false)
            #expect(sut.isLoadingGroups == false)
            #expect(sut.isRefreshing == false)
            #expect(sut.isOffline == false)
            #expect(sut.errorMessage == nil)
            #expect(sut.scheduleData == nil)
            #expect(sut.lastUpdated == nil)
            #expect(sut.groups.isEmpty)
        }

        @Test("GroupId persists to UserDefaults")
        func groupIdPersistence() async {
            // Given
            let mockRepository = MockScheduleRepository()
            let mockUserDefaults = MockUserDefaults()
            let mockEventTypeDetector = MockEventTypeDetector()

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: mockUserDefaults,
                eventTypeDetector: mockEventTypeDetector
            )

            // When
            sut.groupId = 123

            // Then
            #expect(sut.groupId == 123)
            #expect(mockUserDefaults.getValue(forKey: "groupId") as? Int == 123)
        }
    }

    // MARK: - Load Groups Tests

    @MainActor
    @Suite("Load Groups")
    struct LoadGroupsTests {

        @Test("Load groups successfully")
        func loadGroupsSuccess() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let groups = [
                try TestDataFactory.groupInfo().with(code: "CS101").build(),
                try TestDataFactory.groupInfo().with(groupId: 2).with(code: "CS102").build()
            ]
            await mockRepository.setMockedGroups(groups)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )

            // When
            await sut.loadGroups()

            // Then
            #expect(sut.groups.count == 2)
            #expect(sut.isLoadingGroups == false)
            #expect(await mockRepository.verifyGetGroupsCalled(times: 1))
        }

        @Test("Load groups handles failure gracefully")
        func loadGroupsFailure() async {
            // Given
            let mockRepository = MockScheduleRepository()
            await mockRepository.setShouldFailGetGroups(true, error: NetworkError.invalidResponse)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )

            // When
            await sut.loadGroups()

            // Then
            #expect(sut.groups.isEmpty)
            #expect(sut.isLoadingGroups == false)
        }

        @Test("Load groups if needed when empty")
        func loadGroupsIfNeededWhenEmpty() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let groups = [try TestDataFactory.groupInfo().build()]
            await mockRepository.setMockedGroups(groups)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )

            // When
            await sut.loadGroupsIfNeeded()

            // Then
            #expect(sut.groups.count == 1)
        }

        @Test("Load groups if needed skips when groups exist")
        func loadGroupsIfNeededWhenExists() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groups = [try TestDataFactory.groupInfo().build()]

            // When
            await sut.loadGroupsIfNeeded()

            // Then
            #expect(await mockRepository.verifyGetGroupsCalled(times: 1) == false)
        }
    }

    // MARK: - Load Schedule Tests

    @MainActor
    @Suite("Load Schedule")
    struct LoadScheduleTests {

        @Test("Load schedule successfully without cache")
        func loadScheduleSuccess() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let schedule = try TestDataFactory.aggregateResponse(
                groupSchedule: try TestDataFactory.sampleWeekSchedule()
            )
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1

            // When
            await sut.loadSchedule()

            // Then
            #expect(sut.scheduleData != nil)
            #expect(sut.scheduleData?.groupSchedule.count == 5)
            #expect(sut.isLoading == false)
            #expect(sut.isRefreshing == false)
            #expect(sut.isOffline == false)
            #expect(sut.lastUpdated != nil)
        }

        @Test("Load schedule with cached data")
        func loadScheduleWithCache() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let cachedSchedule = try TestDataFactory.aggregateResponse()
            await mockRepository.setMockedCachedSchedule(cachedSchedule)

            let freshSchedule = try TestDataFactory.aggregateResponse(
                groupSchedule: try TestDataFactory.sampleWeekSchedule()
            )
            await mockRepository.setMockedSchedule(freshSchedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1

            // When
            await sut.loadSchedule()

            // Then
            #expect(sut.scheduleData?.groupSchedule.count == 5)
        }

        @Test("Load schedule shows error on failure")
        func loadScheduleFailure() async {
            // Given
            let mockRepository = MockScheduleRepository()
            await mockRepository.setShouldFailGetSchedule(true, error: NetworkError.invalidResponse)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1

            // When
            await sut.loadSchedule()

            // Then
            #expect(sut.errorMessage != nil)
            #expect(sut.isLoading == false)
        }

        @Test("Load schedule with no groupId shows error")
        func loadScheduleNoGroupId() async {
            // Given
            let sut = AppViewModel(
                repository: MockScheduleRepository(),
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            // groupId is 0 by default

            // When
            await sut.loadSchedule()

            // Then
            #expect(sut.errorMessage != nil)
        }

        @Test("Load schedule sets loading states correctly")
        func loadScheduleSetsLoadingStates() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let schedule = try TestDataFactory.aggregateResponse()
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1

            // When
            await sut.loadSchedule()

            // Then
            #expect(sut.isLoading == false)
            #expect(sut.isRefreshing == false)
        }
    }

    // MARK: - Refresh and Cache Tests

    @MainActor
    @Suite("Refresh and Cache")
    struct RefreshAndCacheTests {

        @Test("Refresh calls load schedule")
        func refreshCallsLoadSchedule() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let schedule = try TestDataFactory.aggregateResponse()
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1

            // When
            await sut.refresh()

            // Then
            #expect(sut.scheduleData != nil)
        }

        @Test("Clear cache removes data and timestamp")
        func clearCacheRemovesData() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )

            // When
            await sut.clearCache()

            // Then
            #expect(sut.lastUpdated == nil)
            #expect(await mockRepository.verifyClearScheduleCacheCalled(times: 1))
        }
    }

    // MARK: - EventsProvider Tests

    @MainActor
    @Suite("EventsProvider Protocol")
    struct EventsProviderTests {

        @Test("Has events on date with events")
        func hasEventsOnDateWithEvents() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let events = try TestDataFactory.sampleWeekSchedule()
            let schedule = try TestDataFactory.aggregateResponse(groupSchedule: events)
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1
            await sut.loadSchedule()

            // When
            let hasEvents = sut.hasEvents(on: events[0].startDate!)

            // Then
            #expect(hasEvents == true)
        }

        @Test("Has events on date without events")
        func hasEventsOnDateWithoutEvents() {
            // Given
            let sut = AppViewModel(
                repository: MockScheduleRepository(),
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            let futureDate = Date().addingTimeInterval(86400 * 365) // 1 year ahead

            // When
            let hasEvents = sut.hasEvents(on: futureDate)

            // Then
            #expect(hasEvents == false)
        }

        @Test("Events for date returns matching events")
        func eventsForDateReturnsMatching() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let events = try TestDataFactory.sampleWeekSchedule()
            let schedule = try TestDataFactory.aggregateResponse(groupSchedule: events)
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1
            await sut.loadSchedule()

            // When
            let dateEvents = sut.events(for: events[0].startDate!)

            // Then
            #expect(!dateEvents.isEmpty)
        }

        @Test("Events for date returns empty for empty schedule")
        func eventsForDateEmptySchedule() {
            // Given
            let sut = AppViewModel(
                repository: MockScheduleRepository(),
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )

            // When
            let events = sut.events(for: Date())

            // Then
            #expect(events.isEmpty)
        }

        @Test("Event type for regular day")
        func eventTypeRegularDay() async throws {
            // Given
            let mockEventTypeDetector = MockEventTypeDetector()
            mockEventTypeDetector.setMockedIsOnline(false)

            let mockRepository = MockScheduleRepository()
            let events = try TestDataFactory.sampleWeekSchedule()
            let schedule = try TestDataFactory.aggregateResponse(groupSchedule: events)
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: mockEventTypeDetector
            )
            sut.groupId = 1
            await sut.loadSchedule()

            // When
            let type = sut.eventType(for: events[0].startDate!)

            // Then
            #expect(type == .regular)
        }

        @Test("Event type for online only day")
        func eventTypeOnlineDay() async throws {
            // Given
            let mockEventTypeDetector = MockEventTypeDetector()
            mockEventTypeDetector.setMockedIsOnline(true)

            let mockRepository = MockScheduleRepository()
            let events = try TestDataFactory.sampleWeekSchedule()
            let schedule = try TestDataFactory.aggregateResponse(groupSchedule: events)
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: mockEventTypeDetector
            )
            sut.groupId = 1
            await sut.loadSchedule()

            // When
            let type = sut.eventType(for: events[0].startDate!)

            // Then
            #expect(type == .onlineOnly)
        }

        @Test("Event type for no events")
        func eventTypeNoEvents() {
            // Given
            let sut = AppViewModel(
                repository: MockScheduleRepository(),
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )

            // When
            let type = sut.eventType(for: Date())

            // Then
            #expect(type == .none)
        }
    }

    // MARK: - Selected Group Name Tests

    @MainActor
    @Suite("Selected Group Name")
    struct SelectedGroupNameTests {

        @Test("Selected group name with matching group")
        func selectedGroupNameWithMatch() async throws {
            // Given
            let group = try TestDataFactory.groupInfo().with(code: "CS101").build()
            let mockRepository = MockScheduleRepository()
            await mockRepository.setMockedGroups([group])

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = group.groupId
            await sut.loadGroups()

            // When
            let groupName = sut.selectedGroupName

            // Then
            #expect(groupName == group.displayName)
        }

        @Test("Selected group name without matching group")
        func selectedGroupNameWithoutMatch() async {
            // Given
            let sut = AppViewModel(
                repository: MockScheduleRepository(),
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 999 // Non-existent group

            // When
            let groupName = sut.selectedGroupName

            // Then
            #expect(groupName == nil)
        }
    }

    // MARK: - Integration Tests

    @MainActor
    @Suite("Integration")
    struct IntegrationTests {

        @Test("Full user flow - load groups and schedule")
        func fullUserFlow() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let groups = [try TestDataFactory.groupInfo().build()]
            await mockRepository.setMockedGroups(groups)

            let schedule = try TestDataFactory.aggregateResponse(
                groupSchedule: try TestDataFactory.sampleWeekSchedule()
            )
            await mockRepository.setMockedSchedule(schedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )

            // When - simulate full user flow
            await sut.loadGroups()
            sut.groupId = groups[0].groupId
            await sut.loadSchedule()

            // Then
            #expect(!sut.groups.isEmpty)
            #expect(sut.scheduleData != nil)
            #expect(sut.selectedGroupName == groups[0].displayName)
        }

        @Test("Schedule update invalidates cache")
        func scheduleUpdateInvalidatesCache() async throws {
            // Given
            let mockRepository = MockScheduleRepository()
            let oldSchedule = try TestDataFactory.aggregateResponse()
            await mockRepository.setMockedSchedule(oldSchedule)

            let sut = AppViewModel(
                repository: mockRepository,
                userDefaults: MockUserDefaults(),
                eventTypeDetector: MockEventTypeDetector()
            )
            sut.groupId = 1

            await sut.loadSchedule()
            let firstTimestamp = sut.lastUpdated

            // When - simulate schedule update
            let newSchedule = try TestDataFactory.aggregateResponse(
                groupSchedule: try TestDataFactory.sampleWeekSchedule()
            )
            await mockRepository.setMockedSchedule(newSchedule)
            await sut.refresh()

            // Then
            #expect(sut.lastUpdated != firstTimestamp)
            #expect(sut.scheduleData?.groupSchedule.count == 5)
        }
    }
}

