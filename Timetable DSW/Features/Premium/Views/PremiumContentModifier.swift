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
            .presentationDragIndicator(.hidden)
        }
    }

    @ViewBuilder
    private var premiumOverlay: some View {
        ZStack {
            // Liquid Glass background
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            // Gradient overlay for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Premium card
            VStack(spacing: AppSpacing.xl.value) {
                // Lock icon with glow effect
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    gradientColors[0].opacity(0.4),
                                    gradientColors[1].opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    // Glass circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: gradientColors.map { $0.opacity(0.5) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: gradientColors[0].opacity(0.3), radius: 20, x: 0, y: 10)

                    // Lock icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: AppSpacing.medium.value) {
                    Text(LocalizedString.premiumFeatureTitle.localized)
                        .font(AppTypography.title2.font)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(LocalizedString.premiumTapToUnlock.localized)
                        .font(AppTypography.body.font)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Shimmer effect
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: gradientColors.map { $0.opacity(0.6) },
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 4)
                    .frame(width: 100)
            }
            .padding(AppSpacing.xxxl.value)
            .background {
                RoundedRectangle(cornerRadius: AppCornerRadius.xxl.value)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.xxl.value)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
            .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
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

