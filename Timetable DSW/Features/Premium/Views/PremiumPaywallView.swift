//
//  PremiumPaywallView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import SwiftUI
import StoreKit

struct PremiumPaywallView: View {
    // MARK: - Configuration

    struct Configuration: ComponentConfiguration {
        struct Constants {
            let iconSize: CGFloat = 80
            let spacing: AppSpacing = .xl
            let padding: AppSpacing = .xxl
            let buttonPadding: EdgeInsets = .init(
                top: AppSpacing.medium.value,
                leading: AppSpacing.xxxl.value,
                bottom: AppSpacing.medium.value,
                trailing: AppSpacing.xxxl.value
            )
            let cornerRadius: AppCornerRadius = .xl
            let shadowRadius: CGFloat = 20
            let shadowY: CGFloat = 8
            let glowOpacity: Double = 0.3
        }

        static let constants = Constants()
    }

    // MARK: - Properties

    let feature: PremiumFeature
    let onWatchAd: () -> Void
    let onPurchase: () -> Void

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.storeKitManager) private var storeKitManager: StoreKitManager?
    @EnvironmentObject var appStateService: DefaultAppStateService

    // MARK: - Body

    var body: some View {
        ZStack {
            // Blur background
            AppColor.background.color(for: colorScheme)
                .opacity(0.95)
                .ignoresSafeArea()

            VStack(spacing: Configuration.constants.spacing.value) {
                Spacer()

                iconView
                titleView
                descriptionView

                Spacer()

                actionButtons

                Spacer()
            }
            .padding(Configuration.constants.padding.value)
        }
        .onTapGesture {
            // Dismiss on background tap
            dismiss()
        }
    }

    // MARK: - Subviews

    private var iconView: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(0.2) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: Configuration.constants.iconSize * 1.5, height: Configuration.constants.iconSize * 1.5)
                .blur(radius: 30)

            // Icon
            Image(systemName: feature.icon)
                .font(.system(size: Configuration.constants.iconSize))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: gradientColors.first?.opacity(0.5) ?? .clear,
                    radius: 20,
                    x: 0,
                    y: 10
                )
        }
    }

    private var titleView: some View {
        Text(LocalizedString.premiumFeatureTitle.localized)
            .font(AppTypography.title.font)
            .fontWeight(.bold)
            .themedForeground(.primary, colorScheme: colorScheme)
            .multilineTextAlignment(.center)
    }

    private var descriptionView: some View {
        VStack(spacing: AppSpacing.small.value) {
            Text(feature.displayName)
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .themedForeground(.header, colorScheme: colorScheme)
                .multilineTextAlignment(.center)

            Text(feature.description)
                .font(AppTypography.body.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.medium.value) {
            // Watch ad button
            Button(action: {
                dismiss()
                onWatchAd()
            }) {
                HStack {
                    Image(systemName: "play.rectangle.fill")
                    Text(String(format: LocalizedString.premiumWatchAdButton.localized,
                                DurationFormatter.localizedShortDuration(from: appStateService.tempAwareDuration)))
                        .fontWeight(.semibold)
                }
                .font(AppTypography.body.font)
                .foregroundAppColor(.white, colorScheme: colorScheme)
                .padding(Configuration.constants.buttonPadding)
                .frame(maxWidth: .infinity)
                .background {
                    primaryButtonBackground
                }
                .shadow(
                    color: gradientColors[0].opacity(0.4),
                    radius: Configuration.constants.shadowRadius,
                    x: 0,
                    y: Configuration.constants.shadowY
                )
            }
            .buttonStyle(ScaleButtonStyle())

            // Purchase button
            Button {
                guard let manager = storeKitManager else { return }
                Task {
                    let result = await manager.purchase(.premium)
                    switch result {
                    case .success:
                        dismiss()
                        onPurchase()
                    case .cancelled:
                        break
                    case .pending:
                        break
                    case .failed:
                        break
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "cart.fill")
                    if let product = storeKitManager?.products[.premium] {
                        Text("\(LocalizedString.iapPremiumTitle.localized) • \(product.displayPrice)")
                            .fontWeight(.semibold)
                    } else {
                        Text(LocalizedString.iapPremiumTitle.localized)
                            .fontWeight(.semibold)
                    }
                }
                .font(AppTypography.body.font)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(Configuration.constants.buttonPadding)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                        .strokeBorder(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                }
            }
            .buttonStyle(ScaleButtonStyle())

            // Close button
            Button(LocalizedString.premiumMaybeLater.localized) {
                dismiss()
            }
            .font(AppTypography.subheadline.font)
            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }

    private var primaryButtonBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(0.9)

            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.white.color(for: colorScheme).opacity(Configuration.constants.glowOpacity),
                            AppColor.clear.color(for: colorScheme)
                        ],
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: 100
                    )
                )
        }
    }

    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }
}
