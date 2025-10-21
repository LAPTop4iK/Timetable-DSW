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
            static let lecture = ["wyk", "лекц"]
            static let exercise = ["ćw", "cw", "практ"]
            static let laboratory = ["lab", "лаб"]
            static let online = ["online", "онлайн", "teams", "zoom", "distance"]
            static let cancelled = ["zajęcia odwołane", "odwołane"];
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
