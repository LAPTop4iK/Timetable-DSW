//
//  EventDayType.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 19/10/2025.
//


import Foundation

/// Тип содержимого дня: нет занятий, только онлайн, или обычные (в т.ч. смешанные).
enum EventDayType: Equatable {
    case none
    case onlineOnly
    case regular
}