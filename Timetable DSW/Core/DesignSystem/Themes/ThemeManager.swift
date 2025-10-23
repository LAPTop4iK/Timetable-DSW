//
//  ThemeManager.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI
import Combine
import WidgetKit

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return LocalizedString.appearanceSystem.localized
        case .light:  return LocalizedString.appearanceLight.localized
        case .dark:   return LocalizedString.appearanceDark.localized
        }
    }

    var icon: AppIcon {
        switch self {
        case .system: return .circleLeftHalfFilled
        case .light:  return .sunMaxFill
        case .dark:   return .moonFill
        }
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    // MARK: - Published Properties

    @Published var selectedThemeId: String {
        didSet {
            UserDefaults.standard.set(selectedThemeId, forKey: Keys.selectedTheme)
            // Save to App Group for widget
            AppGroupManager.saveSelectedTheme(id: selectedThemeId, appearanceMode: appearanceMode.rawValue)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: Keys.appearanceMode)
            applyAppearanceMode()
            // Save to App Group for widget
            AppGroupManager.saveSelectedTheme(id: selectedThemeId, appearanceMode: appearanceMode.rawValue)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // MARK: - Keys

    private enum Keys {
        static let selectedTheme = "app.theme.selected"
        static let appearanceMode = "app.appearance.mode"
    }

    // MARK: - Initialization

    private init() {
        self.selectedThemeId = UserDefaults.standard.string(forKey: Keys.selectedTheme) ?? "default"
        let modeString = UserDefaults.standard.string(forKey: Keys.appearanceMode) ?? "system"
        self.appearanceMode = AppearanceMode(rawValue: modeString) ?? .system
        applyAppearanceMode()
    }

    // MARK: - Methods

    func currentTheme(for colorScheme: ColorScheme) -> any Theme {
        ThemeFactory.theme(withId: selectedThemeId, for: colorScheme)
    }

    func allThemes(for colorScheme: ColorScheme) -> [any Theme] {
        ThemeFactory.allThemes(for: colorScheme)
    }

    private func applyAppearanceMode() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }

            switch self.appearanceMode {
            case .system:
                window.overrideUserInterfaceStyle = .unspecified
            case .light:
                window.overrideUserInterfaceStyle = .light
            case .dark:
                window.overrideUserInterfaceStyle = .dark
            }
        }
    }

    func selectTheme(_ themeId: String) {
        selectedThemeId = themeId
    }

    func setAppearanceMode(_ mode: AppearanceMode) {
        appearanceMode = mode
    }
}

// MARK: - Environment Key

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
