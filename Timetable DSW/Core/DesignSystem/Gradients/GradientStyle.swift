//
//  GradientStyle.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

enum GradientStyle {
    case primary
    case contrastPrimary
    case secondary
    case accent
    case success
    case warning
    case error
    case lecture
    case exercise
    case laboratory
    case header
    case online
    case cancelled

    func colors(for scheme: ColorScheme, theme: (any Theme)? = nil) -> [Color] {
        let currentTheme = theme ?? ThemeManager.shared.currentTheme(for: scheme)
        let opacity1: Double = scheme == .dark ? 0.9 : 0.9
        let opacity2: Double = scheme == .dark ? 0.7 : 0.6

        switch self {
        case .primary:
            return [
                currentTheme.primary,
                currentTheme.secondary.opacity(opacity2),
                currentTheme.tertiary.opacity(0.8)
            ]
        case .contrastPrimary:
            return [
                currentTheme.primary,
                currentTheme.secondary,
                currentTheme.tertiary,
            ]

        case .secondary:
            return [
                currentTheme.secondary.opacity(opacity1),
                currentTheme.tertiary.opacity(opacity2)
            ]

        case .accent:
            return [
                currentTheme.accent.opacity(opacity1),
                currentTheme.primary.opacity(opacity2)
            ]

        case .success:
            return [
                currentTheme.success.opacity(opacity1),
                currentTheme.info.opacity(opacity2)
            ]

        case .warning:
            return [
                currentTheme.warning.opacity(opacity1),
                currentTheme.error.opacity(opacity2)
            ]

        case .error:
            return [
                currentTheme.error.opacity(opacity1),
                currentTheme.warning.opacity(opacity2)
            ]

        case .lecture:
            return [
                currentTheme.lectureStart.opacity(opacity1),
                currentTheme.lectureEnd.opacity(opacity2)
            ]

        case .exercise:
            return [
                currentTheme.exerciseStart.opacity(opacity1),
                currentTheme.exerciseEnd.opacity(opacity2)
            ]

        case .laboratory:
            return [
                currentTheme.laboratoryStart.opacity(opacity1),
                currentTheme.laboratoryEnd.opacity(opacity2)
            ]

        case .header:
            return scheme == .dark
                ? [currentTheme.primary, currentTheme.secondary.opacity(opacity2)]
                : [currentTheme.accent, currentTheme.primary.opacity(opacity2)]

        case .online:
            return [
                currentTheme.online.opacity(0.95),
                currentTheme.warning.opacity(opacity2)
            ]

        case .cancelled:
            return [
                currentTheme.cancelled.opacity(0.95),
                currentTheme.cancelled.opacity(0.85)
            ]
        }
    }

    func linearGradient(
        for scheme: ColorScheme,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing,
        theme: (any Theme)? = nil
    ) -> LinearGradient {
        LinearGradient(
            colors: colors(for: scheme, theme: theme),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// MARK: - View Extension
extension View {
    func themedForeground(_ style: GradientStyle, colorScheme: ColorScheme, theme: (any Theme)? = nil) -> some View {
        self.foregroundStyle(
            LinearGradient(
                colors: style.colors(for: colorScheme, theme: theme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
