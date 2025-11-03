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
        app.tabBars.firstMatch
    }

    // MARK: - Actions

    @discardableResult
    func switchToScheduleTab() -> ScheduleScreen {
        uiStep("Switch to Schedule tab") {
            // Try multiple ways to find schedule tab
            if let scheduleTab = tabBar.buttons.element(boundBy: 0).firstMatch, scheduleTab.exists {
                scheduleTab.tap()
            } else {
                tabBar.buttons.firstMatch.tap()
            }
        }
        return ScheduleScreen(app)
    }

    @discardableResult
    func switchToTeachersTab() -> Self {
        uiStep("Switch to Teachers tab") {
            if let teachersTab = tabBar.buttons.element(boundBy: 1).firstMatch, teachersTab.exists {
                teachersTab.tap()
            }
        }
        return self
    }

    @discardableResult
    func switchToSettingsTab() -> SettingsScreen {
        uiStep("Switch to Settings tab") {
            // Settings is usually the last tab
            let lastIndex = tabBar.buttons.count - 1
            if lastIndex >= 0 {
                tabBar.buttons.element(boundBy: lastIndex).tap()
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
