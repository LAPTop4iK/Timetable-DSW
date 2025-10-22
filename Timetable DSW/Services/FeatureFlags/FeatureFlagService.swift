//
//  FeatureFlagService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


import Foundation
import Combine
import SwiftUI

// MARK: - Feature Flags Protocol (Complete)

@MainActor
protocol FeatureFlagService: AnyObject {
    // Basic operations
    func isEnabled(_ flag: FeatureFlag) -> Bool
    func setEnabled(_ flag: FeatureFlag, enabled: Bool)
    func reset(_ flag: FeatureFlag)
    func resetAll()
    func syncFromRemote() async throws
    
    // Additional methods needed by consumers
    func hasLocalOverride(for flag: FeatureFlag) -> Bool
    
    // Publishers for reactive updates
    var flagsPublisher: AnyPublisher<[FeatureFlag: Bool], Never> { get }
}

// MARK: - App State Protocol (Complete)

@MainActor
protocol AppStateService: AnyObject {
    // State properties
    var isPremium: Bool { get }
    var premiumStatus: PremiumStatus { get }
    var state: AppState { get }
    
    // Actions
    func grantPremium()
    func grantTemporaryPremium(duration: TimeInterval)
    func revokePremium()
    func recordAdWatched()
    
    // Publisher for reactive updates
    var statePublisher: AnyPublisher<AppState, Never> { get }
}

// MARK: - DefaultFeatureFlagService conforms to protocol


// MARK: - Mock Services for Testing

#if DEBUG

@MainActor
final class MockFeatureFlagService: FeatureFlagService {
    private var flags: [FeatureFlag: Bool] = [:]
    private var overrides: Set<FeatureFlag> = []
    private let subject = CurrentValueSubject<[FeatureFlag: Bool], Never>([:])
    
    var flagsPublisher: AnyPublisher<[FeatureFlag: Bool], Never> {
        subject.eraseToAnyPublisher()
    }
    
    init(defaultFlags: [FeatureFlag: Bool] = [:]) {
        self.flags = defaultFlags
        subject.send(flags)
    }
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        flags[flag] ?? flag.defaultValue
    }
    
    func setEnabled(_ flag: FeatureFlag, enabled: Bool) {
        flags[flag] = enabled
        overrides.insert(flag)
        subject.send(flags)
    }
    
    func reset(_ flag: FeatureFlag) {
        flags.removeValue(forKey: flag)
        overrides.remove(flag)
        subject.send(flags)
    }
    
    func resetAll() {
        flags.removeAll()
        overrides.removeAll()
        subject.send(flags)
    }
    
    func syncFromRemote() async throws {
        // Mock implementation
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func hasLocalOverride(for flag: FeatureFlag) -> Bool {
        overrides.contains(flag)
    }
}

@MainActor
final class MockAppStateService: AppStateService {
    @Published private(set) var state: AppState
    
    var statePublisher: AnyPublisher<AppState, Never> {
        $state.eraseToAnyPublisher()
    }
    
    var premiumStatus: PremiumStatus {
        state.premiumStatus
    }
    
    var isPremium: Bool {
        state.premiumStatus.isPremium
    }
    
    init(initialState: AppState = .default) {
        self.state = initialState
    }
    
    func grantPremium() {
        state.premiumStatus = .premium
        state.premiumPurchaseDate = Date()
    }
    
    func grantTemporaryPremium(duration: TimeInterval = 3600) {
        let expiresAt = Date().addingTimeInterval(duration)
        state.premiumStatus = .temporaryPremium(expiresAt: expiresAt)
    }
    
    func revokePremium() {
        state.premiumStatus = .free
        state.premiumPurchaseDate = nil
    }
    
    func recordAdWatched() {
        state.lastAdWatchedDate = Date()
        state.totalAdsWatched += 1
    }
}

#endif

// MARK: - Service Container (Dependency Injection)

@MainActor
final class ServiceContainer {
    // Singleton pattern (или можно использовать другой DI подход)
    static let shared = ServiceContainer()
    
    // Services как protocols
    let featureFlagService: FeatureFlagService
    let appStateService: AppStateService
    
    private init(
        featureFlagService: FeatureFlagService? = nil,
        appStateService: AppStateService? = nil
    ) {
        // Production services по умолчанию
        self.featureFlagService = featureFlagService ?? DefaultFeatureFlagService()
        self.appStateService = appStateService ?? DefaultAppStateService()
    }
    
    // Factory для тестов
    static func mock(
        featureFlagService: FeatureFlagService? = nil,
        appStateService: AppStateService? = nil
    ) -> ServiceContainer {
        let featureService: FeatureFlagService?
        let appService: AppStateService?
#if DEBUG
        featureService = featureFlagService ?? MockFeatureFlagService()
        appService = appStateService ?? MockAppStateService()
#else
        featureService = featureFlagService
        appService = appStateService
#endif
        return ServiceContainer(
            featureFlagService: featureService,
            appStateService: appService
        )
    }
}

// MARK: - Environment Key для Protocols



// MARK: - View Extension для удобства

extension View {
    func services(
        featureFlagService: FeatureFlagService,
        appStateService: AppStateService
    ) -> some View {
        self
            .environment(\.featureFlagService, featureFlagService)
            .environment(\.appStateService, appStateService)
    }
}
