//
//  DefaultHapticFeedbackService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import UIKit

final class DefaultHapticFeedbackService: HapticFeedbackService {
    // MARK: - HapticFeedbackService Implementation
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
