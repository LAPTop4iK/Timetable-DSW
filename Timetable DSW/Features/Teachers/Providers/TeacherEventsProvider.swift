//
//  TeacherEventsProvider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

final class TeacherEventsProvider: EventsProviderProtocol {
    // MARK: - Properties
    
    let teacher: Teacher
    private let calendar: Calendar
    private let eventTypeDetector: EventTypeDetector

    // MARK: - Initialization
    
    init(teacher: Teacher,
         calendar: Calendar = .current,
         eventTypeDetector: EventTypeDetector = DefaultEventTypeDetector()) {
        self.teacher = teacher
        self.calendar = calendar
        self.eventTypeDetector = eventTypeDetector
    }

    // MARK: - EventsProviderProtocol
    
    func eventsForDate(_ date: Date) -> [ScheduleEvent] {
        teacher.schedule.filter { ev in
            guard let d = ev.startDate else { return false }
            return calendar.isDate(d, inSameDayAs: date)
        }
    }

    func hasEventsOn(date: Date) -> Bool {
        eventType(on: date) != .none
    }

    func eventType(on date: Date) -> EventDayType {
        let events = eventsForDate(date)
        guard !events.isEmpty else { return .none }
        let allOnline = events.allSatisfy { ev in
            eventTypeDetector.isOnline(remarks: ev.remarks)
        }
        return allOnline ? .onlineOnly : .regular
    }
}
