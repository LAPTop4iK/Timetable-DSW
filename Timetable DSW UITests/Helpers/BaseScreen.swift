//
//  BaseScreen.swift
//  Timetable DSW UITests
//
//  Created by Claude on 03/11/2025.
//

import XCTest

// MARK: - Base Screen (Page Object Pattern)

/// Base class for all screen objects
/// Implements common screen behaviors and utilities
@MainActor
class BaseScreen {

    // MARK: - Properties

    let app: XCUIApplication

    // MARK: - Initialization

    init(_ app: XCUIApplication) {
        self.app = app
    }

    // MARK: - Common Actions

    /// Wait for screen to load
    @discardableResult
    func waitForScreenToLoad(timeout: TimeInterval = UITestTimeout.normal) -> Self {
        Thread.sleep(forTimeInterval: 0.5) // Give screen time to appear
        return self
    }

    /// Navigate back
    @discardableResult
    func navigateBack() -> Self {
        app.navigationBars.buttons.element(boundBy: 0).tap()
        return self
    }

    /// Dismiss modal
    @discardableResult
    func dismissModal() -> Self {
        if app.buttons[AccessibilityIdentifier.Common.closeButton].exists {
            app.buttons[AccessibilityIdentifier.Common.closeButton].tap()
        }
        return self
    }

    /// Pull to refresh
    @discardableResult
    func pullToRefresh(in element: XCUIElement) -> Self {
        let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        let end = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9))
        start.press(forDuration: 0.1, thenDragTo: end)
        return self
    }

    /// Take screenshot of current screen
    @discardableResult
    func takeScreenshot(named name: String) -> Self {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        return self
    }

    // MARK: - Assertions

    /// Assert screen is visible
    func assertScreenIsVisible(timeout: TimeInterval = UITestTimeout.normal, file: StaticString = #file, line: UInt = #line) {
        // Override in subclasses
        fatalError("Override assertScreenIsVisible in subclass")
    }

    /// Assert loading indicator
    func assertIsLoading(file: StaticString = #file, line: UInt = #line) {
        let loadingIndicator = app.activityIndicators[AccessibilityIdentifier.Common.loadingIndicator]
        XCTAssertTrue(loadingIndicator.exists, "Loading indicator should be visible", file: file, line: line)
    }

    /// Assert not loading
    func assertIsNotLoading(timeout: TimeInterval = UITestTimeout.normal, file: StaticString = #file, line: UInt = #line) {
        let loadingIndicator = app.activityIndicators[AccessibilityIdentifier.Common.loadingIndicator]
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: loadingIndicator)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "Loading indicator should disappear", file: file, line: line)
    }
}
