//
//  NativeAdProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import Foundation
import GoogleMobileAds
import Combine

// MARK: - Native Ad Provider

@MainActor
final class NativeAdProvider: NSObject {

    // MARK: - Configuration

    struct Configuration {
        let adUnitID: String
        let cacheSize: Int
        let refreshInterval: TimeInterval

        static let `default` = Configuration(
            adUnitID: "ca-app-pub-3940256099942544/3986624511", // Test ID
            cacheSize: 3,
            refreshInterval: 60.0 // 1 minute
        )
    }

    // MARK: - Published State

    @Published private(set) var nativeAd: NativeAd?
    @Published private(set) var isLoading = false

    // MARK: - Private Properties

    private let configuration: Configuration
    private var adLoader: AdLoader?

    // Static cache (shared across instances)
    private static var adCache: [String: CachedNativeAd] = [:]
    private static var loadingStates: [String: Bool] = [:]

    // MARK: - Cached Ad Model

    private struct CachedNativeAd {
        let ad: NativeAd
        let loadedAt: Date
    }

    // MARK: - Initialization

    init(configuration: Configuration = .default) {
        self.configuration = configuration
        super.init()

        // Try to load from cache immediately
        if let cached = Self.getCachedAd(for: configuration.adUnitID, maxAge: configuration.refreshInterval) {
            self.nativeAd = cached.ad
        }
    }

    // MARK: - Public Methods

    func load() async throws {
        // Check cache first
        if let cached = Self.getCachedAd(for: configuration.adUnitID, maxAge: configuration.refreshInterval) {
            self.nativeAd = cached.ad
            return
        }

        // Check if already loading
        if Self.loadingStates[configuration.adUnitID] == true {
            // Wait for existing load to complete
            try await waitForExistingLoad()
            return
        }

        // Start loading
        Self.loadingStates[configuration.adUnitID] = true
        isLoading = true

        defer {
            Self.loadingStates[configuration.adUnitID] = false
            isLoading = false
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let adViewOptions = NativeAdViewAdOptions()
            adViewOptions.preferredAdChoicesPosition = .topRightCorner

            let loader = AdLoader(
                adUnitID: configuration.adUnitID,
                rootViewController: nil,
                adTypes: [.native],
                options: [adViewOptions]
            )

            let delegate = LoaderDelegate(
                onSuccess: { [weak self] ad in
                    guard let self = self else { return }
                    self.nativeAd = ad
                    ad.delegate = self

                    // Setup video delegate
                    let videoController = ad.mediaContent.videoController
                        videoController.delegate = self

                    // Cache the ad
                    Self.cacheAd(ad, for: self.configuration.adUnitID, cacheSize: self.configuration.cacheSize)

                    continuation.resume()
                },
                onFailure: { error in
                    continuation.resume(throwing: AdError.failedToLoad(error))
                }
            )

            loader.delegate = delegate
            self.adLoader = loader

            loader.load(Request())
        }
    }

    func refresh() async throws {
        // Force refresh by clearing cache
        Self.adCache.removeValue(forKey: configuration.adUnitID)
        try await load()
    }

    // MARK: - Cache Management

    private static func getCachedAd(for adUnitID: String, maxAge: TimeInterval) -> CachedNativeAd? {
        guard let cached = adCache[adUnitID] else { return nil }

        let age = Date().timeIntervalSince(cached.loadedAt)
        guard age < maxAge else {
            adCache.removeValue(forKey: adUnitID)
            return nil
        }

        return cached
    }

    private static func cacheAd(_ ad: NativeAd, for adUnitID: String, cacheSize: Int) {
        adCache[adUnitID] = CachedNativeAd(ad: ad, loadedAt: Date())

        // Trim cache if needed
        if adCache.count > cacheSize {
            let sortedByDate = adCache.sorted { $0.value.loadedAt < $1.value.loadedAt }
            if let oldestKey = sortedByDate.first?.key {
                adCache.removeValue(forKey: oldestKey)
            }
        }
    }

    private func waitForExistingLoad() async throws {
        // Poll until loading is complete or timeout
        let maxWaitTime: TimeInterval = 10.0
        let pollInterval: TimeInterval = 0.1
        var waited: TimeInterval = 0

        while Self.loadingStates[configuration.adUnitID] == true && waited < maxWaitTime {
            try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
            waited += pollInterval
        }

        // Check if we have the ad now
        if let cached = Self.getCachedAd(for: configuration.adUnitID, maxAge: configuration.refreshInterval) {
            self.nativeAd = cached.ad
        } else {
            throw AdError.failedToLoad(NSError(
                domain: "NativeAdProvider",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to load after waiting"]
            ))
        }
    }

    // MARK: - Loader Delegate

    private class LoaderDelegate: NSObject, NativeAdLoaderDelegate {
        let onSuccess: (NativeAd) -> Void
        let onFailure: (Error) -> Void

        init(onSuccess: @escaping (NativeAd) -> Void, onFailure: @escaping (Error) -> Void) {
            self.onSuccess = onSuccess
            self.onFailure = onFailure
        }

        func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
            onSuccess(nativeAd)
        }

        func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
            onFailure(error)
        }
    }
}

// MARK: - Video Controller Delegate

extension NativeAdProvider: VideoControllerDelegate {
    func videoControllerDidPlayVideo(_ videoController: VideoController) {
        print("[NativeAd] Video started playing")
    }

    func videoControllerDidPauseVideo(_ videoController: VideoController) {
        print("[NativeAd] Video paused")
    }

    func videoControllerDidEndVideoPlayback(_ videoController: VideoController) {
        print("[NativeAd] Video ended")
    }

    func videoControllerDidMuteVideo(_ videoController: VideoController) {
        print("[NativeAd] Video muted")
    }

    func videoControllerDidUnmuteVideo(_ videoController: VideoController) {
        print("[NativeAd] Video unmuted")
    }
}

// MARK: - Native Ad Delegate

extension NativeAdProvider: NativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        print("[NativeAd] Click recorded")
    }

    func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        print("[NativeAd] Impression recorded")
    }

    func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        print("[NativeAd] Will present screen")
    }

    func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
        print("[NativeAd] Will dismiss screen")
    }

    func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        print("[NativeAd] Did dismiss screen")
    }
}
