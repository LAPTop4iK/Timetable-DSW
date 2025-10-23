//
//  ThemeSettingsView.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

struct ThemeSettingsView: View {
    // MARK: - Configuration

    struct Configuration: ComponentConfiguration {
        struct Constants {
            let cardCornerRadius: AppCornerRadius = .large
            let cardPadding: AppSpacing = .medium
            let sectionSpacing: AppSpacing = .xl
            let itemSpacing: AppSpacing = .medium
            let previewHeight: CGFloat = 120
            let previewCornerRadius: AppCornerRadius = .medium
            let selectedBorderWidth: CGFloat = 3
            let iconSize: CGFloat = 24
            let titleSize: CGFloat = 16
            let gridColumns: Int = 2
            let gridSpacing: CGFloat = 12
        }
        static let constants = Constants()
    }

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.bottomInsetService) private var bottomInsetService

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Configuration.constants.sectionSpacing.value) {
                appearanceModeSection
                colorThemeSection
            }
            .padding()
        }
        .background(AppColor.background.color(for: colorScheme))
        .navigationTitle(LocalizedString.themeSettingsTitle.localized)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            AppColor.clear.color(for: colorScheme)
                .frame(height: bottomInsetService?.bottomInset ?? 78)
        }
    }

    // MARK: - Appearance Mode Section

    private var appearanceModeSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text(LocalizedString.themeSettingsAppearanceTitle.localized)
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)

            VStack(spacing: 12) {
                ForEach(AppearanceMode.allCases) { mode in
                    AppearanceModeCard(
                        mode: mode,
                        isSelected: themeManager.appearanceMode == mode,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                themeManager.setAppearanceMode(mode)
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Color Theme Section

    private var colorThemeSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text(LocalizedString.themeSettingsColorThemeTitle.localized)
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Configuration.constants.gridSpacing), count: Configuration.constants.gridColumns),
                spacing: Configuration.constants.gridSpacing
            ) {
                ForEach(themeManager.allThemes(for: colorScheme), id: \.id) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: themeManager.selectedThemeId == theme.id,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                themeManager.selectTheme(theme.id)
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Appearance Mode Card

private struct AppearanceModeCard: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium.value) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: GradientStyle.header.colors(for: colorScheme).map { $0.opacity(0.15) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    mode.icon.image()
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: GradientStyle.header.colors(for: colorScheme),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.displayName)
                        .font(AppTypography.body.font)
                        .fontWeight(.medium)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    Text(modeDescription)
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                }

                Spacer()

                if isSelected {
                    AppIcon.checkmarkCircleFill.image()
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: GradientStyle.success.colors(for: colorScheme),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .padding(AppSpacing.medium.value)
            .background(
                RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value)
                    .fill(AppColor.secondaryBackground.color(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value)
                    .strokeBorder(
                        isSelected
                            ? LinearGradient(
                                colors: GradientStyle.success.colors(for: colorScheme),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: ThemeSettingsView.Configuration.constants.selectedBorderWidth
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var modeDescription: String {
        switch mode {
        case .system: return LocalizedString.appearanceDescSystem.localized
        case .light:  return LocalizedString.appearanceDescLight.localized
        case .dark:   return LocalizedString.appearanceDescDark.localized
        }
    }
}

// MARK: - Theme Card

private struct ThemeCard: View {
    let theme: any Theme
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.small.value) {
                // Preview
                ZStack {
                    RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.previewCornerRadius.value)
                        .fill(
                            LinearGradient(
                                colors: [theme.primary, theme.secondary, theme.tertiary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(theme.lectureStart)
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(theme.exerciseStart)
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(theme.laboratoryStart)
                                .frame(width: 16, height: 16)
                        }

                        theme.icon.image()
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(height: ThemeSettingsView.Configuration.constants.previewHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.previewCornerRadius.value)
                        .strokeBorder(
                            isSelected
                                ? LinearGradient(
                                    colors: [theme.accent, theme.primary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                            lineWidth: ThemeSettingsView.Configuration.constants.selectedBorderWidth
                        )
                )

                // Localized Name
                HStack {
                    Text(LocalizedString.themeName(for: theme.id))
                        .font(AppTypography.body.font)
                        .fontWeight(isSelected ? .semibold : .medium)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    if isSelected {
                        AppIcon.checkmarkCircleFill.image()
                            .font(.system(size: 16))
                            .foregroundColor(theme.success)
                    }
                }
            }
            .padding(AppSpacing.small.value)
            .background(
                RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value)
                    .fill(AppColor.secondaryBackground.color(for: colorScheme))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ThemeSettingsView()
}
