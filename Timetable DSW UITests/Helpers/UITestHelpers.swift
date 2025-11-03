//
//  UITestHelpers.swift
//  Timetable DSW UITests
//
//  Created by Claude on 03/11/2025.
//

import XCTest

// MARK: - Timeout Constants

enum UITestTimeout {
    static let short: TimeInterval = 2.0
    static let normal: TimeInterval = 5.0
    static let long: TimeInterval = 10.0
    static let veryLong: TimeInterval = 20.0
}

// MARK: - XCUIElement Extensions

extension XCUIElement {

    /// Wait for element to exist
    func waitForExistence(timeout: TimeInterval = UITestTimeout.normal) -> Bool {
        return waitForExistence(timeout: timeout)
    }

    /// Wait for element to be hittable
    func waitForHittable(timeout: TimeInterval = UITestTimeout.normal) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Tap element after waiting for it to be hittable
    func tapAfterWait(timeout: TimeInterval = UITestTimeout.normal, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(waitForHittable(timeout: timeout), "Element not hittable: \(self)", file: file, line: line)
        tap()
    }

    /// Type text after clearing existing text
    func clearAndType(_ text: String) {
        guard let currentValue = value as? String else { return }

        tap()

        // Delete existing text
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
        typeText(deleteString)

        // Type new text
        typeText(text)
    }

    /// Scroll until element is visible
    func scrollToElement(in scrollView: XCUIElement) {
        while !isHittable {
            scrollView.swipeUp()
        }
    }
}

// MARK: - XCTestCase Extensions

extension XCTestCase {

    /// Wait for app to idle
    func waitForAppToIdle() {
        // Give app time to settle
        Thread.sleep(forTimeInterval: 0.5)
    }

    /// Take screenshot with name
    func takeScreenshot(named name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Step-based UI testing
    @discardableResult
    func uiStep<T>(_ description: String, file: StaticString = #file, line: UInt = #line, action: () throws -> T) rethrows -> T {
        print("📱 UI Step: \(description)")
        return try action()
    }
}

// MARK: - Accessibility Identifiers

enum AccessibilityIdentifier {

    // MARK: - Schedule Screen
    enum Schedule {
        static let rootView = "schedule_root_view"
        static let eventsList = "schedule_events_list"
        static let eventCell = "schedule_event_cell"
        static let emptyState = "schedule_empty_state"
        static let refreshButton = "schedule_refresh_button"
    }

    // MARK: - Settings Screen
    enum Settings {
        static let rootView = "settings_root_view"
        static let groupSelectionButton = "settings_group_selection_button"
        static let themeButton = "settings_theme_button"
        static let notificationsButton = "settings_notifications_button"
        static let aboutButton = "settings_about_button"
    }

    // MARK: - Group Selection Screen
    enum GroupSelection {
        static let rootView = "group_selection_root_view"
        static let searchField = "group_selection_search_field"
        static let groupsList = "group_selection_groups_list"
        static let groupCell = "group_selection_group_cell"
    }

    // MARK: - Teachers Screen
    enum Teachers {
        static let rootView = "teachers_root_view"
        static let teachersList = "teachers_list"
        static let teacherCell = "teachers_teacher_cell"
    }

    // MARK: - Common
    enum Common {
        static let tabBar = "main_tab_bar"
        static let scheduleTab = "tab_schedule"
        static let teachersTab = "tab_teachers"
        static let settingsTab = "tab_settings"
        static let backButton = "navigation_back_button"
        static let closeButton = "navigation_close_button"
        static let loadingIndicator = "loading_indicator"
    }
}

// MARK: - Test Data

enum UITestData {
    static let sampleGroupCode = "CS101"
    static let sampleGroupName = "Computer Science"
    static let searchQuery = "CS"
}
