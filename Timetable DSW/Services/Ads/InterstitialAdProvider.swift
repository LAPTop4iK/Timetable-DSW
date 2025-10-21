//
//  InterstitialAdProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import GoogleMobileAds
import Combine
import UIKit

@MainActor
final class InterstitialAdProvider: NSObject, PresentableAdProvider {
    typealias AdObject = InterstitialAd
    
    let adType: AdType = .interstitial
    private let adUnitID: String
    private var ad: InterstitialAd?
    
    var isReady: Bool { ad != nil }
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    func load() async throws {
        ad = try await withCheckedThrowingContinuation { continuation in
            InterstitialAd.load(with: adUnitID, request: Request()) { ad, error in
                if let error = error {
                    continuation.resume(throwing: AdError.failedToLoad(error))
                } else if let ad = ad {
                    continuation.resume(returning: ad)
                } else {
                    continuation.resume(throwing: AdError.notLoaded)
                }
            }
        }
        ad?.fullScreenContentDelegate = self
    }
    
    func present(from viewController: UIViewController) async throws {
        guard let ad = ad else { throw AdError.notLoaded }
        ad.present(from: viewController)
    }
    
    func reset() {
        ad = nil
    }
}

extension InterstitialAdProvider: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { await reset() }
    }

    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { await reset() }
    }
}
