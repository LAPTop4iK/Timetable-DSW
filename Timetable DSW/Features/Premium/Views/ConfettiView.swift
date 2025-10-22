//
//  ConfettiView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import SwiftUI

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let x: CGFloat
    let y: CGFloat
    let rotation: Double
    let scale: CGFloat
}

// MARK: - Confetti View

struct ConfettiView: View {
    // MARK: - Configuration

    struct Configuration {
        let particleCount: Int
        let animationDuration: Double
        let colors: [Color]

        static let `default` = Configuration(
            particleCount: 50,
            animationDuration: 3.0,
            colors: GradientStyle.primary.colors(for: .light)
        )

        static let rainbow = Configuration(
            particleCount: 60,
            animationDuration: 3.5,
            colors: [
                .red, .orange, .yellow,
                .green, .cyan, .blue,
                .purple, .pink
            ]
        )
    }

    // MARK: - Properties

    let configuration: Configuration
    let onComplete: () -> Void

    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    complete()
                }

            // Particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 10 * particle.scale, height: 10 * particle.scale)
                    .rotationEffect(.degrees(isAnimating ? particle.rotation + 720 : particle.rotation))
                    .offset(
                        x: particle.x,
                        y: isAnimating ? UIScreen.main.bounds.height : particle.y
                    )
                    .opacity(isAnimating ? 0 : 1)
            }

            // Center message
            VStack(spacing: AppSpacing.large.value) {
                Text("🎉")
                    .font(.system(size: 100))
                    .scaleEffect(isAnimating ? 1.0 : 0.5)

                Text(LocalizedString.premiumUnlocked.localized)
                    .font(AppTypography.title.font)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0)
            }
        }
        .onAppear {
            generateParticles()
            withAnimation(.easeOut(duration: configuration.animationDuration)) {
                isAnimating = true
            }

            // Auto-dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + configuration.animationDuration) {
                complete()
            }
        }
    }

    // MARK: - Private Methods

    private func generateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        particles = (0..<configuration.particleCount).map { _ in
            ConfettiParticle(
                color: configuration.colors.randomElement() ?? .blue,
                x: CGFloat.random(in: -screenWidth/2...screenWidth/2),
                y: CGFloat.random(in: (-screenHeight)/2...(-100)),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
        }
    }

    private func complete() {
        onComplete()
    }
}

// MARK: - Confetti Modifier

struct ConfettiModifier: ViewModifier {
    @Binding var isShowing: Bool
    let configuration: ConfettiView.Configuration

    func body(content: Content) -> some View {
        ZStack {
            content

            if isShowing {
                ConfettiView(configuration: configuration) {
                    isShowing = false
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
    }
}

extension View {
    func confetti(
        isShowing: Binding<Bool>,
        configuration: ConfettiView.Configuration = .rainbow
    ) -> some View {
        modifier(
            ConfettiModifier(
                isShowing: isShowing,
                configuration: configuration
            )
        )
    }
}
