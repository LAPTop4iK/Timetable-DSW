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
        app.otherElements[AccessibilityIdentifier.Common.tabBar].firstMatch
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
                // Fallback: first tab button
                app.tabBars.buttons.element(boundBy: 0).tap()
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
                // Fallback: second tab button
                app.tabBars.buttons.element(boundBy: 2).tap()
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
                // Fallback: last tab button
                let lastIndex = app.tabBars.buttons.count - 1
                if lastIndex >= 0 {
                    app.tabBars.buttons.element(boundBy: lastIndex).tap()
                }
            }
        }
        return SettingsScreen(app)
    }

    // MARK: - Assertions

    @discardableResult
    func assertTabBarVisible() -> Self {
        uiStep("Assert tab bar is visible") {
            XCTAssertTrue(tabBar.waitForExistence(timeout: UITestTimeout.normal), "Tab bar should be visible")
        }
        return self
    }

    @discardableResult
    func assertTabCount(_ count: Int) -> Self {
        uiStep("Assert tab count is \(count)") {
            XCTAssertEqual(tabBar.buttons.count, count, "Tab count should be \(count)")
        }
        return self
    }

    override func assertScreenIsVisible(timeout: TimeInterval, file: StaticString, line: UInt) {
        assertTabBarVisible()
    }
}

