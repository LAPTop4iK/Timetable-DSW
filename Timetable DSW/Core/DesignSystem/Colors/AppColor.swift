//
//  AppColor.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

enum AppColor {
    // MARK: - Text Colors
    case primaryText
    case secondaryText
    case tertiaryText
    case quaternaryText

    // MARK: - Background Colors
    case background
    case secondaryBackground
    case tertiaryBackground

    // MARK: - Theme Colors
    case themePrimary
    case themeSecondary
    case themeTertiary
    case themeAccent

    // MARK: - Status Colors
    case success
    case warning
    case error
    case info

    // MARK: - Basic Colors
    case white
    case black
    case clear
    case green
    case orange
    case red
    case blue
    case purple
    case pink
    case cyan

    // MARK: - Custom
    case custom(Color, opacity: Double)

    // MARK: - Method
    func color(for scheme: ColorScheme, theme: (any Theme)? = nil) -> Color {
        let currentTheme = theme ?? ThemeManager.shared.currentTheme(for: scheme)

        switch self {
        case .primaryText:
            return .primary
        case .secondaryText:
            return .secondary
        case .tertiaryText:
            return scheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.5)
        case .quaternaryText:
            return scheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.3)

        case .background:
            return Color(.systemBackground)
        case .secondaryBackground:
            return Color(.secondarySystemBackground)
        case .tertiaryBackground:
            return Color(.tertiarySystemBackground)

        case .themePrimary:
            return currentTheme.primary
        case .themeSecondary:
            return currentTheme.secondary
        case .themeTertiary:
            return currentTheme.tertiary
        case .themeAccent:
            return currentTheme.accent

        case .success:
            return currentTheme.success
        case .warning:
            return currentTheme.warning
        case .error:
            return currentTheme.error
        case .info:
            return currentTheme.info

        case .white:
            return .white
        case .black:
            return .black
        case .clear:
            return .clear
        case .green:
            return .green
        case .orange:
            return .orange
        case .red:
            return .red
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .cyan:
            return .cyan

        case .custom(let color, let opacity):
            return color.opacity(opacity)
        }
    }
}

// MARK: - View Extension
extension View {
    func foregroundAppColor(_ appColor: AppColor, colorScheme: ColorScheme, theme: (any Theme)? = nil) -> some View {
        self.foregroundColor(appColor.color(for: colorScheme, theme: theme))
    }
}