//
//  HapticFeedbackService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import UIKit

protocol HapticFeedbackService {
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    func selection()
    func notification(type: UINotificationFeedbackGenerator.FeedbackType)
}
