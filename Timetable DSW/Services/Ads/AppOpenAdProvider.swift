//
//  AppOpenAdProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import GoogleMobileAds
import Combine
import UIKit

@MainActor
final class AppOpenAdProvider: NSObject, PresentableAdProvider {
    typealias AdObject = AppOpenAd
    
    let adType: AdType = .appOpen
    private let adUnitID: String
    private var ad: AppOpenAd?
    private var loadTime: Date?
    private var lastShownAt: Date?
    private let expirationInterval: TimeInterval = 30 * 60 // 30 минут
    private let cooldownInterval: TimeInterval = 60 // 1 минута
    
    var isReady: Bool {
        guard let loadTime = loadTime, ad != nil else { return false }
        return Date().timeIntervalSince(loadTime) < expirationInterval
    }
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    func load() async throws {
        let loadedAd = try await AppOpenAd.load(with: adUnitID, request: Request())
        ad = loadedAd
        loadTime = Date()
        loadedAd.fullScreenContentDelegate = self
    }
    
    func present(from viewController: UIViewController) async throws {
        guard isReady, let ad = ad else { throw AdError.notLoaded }
        
        // Cooldown check
        if let last = lastShownAt, Date().timeIntervalSince(last) < cooldownInterval {
            throw AdError.failedToPresent(NSError(
                domain: "AppOpenAd",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Cooldown period"]
            ))
        }
        
        ad.present(from: viewController)
        lastShownAt = Date()
    }
    
    func reset() {
        ad = nil
        loadTime = nil
    }
}

extension AppOpenAdProvider: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { await reset() }
    }
    
    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { await reset() }
    }
}
