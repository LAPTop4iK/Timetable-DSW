//
//  FeatureFlag.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


// ===== FILE: Timetable DSW/Services/FeatureFlags/FeatureFlag.swift =====
import Foundation
import Combine

enum FeatureFlag: String, CaseIterable, Codable, Sendable {
    case showSubjectsTab = "show_subjects_tab"
    case showTeachersTab = "show_teachers_tab"
    case enableAnalytics = "enable_analytics"
    case showAds = "show_ads"
    case enablePushNotifications = "enable_push_notifications"
    case darkModeOnly = "dark_mode_only"
    case showDebugMenu = "show_debug_menu"

    nonisolated var defaultValue: Bool {
        switch self {
        case .showSubjectsTab, .showTeachersTab, .showAds:
            return false
        case .enableAnalytics, .enablePushNotifications:
            return false
        case .darkModeOnly:
            return false
        case .showDebugMenu:
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }

    nonisolated var displayName: String {
        switch self {
        case .showSubjectsTab: return "Show Subjects Tab"
        case .showTeachersTab: return "Show Teachers Tab"
        case .enableAnalytics: return "Enable Analytics"
        case .showAds: return "Show Advertisements"
        case .enablePushNotifications: return "Enable Push Notifications"
        case .darkModeOnly: return "Dark Mode Only"
        case .showDebugMenu: return "Show Debug Menu"
        }
    }

    nonisolated var description: String {
        switch self {
        case .showSubjectsTab: return "Display subjects tab in navigation"
        case .showTeachersTab: return "Display teachers tab in navigation"
        case .enableAnalytics: return "Send analytics data"
        case .showAds: return "Display advertisements (disabled for premium users)"
        case .enablePushNotifications: return "Enable push notifications"
        case .darkModeOnly: return "Force dark mode for all users"
        case .showDebugMenu: return "Show debug menu in settings"
        }
    }
}

struct FeatureFlagsResponse: Codable, Sendable {
    let flags: [String: Bool]
    let version: String
    let updatedAt: String
}

struct FeatureFlagsState: Codable, Sendable {
    var localOverrides: [String: Bool]
    var remoteFlags: [String: Bool]
    var version: String?
    var lastSync: Date?

    static let empty = FeatureFlagsState(
        localOverrides: [:],
        remoteFlags: [:],
        version: nil,
        lastSync: nil
    )
}

// MARK: - Protocol (Main Actor для SwiftUI совместимости)


// MARK: - Storage Layer (Single Responsibility: Persistence)

actor FeatureFlagsStorage {
    private let userDefaults: UserDefaults
    private let stateKey = "feature_flags_state"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadState() -> FeatureFlagsState {
        guard let data = userDefaults.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(FeatureFlagsState.self, from: data) else {
            return .empty
        }
        return state
    }

    func saveState(_ state: FeatureFlagsState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        userDefaults.set(data, forKey: stateKey)
    }
}

// MARK: - Sync Layer (Single Responsibility: Remote Sync)

actor FeatureFlagsSyncService {
    private let networkManager: NetworkManager
    private let syncInterval: TimeInterval = 3600 // 1 hour

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func shouldSync(lastSyncDate: Date?) -> Bool {
        guard let lastSync = lastSyncDate else { return true }
        return Date().timeIntervalSince(lastSync) > syncInterval
    }

    func fetchRemoteFlags() async throws -> FeatureFlagsResponse {
        try await networkManager.fetch(endpoint: "/api/feature-flags")
    }
}

// MARK: - Resolution Layer (Single Responsibility: Flag Resolution Logic)

struct FeatureFlagResolver {
    func resolveValue(
        for flag: FeatureFlag,
        localOverride: Bool?,
        remoteValue: Bool?
    ) -> Bool {
        // Priority: local override > remote > default
        if let override = localOverride {
            return override
        }

        if let remote = remoteValue {
            return remote
        }

        return flag.defaultValue
    }

    func resolveAllFlags(
        localOverrides: [String: Bool],
        remoteFlags: [String: Bool]
    ) -> [FeatureFlag: Bool] {
        var result: [FeatureFlag: Bool] = [:]

        for flag in FeatureFlag.allCases {
            let localOverride = localOverrides[flag.rawValue]
            let remoteValue = remoteFlags[flag.rawValue]
            result[flag] = resolveValue(
                for: flag,
                localOverride: localOverride,
                remoteValue: remoteValue
            )
        }

        return result
    }
}

// MARK: - Main Service (@MainActor для SwiftUI)

@MainActor
final class DefaultFeatureFlagService: ObservableObject, FeatureFlagService {

    // MARK: - Dependencies

    private let storage: FeatureFlagsStorage
    private let syncService: FeatureFlagsSyncService
    private let resolver = FeatureFlagResolver()

    // MARK: - State

    @Published private var state: FeatureFlagsState
    private let flagsSubject = CurrentValueSubject<[FeatureFlag: Bool], Never>([:])

    nonisolated var flagsPublisher: AnyPublisher<[FeatureFlag: Bool], Never> {
        flagsSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(
        networkManager: NetworkManager = NetworkManager(),
        userDefaults: UserDefaults = .standard
    ) {
        self.storage = FeatureFlagsStorage(userDefaults: userDefaults)
        self.syncService = FeatureFlagsSyncService(networkManager: networkManager)
        self.state = .empty

        Task {
            await loadInitialState()
        }
    }

    // MARK: - Public Methods

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        resolver.resolveValue(
            for: flag,
            localOverride: state.localOverrides[flag.rawValue],
            remoteValue: state.remoteFlags[flag.rawValue]
        )
    }

    func setEnabled(_ flag: FeatureFlag, enabled: Bool) {
        state.localOverrides[flag.rawValue] = enabled
        updatePublisher()
        Task {
            await storage.saveState(state)
        }
    }

    func reset(_ flag: FeatureFlag) {
        state.localOverrides.removeValue(forKey: flag.rawValue)
        updatePublisher()
        Task {
            await storage.saveState(state)
        }
    }

    func resetAll() {
        state.localOverrides.removeAll()
        updatePublisher()
        Task {
            await storage.saveState(state)
        }
    }

    func syncFromRemote() async throws {
        print("🟢 [FeatureFlags] syncFromRemote() starting... @ \(Date())")
        let response = try await syncService.fetchRemoteFlags()

        print("🟢 [FeatureFlags] Received remote flags: \(response.flags)")
        print("   version: \(response.version)")

        state.remoteFlags = response.flags
        state.version = response.version
        state.lastSync = Date()

        print("🟢 [FeatureFlags] Calling updatePublisher() @ \(Date())")
        updatePublisher()

        await storage.saveState(state)
        print("✅ [FeatureFlags] syncFromRemote() completed @ \(Date())")
    }

    // MARK: - Internal Methods

    func hasLocalOverride(for flag: FeatureFlag) -> Bool {
        state.localOverrides[flag.rawValue] != nil
    }

    // MARK: - Private Methods

    private func loadInitialState() async {
        // Load from storage first
        let loadedState = await storage.loadState()
        state = loadedState
        print("🟡 [FeatureFlags] loadInitialState - loaded from storage @ \(Date())")
        print("   localOverrides: \(state.localOverrides)")
        print("   remoteFlags: \(state.remoteFlags)")
        print("   version: \(state.version ?? "nil")")
        print("   lastSync: \(String(describing: state.lastSync))")

        // Emit initial state to subscribers
        updatePublisher()
        print("🔵 [FeatureFlags] Initial publisher update sent")

        let should = await syncService.shouldSync(lastSyncDate: state.lastSync)
        print("🟡 shouldSync=\(should) lastSync=\(String(describing: state.lastSync)) @\(Date())")

        if should {
            print("🟢 entering syncFromRemote @\(Date())")
            do {
                try await syncFromRemote()
                print("✅ finished syncFromRemote @\(Date())")
            } catch {
                print("❌ syncFromRemote error: \(error) @\(Date())")
            }
        } else {
            print("⚪️ skip sync @\(Date())")
        }
    }

    private func updatePublisher() {
        let allFlags = resolver.resolveAllFlags(
            localOverrides: state.localOverrides,
            remoteFlags: state.remoteFlags
        )
        print("🔵 [FeatureFlags] updatePublisher() sending: \(allFlags) @ \(Date())")
        flagsSubject.send(allFlags)
    }
}

// MARK: - Preview/Mock Service

