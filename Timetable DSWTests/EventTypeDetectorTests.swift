//
//  EventTypeDetectorTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import XCTest
@testable import Timetable_DSW

final class EventTypeDetectorTests: XCTestCase {

    var sut: DefaultEventTypeDetector!

    override func setUp() {
        super.setUp()
        sut = DefaultEventTypeDetector()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Event Type Detection Tests

    func testDetectLectureType_WithPolishKeyword() {
        // Given
        let type = "wyk"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .lecture, "Should detect 'wyk' as lecture")
    }

    func testDetectLectureType_WithRussianKeyword() {
        // Given
        let type = "лекция"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .lecture, "Should detect 'лекц' as lecture")
    }

    func testDetectExerciseType_WithPolishKeyword() {
        // Given
        let type = "ćwiczenia"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .exercise, "Should detect 'ćw' as exercise")
    }

    func testDetectExerciseType_WithCwKeyword() {
        // Given
        let type = "cw"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .exercise, "Should detect 'cw' as exercise")
    }

    func testDetectExerciseType_WithRussianKeyword() {
        // Given
        let type = "практика"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .exercise, "Should detect 'практ' as exercise")
    }

    func testDetectLaboratoryType_WithPolishKeyword() {
        // Given
        let type = "laboratorium"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .laboratory, "Should detect 'lab' as laboratory")
    }

    func testDetectLaboratoryType_WithRussianKeyword() {
        // Given
        let type = "лабораторная"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .laboratory, "Should detect 'лаб' as laboratory")
    }

    func testDetectOtherType_WithUnknownKeyword() {
        // Given
        let type = "seminar"

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .other, "Should detect unknown type as other")
    }

    func testDetectType_WithNilValue() {
        // Given
        let type: String? = nil

        // When
        let result = sut.detectEventType(from: type)

        // Then
        XCTAssertEqual(result, .other, "Should return other for nil type")
    }

    func testDetectType_CaseInsensitive() {
        // Given
        let typeUpperCase = "WYK"
        let typeLowerCase = "wyk"
        let typeMixedCase = "WyK"

        // When
        let resultUpper = sut.detectEventType(from: typeUpperCase)
        let resultLower = sut.detectEventType(from: typeLowerCase)
        let resultMixed = sut.detectEventType(from: typeMixedCase)

        // Then
        XCTAssertEqual(resultUpper, .lecture, "Should be case insensitive")
        XCTAssertEqual(resultLower, .lecture, "Should be case insensitive")
        XCTAssertEqual(resultMixed, .lecture, "Should be case insensitive")
    }

    // MARK: - Online Detection Tests

    func testIsOnline_WithOnlineKeyword() {
        // Given
        let remarks = "online meeting"

        // When
        let result = sut.isOnline(remarks: remarks)

        // Then
        XCTAssertTrue(result, "Should detect 'online' keyword")
    }

    func testIsOnline_WithRussianOnlineKeyword() {
        // Given
        let remarks = "занятие онлайн"

        // When
        let result = sut.isOnline(remarks: remarks)

        // Then
        XCTAssertTrue(result, "Should detect 'онлайн' keyword")
    }

    func testIsOnline_WithTeamsKeyword() {
        // Given
        let remarks = "Microsoft Teams meeting"

        // When
        let result = sut.isOnline(remarks: remarks)

        // Then
        XCTAssertTrue(result, "Should detect 'teams' keyword")
    }

    func testIsOnline_WithZoomKeyword() {
        // Given
        let remarks = "Zoom conference"

        // When
        let result = sut.isOnline(remarks: remarks)

        // Then
        XCTAssertTrue(result, "Should detect 'zoom' keyword")
    }

    func testIsOnline_WithDistanceKeyword() {
        // Given
        let remarks = "distance learning"

        // When
        let result = sut.isOnline(remarks: remarks)

        // Then
        XCTAssertTrue(result, "Should detect 'distance' keyword")
    }

    func testIsOnline_WithOfflineRemarks() {
        // Given
        let remarks = "Room 201"

        // When
        let result = sut.isOnline(remarks: remarks)

        // Then
        XCTAssertFalse(result, "Should not detect online for offline remarks")
    }

    func testIsOnline_WithNilRemarks() {
        // Given
        let remarks: String? = nil

        // When
        let result = sut.isOnline(remarks: remarks)

        // Then
        XCTAssertFalse(result, "Should return false for nil remarks")
    }

    func testIsOnline_CaseInsensitive() {
        // Given
        let remarksUpper = "ONLINE"
        let remarksLower = "online"
        let remarksMixed = "OnLiNe"

        // When
        let resultUpper = sut.isOnline(remarks: remarksUpper)
        let resultLower = sut.isOnline(remarks: remarksLower)
        let resultMixed = sut.isOnline(remarks: remarksMixed)

        // Then
        XCTAssertTrue(resultUpper, "Should be case insensitive")
        XCTAssertTrue(resultLower, "Should be case insensitive")
        XCTAssertTrue(resultMixed, "Should be case insensitive")
    }

    // MARK: - Cancelled Detection Tests

    func testIsCancelled_WithPolishCancelledKeyword() {
        // Given
        let remarks = "zajęcia odwołane"

        // When
        let result = sut.isCancelled(remarks: remarks)

        // Then
        XCTAssertTrue(result, "Should detect 'zajęcia odwołane' as cancelled")
    }

    func testIsCancelled_WithOdwolaneKeyword() {
        // Given
        let remarks = "odwołane"

        // When
        let result = sut.isCancelled(remarks: remarks)

        // Then
        XCTAssertTrue(result, "Should detect 'odwołane' as cancelled")
    }

    func testIsCancelled_WithNormalRemarks() {
        // Given
        let remarks = "Room 201, bring your laptop"

        // When
        let result = sut.isCancelled(remarks: remarks)

        // Then
        XCTAssertFalse(result, "Should not detect normal remarks as cancelled")
    }

    func testIsCancelled_WithNilRemarks() {
        // Given
        let remarks: String? = nil

        // When
        let result = sut.isCancelled(remarks: remarks)

        // Then
        XCTAssertFalse(result, "Should return false for nil remarks")
    }

    func testIsCancelled_CaseInsensitive() {
        // Given
        let remarksUpper = "ODWOŁANE"
        let remarksLower = "odwołane"
        let remarksMixed = "OdWołAnE"

        // When
        let resultUpper = sut.isCancelled(remarks: remarksUpper)
        let resultLower = sut.isCancelled(remarks: remarksLower)
        let resultMixed = sut.isCancelled(remarks: remarksMixed)

        // Then
        XCTAssertTrue(resultUpper, "Should be case insensitive")
        XCTAssertTrue(resultLower, "Should be case insensitive")
        XCTAssertTrue(resultMixed, "Should be case insensitive")
    }
}
