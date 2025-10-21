//
//  AppTypography.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

enum AppTypography {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case bodyMedium
    case bodySemibold
    case callout
    case caption
    case caption2
    case footnote
    case custom(size: CGFloat, weight: Font.Weight)
    
    var font: Font {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .bodyMedium: return .system(size: 17, weight: .medium)
        case .bodySemibold: return .system(size: 17, weight: .semibold)
        case .callout: return .callout
        case .caption: return .caption
        case .caption2: return .caption2
        case .footnote: return .footnote
        case .custom(let size, let weight): return .system(size: size, weight: weight)
        }
    }
}