//
//  ScheduleScreen.swift
//  Timetable DSW UITests
//
//  Created by Claude on 03/11/2025.
//

import XCTest

// MARK: - Schedule Screen Object

@MainActor
final class ScheduleScreen: BaseScreen {

    // MARK: - Elements

    private var rootView: XCUIElement {
        app.otherElements[AccessibilityIdentifier.Schedule.rootView]
    }

    private var eventsList: XCUIElement {
        app.collectionViews[AccessibilityIdentifier.Schedule.eventsList].firstMatch
    }

    private var emptyState: XCUIElement {
        app.otherElements[AccessibilityIdentifier.Schedule.emptyState]
    }

    private var refreshButton: XCUIElement {
        app.buttons[AccessibilityIdentifier.Schedule.refreshButton]
    }

    private var eventCells: XCUIElementQuery {
        eventsList.cells.matching(identifier: AccessibilityIdentifier.Schedule.eventCell)
    }

    // MARK: - Actions

    @discardableResult
    func assertScreenIsOpened(timeout: TimeInterval = UITestTimeout.normal) -> Self {
        uiStep("Assert schedule screen is opened") {
            // Try multiple ways to verify screen
            let exists = rootView.waitForExistence(timeout: timeout) ||
                        eventsList.waitForExistence(timeout: timeout) ||
                        emptyState.waitForExistence(timeout: timeout)

            XCTAssertTrue(exists, "Schedule screen should be visible")
        }
        return self
    }

    @discardableResult
    func waitForEvents(timeout: TimeInterval = UITestTimeout.long) -> Self {
        uiStep("Wait for events to load") {
            let predicate = NSPredicate(format: "count > 0")
            let expectation = XCTNSPredicateExpectation(predicate: predicate, object: eventCells)
            _ = XCTWaiter.wait(for: [expectation], timeout: timeout)
        }
        return self
    }

    @discardableResult
    func tapEvent(at index: Int) -> Self {
        uiStep("Tap event at index \(index)") {
            let event = eventCells.element(boundBy: index)
            XCTAssertTrue(event.waitForExistence(timeout: UITestTimeout.normal), "Event cell should exist")
            event.tap()
        }
        return self
    }

    @discardableResult
    func tapRefresh() -> Self {
        uiStep("Tap refresh button") {
            refreshButton.tapAfterWait()
        }
        return self
    }

    @discardableResult
    func pullToRefresh() -> Self {
        uiStep("Pull to refresh") {
            super.pullToRefresh(in: eventsList)
        }
        return self
    }

    @discardableResult
    func scrollToTop() -> Self {
        uiStep("Scroll to top") {
            eventsList.swipeDown(velocity: .fast)
        }
        return self
    }

    @discardableResult
    func scrollToBottom() -> Self {
        uiStep("Scroll to bottom") {
            eventsList.swipeUp(velocity: .fast)
        }
        return self
    }

    // MARK: - Assertions

    @discardableResult
    func assertHasEvents() -> Self {
        uiStep("Assert has events") {
            XCTAssertGreaterThan(eventCells.count, 0, "Should have events")
        }
        return self
    }

    @discardableResult
    func assertEmptyState() -> Self {
        uiStep("Assert empty state is shown") {
            XCTAssertTrue(emptyState.exists, "Empty state should be visible")
        }
        return self
    }

    @discardableResult
    func assertEventCount(_ count: Int) -> Self {
        uiStep("Assert event count is \(count)") {
            XCTAssertEqual(eventCells.count, count, "Event count should match")
        }
        return self
    }

    @discardableResult
    func assertEventExists(withText text: String) -> Self {
        uiStep("Assert event exists with text '\(text)'") {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
            let event = eventsList.staticTexts.containing(predicate).firstMatch
            XCTAssertTrue(event.exists, "Event with text '\(text)' should exist")
        }
        return self
    }

    override func assertScreenIsVisible(timeout: TimeInterval, file: StaticString, line: UInt) {
        assertScreenIsOpened(timeout: timeout)
    }
}
