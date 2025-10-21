//
//  BannerAdConfiguration.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import GoogleMobileAds

struct BannerAdConfiguration {
    let adUnitID: String
    let width: CGFloat

    var adSize: AdSize {
        currentOrientationAnchoredAdaptiveBanner(width: width)
    }
}
