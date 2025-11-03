//
//  MockEventTypeDetector.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

// MARK: - Mock Event Type Detector

/// Mock implementation of EventTypeDetector for testing
/// Allows control over event type detection behavior
final class MockEventTypeDetector: EventTypeDetector {

    // MARK: - Call Tracking

    private(set) var detectEventTypeCallCount: Int = 0
    private(set) var isOnlineCallCount: Int = 0
    private(set) var isCancelledCallCount: Int = 0

    // MARK: - Mock Responses

    var mockedEventType: EventType = .other
    var mockedIsOnline: Bool = false
    var mockedIsCancelled: Bool = false

    // MARK: - EventTypeDetector Protocol Implementation

    func detectEventType(from type: String?) -> EventType {
        detectEventTypeCallCount += 1
        return mockedEventType
    }

    func isOnline(remarks: String?) -> Bool {
        isOnlineCallCount += 1
        return mockedIsOnline
    }

    func isCancelled(remarks: String?) -> Bool {
        isCancelledCallCount += 1
        return mockedIsCancelled
    }

    // MARK: - Configuration Methods

    func setMockedEventType(_ type: EventType) {
        mockedEventType = type
    }

    func setMockedIsOnline(_ isOnline: Bool) {
        mockedIsOnline = isOnline
    }

    func setMockedIsCancelled(_ isCancelled: Bool) {
        mockedIsCancelled = isCancelled
    }

    func reset() {
        detectEventTypeCallCount = 0
        isOnlineCallCount = 0
        isCancelledCallCount = 0
        mockedEventType = .other
        mockedIsOnline = false
        mockedIsCancelled = false
    }

    // MARK: - Verification Methods

    func verifyDetectEventTypeCalled(times: Int) -> Bool {
        detectEventTypeCallCount == times
    }

    func verifyIsOnlineCalled(times: Int) -> Bool {
        isOnlineCallCount == times
    }

    func verifyIsCancelledCalled(times: Int) -> Bool {
        isCancelledCallCount == times
    }
}
