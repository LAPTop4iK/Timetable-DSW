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
        // Try cells with specific identifier first
        let identifiedCells = app.descendants(matching: .any).matching(identifier: AccessibilityIdentifier.GroupSelection.groupCell)
        if identifiedCells.count > 0 {
            return identifiedCells
        }
        // Fallback to table cells
        return app.tables.cells
    }

    // MARK: - Actions

    @discardableResult
    func assertScreenIsOpened(timeout: TimeInterval = UITestTimeout.normal) -> Self {
        uiStep("Assert group selection screen is opened") {
            let exists = rootView.waitForExistence(timeout: timeout) ||
                        searchField.waitForExistence(timeout: timeout) ||
                        app.navigationBars.containing(NSPredicate(format: "identifier CONTAINS[c] %@", "Group")).firstMatch.waitForExistence(timeout: timeout)
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
            // Try using identified cells first
            if groupCells.count > index {
                let cell = groupCells.element(boundBy: index)
                XCTAssertTrue(cell.waitForExistence(timeout: UITestTimeout.normal), "Group cell should exist")
                cell.tap()
            } else {
                // Fallback to any table cells or buttons
                let allCells = app.tables.cells
                if allCells.count > index {
                    allCells.element(boundBy: index).tap()
                } else {
                    // Try buttons if cells don't work
                    let buttons = app.buttons.allElementsBoundByIndex
                    if index < buttons.count {
                        buttons[index].tap()
                    }
                }
            }
        }
        return self
    }

    @discardableResult
    func selectGroup(withName name: String) -> Self {
        uiStep("Select group with name '\(name)'") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", name)
            // Try cells with identifier first
            var cell = groupCells.containing(predicate).firstMatch
            if !cell.exists {
                // Fallback to any table cells
                cell = app.tables.cells.containing(predicate).firstMatch
            }
            if !cell.exists {
                // Try buttons as last resort
                cell = app.buttons.containing(predicate).firstMatch
            }
            XCTAssertTrue(cell.waitForExistence(timeout: UITestTimeout.normal), "Group with name '\(name)' should exist")
            cell.tap()
        }
        return self
    }

    @discardableResult
    func waitForGroups(timeout: TimeInterval = UITestTimeout.long) -> Self {
        uiStep("Wait for groups to load") {
            // Wait for either identified cells or any table cells
            let predicate = NSPredicate(format: "count > 0")
            let cellsExpectation = XCTNSPredicateExpectation(predicate: predicate, object: groupCells)
            let result = XCTWaiter.wait(for: [cellsExpectation], timeout: timeout)

            // If that fails, try waiting for any table cells
            if result != .completed {
                let tableCells = app.tables.cells
                let tableExpectation = XCTNSPredicateExpectation(predicate: predicate, object: tableCells)
                _ = XCTWaiter.wait(for: [tableExpectation], timeout: UITestTimeout.short)
            }
        }
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertGroupsLoaded() -> Self {
        uiStep("Assert groups are loaded") {
            let hasGroups = groupCells.count > 0 || app.tables.cells.count > 0
            XCTAssertTrue(hasGroups, "Should have groups")
        }
        return self
    }

    @discardableResult
    func assertGroupExists(withName name: String) -> Self {
        uiStep("Assert group exists with name '\(name)'") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", name)
            // Try identified cells first
            var cell = groupCells.containing(predicate).firstMatch
            if !cell.exists {
                // Fallback to any table cells
                cell = app.tables.cells.containing(predicate).firstMatch
            }
            XCTAssertTrue(cell.exists, "Group with name '\(name)' should exist")
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

