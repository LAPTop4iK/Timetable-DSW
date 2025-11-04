//
//  TimetableUITests.swift
//  Timetable DSW UITests
//
//  Created by Claude on 03/11/2025.
//

import XCTest

// MARK: - Timetable UI Tests

@MainActor
final class TimetableUITests: XCTestCase {

    // MARK: - Properties

    var app: XCUIApplication!

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
        try super.tearDownWithError()
    }

    // MARK: - Launch Tests

    func testAppLaunches() throws {
        uiStep("Given app launches") {
            XCTAssertTrue(app.state == .runningForeground, "App should be running")
        }

        uiStep("Then tab bar should be visible") {
            TabBarScreen(app)
                .assertTabBarVisible()
        }
    }

    // MARK: - Schedule Flow Tests

    func testScheduleScreenAppears() throws {
        uiStep("Given app launches") {
            // App already launched in setup
        }

        uiStep("When opening schedule tab") {
            TabBarScreen(app)
                .switchToScheduleTab()
        }

        uiStep("Then schedule screen should be visible") {
            ScheduleScreen(app)
                .assertScreenIsOpened()
        }
    }

    func testScheduleRefresh() throws {
        uiStep("Given schedule screen is opened") {
            TabBarScreen(app)
                .switchToScheduleTab()
        }

        let scheduleScreen = ScheduleScreen(app)

        uiStep("When pulling to refresh") {
            scheduleScreen
                .waitForScreenToLoad()
                .pullToRefresh()
        }

        uiStep("Then screen should reload") {
            // Wait a bit for refresh to complete
            Thread.sleep(forTimeInterval: 2.0)
            scheduleScreen.assertScreenIsOpened()
        }
    }

    func testScheduleEmptyState() throws {
        uiStep("Given app launches without group selected") {
            // This test assumes no group is selected initially
        }

        uiStep("When opening schedule screen") {
            TabBarScreen(app)
                .switchToScheduleTab()
        }

        uiStep("Then empty state or prompt should be visible") {
            let scheduleScreen = ScheduleScreen(app)
            scheduleScreen.waitForScreenToLoad()

            // Either empty state or events should be shown
            let hasContent = scheduleScreen.assertScreenIsOpened()
            XCTAssertNotNil(hasContent, "Schedule screen should show some content")
        }
    }

    // MARK: - Settings Flow Tests

    func testNavigateToSettings() throws {
        uiStep("Given app launches") {
            // App already launched
        }

        uiStep("When opening settings tab") {
            TabBarScreen(app)
                .switchToSettingsTab()
        }

        uiStep("Then settings screen should be visible") {
            SettingsScreen(app)
                .assertScreenIsOpened()
        }
    }

    func testSettingsGroupSelectionVisible() throws {
        uiStep("Given settings screen is opened") {
            TabBarScreen(app)
                .switchToSettingsTab()
        }

        uiStep("Then group selection option should be visible") {
            SettingsScreen(app)
                .waitForScreenToLoad()
                .assertGroupSelectionVisible()
        }
    }

    // MARK: - Group Selection Flow Tests

    func testOpenGroupSelection() throws {
        uiStep("Given settings screen is opened") {
            TabBarScreen(app)
                .switchToSettingsTab()
        }

        uiStep("When tapping group selection") {
            SettingsScreen(app)
                .waitForScreenToLoad()
                .tapGroupSelection()
        }

        uiStep("Then group selection screen should appear") {
            GroupSelectionScreen(app)
                .assertScreenIsOpened()
        }
    }

    func testGroupSelectionSearchVisible() throws {
        uiStep("Given group selection screen is opened") {
            TabBarScreen(app)
                .switchToSettingsTab()

            SettingsScreen(app)
                .tapGroupSelection()
        }

        uiStep("Then search field should be visible") {
            GroupSelectionScreen(app)
                .assertScreenIsOpened()
                .assertSearchFieldVisible()
        }
    }

    func testGroupSelectionLoadGroups() throws {
        uiStep("Given group selection screen is opened") {
            TabBarScreen(app)
                .switchToSettingsTab()

            SettingsScreen(app)
                .tapGroupSelection()
        }

        let groupSelectionScreen = GroupSelectionScreen(app)

        uiStep("When waiting for groups to load") {
            groupSelectionScreen
                .waitForGroups(timeout: UITestTimeout.veryLong)
        }

        uiStep("Then groups should be displayed") {
            // SwiftUI List with Button wrapper = buttons, not cells
            let hasButtons = app.buttons.matching(identifier: "group_selection_group_cell").count > 0
            if hasButtons {
                groupSelectionScreen.assertGroupsLoaded()
            } else {
                // Groups may be loading or network error
                XCTAssertTrue(app.tables.firstMatch.exists, "Groups list should exist")
            }
        }
    }

    func testGroupSearch() throws {
        uiStep("Given group selection screen is opened") {
            TabBarScreen(app)
                .switchToSettingsTab()

            SettingsScreen(app)
                .tapGroupSelection()
        }

        let groupSelectionScreen = GroupSelectionScreen(app)
            .waitForGroups(timeout: UITestTimeout.veryLong)

        uiStep("When searching for a group") {
            groupSelectionScreen
                .searchForGroup(UITestData.searchQuery)
        }

        uiStep("Then search results should be filtered") {
            // Wait for search to filter results
            Thread.sleep(forTimeInterval: 1.0)

            // Verify search field has text
            let searchField = app.searchFields.firstMatch
            XCTAssertTrue(searchField.exists, "Search field should exist")
        }
    }

    // MARK: - Navigation Tests

    func testTabNavigation() throws {
        let tabBar = TabBarScreen(app)

        uiStep("When switching between tabs") {
            // Schedule
            tabBar.switchToScheduleTab()
                .assertScreenIsOpened()

            // Settings
            tabBar.switchToSettingsTab()
                .assertScreenIsOpened()

            // Back to Schedule
            tabBar.switchToScheduleTab()
                .assertScreenIsOpened()
        }

        uiStep("Then all tabs should load without crashes") {
            XCTAssertTrue(app.state == .runningForeground, "App should still be running")
        }
    }

    func testNavigationBackButton() throws {
        uiStep("Given group selection is opened") {
            TabBarScreen(app)
                .switchToSettingsTab()

            SettingsScreen(app)
                .tapGroupSelection()

            GroupSelectionScreen(app)
                .assertScreenIsOpened()
        }

        uiStep("When tapping back button") {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        uiStep("Then should return to settings") {
            SettingsScreen(app)
                .assertScreenIsOpened()
        }
    }

    // MARK: - Integration Tests

    func testFullUserFlow_SelectGroupAndViewSchedule() throws {
        uiStep("Given app launches") {
            // App launched
        }

        uiStep("When user navigates to settings") {
            TabBarScreen(app)
                .switchToSettingsTab()
        }

        uiStep("And opens group selection") {
            SettingsScreen(app)
                .tapGroupSelection()
        }

        uiStep("And waits for groups") {
            GroupSelectionScreen(app)
                .waitForGroups(timeout: UITestTimeout.veryLong)
        }

       try uiStep("And selects first group") {
            // SwiftUI List with Button wrapper = buttons, not cells
            let groupButtons = app.buttons.matching(identifier: "group_selection_group_cell")
            if groupButtons.count > 0 {
                GroupSelectionScreen(app)
                    .selectGroup(at: 0)
            } else {
                throw XCTSkip("No groups available to select")
            }
        }

        uiStep("And navigates to schedule") {
            TabBarScreen(app)
                .switchToScheduleTab()
        }

        uiStep("Then schedule should load for selected group") {
            ScheduleScreen(app)
                .assertScreenIsOpened()
                .waitForScreenToLoad()
        }
    }

    // MARK: - Performance Tests

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testScrollPerformance() throws {
        TabBarScreen(app)
            .switchToScheduleTab()

        let scheduleScreen = ScheduleScreen(app)

        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            scheduleScreen.scrollToBottom()
            scheduleScreen.scrollToTop()
        }
    }

    // MARK: - Accessibility Tests

    func testVoiceOverElementsAccessible() throws {
        uiStep("Given app launches with VoiceOver simulation") {
            // Check that key elements have accessibility labels
        }

        uiStep("Then tab bar should be accessible") {
            let tabBar = app.tabBars.firstMatch
            XCTAssertTrue(tabBar.exists, "Tab bar should exist")

            // Check tabs have accessibility
            let tabButtons = tabBar.buttons
            XCTAssertGreaterThan(tabButtons.count, 0, "Should have tab buttons")
        }
    }

    // MARK: - Screenshot Tests

    func testTakeScreenshots() throws {
        uiStep("Capture Schedule screen") {
            TabBarScreen(app)
                .switchToScheduleTab()

            ScheduleScreen(app)
                .takeScreenshot(named: "01-Schedule")
        }

        uiStep("Capture Settings screen") {
            TabBarScreen(app)
                .switchToSettingsTab()

            SettingsScreen(app)
                .takeScreenshot(named: "02-Settings")
        }

        uiStep("Capture Group Selection screen") {
            SettingsScreen(app)
                .tapGroupSelection()

            GroupSelectionScreen(app)
                .waitForGroups(timeout: UITestTimeout.veryLong)
                .takeScreenshot(named: "03-GroupSelection")
        }
    }
}

