//
//  NativeAdViewModelKey.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


// ===== FILE: Services/Ads/Native/NativeAdViewSui.swift =====

import SwiftUI
import GoogleMobileAds

// MARK: - Environment Key для NativeAdViewModel

private struct NativeAdViewModelKey: EnvironmentKey {
    static let defaultValue: NativeAdViewModel? = nil
}

extension EnvironmentValues {
    var nativeAdViewModel: NativeAdViewModel? {
        get { self[NativeAdViewModelKey.self] }
        set { self[NativeAdViewModelKey.self] = newValue }
    }
}

extension View {
    func nativeAdViewModel(_ viewModel: NativeAdViewModel) -> some View {
        environment(\.nativeAdViewModel, viewModel)
    }
}

// MARK: - NativeAdViewSui с Environment и Eligibility Check

// MARK: - Styled компоненты

struct CardStyleNativeAd: View {
    let style: NativeAdViewStyle
    
    init(style: NativeAdViewStyle = .card) {
        self.style = style
    }
    
    var body: some View {
        NativeAdViewSui(style: style)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
    }
}

// MARK: - View Modifier для удобства

struct WithNativeAds: ViewModifier {
    @StateObject private var nativeViewModel: NativeAdViewModel
    
    init(adUnitID: String = "ca-app-pub-3940256099942544/3986624511", requestInterval: Int = 60) {
        self._nativeViewModel = StateObject(wrappedValue: NativeAdViewModel(adUnitID: adUnitID, requestInterval: requestInterval))
    }
    
    func body(content: Content) -> some View {
        content
            .nativeAdViewModel(nativeViewModel)
            .onAppear {
                nativeViewModel.refreshAd()
            }
    }
}

extension View {
    /// Добавляет поддержку Native Ads через Environment
    /// - Parameters:
    ///   - adUnitID: ID рекламного блока (по умолчанию test ID)
    ///   - requestInterval: Интервал между запросами в секундах (по умолчанию 60)
    func withNativeAds(adUnitID: String = "ca-app-pub-3940256099942544/3986624511", requestInterval: Int = 60) -> some View {
        modifier(WithNativeAds(adUnitID: adUnitID, requestInterval: requestInterval))
    }
}
