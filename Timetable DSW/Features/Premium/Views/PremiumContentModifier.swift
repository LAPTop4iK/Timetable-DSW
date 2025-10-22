//
//  PremiumContentModifier.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import SwiftUI

// MARK: - Premium Content Modifier

struct PremiumContentModifier: ViewModifier {
    let feature: PremiumFeature
    let premiumAccess: PremiumAccess
    let onWatchAd: () -> Void
    let onPurchase: () -> Void

    @State private var showingPaywall = false

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: premiumAccess.hasAccess(to: feature) ? 0 : 8)
                .disabled(!premiumAccess.hasAccess(to: feature))

            if !premiumAccess.hasAccess(to: feature) {
                premiumOverlay
                    .onTapGesture {
                        showingPaywall = true
                    }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PremiumPaywallView(
                feature: feature,
                onWatchAd: onWatchAd,
                onPurchase: onPurchase
            )
            .presentationDetents([.medium, .large])
        }
    }

    @ViewBuilder
    private var premiumOverlay: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Lock icon and text
            VStack(spacing: AppSpacing.large.value) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text(LocalizedString.premiumFeatureTitle.localized)
                    .font(AppTypography.title3.font)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(LocalizedString.premiumTapToUnlock.localized)
                    .font(AppTypography.body.font)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: .dark)
    }
}

// MARK: - View Extension

extension View {
    @ViewBuilder
    func premiumContent(
        feature: PremiumFeature,
        premiumAccess: PremiumAccess,
        coordinator: AdCoordinator?,
        onWatchAd: @escaping () -> Void,
        onPurchase: @escaping () -> Void
    ) -> some View {
        if coordinator?.isAdDisabled() ?? true {
            self
        } else {
            self.modifier(
                PremiumContentModifier(
                    feature: feature,
                    premiumAccess: premiumAccess,
                    onWatchAd: onWatchAd,
                    onPurchase: onPurchase
                )
            )
        }
    }
}

