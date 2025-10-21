//
//  EventsProviderProtocol.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

protocol EventsProviderProtocol {
    func eventsForDate(_ date: Date) -> [ScheduleEvent]
    func hasEventsOn(date: Date) -> Bool
    func eventType(on date: Date) -> EventDayType
}
