# Timetable Widget Setup Instructions

## 📱 Widget Features

This project includes a comprehensive widget system with:

1. **Standard Widgets** - Small, Medium, and Large sizes with liquid glass design
2. **Live Activity** - Real-time tracking of current class with Dynamic Island support
3. **Control Center Widget** - Quick access to schedule from Control Center
4. **Configuration Intent** - Customizable widget options

## 🔧 Setup Steps

### 1. Configure App Groups

1. Open project in Xcode
2. Select **Timetable DSW** target → Signing & Capabilities
3. Click **+ Capability** → Add **App Groups**
4. Create a new App Group (e.g., `group.com.yourdomain.timetable`)
5. Repeat for **TimetableWidget** target

**Important**: Update the App Group identifier in both:
- `TimetableWidget/AppGroupManager.swift`
- `Timetable DSW/Core/Shared/AppGroupManager.swift`

```swift
static let appGroupIdentifier = "group.com.yourdomain.timetable"  // Replace with your ID
```

### 2. Add Widget Files to Target

Make sure all widget files are added to **TimetableWidget** target:
- ✓ TimetableWidget.swift
- ✓ TimetableWidgetBundle.swift
- ✓ TimetableWidgetEntry.swift
- ✓ TimetableWidgetProvider.swift
- ✓ TimetableWidgetViews.swift
- ✓ TimetableLiveActivity.swift
- ✓ TimetableControlWidget.swift
- ✓ WidgetConfigurationIntent.swift
- ✓ AppGroupManager.swift

### 3. Share Models Between Targets

Add these model files to BOTH **Timetable DSW** and **TimetableWidget** targets:
- GroupScheduleResponse.swift
- ScheduleEvent.swift
- AppTheme.swift
- ThemeFactory.swift
- AppColor.swift (design system)

**How to add to multiple targets**:
1. Select the file in Project Navigator
2. Open File Inspector (⌥⌘1)
3. Check both targets in "Target Membership"

### 4. Configure Info.plist

Add to **TimetableWidget/Info.plist**:

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

### 5. Enable Background Modes

For Live Activities, add to main app:
1. **Timetable DSW** target → Signing & Capabilities
2. **+ Capability** → Background Modes
3. Enable: **Background fetch** and **Remote notifications**

### 6. Build and Run

1. Build **TimetableWidget** scheme first
2. Then build **Timetable DSW** scheme
3. Run on device/simulator (widgets don't work in Playgrounds)

## 📊 Widget Types

### Standard Widget
- **Small**: Current/Next class with liquid glass background
- **Medium**: Today's schedule (up to 3 classes visible)
- **Large**: Week overview with all classes

### Live Activity
- **Lock Screen**: Full class details with progress bar
- **Dynamic Island**:
  - Compact: Class icon + time remaining
  - Expanded: Full details + progress
  - Minimal: Just icon

### Control Center Widget
- Quick access buttons to open app
- Toggle showing current class status

## 🎨 Design Features

- **Liquid Glass Effect**: Blurred backgrounds with gradient overlays
- **Theme Support**: Uses selected app theme with proper light/dark mode
- **Gradient Borders**: Semi-transparent white strokes
- **Event Color Coding**:
  - 🟠 Orange: Lectures
  - 🔵 Blue: Exercises
  - 🟣 Purple: Laboratory
- **Online Indicator**: WiFi icon for online classes

## 🔄 Data Flow

```
App loads schedule → Saves to App Group → Widget reads from App Group
      ↓
Theme changes → Updates App Group → Widgets reload
```

## 🚀 Usage

1. Long press on home screen → Add Widget
2. Search for "Timetable"
3. Choose size and add
4. Widget auto-updates based on class schedule

## 🐛 Troubleshooting

**Widget shows "No Data"**:
- Open main app at least once to load schedule
- Check App Group identifier matches in both targets

**Live Activity not appearing**:
- Ensure `NSSupportsLiveActivities` is in Info.plist
- Device must be iOS 16.1+
- Start activity from app code (not implemented yet - requires user interaction)

**Widget doesn't update theme**:
- Verify AppGroupManager is added to both targets
- Check that WidgetKit import is present
- Rebuild widget extension

## 📝 Notes

- Widgets update automatically when:
  - Class starts/ends
  - Schedule is refreshed
  - Theme is changed
- Live Activities must be started manually from app
- Control Center widgets require iOS 17+
- Dynamic Island requires iPhone 14 Pro or later

## 🎯 Next Steps

To enable Live Activities, add this to your app:

```swift
import ActivityKit

// Start Live Activity when class begins
Task {
    let attributes = TimetableLiveActivityAttributes(
        groupId: groupId,
        themeId: selectedThemeId
    )

    let contentState = TimetableLiveActivityAttributes.ContentState(
        eventTitle: event.title,
        eventType: event.type,
        room: event.room,
        startTime: event.startDate,
        endTime: event.endDate,
        teacherName: event.teacherName,
        isOnline: isOnline,
        progress: 0.0
    )

    let activity = try? Activity.request(
        attributes: attributes,
        content: .init(state: contentState, staleDate: nil)
    )
}
```

---

Happy coding! 🎉
