//
//  AppViewModel.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Combine
import Foundation
import WidgetKit

@MainActor
final class AppViewModel: ObservableObject, EventsProviderProtocol {
    // MARK: - Configuration

    struct Configuration {
        struct Constants {
            let scheduleFrom = "2025-09-06"
            let scheduleTo = "2026-02-08"
        }

        static let constants = Constants()
    }

    // MARK: - Performance Cache
    private let eventTypeDetector: EventTypeDetector
    private var eventsDayTypeCache: [String: EventDayType] = [:]
    private var eventsCacheVersion = UUID()

    @Published var scheduleData: AggregateResponse? {
        didSet {
            if scheduleData?.groupSchedule != oldValue?.groupSchedule {
                invalidateEventsCache()
            }
        }
    }

    // MARK: - Published Properties

    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?
    @Published var isOffline = false
    @Published var groups: [GroupInfo] = []
    @Published var isLoadingGroups = false

    // MARK: - Properties

    private let repository: ScheduleRepository
    private let userDefaults: UserDefaults

    // MARK: - User Defaults Keys

    private enum UserDefaultsKey {
        static let groupId = "groupId"
        static let lastUpdated = "lastUpdated"
    }

    // MARK: - Computed Properties

    var groupId: Int {
        get { userDefaults.integer(forKey: UserDefaultsKey.groupId) }
        set { userDefaults.set(newValue, forKey: UserDefaultsKey.groupId) }
    }

    var selectedGroupName: String? {
        groups.first(where: { $0.groupId == groupId })?.displayName
    }

    // MARK: - Initialization

    init(repository: ScheduleRepository,
         userDefaults: UserDefaults = .standard,
         eventTypeDetector: EventTypeDetector = DefaultEventTypeDetector()) {
        self.repository = repository
        self.userDefaults = userDefaults
        self.eventTypeDetector = eventTypeDetector
    }

    // MARK: - Groups Loading

    func loadGroupsIfNeeded() async {
        guard groups.isEmpty else { return }

        groups = await repository.getCachedGroups() ?? []

        if groups.isEmpty {
            await loadGroups()
        }
    }

    func loadGroups() async {
        isLoadingGroups = true
        defer { isLoadingGroups = false }

        do {
            let fetchedGroups = try await repository.getGroups()
            groups = fetchedGroups.sorted { $0.displayName < $1.displayName }
        } catch {
            print("Failed to load groups: \(error)")
        }
    }

    // MARK: - Schedule Loading

    func loadSchedule() async {
        guard groupId > 0 else {
            errorMessage = LocalizedString.settingsPleaseSelectGroup.localized
            return
        }

        await loadCachedScheduleIfNeeded()

        isLoading = scheduleData == nil
        isRefreshing = scheduleData != nil
        errorMessage = nil

        await fetchFreshSchedule()
    }

    private func loadCachedScheduleIfNeeded() async {
        guard scheduleData == nil else { return }

        scheduleData = await repository.getCachedSchedule()
        if scheduleData != nil {
            lastUpdated = userDefaults.object(forKey: UserDefaultsKey.lastUpdated) as? Date
        }
    }

    private func fetchFreshSchedule() async {
        do {
            let fresh = try await repository.getScheduleWithRace(
                groupId: groupId,
                from: Configuration.constants.scheduleFrom,
                to: Configuration.constants.scheduleTo,
                onSemesterSchedule: { [weak self] semesterSchedule in
                    guard let self = self else { return }
                    // Convert semester schedule to AggregateResponse for UI
                    let partialResponse = AggregateResponse(
                        groupId: semesterSchedule.groupId,
                        from: semesterSchedule.from,
                        to: semesterSchedule.to,
                        intervalType: semesterSchedule.intervalType,
                        groupSchedule: semesterSchedule.groupSchedule,
                        teachers: [], // Empty until aggregate arrives
                        fetchedAt: semesterSchedule.fetchedAt
                    )
                    self.scheduleData = partialResponse
                    self.isLoading = false // Hide loading once semester schedule arrives

                    // Save to App Group for widget
                    AppGroupManager.saveSemesterSchedule(semesterSchedule)
                    AppGroupManager.saveSelectedGroupId(self.groupId)
                    AppGroupManager.saveLastUpdated(Date())

                    // Reload widgets
                    WidgetCenter.shared.reloadAllTimelines()
                }
            )
            scheduleData = fresh // Update with full data including teachers
            updateLastUpdatedTimestamp()
            isOffline = false
        } catch {
            errorMessage = error.localizedDescription
            isOffline = true
        }

        isLoading = false
        isRefreshing = false
    }

    private func updateLastUpdatedTimestamp() {
        lastUpdated = Date()
        userDefaults.set(lastUpdated, forKey: UserDefaultsKey.lastUpdated)
    }

    func refresh() async {
        await loadSchedule()
    }

    // MARK: - Cache Management

    func clearCache() async {
        do {
            try await repository.clearScheduleCache()
            scheduleData = nil
            lastUpdated = nil
            userDefaults.removeObject(forKey: UserDefaultsKey.lastUpdated)
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }

    // MARK: - EventsProviderProtocol

    private func cacheKey(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(eventsCacheVersion)-\(components.year!)-\(components.month!)-\(components.day!)"
    }

    private func invalidateEventsCache() {
        eventsDayTypeCache.removeAll()
        eventsCacheVersion = UUID()
    }

    func hasEventsOn(date: Date) -> Bool {
        eventType(on: date) != .none
    }

    func eventsForDate(_ date: Date) -> [ScheduleEvent] {
        guard let scheduleData = scheduleData else { return [] }

        return scheduleData.groupSchedule.filter { event in
            guard let eventDate = event.startDate else { return false }
            return Calendar.current.isDate(eventDate, inSameDayAs: date)
        }
    }

    func eventType(on date: Date) -> EventDayType {
        let key = cacheKey(for: date)
        if let cached = eventsDayTypeCache[key] { return cached }

        let events = eventsForDate(date)
        let value: EventDayType
        if events.isEmpty {
            value = .none
        } else {
            let allOnline = events.allSatisfy { ev in
                eventTypeDetector.isOnline(remarks: ev.remarks)
            }
            value = allOnline ? .onlineOnly : .regular
        }
        eventsDayTypeCache[key] = value
        return value
    }
}
