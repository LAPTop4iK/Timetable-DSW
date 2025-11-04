//
//  TabBarScreen.swift
//  Timetable DSW UITests
//
//  Created by Claude on 03/11/2025.
//

import XCTest

// MARK: - Tab Bar Screen Object

@MainActor
final class TabBarScreen: BaseScreen {

    // MARK: - Elements

    private var tabBar: XCUIElement {
        // Try different query types for SwiftUI views
        let element = app.otherElements[AccessibilityIdentifier.Common.tabBar].firstMatch
        if element.exists {
            return element
        }
        // Fallback: any container with the identifier
        return app.descendants(matching: .any)[AccessibilityIdentifier.Common.tabBar].firstMatch
    }

    private var scheduleTab: XCUIElement {
        app.buttons[AccessibilityIdentifier.Common.scheduleTab].firstMatch
    }

    private var teachersTab: XCUIElement {
        app.buttons[AccessibilityIdentifier.Common.teachersTab].firstMatch
    }

    private var settingsTab: XCUIElement {
        app.buttons[AccessibilityIdentifier.Common.settingsTab].firstMatch
    }

    // MARK: - Actions

    @discardableResult
    func switchToScheduleTab() -> ScheduleScreen {
        uiStep("Switch to Schedule tab") {
            if scheduleTab.waitForExistence(timeout: UITestTimeout.normal) {
                scheduleTab.tap()
            } else {
                // Fallback: find button containing schedule icon/text
                let fallbackButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS[c] 'schedule' OR label CONTAINS[c] 'schedule'")).firstMatch
                if fallbackButton.exists {
                    fallbackButton.tap()
                }
            }
        }
        return ScheduleScreen(app)
    }

    @discardableResult
    func switchToTeachersTab() -> Self {
        uiStep("Switch to Teachers tab") {
            if teachersTab.waitForExistence(timeout: UITestTimeout.normal) {
                teachersTab.tap()
            } else {
                // Fallback: find button containing teachers icon/text
                let fallbackButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS[c] 'teachers' OR label CONTAINS[c] 'teachers'")).firstMatch
                if fallbackButton.exists {
                    fallbackButton.tap()
                }
            }
        }
        return self
    }

    @discardableResult
    func switchToSettingsTab() -> SettingsScreen {
        uiStep("Switch to Settings tab") {
            if settingsTab.waitForExistence(timeout: UITestTimeout.normal) {
                settingsTab.tap()
            } else {
                // Fallback: find button containing settings icon/text
                let fallbackButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS[c] 'settings' OR label CONTAINS[c] 'settings'")).firstMatch
                if fallbackButton.exists {
                    fallbackButton.tap()
                }
            }
        }
        return SettingsScreen(app)
    }

    // MARK: - Assertions

    @discardableResult
    func assertTabBarVisible() -> Self {
        uiStep("Assert tab bar is visible") {
            // Check if any tab button is visible (more reliable for custom tab bars)
            let tabBarExists = tabBar.waitForExistence(timeout: UITestTimeout.normal) ||
                              scheduleTab.waitForExistence(timeout: UITestTimeout.normal) ||
                              settingsTab.waitForExistence(timeout: UITestTimeout.normal)
            XCTAssertTrue(tabBarExists, "Tab bar should be visible (at least one tab button should exist)")
        }
        return self
    }

    @discardableResult
    func assertTabCount(_ count: Int) -> Self {
        uiStep("Assert tab count is \(count)") {
            // Count visible tab buttons with identifiers
            let visibleButtons = [scheduleTab, teachersTab, settingsTab].filter { $0.exists }
            XCTAssertEqual(visibleButtons.count, count, "Tab count should be \(count)")
        }
        return self
    }

    override func assertScreenIsVisible(timeout: TimeInterval, file: StaticString, line: UInt) {
        assertTabBarVisible()
    }
}

