//
//  FeatureFlagParameters.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import Foundation
import Combine
import SwiftUI

// MARK: - Parameter Types

/// Type-safe parameter value
enum FeatureFlagParameterValue: Codable, Sendable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)
    case stringArray([String])

    // MARK: - decode

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Порядок важен: если JSON пришёл 900 -> сначала пытаемся Int
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
            return
        }
        if let doubleVal = try? container.decode(Double.self) {
            self = .double(doubleVal)
            return
        }
        if let boolVal = try? container.decode(Bool.self) {
            self = .bool(boolVal)
            return
        }
        if let stringVal = try? container.decode(String.self) {
            self = .string(stringVal)
            return
        }
        if let arrayVal = try? container.decode([String].self) {
            self = .stringArray(arrayVal)
            return
        }

        // Если ничего не подошло
        throw DecodingError.typeMismatch(
            FeatureFlagParameterValue.self,
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported parameter value type"
            )
        )
    }

    // MARK: - encode (на будущее, debug overrides)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let v):          try container.encode(v)
        case .double(let v):       try container.encode(v)
        case .bool(let v):         try container.encode(v)
        case .string(let v):       try container.encode(v)
        case .stringArray(let v):  try container.encode(v)
        }
    }

    // Удобные вьюшные геттеры
    var intValue: Int? {
        if case let .int(v) = self { return v }
        return nil
    }

    var stringValue: String? {
        if case let .string(v) = self { return v }
        return nil
    }

    var timeIntervalValue: TimeInterval? {
        switch self {
        case .int(let i):     return TimeInterval(i)
        case .double(let d):  return TimeInterval(d)
        default:              return nil
        }
    }
}

// MARK: - Parameter Definition

actor FeatureFlagsParameterSyncService {
    private let networkManager: NetworkManager
    private let syncInterval: TimeInterval = 3600 // 1 hour

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func shouldSync(lastSyncDate: Date?) -> Bool {
        guard let lastSync = lastSyncDate else { return true }
        return Date().timeIntervalSince(lastSync) > syncInterval
    }

    func fetchRemoteFlags() async throws -> FeatureFlagParametersResponse {
        try await networkManager.fetch(endpoint: "/api/feature-parameters")
    }
}

struct FeatureFlagParameterDefinition: Codable, Sendable {
    let key: String
    let defaultValue: FeatureFlagParameterValue

    var displayName: String {
        key.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Parameters Configuration

/// Configuration for feature flag parameters
enum FeatureFlagParameterKey: String, CaseIterable, Sendable {
    case bannerPosition = "banner_position"
    case bannerRefreshInterval = "banner_refresh_interval"
    case interstitialCooldown = "interstitial_cooldown"
    case nativeAdCacheSize = "native_ad_cache_size"
    case premiumTrialDuration = "premium_trial_duration"
    case weekSwitchCooldownInterval = "week_switch_cooldown_interval"
    case weekSwitchActionsBeforeShow = "week_switch_actions_before_show"

    var definition: FeatureFlagParameterDefinition {
        switch self {
        case .bannerPosition:
            return FeatureFlagParameterDefinition(
                key: rawValue,
                defaultValue: .string("bottom")
            )
        case .bannerRefreshInterval:
            return FeatureFlagParameterDefinition(
                key: rawValue,
                defaultValue: .int(60) // seconds
            )
        case .interstitialCooldown:
            return FeatureFlagParameterDefinition(
                key: rawValue,
                defaultValue: .int(300) // 5 minutes
            )
        case .nativeAdCacheSize:
            return FeatureFlagParameterDefinition(
                key: rawValue,
                defaultValue: .int(3)
            )
        case .premiumTrialDuration:
            return FeatureFlagParameterDefinition(
                key: rawValue,
                defaultValue: .int(Int(AppStateConfiguration.temporaryPremiumDuration))
            )
        case .weekSwitchCooldownInterval:
            return FeatureFlagParameterDefinition(
                key: rawValue,
                defaultValue: .int(300) // 5 minutes
            )
        case .weekSwitchActionsBeforeShow:
            return FeatureFlagParameterDefinition(
                key: rawValue,
                defaultValue: .int(3) // Show after every 3 week switches
            )
        }
    }

    var displayName: String {
        switch self {
        case .bannerPosition: return "Banner Position"
        case .bannerRefreshInterval: return "Banner Refresh Interval"
        case .interstitialCooldown: return "Interstitial Cooldown"
        case .nativeAdCacheSize: return "Native Ad Cache Size"
        case .premiumTrialDuration: return "Premium Trial Duration"
        case .weekSwitchCooldownInterval: return "Week Switch Cooldown Interval"
        case .weekSwitchActionsBeforeShow: return "Week Switch Actions Before Show"
        }
    }

    var description: String {
        switch self {
        case .bannerPosition:
            return "Position of banner ad (bottom, top, aboveTabBar)"
        case .bannerRefreshInterval:
            return "How often to refresh banner ads (seconds)"
        case .interstitialCooldown:
            return "Cooldown between interstitial ads (seconds)"
        case .nativeAdCacheSize:
            return "Number of native ads to cache"
        case .premiumTrialDuration:
            return "Duration of premium trial after rewarded ad (seconds)"
        case .weekSwitchCooldownInterval:
            return "Cooldown between interstitial ads for week switches (seconds)"
        case .weekSwitchActionsBeforeShow:
            return "Number of week switch actions before showing interstitial ad"
        }
    }
}

// MARK: - Storage State

struct FeatureFlagParametersState: Codable, Sendable {
    var localOverrides: [String: FeatureFlagParameterValue]
    var remoteParameters: [String: FeatureFlagParameterValue]
    var lastSync: Date?

    static let empty = FeatureFlagParametersState(
        localOverrides: [:],
        remoteParameters: [:],
        lastSync: nil
    )
}

// MARK: - Response Model

struct FeatureFlagParametersResponse: Codable, Sendable {
    let parameters: [String: FeatureFlagParameterValue]
    let version: String
    let updatedAt: String
}

// MARK: - Storage Layer

actor FeatureFlagParametersStorage {
    private let userDefaults: UserDefaults
    private let stateKey = "feature_flag_parameters_state"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadState() -> FeatureFlagParametersState {
        guard let data = userDefaults.data(forKey: stateKey),
              let state = try? JSONDecoder().decode(FeatureFlagParametersState.self, from: data) else {
            return .empty
        }
        return state
    }

    func saveState(_ state: FeatureFlagParametersState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        userDefaults.set(data, forKey: stateKey)
    }
}

// MARK: - Main Service

@MainActor
final class FeatureFlagParametersService: ObservableObject {

    // MARK: - Published State

    @Published private var state: FeatureFlagParametersState

    // MARK: - Dependencies

    private let storage: FeatureFlagParametersStorage
    private let syncService: FeatureFlagsParameterSyncService
    private let parametersSubject = CurrentValueSubject<[FeatureFlagParameterKey: FeatureFlagParameterValue], Never>([:])

    nonisolated var parametersPublisher: AnyPublisher<[FeatureFlagParameterKey: FeatureFlagParameterValue], Never> {
        parametersSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(networkManager: NetworkManager = NetworkManager(), userDefaults: UserDefaults = .standard) {
        self.storage = FeatureFlagParametersStorage(userDefaults: userDefaults)
        self.syncService = FeatureFlagsParameterSyncService(networkManager: networkManager)
        self.state = .empty

        Task {
            await loadInitialState()
        }
    }

    // MARK: - Public Methods

    /// Get parameter value with type-safe access
    func getValue<T>(_ key: FeatureFlagParameterKey, as type: T.Type) -> T? {
        let value = resolveValue(for: key)

        switch value {
        case .string(let str) where T.self == String.self:
            return str as? T
        case .int(let num) where T.self == Int.self:
            return num as? T
        case .double(let num) where T.self == Double.self:
            return num as? T
        case .bool(let flag) where T.self == Bool.self:
            return flag as? T
        case .stringArray(let arr) where T.self == [String].self:
            return arr as? T
        default:
            return nil
        }
    }

    /// Get string parameter (convenience)
    func getString(_ key: FeatureFlagParameterKey) -> String? {
        getValue(key, as: String.self)
    }

    /// Get int parameter (convenience)
    func getInt(_ key: FeatureFlagParameterKey) -> Int? {
        getValue(key, as: Int.self)
    }

    /// Get double parameter (convenience)
    func getDouble(_ key: FeatureFlagParameterKey) -> Double? {
        getValue(key, as: Double.self)
    }

    /// Get bool parameter (convenience)
    func getBool(_ key: FeatureFlagParameterKey) -> Bool? {
        getValue(key, as: Bool.self)
    }

    /// Get string array parameter (convenience)
    func getStringArray(_ key: FeatureFlagParameterKey) -> [String]? {
        getValue(key, as: [String].self)
    }

    /// Set local override
    func setValue(_ key: FeatureFlagParameterKey, value: FeatureFlagParameterValue) {
        state.localOverrides[key.rawValue] = value
        updatePublisher()
        Task {
            await storage.saveState(state)
        }
    }

    /// Remove local override
    func reset(_ key: FeatureFlagParameterKey) {
        state.localOverrides.removeValue(forKey: key.rawValue)
        updatePublisher()
        Task {
            await storage.saveState(state)
        }
    }

    /// Reset all local overrides
    func resetAll() {
        state.localOverrides.removeAll()
        updatePublisher()
        Task {
            await storage.saveState(state)
        }
    }

    // MARK: - Private Methods

    private func resolveValue(for key: FeatureFlagParameterKey) -> FeatureFlagParameterValue {
        // Priority: local override > remote > default
        if let override = state.localOverrides[key.rawValue] {
            return override
        }

        if let remote = state.remoteParameters[key.rawValue] {
            return remote
        }

        return key.definition.defaultValue
    }

    private func loadInitialState() async {
        let cached = await storage.loadState()
        self.state = cached
        
        updatePublisher()
        
        let should = await syncService.shouldSync(lastSyncDate: cached.lastSync)
        guard should else { return }
        
        do {
            try await syncFromRemote()
        } catch {
            print("⚪️ skip sync error@\(Date())")
        }
    }

    func syncFromRemote() async throws {
        let response = try await syncService.fetchRemoteFlags()

        state.remoteParameters = response.parameters
        state.lastSync = Date()

        updatePublisher()
        await storage.saveState(state)
    }

    private func updatePublisher() {
        var result: [FeatureFlagParameterKey: FeatureFlagParameterValue] = [:]

        for key in FeatureFlagParameterKey.allCases {
            result[key] = resolveValue(for: key)
        }

        parametersSubject.send(result)
    }
}

// MARK: - Environment Key

private struct FeatureFlagParametersServiceKey: EnvironmentKey {
    static let defaultValue: FeatureFlagParametersService? = nil
}

extension EnvironmentValues {
    var featureFlagParameters: FeatureFlagParametersService? {
        get { self[FeatureFlagParametersServiceKey.self] }
        set { self[FeatureFlagParametersServiceKey.self] = newValue }
    }
}

extension View {
    func featureFlagParameters(_ service: FeatureFlagParametersService) -> some View {
        environment(\.featureFlagParameters, service)
    }
}


enum DurationFormatter {
    /// Возвращает человекочитаемую длительность из секунд:
    ///  - 3600 -> "1 godzina" (при польской локали)
    ///  - 7200 -> "2 godziny"
    ///  - 86400 -> "1 dzień"
    ///  - 172800 -> "2 dni"
    ///
    /// Локаль берётся системная автоматически.
    static func localizedShortDuration(from seconds: TimeInterval) -> String {
        // Кешируем форматтер как static -> без аллокаций каждый раз
        struct Cache {
            static let formatter: DateComponentsFormatter = {
                let f = DateComponentsFormatter()
                // какие единицы нам разрешены
                f.allowedUnits = [.day, .hour, .minute]
                // хотим только самую крупную единицу (не "1 godzina 30 minut")
                f.maximumUnitCount = 1
                // полноразмерные единицы ("godzina", "dzień", "minuta")
                f.unitsStyle = .full
                // локаль не задаём вручную -> возьмётся Locale.current
                return f
            }()
        }

        // Если форматтер вдруг вернул nil (редко, но на всякий)
        return Cache.formatter.string(from: seconds) ?? ""
    }
}
