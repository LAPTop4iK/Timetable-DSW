//
//  ErrorView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct ErrorView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let iconSize: CGFloat = AppDimensions.iconXL.value * 2
            let spacing: AppSpacing = .xl
            let buttonPadding: EdgeInsets = .init(
                top: AppSpacing.medium.value,
                leading: AppSpacing.xxl.value,
                bottom: AppSpacing.medium.value,
                trailing: AppSpacing.xxl.value
            )
            let containerPadding: AppSpacing = .xxl
            let shadowRadius: CGFloat = 8
            let shadowY: CGFloat = 4
            let glowOpacity: Double = 0.3
            let gradientOpacity: Double = 0.9
            let glowStartRadius: CGFloat = 5
            let glowEndRadius: CGFloat = 40
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    let message: String
    let onRetry: () -> Void
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let hapticService: HapticFeedbackService
    
    // MARK: - Initialization
    
    init(
        message: String,
        onRetry: @escaping () -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self.message = message
        self.onRetry = onRetry
        self.hapticService = hapticService
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Configuration.constants.spacing.value) {
            iconView
            messageView
            retryButton
        }
        .padding(Configuration.constants.containerPadding.value)
    }
    
    // MARK: - Subviews
    
    private var iconView: some View {
        ZStack {
            // Glow background for liquid glass effect
            Circle()
                .fill(
                    LinearGradient(
                        colors: iconGradientColors.map { $0.opacity(0.15) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: Configuration.constants.iconSize * 1.2, height: Configuration.constants.iconSize * 1.2)
                .blur(radius: 20)

            AppIcon.exclamationTriangleFill.image()
                .font(.system(size: Configuration.constants.iconSize))
                .foregroundStyle(
                    LinearGradient(
                        colors: iconGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: iconGradientColors.first?.opacity(0.3) ?? .clear,
                    radius: 10,
                    x: 0,
                    y: 4
                )
        }
    }
    
    private var messageView: some View {
        Text(message)
            .font(AppTypography.body.font)
            .multilineTextAlignment(.center)
            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var retryButton: some View {
        Button(action: handleRetry) {
            Text(LocalizedString.generalRetry.localized)
                .font(AppTypography.custom(size: 16, weight: .semibold).font)
                .foregroundAppColor(.white, colorScheme: colorScheme)
                .padding(Configuration.constants.buttonPadding)
                .background {
                    buttonBackground
                }
                .shadow(
                    color: gradientColors[0].opacity(Configuration.constants.gradientOpacity - 0.5),
                    radius: Configuration.constants.shadowRadius,
                    x: 0,
                    y: Configuration.constants.shadowY
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var buttonBackground: some View {
        ZStack {
            Capsule()
                .fill(.ultraThinMaterial)
            
            Capsule()
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(Configuration.constants.gradientOpacity)
            
            Capsule()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.white.color(for: colorScheme).opacity(Configuration.constants.glowOpacity),
                            AppColor.clear.color(for: colorScheme)
                        ],
                        center: .topLeading,
                        startRadius: Configuration.constants.glowStartRadius,
                        endRadius: Configuration.constants.glowEndRadius
                    )
                )
        }
    }
    
    // MARK: - Computed Properties

    private var gradientColors: [Color] {
        // Use warning gradient (orange-red) to indicate error while maintaining app aesthetic
        // This is less harsh than pure error red but still clearly communicates issue
        GradientStyle.warning.colors(for: colorScheme)
    }

    private var iconGradientColors: [Color] {
        // Icon uses primary gradient for softer, app-consistent look
        GradientStyle.primary.colors(for: colorScheme)
    }
    
    // MARK: - Actions
    
    private func handleRetry() {
        hapticService.impact(style: .medium)
        onRetry()
    }
}