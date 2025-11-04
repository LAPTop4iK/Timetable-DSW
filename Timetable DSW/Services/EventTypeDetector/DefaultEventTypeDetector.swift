//
//  DefaultEventTypeDetector.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

final class DefaultEventTypeDetector: EventTypeDetector {
    // MARK: - Configuration
    
    struct Configuration {
        struct Keywords {
            static let lecture = ["wyk", "лекц", "lecture"]
            static let exercise = ["ćw", "cw", "практ", "exercise"]
            static let laboratory = ["lab", "лаб"]
            static let online = ["online", "онлайн", "teams", "zoom", "distance", "remote", "meet.google.com"]
            static let cancelled = ["zajęcia odwołane", "odwołane", "cancelled", "canceled", "отменено"]
        }
    }
    
    // MARK: - EventTypeDetector Implementation
    
    func detectEventType(from type: String?) -> EventType {
        guard let type = type?.lowercased() else { return .other }
        
        if Configuration.Keywords.lecture.contains(where: { type.contains($0) }) {
            return .lecture
        }
        
        if Configuration.Keywords.exercise.contains(where: { type.contains($0) }) {
            return .exercise
        }
        
        if Configuration.Keywords.laboratory.contains(where: { type.contains($0) }) {
            return .laboratory
        }
        
        return .other
    }
    
    func isOnline(remarks: String?) -> Bool {
        let remarksLower = remarks?.lowercased() ?? ""
        
        return Configuration.Keywords.online.contains { keyword in
            remarksLower.contains(keyword)
        }
    }

    func isCancelled(remarks: String?) -> Bool {
        let remarksLower = remarks?.lowercased() ?? ""
        
        return Configuration.Keywords.cancelled.contains { keyword in
            remarksLower.contains(keyword)
        }
    }
}

struct EventPresentationInfo {
    let kind: EventType        // lecture / exercise / lab / other
    let isOnline: Bool         // пара онлайн?
    let isCancelled: Bool      // пара отменена?

    init(event: ScheduleEvent,
                detector: EventTypeDetector = DefaultEventTypeDetector()) {
        self.kind = detector.detectEventType(from: event.type)
        self.isOnline = detector.isOnline(remarks: event.remarks)
        self.isCancelled = detector.isCancelled(remarks: event.remarks)
    }
}
