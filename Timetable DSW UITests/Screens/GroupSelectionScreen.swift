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
        app.tables[AccessibilityIdentifier.GroupSelection.groupsList].firstMatch
    }

    private var groupCells: XCUIElementQuery {
        app.tables.cells.matching(identifier: AccessibilityIdentifier.GroupSelection.groupCell)
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
            let cells = app.tables.cells
            let cell = cells.element(boundBy: index)
            XCTAssertTrue(cell.waitForExistence(timeout: UITestTimeout.normal), "Group cell should exist")
            cell.tap()
        }
        return self
    }

    @discardableResult
    func selectGroup(withName name: String) -> Self {
        uiStep("Select group with name '\(name)'") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", name)
            let cell = app.tables.cells.containing(predicate).firstMatch
            XCTAssertTrue(cell.waitForExistence(timeout: UITestTimeout.normal), "Group with name '\(name)' should exist")
            cell.tap()
        }
        return self
    }

    @discardableResult
    func waitForGroups(timeout: TimeInterval = UITestTimeout.long) -> Self {
        uiStep("Wait for groups to load") {
            let cells = app.tables.cells
            let predicate = NSPredicate(format: "count > 0")
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: cells)
            _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
        }
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertGroupsLoaded() -> Self {
        uiStep("Assert groups are loaded") {
            XCTAssertGreaterThan(app.tables.cells.count, 0, "Should have groups")
        }
        return self
    }

    @discardableResult
    func assertGroupExists(withName name: String) -> Self {
        uiStep("Assert group exists with name '\(name)'") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", name)
            let cell = app.tables.cells.containing(predicate).firstMatch
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

