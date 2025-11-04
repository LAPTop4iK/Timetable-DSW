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
        app.otherElements[AccessibilityIdentifier.Settings.rootView]
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
            let exists = rootView.waitForExistence(timeout: timeout) ||
                        app.navigationBars["Settings"].waitForExistence(timeout: timeout)
            XCTAssertTrue(exists, "Settings screen should be visible")
        }
        return self
    }

    @discardableResult
    func tapGroupSelection() -> GroupSelectionScreen {
        uiStep("Tap group selection") {
            if groupSelectionButton.waitForExistence(timeout: UITestTimeout.normal) {
                groupSelectionButton.tap()
            } else {
                // Fallback: find any button or element with "Group" or "Группа" text
                let groupPredicate = NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@", "Group", "Группа")
                let groupButton = app.buttons.containing(groupPredicate).firstMatch

                if groupButton.waitForExistence(timeout: UITestTimeout.short) {
                    groupButton.tap()
                } else {
                    // Try to find in any interactive element
                    let anyElement = app.descendants(matching: .any).containing(groupPredicate).firstMatch
                    if anyElement.waitForExistence(timeout: UITestTimeout.short) {
                        anyElement.tap()
                    }
                }
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
