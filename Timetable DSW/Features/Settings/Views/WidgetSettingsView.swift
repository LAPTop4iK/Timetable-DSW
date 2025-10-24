//
//  WidgetSettingsView.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//  Restyled 24/10/2025 (GradientStyle-based)
//  Slim 24/10/2025: no effects except gradient strokes
//

import SwiftUI
import WidgetKit

struct WidgetSettingsView: View {
    // MARK: - Configuration
    struct Configuration: ComponentConfiguration {
        struct Constants {
            // Layout
            let hPadding: AppSpacing = .large
            let vPadding: AppSpacing = .large
            let sectionSpacing: AppSpacing = .large
            let itemSpacing: AppSpacing = .medium

            // Multipliers
            let sectionSpacingMultiplier: CGFloat = 1.35
            let itemSpacingMultiplier: CGFloat = 1.20
            let cardVPadMultiplier: CGFloat = 1.40

            // Cards
            let containerCorner: AppCornerRadius = .large
            let cardPadding: AppSpacing = .large
            let cardStrokeOpacity: Double = 0.28

            // Misc
            let numberBadgeSize: CGFloat = 28
            let iconSize: CGFloat = 28
        }
        static let constants = Constants()
    }

    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.bottomInsetService) private var bottomInsetService

    // MARK: - State
    @State private var lastUpdated: Date? = AppGroupManager.loadLastUpdated()

    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(
                spacing: Configuration.constants.sectionSpacing.value * Configuration.constants.sectionSpacingMultiplier
            ) {
                headerSection
                statusSection
                instructionsSection
                widgetTypesSection
                troubleshootingSection
                footerRefreshHint
            }
            .padding(.horizontal, Configuration.constants.hPadding.value)
            .padding(.vertical, Configuration.constants.vPadding.value)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: refreshWidgets) {
                    AppIcon.arrowClockwise.image()
                        .font(.system(size: 16, weight: .semibold))
                        .themedForeground(.header, colorScheme: colorScheme)
                        .accessibilityLabel(LocalizedString.settingsRefresh.localized)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppColor.clear.color(for: colorScheme)
                .frame(height: bottomInsetService?.bottomInset ?? 78)
        }
        .background(AppColor.background.color(for: colorScheme).ignoresSafeArea())
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(LocalizedString.widgetTitle.localized)
                .font(AppTypography.title2.font)
                .fontWeight(.semibold)
                .themedForeground(.primary, colorScheme: colorScheme)

            Text(LocalizedString.widgetSettingsSubtitle.localized)
                .font(AppTypography.subheadline.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Status
    private var statusSection: some View {
        cardContainer {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    // Только градиентная обводка
                    Circle()
                        .stroke(gradientStroke(), lineWidth: 1)
                        .frame(width: 42, height: 42)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .themedForeground(.success, colorScheme: colorScheme)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(LocalizedString.widgetEnabledTitle.localized)
                        .font(AppTypography.body.font)
                        .fontWeight(.semibold)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    if let lastUpdated {
                        Text("\(LocalizedString.settingsLastUpdated.localized): \(lastUpdated, style: .relative) \(LocalizedString.relativeAgo.localized)")
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .layoutPriority(1)
                    } else {
                        Text(LocalizedString.widgetNeverUpdated.localized)
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .layoutPriority(1)
                    }

                    Text(LocalizedString.widgetAccessDescription.localized)
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                        .padding(.top, 6)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)
                }

                Spacer(minLength: 0)

                Button(action: refreshWidgets) {
                    HStack(spacing: 6) {
                        AppIcon.arrowClockwise.image()
                            .font(.system(size: 14, weight: .semibold))
                        Text(LocalizedString.settingsRefresh.localized)
                            .font(AppTypography.caption.font)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .themedForeground(.primary, colorScheme: colorScheme)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    // Только капсула-обводка без фона
                    .overlay(
                        Capsule().stroke(gradientStroke(), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(LocalizedString.settingsRefresh.localized)
            }
        }
    }

    // MARK: - Instructions
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(LocalizedString.widgetHowToAdd.localized)

            cardContainer {
                VStack(
                    alignment: .leading,
                    spacing: CGFloat(12) * Configuration.constants.itemSpacingMultiplier
                ) {
                    instructionRow(step: 1, text: LocalizedString.widgetInstructionStep1.localized)
                    instructionRow(step: 2, text: LocalizedString.widgetInstructionStep2.localized)
                    instructionRow(step: 3, text: LocalizedString.widgetInstructionStep3.localized)
                    instructionRow(step: 4, text: LocalizedString.widgetInstructionStep4.localized)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func instructionRow(step: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                // Только обводка
                Circle()
                    .stroke(gradientStroke(), lineWidth: 1)
                    .frame(width: Configuration.constants.numberBadgeSize, height: Configuration.constants.numberBadgeSize)
                Text("\(step)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)
            }

            Text(text)
                .font(AppTypography.body.font)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
        }
    }

    // MARK: - Widget Types
    private var widgetTypesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(LocalizedString.widgetAvailable.localized)

            VStack(
                spacing: Configuration.constants.itemSpacing.value * Configuration.constants.itemSpacingMultiplier
            ) {
                widgetTypeCard(
                    title: LocalizedString.widgetTypeSmallTitle.localized,
                    icon: "square.fill",
                    description: LocalizedString.widgetTypeSmallDescription.localized
                )
                widgetTypeCard(
                    title: LocalizedString.widgetTypeMediumTitle.localized,
                    icon: "rectangle.fill",
                    description: LocalizedString.widgetTypeMediumDescription.localized
                )
                widgetTypeCard(
                    title: LocalizedString.widgetTypeLargeTitle.localized,
                    icon: "rectangle.portrait.fill",
                    description: LocalizedString.widgetTypeLargeDescription.localized
                )
                widgetTypeCard(
                    title: LocalizedString.widgetTypeLiveTitle.localized,
                    icon: "circle.hexagongrid.circle.fill",
                    description: LocalizedString.widgetTypeLiveDescription.localized
                )
            }
        }
    }

    private func widgetTypeCard(title: String, icon: String, description: String) -> some View {
        cardContainer {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    // Контейнер иконки — только обводка
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(gradientStroke(), lineWidth: 1)
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: Configuration.constants.iconSize))
                        .themedForeground(.primary, colorScheme: colorScheme)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.body.font)
                        .fontWeight(.semibold)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)

                    Text(description)
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .layoutPriority(1)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Troubleshooting
    private var troubleshootingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(LocalizedString.widgetTroubleshooting.localized)

            cardContainer {
                VStack(
                    alignment: .leading,
                    spacing: CGFloat(14) * Configuration.constants.itemSpacingMultiplier
                ) {
                    troubleshootingItem(
                        problem: LocalizedString.widgetTroubleNoDataTitle.localized,
                        solution: LocalizedString.widgetTroubleNoDataSolution.localized
                    )
                    Divider()
                    troubleshootingItem(
                        problem: LocalizedString.widgetTroubleNotUpdatingTitle.localized,
                        solution: LocalizedString.widgetTroubleNotUpdatingSolution.localized
                    )
                    Divider()
                    troubleshootingItem(
                        problem: LocalizedString.widgetTroubleWrongThemeTitle.localized,
                        solution: LocalizedString.widgetTroubleWrongThemeSolution.localized
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func troubleshootingItem(problem: String, solution: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .themedForeground(.warning, colorScheme: colorScheme)

                Text(problem)
                    .font(AppTypography.caption.font)
                    .fontWeight(.semibold)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .layoutPriority(1)
            }

            Text(solution)
                .font(AppTypography.caption2.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 22)
                .layoutPriority(1)
        }
    }

    // MARK: - Footer
    private var footerRefreshHint: some View {
        HStack(spacing: 8) {
            AppIcon.arrowClockwise.image()
                .font(.system(size: 14, weight: .semibold))
                .themedForeground(.primary, colorScheme: colorScheme)
            Text(LocalizedString.widgetFooterReloadHint.localized)
                .font(AppTypography.caption2.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }

    // MARK: - Card container (only gradient stroke)
    private func cardContainer<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        let corner = Configuration.constants.containerCorner.value

        return VStack(alignment: .leading, spacing: 0) {
            content()
                .padding(.vertical, Configuration.constants.cardPadding.value * Configuration.constants.cardVPadMultiplier)
                .padding(.horizontal, Configuration.constants.cardPadding.value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        // Без фонов/теней/blur — только обводка
        .overlay(
            RoundedRectangle(cornerRadius: corner)
                .stroke(gradientStroke(), lineWidth: 1)
        )
    }

    private func gradientStroke(opacity: Double = Configuration.constants.cardStrokeOpacity) -> LinearGradient {
        let colors = GradientStyle.primary.colors(for: colorScheme).map { $0.opacity(opacity) }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(AppTypography.title3.font)
            .fontWeight(.semibold)
            .themedForeground(.primary, colorScheme: colorScheme)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Actions
    private func refreshWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        let now = Date()
        lastUpdated = now
        AppGroupManager.saveLastUpdated(now)
    }
}
