//
//  AdCoordinator.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import Combine
import Foundation
import UIKit

protocol AdCoordinator {
    func loadAd(type: AdType) async throws
    func showAd(type: AdType) async throws
    func isAdReady(type: AdType) -> Bool
    func isAdDisabled() -> Bool
    var rewardPublisher: AnyPublisher<Bool, Never> { get }

    // View factories
    func makeBannerView(width: CGFloat) -> UIView
//    func makeNativeAdView() -> UIView

    // Utilities
    func presentAdInspector() async
    func setTestDevices(_ deviceIDs: [String])
}
