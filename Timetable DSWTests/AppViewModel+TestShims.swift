//
//  AppViewModel+TestShims.swift
//  Timetable DSWTests
//
//  Created by Claude on 03/11/2025.
//

import Foundation
@testable import Timetable_DSW

extension AppViewModel {
    // Test-friendly wrappers that forward to production API
    func hasEvents(on date: Date) -> Bool { hasEventsOn(date: date) }
    func events(for date: Date) -> [ScheduleEvent] { eventsForDate(date) }
    func eventType(for date: Date) -> EventDayType { eventType(on: date) }
}
