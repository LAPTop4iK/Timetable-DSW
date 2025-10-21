//
//  GradientStyle.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

enum GradientStyle {
    case primary
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

    func colors(for scheme: ColorScheme) -> [Color] {
        switch self {
        case .primary:
            return scheme == .dark
                ? [Color.purple.opacity(0.9), Color.blue.opacity(0.7), Color.pink.opacity(0.8)]
                : [Color.pink.opacity(0.9), Color.purple.opacity(0.8), Color.blue.opacity(0.6)]

        case .secondary:
            return scheme == .dark
                ? [Color.blue.opacity(0.9), Color.cyan.opacity(0.7)]
                : [Color.blue.opacity(0.9), Color.cyan.opacity(0.6)]

        case .accent:
            return scheme == .dark
                ? [Color.purple.opacity(0.9), Color.pink.opacity(0.7)]
                : [Color.purple.opacity(0.9), Color.pink.opacity(0.6)]

        case .success:
            return scheme == .dark
                ? [Color.green.opacity(0.9), Color.cyan.opacity(0.7)]
                : [Color.green.opacity(0.9), Color.cyan.opacity(0.6)]

        case .warning:
            return [Color.orange.opacity(0.9), Color.red.opacity(0.7)]

        case .error:
            return [Color.orange.opacity(0.9), Color.red.opacity(0.7)]

        case .lecture:
            return scheme == .dark
                ? [Color.orange.opacity(0.9), Color.red.opacity(0.7)]
                : [Color.orange.opacity(0.9), Color.red.opacity(0.6)]

        case .exercise:
            return scheme == .dark
                ? [Color.blue.opacity(0.9), Color.cyan.opacity(0.7)]
                : [Color.blue.opacity(0.9), Color.cyan.opacity(0.6)]

        case .laboratory:
            return scheme == .dark
                ? [Color.purple.opacity(0.9), Color.pink.opacity(0.7)]
                : [Color.purple.opacity(0.9), Color.pink.opacity(0.6)]

        case .header:
            return scheme == .dark
                ? [Color.purple.opacity(0.9), Color.blue.opacity(0.7)]
                : [Color.pink.opacity(0.9), Color.purple.opacity(0.7)]

        case .online:
            return scheme == .dark
                ? [Color.yellow.opacity(0.95), Color.orange.opacity(0.7)]
                : [Color.yellow.opacity(0.95), Color.orange.opacity(0.6)]

        case .cancelled:
            return scheme == .dark
            ? [Color(red: 0.90, green: 0.12, blue: 0.22).opacity(0.95), Color(red: 0.40, green: 0.00, blue: 0.12).opacity(0.85)]
            : [Color(red: 0.95, green: 0.22, blue: 0.30).opacity(0.95), Color(red: 0.65, green: 0.00, blue: 0.18).opacity(0.70)]
        }
    }

    func linearGradient(
        for scheme: ColorScheme,
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> LinearGradient {
        LinearGradient(
            colors: colors(for: scheme),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// MARK: - View Extension
extension View {
    func themedForeground(_ style: GradientStyle, colorScheme: ColorScheme) -> some View {
        self.foregroundStyle(
            LinearGradient(
                colors: style.colors(for: colorScheme),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
