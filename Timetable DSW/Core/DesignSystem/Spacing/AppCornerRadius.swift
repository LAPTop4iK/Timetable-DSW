//
//  AppCornerRadius.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

public enum AppCornerRadius {
    case xs
    case small
    case medium
    case large
    case xl
    case xxl
    case circle
    case custom(CGFloat)
    
    public var value: CGFloat {
        switch self {
        case .xs: return 4
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        case .xl: return 24
        case .xxl: return 32
        case .circle: return 999
        case .custom(let value): return value
        }
    }
}
