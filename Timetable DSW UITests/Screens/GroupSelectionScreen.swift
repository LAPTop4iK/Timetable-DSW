//
//  GroupSelectionScreen.swift
//  Timetable DSW UITests
//
//  Created by Claude on 03/11/2025.
//

import XCTest

// MARK: - Group Selection Screen Object

@MainActor
final class GroupSelectionScreen: BaseScreen {

    // MARK: - Elements

    private var rootView: XCUIElement {
        app.otherElements[AccessibilityIdentifier.GroupSelection.rootView]
    }

    private var searchField: XCUIElement {
        app.searchFields.firstMatch
    }

    private var groupsList: XCUIElement {
        // Try to find the list with identifier first
        let list = app.tables[AccessibilityIdentifier.GroupSelection.groupsList].firstMatch
        if list.exists {
            return list
        }
        // Fallback: any table/list
        return app.tables.firstMatch
    }

    private var groupCells: XCUIElementQuery {
        // In SwiftUI, List with Button wrapper creates .button elements, NOT .cell
        // Each row is: List -> Button (with identifier) -> GroupRow (HStack)
        let identifiedButtons = app.buttons.matching(identifier: AccessibilityIdentifier.GroupSelection.groupCell)
        if identifiedButtons.count > 0 {
            return identifiedButtons
        }
        // Fallback: try finding with descendants
        return app.descendants(matching: .button).matching(identifier: AccessibilityIdentifier.GroupSelection.groupCell)
    }

    // MARK: - Actions

    @discardableResult
    func assertScreenIsOpened(timeout: TimeInterval = UITestTimeout.normal) -> Self {
        uiStep("Assert group selection screen is opened") {
            // Fast check first
            if rootView.exists || searchField.exists {
                return self
            }

            // Then wait if needed
            let exists = searchField.waitForExistence(timeout: timeout)
            XCTAssertTrue(exists, "Group selection screen should be visible")
        }
        return self
    }

    @discardableResult
    func searchForGroup(_ query: String) -> Self {
        uiStep("Search for group '\(query)'") {
            searchField.tap()
            searchField.typeText(query)
        }
        return self
    }

    @discardableResult
    func clearSearch() -> Self {
        uiStep("Clear search") {
            let clearButton = searchField.buttons["Clear text"].firstMatch
            if clearButton.exists {
                clearButton.tap()
            } else {
                searchField.clearAndType("")
            }
        }
        return self
    }

    @discardableResult
    func selectGroup(at index: Int) -> Self {
        uiStep("Select group at index \(index)") {
            // SwiftUI List with Button wrapper = buttons, not cells
            if groupCells.count > index {
                let button = groupCells.element(boundBy: index)
                if button.waitForExistence(timeout: UITestTimeout.short) {
                    button.tap()
                }
            }
        }
        return self
    }

    @discardableResult
    func selectGroup(withName name: String) -> Self {
        uiStep("Select group with name '\(name)'") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", name)
            // SwiftUI List with Button wrapper = buttons
            let button = groupCells.containing(predicate).firstMatch
            if button.waitForExistence(timeout: UITestTimeout.short) {
                button.tap()
            }
        }
        return self
    }

    @discardableResult
    func waitForGroups(timeout: TimeInterval = UITestTimeout.long) -> Self {
        uiStep("Wait for groups to load") {
            // Wait for group buttons to appear
            let predicate = NSPredicate(format: "count > 0")
            let buttonsExpectation = XCTNSPredicateExpectation(predicate: predicate, object: groupCells)
            _ = XCTWaiter.wait(for: [buttonsExpectation], timeout: timeout)
        }
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertGroupsLoaded() -> Self {
        uiStep("Assert groups are loaded") {
            // SwiftUI List with Button wrapper = buttons
            XCTAssertGreaterThan(groupCells.count, 0, "Should have group buttons")
        }
        return self
    }

    @discardableResult
    func assertGroupExists(withName name: String) -> Self {
        uiStep("Assert group exists with name '\(name)'") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", name)
            let button = groupCells.containing(predicate).firstMatch
            XCTAssertTrue(button.exists, "Group button with name '\(name)' should exist")
        }
        return self
    }

    @discardableResult
    func assertSearchFieldVisible() -> Self {
        uiStep("Assert search field is visible") {
            XCTAssertTrue(searchField.exists, "Search field should be visible")
        }
        return self
    }

    override func assertScreenIsVisible(timeout: TimeInterval, file: StaticString, line: UInt) {
        assertScreenIsOpened(timeout: timeout)
    }
}

