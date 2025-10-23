//
//  AppTheme.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

// MARK: - Theme Protocol

protocol Theme {
    var id: String { get }
    var name: String { get }
    var icon: String { get }

    // Primary colors
    var primary: Color { get }
    var secondary: Color { get }
    var tertiary: Color { get }
    var accent: Color { get }

    // Event type colors
    var lectureStart: Color { get }
    var lectureEnd: Color { get }
    var exerciseStart: Color { get }
    var exerciseEnd: Color { get }
    var laboratoryStart: Color { get }
    var laboratoryEnd: Color { get }

    // Status colors
    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
    var info: Color { get }

    // Special states
    var online: Color { get }
    var cancelled: Color { get }
}

// MARK: - Default Theme (Original Purple/Pink)

struct DefaultTheme: Theme {
    let id = "default"
    let name = "Default"
    let icon = "sparkles"
    let isDark: Bool

    var primary: Color { isDark ? Color.purple.opacity(0.9) : Color.pink.opacity(0.9) }
    var secondary: Color { isDark ? Color.blue.opacity(0.7) : Color.purple.opacity(0.7) }
    var tertiary: Color { isDark ? Color.pink.opacity(0.8) : Color.blue.opacity(0.6) }
    var accent: Color { isDark ? Color.purple : Color.pink }

    var lectureStart: Color { Color.orange.opacity(0.9) }
    var lectureEnd: Color { Color.red.opacity(isDark ? 0.7 : 0.6) }
    var exerciseStart: Color { Color.blue.opacity(0.9) }
    var exerciseEnd: Color { Color.cyan.opacity(isDark ? 0.7 : 0.6) }
    var laboratoryStart: Color { Color.purple.opacity(0.9) }
    var laboratoryEnd: Color { Color.pink.opacity(isDark ? 0.7 : 0.6) }

    var success: Color { .green }
    var warning: Color { .orange }
    var error: Color { .red }
    var info: Color { .blue }

    var online: Color { Color.yellow.opacity(0.95) }
    var cancelled: Color { isDark ? Color(red: 0.90, green: 0.12, blue: 0.22) : Color(red: 0.95, green: 0.22, blue: 0.30) }
}

// MARK: - Ocean Theme

struct OceanTheme: Theme {
    let id = "ocean"
    let name = "Ocean"
    let icon = "water.waves"
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.2, green: 0.6, blue: 0.86) : Color(red: 0.0, green: 0.48, blue: 0.8) }
    var secondary: Color { isDark ? Color(red: 0.0, green: 0.7, blue: 0.8) : Color(red: 0.0, green: 0.55, blue: 0.65) }
    var tertiary: Color { isDark ? Color(red: 0.1, green: 0.4, blue: 0.7) : Color(red: 0.0, green: 0.35, blue: 0.6) }
    var accent: Color { isDark ? Color.cyan : Color.teal }

    var lectureStart: Color { Color(red: 0.0, green: 0.6, blue: 0.8) }
    var lectureEnd: Color { Color(red: 0.0, green: 0.4, blue: 0.6) }
    var exerciseStart: Color { Color(red: 0.2, green: 0.7, blue: 0.9) }
    var exerciseEnd: Color { Color.cyan }
    var laboratoryStart: Color { Color.teal }
    var laboratoryEnd: Color { Color(red: 0.0, green: 0.55, blue: 0.65) }

    var success: Color { Color(red: 0.0, green: 0.75, blue: 0.65) }
    var warning: Color { Color(red: 1.0, green: 0.7, blue: 0.0) }
    var error: Color { Color(red: 0.9, green: 0.3, blue: 0.3) }
    var info: Color { Color.cyan }

    var online: Color { Color(red: 0.4, green: 0.85, blue: 0.95) }
    var cancelled: Color { Color(red: 0.4, green: 0.5, blue: 0.6) }
}

// MARK: - Sunset Theme

struct SunsetTheme: Theme {
    let id = "sunset"
    let name = "Sunset"
    let icon = "sunset.fill"
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 1.0, green: 0.45, blue: 0.35) : Color(red: 0.95, green: 0.3, blue: 0.2) }
    var secondary: Color { isDark ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 0.9, green: 0.5, blue: 0.1) }
    var tertiary: Color { isDark ? Color(red: 0.9, green: 0.35, blue: 0.5) : Color(red: 0.85, green: 0.25, blue: 0.4) }
    var accent: Color { isDark ? Color.orange : Color(red: 1.0, green: 0.3, blue: 0.3) }

    var lectureStart: Color { Color(red: 1.0, green: 0.5, blue: 0.2) }
    var lectureEnd: Color { Color(red: 0.95, green: 0.3, blue: 0.3) }
    var exerciseStart: Color { Color(red: 1.0, green: 0.65, blue: 0.3) }
    var exerciseEnd: Color { Color(red: 0.9, green: 0.45, blue: 0.2) }
    var laboratoryStart: Color { Color(red: 0.9, green: 0.35, blue: 0.5) }
    var laboratoryEnd: Color { Color(red: 0.8, green: 0.2, blue: 0.4) }

    var success: Color { Color(red: 1.0, green: 0.7, blue: 0.2) }
    var warning: Color { Color(red: 1.0, green: 0.55, blue: 0.1) }
    var error: Color { Color(red: 0.9, green: 0.2, blue: 0.2) }
    var info: Color { Color(red: 1.0, green: 0.6, blue: 0.3) }

    var online: Color { Color(red: 1.0, green: 0.75, blue: 0.3) }
    var cancelled: Color { Color(red: 0.6, green: 0.3, blue: 0.3) }
}

// MARK: - Forest Theme

struct ForestTheme: Theme {
    let id = "forest"
    let name = "Forest"
    let icon = "leaf.fill"
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.4, green: 0.75, blue: 0.45) : Color(red: 0.2, green: 0.65, blue: 0.3) }
    var secondary: Color { isDark ? Color(red: 0.5, green: 0.85, blue: 0.6) : Color(red: 0.3, green: 0.75, blue: 0.4) }
    var tertiary: Color { isDark ? Color(red: 0.3, green: 0.6, blue: 0.4) : Color(red: 0.15, green: 0.5, blue: 0.25) }
    var accent: Color { isDark ? Color.mint : Color.green }

    var lectureStart: Color { Color(red: 0.6, green: 0.8, blue: 0.3) }
    var lectureEnd: Color { Color(red: 0.4, green: 0.7, blue: 0.2) }
    var exerciseStart: Color { Color(red: 0.3, green: 0.75, blue: 0.5) }
    var exerciseEnd: Color { Color(red: 0.2, green: 0.6, blue: 0.4) }
    var laboratoryStart: Color { Color(red: 0.45, green: 0.85, blue: 0.6) }
    var laboratoryEnd: Color { Color.mint }

    var success: Color { Color(red: 0.3, green: 0.8, blue: 0.4) }
    var warning: Color { Color(red: 0.9, green: 0.75, blue: 0.2) }
    var error: Color { Color(red: 0.85, green: 0.35, blue: 0.3) }
    var info: Color { Color(red: 0.4, green: 0.75, blue: 0.5) }

    var online: Color { Color(red: 0.7, green: 0.9, blue: 0.4) }
    var cancelled: Color { Color(red: 0.5, green: 0.55, blue: 0.5) }
}

// MARK: - Lavender Theme

struct LavenderTheme: Theme {
    let id = "lavender"
    let name = "Lavender"
    let icon = "sparkle"
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.7, green: 0.6, blue: 0.9) : Color(red: 0.6, green: 0.45, blue: 0.8) }
    var secondary: Color { isDark ? Color(red: 0.8, green: 0.7, blue: 0.95) : Color(red: 0.7, green: 0.55, blue: 0.85) }
    var tertiary: Color { isDark ? Color(red: 0.6, green: 0.5, blue: 0.8) : Color(red: 0.5, green: 0.35, blue: 0.7) }
    var accent: Color { isDark ? Color(red: 0.75, green: 0.65, blue: 0.95) : Color(red: 0.65, green: 0.5, blue: 0.85) }

    var lectureStart: Color { Color(red: 0.8, green: 0.6, blue: 0.9) }
    var lectureEnd: Color { Color(red: 0.65, green: 0.45, blue: 0.8) }
    var exerciseStart: Color { Color(red: 0.7, green: 0.65, blue: 0.95) }
    var exerciseEnd: Color { Color(red: 0.6, green: 0.55, blue: 0.85) }
    var laboratoryStart: Color { Color(red: 0.75, green: 0.5, blue: 0.85) }
    var laboratoryEnd: Color { Color(red: 0.65, green: 0.4, blue: 0.75) }

    var success: Color { Color(red: 0.6, green: 0.8, blue: 0.7) }
    var warning: Color { Color(red: 0.9, green: 0.7, blue: 0.5) }
    var error: Color { Color(red: 0.9, green: 0.4, blue: 0.5) }
    var info: Color { Color(red: 0.7, green: 0.6, blue: 0.9) }

    var online: Color { Color(red: 0.85, green: 0.75, blue: 0.95) }
    var cancelled: Color { Color(red: 0.6, green: 0.55, blue: 0.7) }
}

// MARK: - Cherry Blossom Theme

struct CherryBlossomTheme: Theme {
    let id = "cherry"
    let name = "Cherry Blossom"
    let icon = "heart.fill"
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 1.0, green: 0.7, blue: 0.8) : Color(red: 0.95, green: 0.5, blue: 0.65) }
    var secondary: Color { isDark ? Color(red: 0.95, green: 0.6, blue: 0.75) : Color(red: 0.9, green: 0.4, blue: 0.6) }
    var tertiary: Color { isDark ? Color(red: 0.9, green: 0.5, blue: 0.7) : Color(red: 0.85, green: 0.35, blue: 0.55) }
    var accent: Color { isDark ? Color.pink : Color(red: 0.95, green: 0.4, blue: 0.6) }

    var lectureStart: Color { Color(red: 1.0, green: 0.65, blue: 0.75) }
    var lectureEnd: Color { Color(red: 0.9, green: 0.45, blue: 0.6) }
    var exerciseStart: Color { Color(red: 0.95, green: 0.75, blue: 0.85) }
    var exerciseEnd: Color { Color(red: 0.85, green: 0.55, blue: 0.7) }
    var laboratoryStart: Color { Color(red: 0.9, green: 0.6, blue: 0.8) }
    var laboratoryEnd: Color { Color(red: 0.8, green: 0.4, blue: 0.65) }

    var success: Color { Color(red: 0.9, green: 0.75, blue: 0.8) }
    var warning: Color { Color(red: 1.0, green: 0.75, blue: 0.6) }
    var error: Color { Color(red: 0.95, green: 0.35, blue: 0.45) }
    var info: Color { Color(red: 0.95, green: 0.7, blue: 0.85) }

    var online: Color { Color(red: 1.0, green: 0.8, blue: 0.9) }
    var cancelled: Color { Color(red: 0.7, green: 0.5, blue: 0.6) }
}

// MARK: - Midnight Theme

struct MidnightTheme: Theme {
    let id = "midnight"
    let name = "Midnight"
    let icon = "moon.stars.fill"
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.4, green: 0.5, blue: 0.9) : Color(red: 0.25, green: 0.35, blue: 0.75) }
    var secondary: Color { isDark ? Color(red: 0.5, green: 0.4, blue: 0.85) : Color(red: 0.35, green: 0.25, blue: 0.7) }
    var tertiary: Color { isDark ? Color(red: 0.3, green: 0.45, blue: 0.8) : Color(red: 0.2, green: 0.3, blue: 0.65) }
    var accent: Color { isDark ? Color.indigo : Color(red: 0.3, green: 0.4, blue: 0.8) }

    var lectureStart: Color { Color(red: 0.45, green: 0.55, blue: 0.95) }
    var lectureEnd: Color { Color(red: 0.3, green: 0.4, blue: 0.8) }
    var exerciseStart: Color { Color(red: 0.5, green: 0.45, blue: 0.9) }
    var exerciseEnd: Color { Color(red: 0.35, green: 0.3, blue: 0.75) }
    var laboratoryStart: Color { Color(red: 0.4, green: 0.5, blue: 0.85) }
    var laboratoryEnd: Color { Color.indigo }

    var success: Color { Color(red: 0.4, green: 0.7, blue: 0.9) }
    var warning: Color { Color(red: 0.8, green: 0.65, blue: 0.4) }
    var error: Color { Color(red: 0.85, green: 0.4, blue: 0.5) }
    var info: Color { Color(red: 0.5, green: 0.6, blue: 0.95) }

    var online: Color { Color(red: 0.6, green: 0.7, blue: 1.0) }
    var cancelled: Color { Color(red: 0.4, green: 0.45, blue: 0.6) }
}

// MARK: - Theme Factory

struct ThemeFactory {
    static func allThemes(for colorScheme: ColorScheme) -> [any Theme] {
        let isDark = colorScheme == .dark
        return [
            DefaultTheme(isDark: isDark),
            OceanTheme(isDark: isDark),
            SunsetTheme(isDark: isDark),
            ForestTheme(isDark: isDark),
            LavenderTheme(isDark: isDark),
            CherryBlossomTheme(isDark: isDark),
            MidnightTheme(isDark: isDark)
        ]
    }

    static func theme(withId id: String, for colorScheme: ColorScheme) -> any Theme {
        let isDark = colorScheme == .dark
        switch id {
        case "ocean": return OceanTheme(isDark: isDark)
        case "sunset": return SunsetTheme(isDark: isDark)
        case "forest": return ForestTheme(isDark: isDark)
        case "lavender": return LavenderTheme(isDark: isDark)
        case "cherry": return CherryBlossomTheme(isDark: isDark)
        case "midnight": return MidnightTheme(isDark: isDark)
        default: return DefaultTheme(isDark: isDark)
        }
    }
}
