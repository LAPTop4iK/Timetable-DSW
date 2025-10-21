//
//  CalendarHelper.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


//
//  CalendarHelper.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import Foundation

enum CalendarHelper {
    /// Генерирует массив дат внутри заданного интервала
    /// - Parameters:
    ///   - calendar: Calendar для использования
    ///   - interval: Интервал дат
    ///   - components: Компоненты для поиска совпадений
    /// - Returns: Массив дат
    static func generateDates(
        in calendar: Calendar,
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        
        calendar.enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
        return dates
    }
}