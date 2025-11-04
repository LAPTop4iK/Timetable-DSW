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
        // SwiftUI custom tab bar can be various types
        app.descendants(matching: .any)[AccessibilityIdentifier.Common.tabBar].firstMatch
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
            // Fast check with short timeout, then tap if exists
            if scheduleTab.waitForExistence(timeout: UITestTimeout.short) {
                scheduleTab.tap()
            }
        }
        return ScheduleScreen(app)
    }

    @discardableResult
    func switchToTeachersTab() -> Self {
        uiStep("Switch to Teachers tab") {
            if teachersTab.waitForExistence(timeout: UITestTimeout.short) {
                teachersTab.tap()
            }
        }
        return self
    }

    @discardableResult
    func switchToSettingsTab() -> SettingsScreen {
        uiStep("Switch to Settings tab") {
            if settingsTab.waitForExistence(timeout: UITestTimeout.short) {
                settingsTab.tap()
            }
        }
        return SettingsScreen(app)
    }

    // MARK: - Assertions

    @discardableResult
    func assertTabBarVisible() -> Self {
        uiStep("Assert tab bar is visible") {
            // Fast check: if any tab button exists, tab bar is visible
            let tabBarExists = scheduleTab.exists || settingsTab.exists || teachersTab.exists
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

