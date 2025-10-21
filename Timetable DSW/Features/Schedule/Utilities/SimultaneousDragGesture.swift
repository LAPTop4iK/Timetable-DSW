//
//  SimultaneousDragGesture.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

// MARK: - Simultaneous Drag Gesture (iOS 18 fix)

struct SimultaneousDragGesture: UIGestureRecognizerRepresentable {
    // MARK: - Properties
    
    let onChanged: (DragValue) -> Void
    let onEnded: (DragValue) -> Void
    
    // MARK: - Drag Value
    
    struct DragValue {
        let translation: CGSize
        let location: CGPoint
    }
    
    // MARK: - UIGestureRecognizerRepresentable
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        let translation = recognizer.translation(in: recognizer.view)
        let location = recognizer.location(in: recognizer.view)
        
        let value = DragValue(
            translation: CGSize(width: translation.x, height: translation.y),
            location: location
        )
        
        switch recognizer.state {
        case .began, .changed:
            onChanged(value)
        case .ended, .cancelled:
            onEnded(value)
        default:
            break
        }
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}