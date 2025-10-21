// ===== ИСПРАВЛЕННЫЙ NativeAdViewModel.swift =====

import SwiftUI
import GoogleMobileAds
import Combine

@MainActor
class NativeAdViewModel: NSObject, ObservableObject, NativeAdLoaderDelegate {
    @Published public var nativeAd: NativeAd?
    @Published public var isLoading: Bool = false

    private var adLoader: AdLoader!
    private var adUnitID: String
    private var lastRequestTime: Date?
    public var requestInterval: Int

    // Static кэш как в рабочем примере
    private static var cachedAds: [String: NativeAd] = [:]
    private static var lastRequestTimes: [String: Date] = [:]

    public init(adUnitID: String = "ca-app-pub-3940256099942544/3986624511", requestInterval: Int = 1 * 60) {
        self.adUnitID = adUnitID
        self.requestInterval = requestInterval
        super.init()

        // ✅ Устанавливаем из кэша при инициализации
        self.nativeAd = NativeAdViewModel.cachedAds[adUnitID]
        self.lastRequestTime = NativeAdViewModel.lastRequestTimes[adUnitID]
    }

    public func refreshAd() {
        let now = Date()

        // ✅ ИСПРАВЛЕНИЕ: Явно переустанавливаем из кэша при rate limiting
        if let cachedAd = NativeAdViewModel.cachedAds[adUnitID],
           let lastRequest = lastRequestTime,
           now.timeIntervalSince(lastRequest) < Double(requestInterval) {

            let remaining = Int(Double(requestInterval) - now.timeIntervalSince(lastRequest))
            print("[NativeAd] Rate limited. Using cached ad. Wait \(remaining)s before new request.")

            // ✅ КРИТИЧНО: Переустанавливаем из кэша чтобы триггернуть SwiftUI update
            self.nativeAd = cachedAd

            // ✅ Явно триггерим обновление (на случай если это тот же объект)
            objectWillChange.send()

            return
        }

        guard !isLoading else {
            print("[NativeAd] Already loading, request canceled.")
            return
        }

        isLoading = true
        lastRequestTime = now
        NativeAdViewModel.lastRequestTimes[adUnitID] = now

        let adViewOptions = NativeAdViewAdOptions()
        adViewOptions.preferredAdChoicesPosition = .topRightCorner
        adLoader = AdLoader(adUnitID: adUnitID, rootViewController: nil, adTypes: [.native], options: [adViewOptions])
        adLoader.delegate = self
        adLoader.load(Request())
    }

    public func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print("[NativeAd] Loaded successfully")

        self.nativeAd = nativeAd
        nativeAd.delegate = self
        self.isLoading = false

        // Кэшируем
        NativeAdViewModel.cachedAds[adUnitID] = nativeAd

        // Setup video delegate
        nativeAd.mediaContent.videoController.delegate = self
    }

    public func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("[NativeAd] Failed: \(error.localizedDescription)")
        self.isLoading = false
    }
}

// MARK: - Delegates

extension NativeAdViewModel: VideoControllerDelegate {
    public func videoControllerDidPlayVideo(_ videoController: VideoController) {
        print("[NativeAd] Video started playing")
    }

    public func videoControllerDidPauseVideo(_ videoController: VideoController) {
        print("[NativeAd] Video paused")
    }

    public func videoControllerDidEndVideoPlayback(_ videoController: VideoController) {
        print("[NativeAd] Video ended")
    }

    public func videoControllerDidMuteVideo(_ videoController: VideoController) {
        print("[NativeAd] Video muted")
    }

    public func videoControllerDidUnmuteVideo(_ videoController: VideoController) {
        print("[NativeAd] Video unmuted")
    }
}

extension NativeAdViewModel: NativeAdDelegate {
    public func nativeAdDidRecordClick(_ nativeAd: NativeAd) {
        print("[NativeAd] Click recorded")
    }

    public func nativeAdDidRecordImpression(_ nativeAd: NativeAd) {
        print("[NativeAd] Impression recorded")
    }

    public func nativeAdWillPresentScreen(_ nativeAd: NativeAd) {
        print("[NativeAd] Will present screen")
    }

    public func nativeAdWillDismissScreen(_ nativeAd: NativeAd) {
        print("[NativeAd] Will dismiss screen")
    }

    public func nativeAdDidDismissScreen(_ nativeAd: NativeAd) {
        print("[NativeAd] Did dismiss screen")
    }
}
