//
//  AdUnitIDsConfiguration.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


struct AdUnitIDsConfiguration {
    let rewarded: String
    let interstitial: String
    let banner: String
    let rewardedInterstitial: String
    let appOpen: String
    let native: String

    static let test = AdUnitIDsConfiguration(
        rewarded: "ca-app-pub-3940256099942544/1712485313",
        interstitial: "ca-app-pub-3940256099942544/4411468910",
        banner: "ca-app-pub-3940256099942544/2934735716",
        rewardedInterstitial: "ca-app-pub-3940256099942544/6978759866",
        appOpen: "ca-app-pub-3940256099942544/5662855259",
        native: "ca-app-pub-3940256099942544/3986624511"
    )

    static let production = AdUnitIDsConfiguration(
        rewarded: "ca-app-pub-2195931602320991/5476969834",
        interstitial: "ca-app-pub-2195931602320991/5169848072",
        banner: "ca-app-pub-2195931602320991/9416214847",
        rewardedInterstitial: "YOUR_REWARDED_INTERSTITIAL_AD_UNIT_ID",
        appOpen: "YOUR_APP_OPEN_AD_UNIT_ID",
        native: "YOUR_NATIVE_AD_UNIT_ID"
    )
}
