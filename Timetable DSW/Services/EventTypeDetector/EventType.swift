//
//  EventType.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

// MARK: - Event Type

enum EventType {
    case lecture
    case exercise
    case laboratory
    case other
}

// MARK: - Protocol

protocol EventTypeDetector {
    func detectEventType(from type: String?) -> EventType
    func isOnline(remarks: String?) -> Bool
    func isCancelled(remarks: String?) -> Bool
}
