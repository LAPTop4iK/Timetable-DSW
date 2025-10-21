//
//  BottomInsetService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import Foundation
import SwiftUI
import Combine

// MARK: - Configuration

enum BannerPosition: String, Codable, CaseIterable, Sendable {
    case bottom         // Banner at very bottom of screen
    case top            // Banner at top of screen
    case aboveTabBar    // Banner above tab bar

    var displayName: String {
        switch self {
        case .bottom: return "Bottom"
        case .top: return "Top"
        case .aboveTabBar: return "Above Tab Bar"
        }
    }
}

struct BottomInsetConfiguration {
    let tabBarHeight: CGFloat
    let bannerHeight: CGFloat
    let spacing: CGFloat

    static let `default` = BottomInsetConfiguration(
        tabBarHeight: 78,      // Standard iOS tab bar with safe area
        bannerHeight: 50,      // Standard banner ad height
        spacing: 8             // Spacing between elements
    )
}

// MARK: - Service Protocol

@MainActor
protocol BottomInsetService: ObservableObject {
    var bottomInset: CGFloat { get }
    var bannerPosition: BannerPosition { get }

    func updateBannerPosition(_ position: BannerPosition)
    func updateBannerHeight(_ height: CGFloat)
    func updateTabBarHeight(_ height: CGFloat)
}

// MARK: - Implementation

@MainActor
final class DefaultBottomInsetService: ObservableObject, BottomInsetService {

    // MARK: - Published Properties

    @Published private(set) var bottomInset: CGFloat
    @Published var bannerPosition: BannerPosition

    // MARK: - Private Properties

    private var configuration: BottomInsetConfiguration
    private let appStateService: AppStateService
    private let featureFlagService: FeatureFlagService
    private let parametersService: FeatureFlagParametersService?
    private var cancellables = Set<AnyCancellable>()

    private var currentBannerHeight: CGFloat = 0
    private var currentTabBarHeight: CGFloat = 0

    // MARK: - Initialization

    init(
        configuration: BottomInsetConfiguration = .default,
        appStateService: AppStateService,
        featureFlagService: FeatureFlagService,
        parametersService: FeatureFlagParametersService? = nil,
        initialBannerPosition: BannerPosition = .bottom
    ) {
        self.configuration = configuration
        self.appStateService = appStateService
        self.featureFlagService = featureFlagService
        self.parametersService = parametersService

        // Get initial position from parameters or fallback
        let positionFromParams = parametersService?.getString(.bannerPosition)
            .flatMap { BannerPosition(rawValue: $0) } ?? initialBannerPosition

        self.bannerPosition = positionFromParams
        self.currentTabBarHeight = configuration.tabBarHeight
        self.currentBannerHeight = configuration.bannerHeight

        // Calculate initial value
        self.bottomInset = Self.calculateBottomInset(
            tabBarHeight: currentTabBarHeight,
            bannerHeight: currentBannerHeight,
            bannerPosition: bannerPosition,
            isPremium: appStateService.isPremium,
            showAds: featureFlagService.isEnabled(.showAds),
            spacing: configuration.spacing
        )

        setupObservers()
    }

    // MARK: - Public Methods

    func updateBannerPosition(_ position: BannerPosition) {
        bannerPosition = position
        recalculateInset()
    }

    func updateBannerHeight(_ height: CGFloat) {
        currentBannerHeight = height
        recalculateInset()
    }

    func updateTabBarHeight(_ height: CGFloat) {
        currentTabBarHeight = height
        recalculateInset()
    }

    // MARK: - Private Methods

    private func setupObservers() {
        // Observe premium status changes
        appStateService.statePublisher
            .map(\.premiumStatus.isPremium)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.recalculateInset()
            }
            .store(in: &cancellables)

        // Observe ads feature flag changes
        featureFlagService.flagsPublisher
            .map { $0[.showAds] ?? true }
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.recalculateInset()
            }
            .store(in: &cancellables)

        // Observe banner position parameter changes
        parametersService?.parametersPublisher
            .compactMap { $0[.bannerPosition] }
            .compactMap { value -> String? in
                if case .string(let str) = value {
                    return str
                }
                return nil
            }
            .compactMap { BannerPosition(rawValue: $0) }
            .sink { [weak self] newPosition in
                self?.bannerPosition = newPosition
                self?.recalculateInset()
            }
            .store(in: &cancellables)
    }

    private func recalculateInset() {
        bottomInset = Self.calculateBottomInset(
            tabBarHeight: currentTabBarHeight,
            bannerHeight: currentBannerHeight,
            bannerPosition: bannerPosition,
            isPremium: appStateService.isPremium,
            showAds: featureFlagService.isEnabled(.showAds),
            spacing: configuration.spacing
        )
    }

    private static func calculateBottomInset(
        tabBarHeight: CGFloat,
        bannerHeight: CGFloat,
        bannerPosition: BannerPosition,
        isPremium: Bool,
        showAds: Bool,
        spacing: CGFloat
    ) -> CGFloat {
        // If premium or ads disabled, only tab bar height
        guard !isPremium && showAds else {
            return tabBarHeight
        }

        // Calculate based on banner position
        switch bannerPosition {
        case .bottom:
            // Banner below tab bar: tab bar + banner + spacing
            return tabBarHeight + bannerHeight + spacing

        case .top:
            // Banner at top: only tab bar height (banner doesn't affect bottom)
            return tabBarHeight

        case .aboveTabBar:
            // Banner above tab bar: tab bar + banner + spacing
            return tabBarHeight + bannerHeight + spacing
        }
    }
}

// MARK: - Environment Key

private struct BottomInsetServiceKey: EnvironmentKey {
    static let defaultValue: DefaultBottomInsetService? = nil
}

extension EnvironmentValues {
    var bottomInsetService: DefaultBottomInsetService? {
        get { self[BottomInsetServiceKey.self] }
        set { self[BottomInsetServiceKey.self] = newValue }
    }
}

extension View {
    func bottomInsetService(_ service: DefaultBottomInsetService) -> some View {
        environment(\.bottomInsetService, service)
    }
}

// MARK: - Mock for Testing

#if DEBUG
@MainActor
final class MockBottomInsetService: ObservableObject, BottomInsetService {
    @Published private(set) var bottomInset: CGFloat
    @Published var bannerPosition: BannerPosition

    init(
        bottomInset: CGFloat = 78,
        bannerPosition: BannerPosition = .bottom
    ) {
        self.bottomInset = bottomInset
        self.bannerPosition = bannerPosition
    }

    func updateBannerPosition(_ position: BannerPosition) {
        bannerPosition = position
    }

    func updateBannerHeight(_ height: CGFloat) {}
    func updateTabBarHeight(_ height: CGFloat) {}
}
#endif
