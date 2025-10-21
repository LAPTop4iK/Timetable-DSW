//
//  BannerAdProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


import GoogleMobileAds
import UIKit
import Combine

@MainActor
final class BannerAdProvider: NSObject, ViewAdProvider {
    typealias AdObject = BannerView
    typealias ViewType = UIView

    let adType: AdType = .banner
    private let configuration: BannerAdConfiguration
    private let viewControllerProvider: ViewControllerProvider

    private weak var bannerView: BannerView?

    var isReady: Bool { bannerView != nil }

    init(
        configuration: BannerAdConfiguration,
        viewControllerProvider: ViewControllerProvider
    ) {
        self.configuration = configuration
        self.viewControllerProvider = viewControllerProvider
        super.init()
    }

    func load() async throws {
        // Banner loads automatically when view is created
    }

    func createView() -> UIView {
        // Create banner view
        let banner = BannerView(adSize: configuration.adSize)
        banner.adUnitID = configuration.adUnitID
        banner.delegate = self
        banner.translatesAutoresizingMaskIntoConstraints = false

        self.bannerView = banner

        // Get root view controller and load ad
        Task { @MainActor in
            banner.rootViewController = await viewControllerProvider.getTopMostViewController()
            banner.load(Request())
        }

        return banner
    }

    func reset() {
        bannerView = nil
    }
}

// MARK: - Banner View Delegate

extension BannerAdProvider: BannerViewDelegate {
    nonisolated func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("[Banner] Ad received, size: \(bannerView.adSize.size)")
    }

    nonisolated func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("[Banner] Failed to receive ad: \(error.localizedDescription)")
    }

    nonisolated func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        print("[Banner] Impression recorded")
    }

    nonisolated func bannerViewWillPresentScreen(_ bannerView: BannerView) {
        print("[Banner] Will present screen")
    }

    nonisolated func bannerViewDidDismissScreen(_ bannerView: BannerView) {
        print("[Banner] Did dismiss screen")
    }
}

extension BannerAdProvider {
    /// Factory method for easy creation
    static func create(
        width: CGFloat,
        adUnitID: String = "ca-app-pub-3940256099942544/2934735716",
        viewControllerProvider: ViewControllerProvider
    ) -> BannerAdProvider {
        let config = BannerAdConfiguration(
            adUnitID: adUnitID,
            width: width
        )
        return BannerAdProvider(
            configuration: config,
            viewControllerProvider: viewControllerProvider
        )
    }
}
