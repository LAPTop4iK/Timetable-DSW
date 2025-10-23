//
//  AppTheme.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

enum ThemeConst {
    enum id {
        static let `default`   = "default"
        static let ocean       = "ocean"
        static let sunset      = "sunset"
        static let forest      = "forest"
        static let lavender    = "lavender"
        static let cherry      = "cherry"
        static let midnight    = "midnight"
        static let monochrome  = "monochrome"
    }

    /// Технические имена тем (могут использоваться как fallback/отладка).
    /// Для UI мы показываем локализованное имя через `LocalizedString.themeName(for:)`.
    enum name {
        static let `default`   = "Default"
        static let ocean       = "Ocean"
        static let sunset      = "Sunset"
        static let forest      = "Forest"
        static let lavender    = "Lavender"
        static let cherry      = "Cherry Blossom"
        static let midnight    = "Midnight"
        static let monochrome  = "Monochrome"
    }
}

// MARK: - Theme Protocol

protocol Theme {
    var id: String { get }
    var name: String { get }      // техническое имя (для логов / fallback)
    var icon: AppIcon { get }     // системная иконка через AppIcon
    var isDark: Bool { get }

    var primary: Color { get }
    var secondary: Color { get }
    var tertiary: Color { get }
    var accent: Color { get }

    var lectureStart: Color { get }
    var lectureEnd: Color { get }
    var exerciseStart: Color { get }
    var exerciseEnd: Color { get }
    var laboratoryStart: Color { get }
    var laboratoryEnd: Color { get }

    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
    var info: Color { get }

    var online: Color { get }
    var cancelled: Color { get }
}

// MARK: - Default Theme

struct DefaultTheme: Theme {
    let id = ThemeConst.id.default
    let name = ThemeConst.name.default
    let icon: AppIcon = .sparkles
    let isDark: Bool

    var primary: Color { isDark ? Color.purple.opacity(0.9) : Color.pink.opacity(0.9) }
    var secondary: Color { isDark ? Color.blue.opacity(0.7) : Color.purple.opacity(0.7) }
    var tertiary: Color { isDark ? Color.pink.opacity(0.8) : Color.blue.opacity(0.6) }
    var accent: Color { isDark ? Color.purple : Color.pink }

    var lectureStart: Color { Color(red: 1.0, green: 0.5, blue: 0.0) }
    var lectureEnd: Color { Color(red: 0.9, green: 0.2, blue: 0.1) }
    var exerciseStart: Color { Color(red: 0.1, green: 0.6, blue: 1.0) }
    var exerciseEnd: Color { Color(red: 0.0, green: 0.8, blue: 0.9) }
    var laboratoryStart: Color { Color(red: 0.7, green: 0.2, blue: 0.9) }
    var laboratoryEnd: Color { Color(red: 0.9, green: 0.3, blue: 0.7) }

    var success: Color { Color(red: 0.18, green: 0.78, blue: 0.70) }
    var warning: Color { .orange }
    var error: Color { .red }
    var info: Color { Color(red: 0.40, green: 0.45, blue: 0.95) }

    var online: Color { isDark ? Color(red: 1.0, green: 0.85, blue: 0.2) : Color(red: 1.0, green: 0.75, blue: 0.0) }
    var cancelled: Color { isDark ? Color(red: 0.95, green: 0.2, blue: 0.25) : Color(red: 0.9, green: 0.15, blue: 0.2) }
}

// MARK: - Ocean Theme

struct OceanTheme: Theme {
    let id = ThemeConst.id.ocean
    let name = ThemeConst.name.ocean
    let icon: AppIcon = .waterWaves
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.2, green: 0.6, blue: 0.86) : Color(red: 0.0, green: 0.48, blue: 0.8) }
    var secondary: Color { isDark ? Color(red: 0.0, green: 0.7, blue: 0.8) : Color(red: 0.0, green: 0.55, blue: 0.65) }
    var tertiary: Color { isDark ? Color(red: 0.1, green: 0.4, blue: 0.7) : Color(red: 0.0, green: 0.35, blue: 0.6) }
    var accent: Color { isDark ? Color.cyan : Color.teal }

    var lectureStart: Color { Color(red: 1.0, green: 0.6, blue: 0.2) }
    var lectureEnd: Color { Color(red: 0.9, green: 0.3, blue: 0.2) }
    var exerciseStart: Color { Color(red: 0.0, green: 0.7, blue: 1.0) }
    var exerciseEnd: Color { Color(red: 0.2, green: 0.9, blue: 1.0) }
    var laboratoryStart: Color { Color(red: 0.1, green: 0.5, blue: 0.7) }
    var laboratoryEnd: Color { Color(red: 0.0, green: 0.65, blue: 0.8) }

    var success: Color { Color(red: 0.0, green: 0.75, blue: 0.65) }
    var warning: Color { Color(red: 1.0, green: 0.7, blue: 0.0) }
    var error: Color { Color(red: 0.9, green: 0.3, blue: 0.3) }
    var info: Color { Color.cyan }

    var online: Color { isDark ? Color(red: 1.0, green: 0.9, blue: 0.3) : Color(red: 1.0, green: 0.8, blue: 0.1) }
    var cancelled: Color { isDark ? Color(red: 0.95, green: 0.25, blue: 0.3) : Color(red: 0.9, green: 0.2, blue: 0.25) }
}

// MARK: - Sunset Theme

struct SunsetTheme: Theme {
    let id = ThemeConst.id.sunset
    let name = ThemeConst.name.sunset
    let icon: AppIcon = .sunsetFill
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 1.0, green: 0.45, blue: 0.35) : Color(red: 0.95, green: 0.3, blue: 0.2) }
    var secondary: Color { isDark ? Color(red: 1.0, green: 0.6, blue: 0.2) : Color(red: 0.9, green: 0.5, blue: 0.1) }
    var tertiary: Color { isDark ? Color(red: 0.9, green: 0.35, blue: 0.5) : Color(red: 0.85, green: 0.25, blue: 0.4) }
    var accent: Color { isDark ? Color.orange : Color(red: 1.0, green: 0.3, blue: 0.3) }

    var lectureStart: Color { Color(red: 1.0, green: 0.4, blue: 0.0) }
    var lectureEnd: Color { Color(red: 0.95, green: 0.15, blue: 0.1) }
    var exerciseStart: Color { Color(red: 1.0, green: 0.75, blue: 0.2) }
    var exerciseEnd: Color { Color(red: 1.0, green: 0.55, blue: 0.0) }
    var laboratoryStart: Color { Color(red: 0.9, green: 0.2, blue: 0.5) }
    var laboratoryEnd: Color { Color(red: 0.75, green: 0.1, blue: 0.35) }

    var success: Color { Color(red: 1.0, green: 0.7, blue: 0.2) }
    var warning: Color { Color(red: 1.0, green: 0.55, blue: 0.1) }
    var error: Color { Color(red: 0.9, green: 0.2, blue: 0.2) }
    var info: Color { Color(red: 1.0, green: 0.6, blue: 0.3) }

    var online: Color { isDark ? Color(red: 1.0, green: 0.85, blue: 0.25) : Color(red: 1.0, green: 0.75, blue: 0.1) }
    var cancelled: Color { isDark ? Color(red: 0.95, green: 0.15, blue: 0.2) : Color(red: 0.9, green: 0.1, blue: 0.15) }
}

// MARK: - Forest Theme

struct ForestTheme: Theme {
    let id = ThemeConst.id.forest
    let name = ThemeConst.name.forest
    let icon: AppIcon = .leafFill
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.4, green: 0.75, blue: 0.45) : Color(red: 0.2, green: 0.65, blue: 0.3) }
    var secondary: Color { isDark ? Color(red: 0.5, green: 0.85, blue: 0.6) : Color(red: 0.3, green: 0.75, blue: 0.4) }
    var tertiary: Color { isDark ? Color(red: 0.3, green: 0.6, blue: 0.4) : Color(red: 0.15, green: 0.5, blue: 0.25) }
    var accent: Color { isDark ? Color.mint : Color.green }

    var lectureStart: Color { Color(red: 0.8, green: 0.7, blue: 0.2) }
    var lectureEnd: Color { Color(red: 0.6, green: 0.5, blue: 0.1) }
    var exerciseStart: Color { Color(red: 0.2, green: 0.6, blue: 0.5) }
    var exerciseEnd: Color { Color(red: 0.1, green: 0.5, blue: 0.4) }
    var laboratoryStart: Color { Color(red: 0.5, green: 0.8, blue: 0.3) }
    var laboratoryEnd: Color { Color(red: 0.3, green: 0.7, blue: 0.2) }

    var success: Color { Color(red: 0.3, green: 0.8, blue: 0.4) }
    var warning: Color { Color(red: 0.9, green: 0.75, blue: 0.2) }
    var error: Color { Color(red: 0.85, green: 0.35, blue: 0.3) }
    var info: Color { Color(red: 0.4, green: 0.75, blue: 0.5) }

    var online: Color { isDark ? Color(red: 1.0, green: 0.9, blue: 0.2) : Color(red: 1.0, green: 0.8, blue: 0.0) }
    var cancelled: Color { isDark ? Color(red: 0.9, green: 0.2, blue: 0.25) : Color(red: 0.85, green: 0.15, blue: 0.2) }
}

// MARK: - Lavender Theme

struct LavenderTheme: Theme {
    let id = ThemeConst.id.lavender
    let name = ThemeConst.name.lavender
    let icon: AppIcon = .sparkle
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.7, green: 0.6, blue: 0.9) : Color(red: 0.6, green: 0.45, blue: 0.8) }
    var secondary: Color { isDark ? Color(red: 0.8, green: 0.7, blue: 0.95) : Color(red: 0.7, green: 0.55, blue: 0.85) }
    var tertiary: Color { isDark ? Color(red: 0.6, green: 0.5, blue: 0.8) : Color(red: 0.5, green: 0.35, blue: 0.7) }
    var accent: Color { isDark ? Color(red: 0.75, green: 0.65, blue: 0.95) : Color(red: 0.65, green: 0.5, blue: 0.85) }

    var lectureStart: Color { Color(red: 0.5, green: 0.3, blue: 0.9) }
    var lectureEnd: Color { Color(red: 0.4, green: 0.2, blue: 0.75) }
    var exerciseStart: Color { Color(red: 0.7, green: 0.5, blue: 1.0) }
    var exerciseEnd: Color { Color(red: 0.6, green: 0.4, blue: 0.9) }
    var laboratoryStart: Color { Color(red: 0.85, green: 0.4, blue: 0.9) }
    var laboratoryEnd: Color { Color(red: 0.75, green: 0.3, blue: 0.8) }

    var success: Color { Color(red: 0.6, green: 0.8, blue: 0.7) }
    var warning: Color { Color(red: 0.9, green: 0.7, blue: 0.5) }
    var error: Color { Color(red: 0.9, green: 0.4, blue: 0.5) }
    var info: Color { Color(red: 0.7, green: 0.6, blue: 0.9) }

    var online: Color { isDark ? Color(red: 1.0, green: 0.9, blue: 0.3) : Color(red: 1.0, green: 0.8, blue: 0.1) }
    var cancelled: Color { isDark ? Color(red: 0.95, green: 0.25, blue: 0.35) : Color(red: 0.9, green: 0.2, blue: 0.3) }
}

// MARK: - Cherry Blossom Theme

struct CherryBlossomTheme: Theme {
    let id = ThemeConst.id.cherry
    let name = ThemeConst.name.cherry
    let icon: AppIcon = .heartFill
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 1.0, green: 0.7, blue: 0.8) : Color(red: 0.95, green: 0.5, blue: 0.65) }
    var secondary: Color { isDark ? Color(red: 0.95, green: 0.6, blue: 0.75) : Color(red: 0.9, green: 0.4, blue: 0.6) }
    var tertiary: Color { isDark ? Color(red: 0.9, green: 0.5, blue: 0.7) : Color(red: 0.85, green: 0.35, blue: 0.55) }
    var accent: Color { isDark ? Color.pink : Color(red: 0.95, green: 0.4, blue: 0.6) }

    var lectureStart: Color { Color(red: 1.0, green: 0.5, blue: 0.7) }
    var lectureEnd: Color { Color(red: 0.9, green: 0.3, blue: 0.5) }
    var exerciseStart: Color { Color(red: 1.0, green: 0.75, blue: 0.85) }
    var exerciseEnd: Color { Color(red: 0.95, green: 0.6, blue: 0.75) }
    var laboratoryStart: Color { Color(red: 0.9, green: 0.45, blue: 0.75) }
    var laboratoryEnd: Color { Color(red: 0.75, green: 0.25, blue: 0.55) }

    var success: Color { Color(red: 0.9, green: 0.75, blue: 0.8) }
    var warning: Color { Color(red: 1.0, green: 0.75, blue: 0.6) }
    var error: Color { Color(red: 0.95, green: 0.35, blue: 0.45) }
    var info: Color { Color(red: 0.95, green: 0.7, blue: 0.85) }

    var online: Color { isDark ? Color(red: 1.0, green: 0.9, blue: 0.35) : Color(red: 1.0, green: 0.8, blue: 0.15) }
    var cancelled: Color { isDark ? Color(red: 0.95, green: 0.2, blue: 0.3) : Color(red: 0.9, green: 0.15, blue: 0.25) }
}

// MARK: - Midnight Theme

struct MidnightTheme: Theme {
    let id = ThemeConst.id.midnight
    let name = ThemeConst.name.midnight
    let icon: AppIcon = .moonStarsFill
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.4, green: 0.5, blue: 0.9) : Color(red: 0.25, green: 0.35, blue: 0.75) }
    var secondary: Color { isDark ? Color(red: 0.5, green: 0.4, blue: 0.85) : Color(red: 0.35, green: 0.25, blue: 0.7) }
    var tertiary: Color { isDark ? Color(red: 0.3, green: 0.45, blue: 0.8) : Color(red: 0.2, green: 0.3, blue: 0.65) }
    var accent: Color { isDark ? Color.indigo : Color(red: 0.3, green: 0.4, blue: 0.8) }

    var lectureStart: Color { Color(red: 0.3, green: 0.5, blue: 1.0) }
    var lectureEnd: Color { Color(red: 0.2, green: 0.35, blue: 0.8) }
    var exerciseStart: Color { Color(red: 0.5, green: 0.35, blue: 0.9) }
    var exerciseEnd: Color { Color(red: 0.35, green: 0.2, blue: 0.7) }
    var laboratoryStart: Color { Color(red: 0.4, green: 0.6, blue: 0.95) }
    var laboratoryEnd: Color { Color(red: 0.25, green: 0.45, blue: 0.75) }

    var success: Color { Color(red: 0.4, green: 0.7, blue: 0.9) }
    var warning: Color { Color(red: 0.8, green: 0.65, blue: 0.4) }
    var error: Color { Color(red: 0.85, green: 0.4, blue: 0.5) }
    var info: Color { Color(red: 0.5, green: 0.6, blue: 0.95) }

    var online: Color { isDark ? Color(red: 1.0, green: 0.9, blue: 0.3) : Color(red: 1.0, green: 0.8, blue: 0.1) }
    var cancelled: Color { isDark ? Color(red: 0.9, green: 0.25, blue: 0.3) : Color(red: 0.85, green: 0.2, blue: 0.25) }
}

// MARK: - Monochrome Theme

struct MonochromeTheme: Theme {
    let id = ThemeConst.id.monochrome
    let name = ThemeConst.name.monochrome
    let icon: AppIcon = .squareGrid2x2Fill
    let isDark: Bool

    var primary: Color { isDark ? Color(red: 0.45, green: 0.5, blue: 0.55) : Color(red: 0.4, green: 0.42, blue: 0.45) }
    var secondary: Color { isDark ? Color(red: 0.35, green: 0.38, blue: 0.42) : Color(red: 0.5, green: 0.52, blue: 0.55) }
    var tertiary: Color { isDark ? Color(red: 0.3, green: 0.33, blue: 0.37) : Color(red: 0.55, green: 0.57, blue: 0.6) }
    var accent: Color { isDark ? Color(red: 0.5, green: 0.55, blue: 0.6) : Color(red: 0.35, green: 0.38, blue: 0.42) }

    var lectureStart: Color { Color(red: 0.6, green: 0.5, blue: 0.4) }
    var lectureEnd: Color { Color(red: 0.5, green: 0.42, blue: 0.35) }
    var exerciseStart: Color { Color(red: 0.4, green: 0.48, blue: 0.55) }
    var exerciseEnd: Color { Color(red: 0.35, green: 0.42, blue: 0.48) }
    var laboratoryStart: Color { Color(red: 0.45, green: 0.52, blue: 0.45) }
    var laboratoryEnd: Color { Color(red: 0.38, green: 0.45, blue: 0.38) }

    var success: Color { Color(red: 0.4, green: 0.55, blue: 0.5) }
    var warning: Color { Color(red: 0.65, green: 0.55, blue: 0.4) }
    var error: Color { Color(red: 0.6, green: 0.4, blue: 0.4) }
    var info: Color { Color(red: 0.4, green: 0.48, blue: 0.55) }

    var online: Color { isDark ? Color(red: 0.8, green: 0.75, blue: 0.5) : Color(red: 0.75, green: 0.7, blue: 0.45) }
    var cancelled: Color { isDark ? Color(red: 0.7, green: 0.45, blue: 0.45) : Color(red: 0.65, green: 0.4, blue: 0.4) }
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
            MidnightTheme(isDark: isDark),
            MonochromeTheme(isDark: isDark)
        ]
    }

    static func theme(withId id: String, for colorScheme: ColorScheme) -> any Theme {
        let isDark = colorScheme == .dark
        switch id {
        case ThemeConst.id.ocean:      return OceanTheme(isDark: isDark)
        case ThemeConst.id.sunset:     return SunsetTheme(isDark: isDark)
        case ThemeConst.id.forest:     return ForestTheme(isDark: isDark)
        case ThemeConst.id.lavender:   return LavenderTheme(isDark: isDark)
        case ThemeConst.id.cherry:     return CherryBlossomTheme(isDark: isDark)
        case ThemeConst.id.midnight:   return MidnightTheme(isDark: isDark)
        case ThemeConst.id.monochrome: return MonochromeTheme(isDark: isDark)
        default:                       return DefaultTheme(isDark: isDark)
        }
    }
}
