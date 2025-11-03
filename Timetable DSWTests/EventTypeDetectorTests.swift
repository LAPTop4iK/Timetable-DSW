//
//  EventTypeDetectorTests.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Testing
@testable import Timetable_DSW

@Suite("EventTypeDetector Tests")
struct EventTypeDetectorTests {

    let sut = DefaultEventTypeDetector()

    // MARK: - Event Type Detection Tests

    @Suite("Event Type Detection")
    struct EventTypeDetectionTests {
        let sut = DefaultEventTypeDetector()

        @Test("Detect lecture types", arguments: [
            "wyk",
            "wykład",
            "лекция",
            "lecture"
        ])
        func detectLectureType(typeString: String) {
            // When
            let result = sut.detectEventType(from: typeString)

            // Then
            #expect(result == .lecture)
        }

        @Test("Detect exercise types", arguments: [
            "ćwiczenia",
            "cw",
            "ćw",
            "практика",
            "exercise"
        ])
        func detectExerciseType(typeString: String) {
            // When
            let result = sut.detectEventType(from: typeString)

            // Then
            #expect(result == .exercise)
        }

        @Test("Detect laboratory types", arguments: [
            "laboratorium",
            "lab",
            "лабораторная",
            "лаб"
        ])
        func detectLaboratoryType(typeString: String) {
            // When
            let result = sut.detectEventType(from: typeString)

            // Then
            #expect(result == .laboratory)
        }

        @Test("Detect other/unknown type", arguments: [
            "seminar",
            "workshop",
            "consultation",
            "exam"
        ])
        func detectOtherType(typeString: String) {
            // When
            let result = sut.detectEventType(from: typeString)

            // Then
            #expect(result == .other)
        }

        @Test("Return other for nil type")
        func detectTypeWithNilValue() {
            // Given
            let type: String? = nil

            // When
            let result = sut.detectEventType(from: type)

            // Then
            #expect(result == .other)
        }

        @Test("Event type detection is case insensitive", arguments: [
            "WYK",
            "wyk",
            "WyK",
            "WYKŁAD"
        ])
        func caseInsensitiveDetection(typeString: String) {
            // When
            let result = sut.detectEventType(from: typeString)

            // Then
            #expect(result == .lecture)
        }
    }

    // MARK: - Online Detection Tests

    @Suite("Online Detection")
    struct OnlineDetectionTests {
        let sut = DefaultEventTypeDetector()

        @Test("Detect online keywords", arguments: [
            "online meeting",
            "zajęcia онлайн",
            "Microsoft Teams meeting",
            "Zoom conference",
            "distance learning",
            "meet.google.com",
            "remote"
        ])
        func detectOnlineKeywords(remarks: String) {
            // When
            let result = sut.isOnline(remarks: remarks)

            // Then
            #expect(result == true)
        }

        @Test("Offline remarks are not detected as online", arguments: [
            "Room 201",
            "Bring your laptop",
            "Building A",
            "In-person meeting"
        ])
        func offlineRemarksNotOnline(remarks: String) {
            // When
            let result = sut.isOnline(remarks: remarks)

            // Then
            #expect(result == false)
        }

        @Test("Return false for nil remarks")
        func nilRemarksNotOnline() {
            // Given
            let remarks: String? = nil

            // When
            let result = sut.isOnline(remarks: remarks)

            // Then
            #expect(result == false)
        }

        @Test("Online detection is case insensitive", arguments: [
            "ONLINE",
            "online",
            "OnLiNe",
            "TEAMS",
            "teams",
            "Teams"
        ])
        func caseInsensitiveOnlineDetection(remarks: String) {
            // When
            let result = sut.isOnline(remarks: remarks)

            // Then
            #expect(result == true)
        }
    }

    // MARK: - Cancelled Detection Tests

    @Suite("Cancelled Detection")
    struct CancelledDetectionTests {
        let sut = DefaultEventTypeDetector()

        @Test("Detect cancelled keywords", arguments: [
            "zajęcia odwołane",
            "odwołane",
            "cancelled",
            "canceled",
            "отменено"
        ])
        func detectCancelledKeywords(remarks: String) {
            // When
            let result = sut.isCancelled(remarks: remarks)

            // Then
            #expect(result == true)
        }

        @Test("Normal remarks are not cancelled", arguments: [
            "Room 201, bring your laptop",
            "Building A",
            "Regular class"
        ])
        func normalRemarksNotCancelled(remarks: String) {
            // When
            let result = sut.isCancelled(remarks: remarks)

            // Then
            #expect(result == false)
        }

        @Test("Return false for nil remarks")
        func nilRemarksNotCancelled() {
            // Given
            let remarks: String? = nil

            // When
            let result = sut.isCancelled(remarks: remarks)

            // Then
            #expect(result == false)
        }

        @Test("Cancelled detection is case insensitive", arguments: [
            "ODWOŁANE",
            "odwołane",
            "OdWołAnE",
            "CANCELLED",
            "Cancelled"
        ])
        func caseInsensitiveCancelledDetection(remarks: String) {
            // When
            let result = sut.isCancelled(remarks: remarks)

            // Then
            #expect(result == true)
        }
    }
}
