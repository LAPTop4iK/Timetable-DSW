//
//  RewardedAdProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import GoogleMobileAds
import Combine
import UIKit

@MainActor
final class RewardedAdProvider: NSObject, RewardableAdProvider {
    typealias AdObject = RewardedAd
    
    let adType: AdType = .rewarded
    private let adUnitID: String
    private var ad: RewardedAd?
    private var didEarnReward = false
    private var presentationContinuation: CheckedContinuation<Void, Error>?
    private let rewardSubject = PassthroughSubject<Bool, Never>()
    
    var isReady: Bool { ad != nil }
    var rewardPublisher: AnyPublisher<Bool, Never> {
        rewardSubject.eraseToAnyPublisher()
    }
    
    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    func load() async throws {
        ad = try await withCheckedThrowingContinuation { continuation in
            RewardedAd.load(with: adUnitID, request: Request()) { ad, error in
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
        
        didEarnReward = false
        
        try await withCheckedThrowingContinuation { continuation in
            presentationContinuation = continuation
            ad.present(from: viewController) { [weak self] in
                self?.didEarnReward = true
                self?.rewardSubject.send(true)
            }
        }
    }
    
    func reset() {
        ad = nil
        presentationContinuation = nil
        didEarnReward = false
    }
}

extension RewardedAdProvider: FullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            if let cont = presentationContinuation {
                presentationContinuation = nil
                if didEarnReward {
                    cont.resume()
                } else {
                    cont.resume(throwing: AdError.noReward)
                }
            }
            reset()
        }
    }
    
    nonisolated func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            presentationContinuation?.resume(throwing: AdError.failedToPresent(error))
            presentationContinuation = nil
            reset()
        }
    }
}
