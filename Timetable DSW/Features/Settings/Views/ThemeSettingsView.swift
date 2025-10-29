//
//  ThemeSettingsView.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//  Update 24/10/2025:
//  - AppearanceModeCard: gradient background + gradient circle
//  - ThemeCard: gradient outer card bg (name row), full-cell hit area, gradient preview bg + gradient icon
//  - Section titles use gradient foreground (as on Widget screen)
//

import SwiftUI

struct ThemeSettingsView: View {
    // MARK: - Configuration
    struct Configuration: ComponentConfiguration {
        struct Constants {
            // как у WidgetSettingsView
            let hPadding: AppSpacing = .xxxl
            let vPadding: AppSpacing = .large
            let sectionSpacing: AppSpacing = .large
            let sectionSpacingMultiplier: CGFloat = 1.35

            let cardCornerRadius: AppCornerRadius = .large
            let cardPadding: AppSpacing = .medium
            let itemSpacing: AppSpacing = .medium
            let previewHeight: CGFloat = 120
            let previewCornerRadius: AppCornerRadius = .medium
            let selectedBorderWidth: CGFloat = 3
            let normalBorderWidth: CGFloat = 1
            let iconSize: CGFloat = 24
            let gridColumns: Int = 2
            let gridSpacing: CGFloat = 12
            let strokeOpacity: Double = 0.28
            let cardBgOpacity: Double = 0.08
            let circleBgOpacity: Double = 0.20
        }
        static let constants = Constants()
    }

    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.bottomInsetService) private var bottomInsetService

    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(
                spacing: Configuration.constants.sectionSpacing.value * Configuration.constants.sectionSpacingMultiplier
            ) {
                appearanceModeSection

                colorThemeSection
            }
            .padding(.horizontal, Configuration.constants.hPadding.value)
            .padding(.vertical, Configuration.constants.vPadding.value)
        }
        .contentMargins(.top, Configuration.constants.hPadding.value * 2, for: .scrollContent)
        .scrollIndicators(.never) // (1) скрыли индикатор
        .background(AppColor.background.color(for: colorScheme).ignoresSafeArea()) // (2) фон как у виджетов
        .safeAreaInset(edge: .bottom) {
            AppColor.clear.color(for: colorScheme)
                .frame(height: bottomInsetService?.bottomInset ?? 78)
        }
    }

    // MARK: - Sections
    private var appearanceModeSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text(LocalizedString.themeSettingsAppearanceTitle.localized)
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundStyle(primaryGradient())

            VStack(spacing: 12) {
                ForEach(AppearanceMode.allCases) { mode in
                    AppearanceModeCard(
                        mode: mode,
                        isSelected: themeManager.appearanceMode == mode,
                        stroke: gradientStroke(),
                        selectedStrokeWidth: Configuration.constants.selectedBorderWidth,
                        normalStrokeWidth: Configuration.constants.normalBorderWidth,
                        cardBg: primaryGradient(opacity: Configuration.constants.cardBgOpacity),
                        circleBg: LinearGradient(
                            colors: GradientStyle.header
                                .colors(for: colorScheme)
                                .map { $0.opacity(Configuration.constants.circleBgOpacity) },
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        circleIconGradient: LinearGradient(
                            colors: GradientStyle.header.colors(for: colorScheme),
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            themeManager.setAppearanceMode(mode)
                        }
                    }
                }
            }
        }
    }

    private var colorThemeSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text(LocalizedString.themeSettingsColorThemeTitle.localized)
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundStyle(primaryGradient())

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Configuration.constants.gridSpacing), count: Configuration.constants.gridColumns),
                spacing: Configuration.constants.gridSpacing
            ) {
                ForEach(themeManager.allThemes(for: colorScheme), id: \.id) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: themeManager.selectedThemeId == theme.id,
                        stroke: gradientStroke(),
                        selectedStrokeWidth: Configuration.constants.selectedBorderWidth,
                        normalStrokeWidth: Configuration.constants.normalBorderWidth,
                        previewCorner: Configuration.constants.previewCornerRadius.value,
                        previewHeight: Configuration.constants.previewHeight,
                        outerCardBg: primaryGradient(opacity: Configuration.constants.cardBgOpacity),
                        themeIconGradient: LinearGradient(
                            colors: [theme.accent, theme.primary],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            themeManager.selectTheme(theme.id)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    private func primaryGradient(opacity: Double = 1.0) -> LinearGradient {
        LinearGradient(
            colors: GradientStyle.contrastPrimary.colors(for: colorScheme).map { $0.opacity(opacity) },
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    private func gradientStroke(opacity: Double = Configuration.constants.strokeOpacity) -> LinearGradient {
        LinearGradient(
            colors: GradientStyle.primary.colors(for: colorScheme).map { $0.opacity(opacity) },
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
    private func primaryGradient() -> any ShapeStyle { primaryGradient(opacity: 1.0) }
}

// MARK: - Appearance Mode Card
private struct AppearanceModeCard: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let stroke: LinearGradient
    let selectedStrokeWidth: CGFloat
    let normalStrokeWidth: CGFloat
    let cardBg: LinearGradient
    let circleBg: LinearGradient
    let circleIconGradient: LinearGradient
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium.value) {
                ZStack {
                    Circle()
                        .fill(circleBg)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(stroke, lineWidth: normalStrokeWidth))

                    mode.icon.image()
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(circleIconGradient)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.displayName)
                        .font(AppTypography.body.font)
                        .fontWeight(.medium)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    Text(description(for: mode))
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                }

                Spacer()

                if isSelected {
                    AppIcon.checkmarkCircleFill.image()
                        .font(.system(size: 24))
                        .themedForeground(.success, colorScheme: colorScheme)
                }
            }
            .padding(AppSpacing.medium.value)
            .background(
                RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value)
                    .fill(cardBg) // градиентная подложка карточки стиля
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value)
                    .stroke(stroke, lineWidth: isSelected ? selectedStrokeWidth : normalStrokeWidth)
            )
            .contentShape(RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value))
        }
        .buttonStyle(.plain)
    }

    private func description(for mode: AppearanceMode) -> String {
        switch mode {
        case .system: return LocalizedString.appearanceDescSystem.localized
        case .light:  return LocalizedString.appearanceDescLight.localized
        case .dark:   return LocalizedString.appearanceDescDark.localized
        }
    }
}

// MARK: - Theme Card (gradient outer bg, gradient preview bg, full hit area, gradient icon)
private struct ThemeCard: View {
    let theme: any Theme
    let isSelected: Bool
    let stroke: LinearGradient
    let selectedStrokeWidth: CGFloat
    let normalStrokeWidth: CGFloat
    let previewCorner: CGFloat
    let previewHeight: CGFloat
    let outerCardBg: LinearGradient
    let themeIconGradient: LinearGradient
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.small.value) {
                // Preview: градиентный фон + рамка
                ZStack {
                    RoundedRectangle(cornerRadius: previewCorner)
                        .fill(
                            LinearGradient(
                                colors: [theme.primary, theme.secondary, theme.tertiary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: previewCorner)
                                .stroke(stroke, lineWidth: isSelected ? selectedStrokeWidth : normalStrokeWidth)
                        )

                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Circle().fill(theme.lectureStart).frame(width: 16, height: 16)
                            Circle().fill(theme.exerciseStart).frame(width: 16, height: 16)
                            Circle().fill(theme.laboratoryStart).frame(width: 16, height: 16)
                        }

                        // Иконка темы с градиентной заливкой
                        theme.icon.image()
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(themeIconGradient)
                    }
                }
                .frame(height: previewHeight)

                // Название темы + маркер выбора
                HStack(spacing: 6) {
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
            // Фон внешней карточки темы — градиент (как просили)
            .background(
                RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value)
                    .fill(outerCardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value)
                    .stroke(stroke, lineWidth: isSelected ? selectedStrokeWidth : normalStrokeWidth)
            )
            // Тап по всей ячейке (включая паддинги)
            .contentShape(RoundedRectangle(cornerRadius: ThemeSettingsView.Configuration.constants.cardCornerRadius.value))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ThemeSettingsView()
}
