//
//  SettingsScreen.swift
//  Timetable DSW UITests
//
//  Created by Claude on 03/11/2025.
//

import XCTest

// MARK: - Settings Screen Object

@MainActor
final class SettingsScreen: BaseScreen {

    // MARK: - Elements

    private var rootView: XCUIElement {
        // SwiftUI Form maps to UITableView in XCUITest
        let table = app.tables[AccessibilityIdentifier.Settings.rootView].firstMatch
        if table.exists {
            return table
        }
        // Fallback to otherElements
        return app.otherElements[AccessibilityIdentifier.Settings.rootView].firstMatch
    }

    private var groupSelectionButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Settings.groupSelectionButton].firstMatch
    }

    private var themeButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Settings.themeButton].firstMatch
    }

    private var aboutButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Settings.aboutButton].firstMatch
    }

    // MARK: - Actions

    @discardableResult
    func assertScreenIsOpened(timeout: TimeInterval = UITestTimeout.normal) -> Self {
        uiStep("Assert settings screen is opened") {
            // Fast check first
            if rootView.exists || groupSelectionButton.exists {
                return self
            }

            // Then wait if needed
            let exists = rootView.waitForExistence(timeout: timeout)
            XCTAssertTrue(exists, "Settings screen should be visible")
        }
        return self
    }

    @discardableResult
    func tapGroupSelection() -> GroupSelectionScreen {
        uiStep("Tap group selection") {
            if groupSelectionButton.waitForExistence(timeout: UITestTimeout.short) {
                groupSelectionButton.tap()
            }
        }
        return GroupSelectionScreen(app)
    }

    @discardableResult
    func tapTheme() -> Self {
        uiStep("Tap theme settings") {
            themeButton.tapAfterWait()
        }
        return self
    }

    @discardableResult
    func tapAbout() -> Self {
        uiStep("Tap about") {
            aboutButton.tapAfterWait()
        }
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertGroupSelectionVisible() -> Self {
        uiStep("Assert group selection is visible") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", "Group")
            let element = app.buttons.containing(predicate).firstMatch
            XCTAssertTrue(element.waitForExistence(timeout: UITestTimeout.normal), "Group selection should be visible")
        }
        return self
    }

    override func assertScreenIsVisible(timeout: TimeInterval, file: StaticString, line: UInt) {
        assertScreenIsOpened(timeout: timeout)
    }
}
