//
//  ScaleButtonStyle.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    // MARK: - Configuration
    
    struct Configuration {
        struct Constants {
            let pressedScale: Double = 0.95
            let springResponse: Double = 0.3
            let springDamping: Double = 0.6
        }
        
        static let constants = Constants()
    }
    
    // MARK: - ButtonStyle
    
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Configuration.constants.pressedScale : 1.0)
            .animation(
                .spring(
                    response: Configuration.constants.springResponse,
                    dampingFraction: Configuration.constants.springDamping
                ),
                value: configuration.isPressed
            )
    }
}