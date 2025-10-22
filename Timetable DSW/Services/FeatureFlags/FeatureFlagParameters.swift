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
enum FeatureFlagParameterValue: Codable, Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case stringArray([String])

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type, value
    }

    private enum ValueType: String, Codable {
        case string, int, double, bool, stringArray
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .string(let val):
            try container.encode(ValueType.string, forKey: .type)
            try container.encode(val, forKey: .value)
        case .int(let val):
            try container.encode(ValueType.int, forKey: .type)
            try container.encode(val, forKey: .value)
        case .double(let val):
            try container.encode(ValueType.double, forKey: .type)
            try container.encode(val, forKey: .value)
        case .bool(let val):
            try container.encode(ValueType.bool, forKey: .type)
            try container.encode(val, forKey: .value)
        case .stringArray(let val):
            try container.encode(ValueType.stringArray, forKey: .type)
            try container.encode(val, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ValueType.self, forKey: .type)

        switch type {
        case .string:
            self = .string(try container.decode(String.self, forKey: .value))
        case .int:
            self = .int(try container.decode(Int.self, forKey: .value))
        case .double:
            self = .double(try container.decode(Double.self, forKey: .value))
        case .bool:
            self = .bool(try container.decode(Bool.self, forKey: .value))
        case .stringArray:
            self = .stringArray(try container.decode([String].self, forKey: .value))
        }
    }
}

// MARK: - Parameter Definition

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
                defaultValue: .int(3600) // 1 hour
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
        }
    }
}

// MARK: - Storage State

struct FeatureFlagParametersState: Codable, Sendable {
    var localOverrides: [String: FeatureFlagParameterValue]
    var remoteParameters: [String: FeatureFlagParameterValue]

    static let empty = FeatureFlagParametersState(
        localOverrides: [:],
        remoteParameters: [:]
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
    private let parametersSubject = CurrentValueSubject<[FeatureFlagParameterKey: FeatureFlagParameterValue], Never>([:])

    nonisolated var parametersPublisher: AnyPublisher<[FeatureFlagParameterKey: FeatureFlagParameterValue], Never> {
        parametersSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.storage = FeatureFlagParametersStorage(userDefaults: userDefaults)
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
        state = await storage.loadState()
        updatePublisher()
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
