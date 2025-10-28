//
//  SiriStyleBorderEffect.swift
//  Timetable DSW
//
//  Siri-style gradient border animation
//

import SwiftUI

struct SiriStyleBorderEffect: ViewModifier {
    let isActive: Bool

    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if isActive {
                        // Rotating gradient border - optimized
                        RoundedRectangle(cornerRadius: 0)
                            .strokeBorder(
                                AngularGradient(
                                    colors: GradientStyle.primary.colors(for: colorScheme),
                                    center: .center,
                                    startAngle: .degrees(rotation),
                                    endAngle: .degrees(rotation + 360)
                                ),
                                lineWidth: 4  // Reduced from 8 to 4
                            )
                            .blur(radius: 8)  // Reduced from 16 to 8 - major performance gain
                            .opacity(opacity)
                            .drawingGroup()  // Render in offscreen buffer - major performance gain
                    }
                }
                .allowsHitTesting(false)
            )
            .ignoresSafeArea()
            .onChange(of: isActive) { newValue in
                if newValue {
                    withAnimation(.easeIn(duration: 0.2)) {
                        opacity = 1.0
                    }

                    withAnimation(.linear(duration: 2.0).repeatCount(2, autoreverses: false)) {
                        rotation = 720
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            opacity = 0
                        }
                    }
                } else {
                    rotation = 0
                    opacity = 0
                }
            }
    }
}

extension View {
    func siriStyleBorder(isActive: Bool) -> some View {
        modifier(SiriStyleBorderEffect(isActive: isActive))
    }
}
