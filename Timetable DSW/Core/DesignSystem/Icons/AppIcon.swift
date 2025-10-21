//
//  AppIcon.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

enum AppIcon {
    // MARK: - Navigation
    case calendar
    case people
    case gear
    case chevronLeft
    case chevronRight
    case chevronUp
    case chevronDown
    case chevronLeftCircleFill
    case chevronRightCircleFill
    
    // MARK: - Actions
    case checkmark
    case xmark
    case plus
    case minus
    case trash
    case docOnDoc
    case arrowClockwise
    case pencil
    case squareAndArrowUp
    
    // MARK: - Status
    case checkmarkCircleFill
    case exclamationTriangleFill
    case exclamationMarkCircle
    case infoCircle
    case wifiSlash
    case wifi
    case circle
    case circleFill
    
    // MARK: - Calendar
    case calendarBadgeCheckmark
    case clock
    case clockFill
    
    // MARK: - People
    case person
    case person2
    case person3Fill
    case personFill
    case person2Slash
    
    // MARK: - Search
    case magnifyingGlass
    case listBullet
    case lineHorizontal3DecreaseCircle

    case envelope
    case lockOpen

    // MARK: - System Name
    var systemName: String {
        switch self {
        case .calendar: return "calendar"
        case .people: return "person.2"
        case .gear: return "gear"
        case .chevronLeft: return "chevron.left"
        case .chevronRight: return "chevron.right"
        case .chevronUp: return "chevron.up"
        case .chevronDown: return "chevron.down"
        case .chevronLeftCircleFill: return "chevron.left.circle.fill"
        case .chevronRightCircleFill: return "chevron.right.circle.fill"
            
        case .checkmark: return "checkmark"
        case .xmark: return "xmark"
        case .plus: return "plus"
        case .minus: return "minus"
        case .trash: return "trash"
        case .docOnDoc: return "doc.on.doc"
        case .arrowClockwise: return "arrow.clockwise"
        case .pencil: return "pencil"
        case .squareAndArrowUp: return "square.and.arrow.up"
            
        case .checkmarkCircleFill: return "checkmark.circle.fill"
        case .exclamationTriangleFill: return "exclamationmark.triangle.fill"
        case .exclamationMarkCircle: return "exclamationmark.circle"
        case .infoCircle: return "info.circle"
        case .wifiSlash: return "wifi.slash"
        case .wifi: return "wifi"
        case .circle: return "circle"
        case .circleFill: return "circle.fill"
            
        case .calendarBadgeCheckmark: return "calendar.badge.checkmark"
        case .clock: return "clock"
        case .clockFill: return "clock.fill"
            
        case .person: return "person"
        case .person2: return "person.2"
        case .person3Fill: return "person.3.fill"
        case .personFill: return "person.fill"
        case .person2Slash: return "person.2.slash"
            
        case .magnifyingGlass: return "magnifyingglass"
        case .listBullet: return "list.bullet"
        case .lineHorizontal3DecreaseCircle: return "line.horizontal.3.decrease.circle"

        case .envelope: return "envelope"
        case .lockOpen: return "lock.open"
        }
    }
    
    // MARK: - Image
    func image() -> Image {
        Image(systemName: systemName)
    }
}
