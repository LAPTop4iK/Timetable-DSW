//
//  AdMobCoordinator.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


import Foundation
import Combine
import GoogleMobileAds
import UIKit
import AppTrackingTransparency

@MainActor
final class AdMobCoordinator: AdCoordinator {

    // Dependencies
    private let eligibilityService: AdEligibilityService
    private let viewControllerProvider: ViewControllerProvider
    private let configuration: AdUnitIDsConfiguration

    // Providers cache
    private var interstitialProvider: InterstitialAdProvider?
    private var rewardedProvider: RewardedAdProvider?
    private var rewardedInterstitialProvider: RewardedInterstitialAdProvider?
    private var appOpenProvider: AppOpenAdProvider?
    private var nativeAdProviders: [String: NativeAdProvider] = [:] // Key: identifier

    // State
    private var isPresenting = false
    private let rewardSubject = PassthroughSubject<Bool, Never>()
    private var isStarted = false
    private var consentATT: ATTrackingManager.AuthorizationStatus = .notDetermined


    var rewardPublisher: AnyPublisher<Bool, Never> {
        rewardSubject.eraseToAnyPublisher()
    }

    init(
        eligibilityService: AdEligibilityService,
        viewControllerProvider: ViewControllerProvider,
        configuration: AdUnitIDsConfiguration
    ) {
        self.eligibilityService = eligibilityService
        self.viewControllerProvider = viewControllerProvider
        self.configuration = configuration
    }

    // MARK: - Public Methods

    func start(afterATT status: ATTrackingManager.AuthorizationStatus) {
        guard !isStarted else { return }
        consentATT = status
        isStarted = true
        MobileAds.shared.start()
    }

    private func ensureStarted() throws {
           guard isStarted else { throw AdError.failedToPresent(NSError(
               domain: "AdCoordinator", code: 2,
               userInfo: [NSLocalizedDescriptionKey: "Ads SDK not started yet (wait for ATT)."]
           )) }
       }


    func isAdDisabled() -> Bool {
        !isStarted || !eligibilityService.canShowAds
    }

    func loadAd(type: AdType) async throws {
        try ensureStarted()
        try eligibilityService.checkEligibility()

        switch type {
        case .interstitial:
            let provider = InterstitialAdProvider(adUnitID: configuration.interstitial)
            try await provider.load()
            interstitialProvider = provider

        case .rewarded:
            let provider = RewardedAdProvider(adUnitID: configuration.rewarded)
            try await provider.load()
            setupRewardPublisher(for: provider)
            rewardedProvider = provider

        case .rewardedInterstitial:
            let provider = RewardedInterstitialAdProvider(adUnitID: configuration.rewardedInterstitial)
            try await provider.load()
            setupRewardPublisher(for: provider)
            rewardedInterstitialProvider = provider

        case .appOpen:
            let provider = AppOpenAdProvider(adUnitID: configuration.appOpen)
            try await provider.load()
            appOpenProvider = provider

        case .native, .banner:
            break
        }
    }

    func showAd(type: AdType) async throws {
        try ensureStarted()
        try eligibilityService.checkEligibility()

        guard !isPresenting else {
            throw AdError.failedToPresent(NSError(
                domain: "AdCoordinator",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Another ad is presenting"]
            ))
        }

        isPresenting = true
        defer { isPresenting = false }

        let viewController = try await viewControllerProvider.acquirePresentingViewController(timeout: 2.0)

        switch type {
        case .interstitial:
            guard let provider = interstitialProvider else { throw AdError.notLoaded }
            try await provider.present(from: viewController)

        case .rewarded:
            guard let provider = rewardedProvider else { throw AdError.notLoaded }
            try await provider.present(from: viewController)

        case .rewardedInterstitial:
            guard let provider = rewardedInterstitialProvider else { throw AdError.notLoaded }
            try await provider.present(from: viewController)

        case .appOpen:
            guard let provider = appOpenProvider else { throw AdError.notLoaded }
            try await provider.present(from: viewController)

        case .banner, .native:
            break
        }
    }

    func isAdReady(type: AdType) -> Bool {
        guard isStarted, eligibilityService.canShowAds else { return false }

        switch type {
        case .interstitial:
            return interstitialProvider?.isReady ?? false
        case .rewarded:
            return rewardedProvider?.isReady ?? false
        case .rewardedInterstitial:
            return rewardedInterstitialProvider?.isReady ?? false
        case .appOpen:
            return appOpenProvider?.isReady ?? false
        case .native:
            return true
        case .banner:
            return true
        }
    }

    // MARK: - Native Ad Methods

    /// Create or get existing native ad provider
    func getNativeAdProvider(identifier: String = "default") -> NativeAdProvider {
        if let existing = nativeAdProviders[identifier] {
            return existing
        }

        let config = NativeAdProvider.Configuration(
            adUnitID: configuration.native,
            cacheSize: 3,
            refreshInterval: 60.0
        )

        let provider = NativeAdProvider(configuration: config)
        nativeAdProviders[identifier] = provider

        return provider
    }

    /// Load native ad for specific identifier
    func loadNativeAd(identifier: String = "default") async throws {
        try eligibilityService.checkEligibility()

        let provider = getNativeAdProvider(identifier: identifier)
        try await provider.load()
    }

    /// Refresh native ad (force reload)
    func refreshNativeAd(identifier: String = "default") async throws {
        try eligibilityService.checkEligibility()

        guard let provider = nativeAdProviders[identifier] else {
            throw AdError.notLoaded
        }

        try await provider.refresh()
    }

    // MARK: - View Factories

    func makeBannerView(width: CGFloat) -> UIView {
        let provider = BannerAdProvider.create(
            width: width,
            adUnitID: configuration.banner,
            viewControllerProvider: viewControllerProvider
        )
        return provider.createView()
    }

    // MARK: - Utilities

    func presentAdInspector() async {
        guard let rootVC = await viewControllerProvider.getRootViewController() else { return }
        MobileAds.shared.presentAdInspector(from: rootVC) { error in
            if let error = error {
                print("[AdInspector] Error: \(error)")
            }
        }
    }

    func setTestDevices(_ deviceIDs: [String]) {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = deviceIDs
    }

    // MARK: - Private Helpers

    private func setupRewardPublisher(for provider: RewardableAdProvider) {
        provider.rewardPublisher
            .sink { [weak self] earned in
                self?.rewardSubject.send(earned)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Dependency Injection Helpers

extension AdMobCoordinator {
    static func makeForProduction(
        featureFlagService: FeatureFlagService,
        appStateService: AppStateService
    ) -> AdMobCoordinator {
        let eligibility = DefaultAdEligibilityService(
            featureFlagService: featureFlagService,
            appStateService: appStateService
        )
        let vcProvider = DefaultViewControllerProvider()

        #if DEBUG
        let config = AdUnitIDsConfiguration.test
        #else
        let config = AdUnitIDsConfiguration.production
        #endif

        return AdMobCoordinator(
            eligibilityService: eligibility,
            viewControllerProvider: vcProvider,
            configuration: config
        )
    }
}
