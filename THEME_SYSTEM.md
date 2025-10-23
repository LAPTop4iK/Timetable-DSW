# Theme System Documentation

## Overview

The Timetable DSW app now includes a comprehensive theming system that allows users to customize the app's appearance with multiple color schemes and appearance modes.

## Features

### 1. Multiple Color Themes

The app includes 7 unique, professionally designed color themes:

#### **Default** (Purple/Pink)
- The original app color scheme
- Purple and pink gradients
- Warm, inviting appearance

#### **Ocean** (Blue/Teal)
- Calming ocean-inspired palette
- Cool blues and teals
- Professional and clean

#### **Sunset** (Orange/Red)
- Warm sunset colors
- Energetic orange and red tones
- Bold and vibrant

#### **Forest** (Green)
- Nature-inspired greens
- Fresh and calming
- Eco-friendly aesthetic

#### **Lavender** (Purple)
- Soft lavender tones
- Gentle and soothing
- Elegant appearance

#### **Cherry Blossom** (Pink)
- Delicate pink shades
- Romantic and gentle
- Springtime-inspired

#### **Midnight** (Blue/Indigo)
- Deep night sky colors
- Mysterious and sophisticated
- Perfect for nighttime use

### 2. Appearance Modes

Users can choose from three appearance modes:

- **System**: Follows device system settings (default)
- **Light**: Always uses light mode
- **Dark**: Always uses dark mode

### 3. Dynamic Color Adaptation

All themes automatically adapt to both light and dark modes, ensuring optimal contrast and readability in any lighting condition.

## Architecture

### Core Components

#### `AppTheme.swift`
Defines the theme protocol and all theme implementations.

```swift
protocol Theme {
    var id: String { get }
    var name: String { get }
    var icon: String { get }

    // Color properties
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
```

#### `ThemeManager.swift`
Centralized theme management singleton.

```swift
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var selectedThemeId: String
    @Published var appearanceMode: AppearanceMode

    func currentTheme(for colorScheme: ColorScheme) -> any Theme
    func allThemes(for colorScheme: ColorScheme) -> [any Theme]
    func selectTheme(_ themeId: String)
    func setAppearanceMode(_ mode: AppearanceMode)
}
```

#### `ThemeSettingsView.swift`
User interface for theme customization with:
- Appearance mode selector
- Theme preview cards
- Visual feedback and animations

### Design System Integration

#### Updated `AppColor.swift`
```swift
enum AppColor {
    case themePrimary
    case themeSecondary
    case themeTertiary
    case themeAccent
    case success
    case warning
    case error
    case info
    // ...

    func color(for scheme: ColorScheme, theme: (any Theme)? = nil) -> Color
}
```

#### Updated `GradientStyle.swift`
```swift
enum GradientStyle {
    case primary
    case secondary
    case accent
    case lecture
    case exercise
    case laboratory
    // ...

    func colors(for scheme: ColorScheme, theme: (any Theme)? = nil) -> [Color]
}
```

## Usage

### For Users

1. Open the app and navigate to **Settings**
2. Tap on **Appearance** section
3. Choose your preferred **Appearance Mode** (System/Light/Dark)
4. Select your favorite **Color Theme** from the grid
5. Changes are applied immediately and saved automatically

### For Developers

#### Accessing the Current Theme

```swift
@Environment(\.colorScheme) var colorScheme
@EnvironmentObject var themeManager: ThemeManager

var currentTheme: any Theme {
    themeManager.currentTheme(for: colorScheme)
}
```

#### Using Theme Colors

```swift
// Using AppColor (recommended)
Text("Hello")
    .foregroundAppColor(.themePrimary, colorScheme: colorScheme)

// Using GradientStyle
RoundedRectangle(cornerRadius: 12)
    .fill(
        GradientStyle.primary.linearGradient(for: colorScheme)
    )

// Direct theme access
Circle()
    .fill(currentTheme.accent)
```

#### Creating a New Theme

1. Create a new struct conforming to `Theme` protocol in `AppTheme.swift`:

```swift
struct MyCustomTheme: Theme {
    let id = "myCustomTheme"
    let name = "My Custom Theme"
    let icon = "star.fill"
    let isDark: Bool

    var primary: Color { /* your color */ }
    var secondary: Color { /* your color */ }
    // ... implement all required properties
}
```

2. Add it to `ThemeFactory`:

```swift
static func allThemes(for colorScheme: ColorScheme) -> [any Theme] {
    let isDark = colorScheme == .dark
    return [
        DefaultTheme(isDark: isDark),
        // ... other themes
        MyCustomTheme(isDark: isDark)
    ]
}
```

## File Structure

```
Timetable DSW/
├── Core/
│   └── DesignSystem/
│       ├── Colors/
│       │   └── AppColor.swift (updated)
│       ├── Gradients/
│       │   └── GradientStyle.swift (updated)
│       ├── Icons/
│       │   └── AppIcon.swift (updated)
│       └── Themes/
│           ├── AppTheme.swift (new)
│           └── ThemeManager.swift (new)
├── Features/
│   └── Settings/
│       └── Views/
│           ├── SettingsView.swift (updated)
│           └── ThemeSettingsView.swift (new)
└── App/
    └── DSWScheduleApp.swift (updated)
```

## Technical Details

### Persistence

- Theme selection is saved to `UserDefaults` with key `app.theme.selected`
- Appearance mode is saved to `UserDefaults` with key `app.appearance.mode`
- Changes persist across app launches

### Performance

- Singleton pattern for ThemeManager ensures single source of truth
- Published properties trigger UI updates automatically
- Minimal overhead with protocol-based design
- Colors are computed on-demand, not cached

### Backward Compatibility

- All existing code continues to work without modifications
- Optional `theme` parameter allows gradual migration
- Default behavior uses ThemeManager automatically

## Future Enhancements

Potential improvements for the theme system:

1. **Custom Theme Creation**: Allow users to create their own themes
2. **Theme Import/Export**: Share themes between users
3. **Scheduled Themes**: Automatically switch themes based on time of day
4. **More Themes**: Add seasonal themes, holiday themes, etc.
5. **Accessibility**: High contrast themes for better accessibility
6. **Premium Themes**: Unlock additional themes with premium subscription

## Testing

To test the theme system:

1. Navigate to Settings → Appearance
2. Try switching between different appearance modes
3. Select each theme and verify colors update throughout the app
4. Close and reopen the app to verify persistence
5. Test in both light and dark system modes

## Troubleshooting

**Theme not changing:**
- Ensure ThemeManager is added to environment in DSWScheduleApp.swift
- Check that views use `@EnvironmentObject var themeManager: ThemeManager`

**Colors not updating:**
- Verify views observe `colorScheme` changes
- Make sure to use `AppColor` and `GradientStyle` instead of hardcoded colors

**Appearance mode not working:**
- Check that window's `overrideUserInterfaceStyle` is being set
- Verify app has access to window scene

## Credits

Theme system designed and implemented with Claude Code.

---

For questions or issues, please contact the development team or create an issue in the repository.
