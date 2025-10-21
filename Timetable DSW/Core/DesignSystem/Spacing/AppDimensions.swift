//
//  AppDimensions.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Foundation

enum AppDimensions {
    // MARK: - Icons
    case iconXS
    case iconSmall
    case iconMedium
    case iconLarge
    case iconXL
    
    // MARK: - Avatar
    case avatarSmall
    case avatarMedium
    case avatarLarge
    
    // MARK: - Components
    case chipMinHeight
    case chipCompactHeight
    case chipMaxHeight
    case tabBarHeight
    case headerMinHeight
    case buttonHeight
    
    // MARK: - Lines
    case lineXS
    case lineSmall
    case lineMedium
    
    // MARK: - Dots
    case dotSmall
    case dotMedium
    case dotLarge
    
    // MARK: - Gestures
    case minimumSwipeDistance
    case weekChangeThreshold
    
    var value: CGFloat {
        switch self {
        // Icons
        case .iconXS: return 12
        case .iconSmall: return 16
        case .iconMedium: return 20
        case .iconLarge: return 24
        case .iconXL: return 32
            
        // Avatar
        case .avatarSmall: return 32
        case .avatarMedium: return 40
        case .avatarLarge: return 48
            
        // Components
        case .chipMinHeight: return 56
        case .chipCompactHeight: return 58
        case .chipMaxHeight: return 72
        case .tabBarHeight: return 70
        case .headerMinHeight: return 200
        case .buttonHeight: return 44
            
        // Lines
        case .lineXS: return 1
        case .lineSmall: return 2
        case .lineMedium: return 4
            
        // Dots
        case .dotSmall: return 4
        case .dotMedium: return 6
        case .dotLarge: return 8
            
        // Gestures
        case .minimumSwipeDistance: return 30
        case .weekChangeThreshold: return 100
        }
    }
}
