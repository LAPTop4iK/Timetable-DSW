//
//  PremiumStatusScreen.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import SwiftUI

struct PremiumStatusScreen: View {
    // MARK: - Configuration

    struct Configuration: ComponentConfiguration {
        struct Constants {
            let iconSize: CGFloat = 70
            let spacing: AppSpacing = .xl
            let padding: AppSpacing = .xxl
            let timerFont: Font = .system(size: 48, weight: .bold, design: .rounded)
            let buttonPadding: EdgeInsets = .init(
                top: AppSpacing.medium.value,
                leading: AppSpacing.xxxl.value,
                bottom: AppSpacing.medium.value,
                trailing: AppSpacing.xxxl.value
            )
        }

        static let constants = Constants()
    }

    // MARK: - Properties

    let premiumAccess: PremiumAccess
    let onWatchAd: () -> Void
    let onPurchase: () -> Void

    @State private var timeRemaining: String = ""
    @State private var timer: Timer?

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.storeKitManager) private var storeKitManager: StoreKitManager?
    @EnvironmentObject var appStateService: DefaultAppStateService

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Configuration.constants.spacing.value) {
                    iconView
                    statusContent

                    Spacer()

                    if !premiumAccess.isPremium {
                        actionButtons
                    }

                    Spacer()
                }
                .padding(Configuration.constants.padding.value)
            }
            .contentMargins(.top, UIDevice.isIPad ? -50 : 0, for: .scrollContent)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    // MARK: - Subviews

    private var iconView: some View {
        ZStack {
            // Glow effect
            if UIDevice.isIPhone {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Configuration.constants.iconSize * 1.5, height: Configuration.constants.iconSize * 1.5)
                    .blur(radius: 40)
            }
            // Icon
            if premiumAccess.isPremium {
                Image(systemName: "crown.fill")
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
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: Configuration.constants.iconSize))
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }
        }
    }

    @ViewBuilder
    private var statusContent: some View {
        if premiumAccess.isPremium {
            premiumContent
        } else {
            nonPremiumContent
        }
    }

    private var premiumContent: some View {
        VStack(spacing: AppSpacing.large.value) {
            Text(LocalizedString.premiumActive.localized)
                .font(AppTypography.title.font)
                .fontWeight(.bold)
                .themedForeground(.primary, colorScheme: colorScheme)

            switch premiumAccess.status {
            case .premium:
                permanentPremiumView
            case .temporaryPremium:
                temporaryPremiumView
            case .free:
                EmptyView()
            }
        }
    }

    private var permanentPremiumView: some View {
        VStack(spacing: AppSpacing.medium.value) {
            Text(LocalizedString.premiumThankYou.localized)
                .font(AppTypography.body.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .multilineTextAlignment(.center)

            Text(LocalizedString.premiumEnjoyFeatures.localized)
                .font(AppTypography.headline.font)
                .fontWeight(.semibold)
                .themedForeground(.header, colorScheme: colorScheme)
                .multilineTextAlignment(.center)
                .padding(.top, AppSpacing.small.value)

            // Features list
            VStack(alignment: .leading, spacing: AppSpacing.small.value) {
                ForEach(PremiumFeature.allCases, id: \.self) { feature in
                    featureRow(feature)
                }
            }
            .padding(.top, AppSpacing.large.value)
        }
    }

    private var temporaryPremiumView: some View {
        VStack(spacing: AppSpacing.large.value) {
            Text(LocalizedString.premiumTimeRemaining.localized)
                .font(AppTypography.subheadline.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)

            Text(timeRemaining)
                .font(Configuration.constants.timerFont)
                .fontWeight(.bold)
                .themedForeground(.primary, colorScheme: colorScheme)
                .monospacedDigit()

            Text(LocalizedString.premiumWatchOrPurchase.localized)
                .font(AppTypography.body.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .multilineTextAlignment(.center)
                .padding(.top, AppSpacing.medium.value)
        }
    }

    private var nonPremiumContent: some View {
        VStack(spacing: AppSpacing.large.value) {
            Text(LocalizedString.premiumUnlockTitle.localized)
                .font(AppTypography.title.font)
                .fontWeight(.bold)
                .themedForeground(.primary, colorScheme: colorScheme)

            Text(LocalizedString.premiumGetAccess.localized)
                .font(AppTypography.body.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .multilineTextAlignment(.center)

            // Features list
            VStack(alignment: .leading, spacing: AppSpacing.medium.value) {
                ForEach(PremiumFeature.allCases, id: \.self) { feature in
                    featureRow(feature)
                }
            }
            .padding(.top, AppSpacing.large.value)
        }
    }

    private func featureRow(_ feature: PremiumFeature) -> some View {
        HStack(spacing: AppSpacing.medium.value) {
            Image(systemName: feature.icon)
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.displayName)
                    .font(AppTypography.subheadline.font)
                    .fontWeight(.semibold)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                Text(feature.description)
                    .font(AppTypography.caption.font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }

            Spacer()
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.medium.value) {
            // Watch ad button
            Button(action: {
//                dismiss()
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
            }
            .buttonStyle(ScaleButtonStyle())

            // Purchase button
            Button {
                guard let manager = storeKitManager else { return }
                Task {
                    let result = await manager.purchase(.premium)
                    switch result {
                    case .success:
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
                    if let productInfo = storeKitManager?.getProductInfo(for: .premium) {
                        Text("\(LocalizedString.iapPremiumTitle.localized) • \(productInfo.displayPrice)")
                            .fontWeight(.semibold)
                    } else {
                        Text(LocalizedString.premiumPurchaseButton.localized)
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
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
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
        }
    }

    private var primaryButtonBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(0.9)

            RoundedRectangle(cornerRadius: AppCornerRadius.xl.value)
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.white.color(for: colorScheme).opacity(0.3),
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

    // MARK: - Timer

    private func startTimer() {
        updateTimeRemaining()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateTimeRemaining() {
        guard case .temporaryPremium(let expiresAt) = premiumAccess.status else {
            timeRemaining = ""
            return
        }

        let remaining = expiresAt.timeIntervalSince(Date())
        guard remaining > 0 else {
            timeRemaining = "00:00:00"
            stopTimer()
            return
        }

        let hours = Int(remaining) / AppStateConfiguration.secondsInHour
        let minutes = (Int(remaining) % AppStateConfiguration.secondsInHour) / 60
        let seconds = Int(remaining) % 60

        timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
