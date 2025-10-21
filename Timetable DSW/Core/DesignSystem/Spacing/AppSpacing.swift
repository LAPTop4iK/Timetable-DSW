//
//  AppSpacing.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

enum AppSpacing {
    case xxs
    case xs
    case small
    case medium
    case large
    case xl
    case xxl
    case xxxl
    case custom(CGFloat)
    
    var value: CGFloat {
        switch self {
        case .xxs: return 2
        case .xs: return 4
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        case .xl: return 20
        case .xxl: return 24
        case .xxxl: return 32
        case .custom(let value): return value
        }
    }
}
