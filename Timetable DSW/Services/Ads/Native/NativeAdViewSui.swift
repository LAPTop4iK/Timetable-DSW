//
//  NativeAdViewSui.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//

import SwiftUI


struct NativeAdViewSui: View {
    @Environment(\.adCoordinator) private var coordinator
    @Environment(\.nativeAdViewModel) private var environmentViewModel
    
    let style: NativeAdViewStyle
    let viewModel: NativeAdViewModel?
    
    // Вариант 1: Использовать ViewModel из Environment (рекомендуется)
    init(style: NativeAdViewStyle = .card) {
        self.style = style
        self.viewModel = nil
    }
    
    // Вариант 2: Передать свой ViewModel
    init(viewModel: NativeAdViewModel, style: NativeAdViewStyle = .card) {
        self.style = style
        self.viewModel = viewModel
    }
    
    var body: some View {
        // Проверка через coordinator (premium/feature flags)
        if coordinator?.isAdDisabled() ?? true {
            EmptyView()
        } else if let nativeViewModel = viewModel ?? environmentViewModel {
            NativeAdViewRepresentable(nativeViewModel: nativeViewModel, style: style)
                .frame(height: heightForStyle(style))
                .background(Color(uiColor: .secondarySystemBackground))
        } else {
            // Fallback если нет ViewModel (для отладки)
            Color.red.opacity(0.3)
                .frame(height: heightForStyle(style))
                .overlay(
                    Text("⚠️ NativeAdViewModel not provided")
                        .font(.caption)
                        .foregroundColor(.white)
                )
        }
    }
    
    private func heightForStyle(_ style: NativeAdViewStyle) -> CGFloat {
        switch style {
        case .basic: return 150
        case .card: return 380
        case .banner: return 80
        case .largeBanner: return 500
        }
    }
}
