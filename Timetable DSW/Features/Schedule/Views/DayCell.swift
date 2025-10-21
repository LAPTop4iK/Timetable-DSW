//
//  DayCell.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct DayCell: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let height: CGFloat = AppDimensions.buttonHeight.value
            let cornerRadius: AppCornerRadius = .medium
            let borderWidth: CGFloat = AppDimensions.lineSmall.value
            let dotSize: CGFloat = AppDimensions.dotSmall.value
            let spacing: AppSpacing = .xxs
            let tapThreshold: CGFloat = 10
            let backgroundOpacity: Double = 0.5
            let inactiveBackgroundOpacity: Double = 0.2
            let selectedOpacity: Double = 0.9
            let selectedScale: Double = 1.05
            let shadowRadius: CGFloat = 6
            let shadowY: CGFloat = 3
            let shadowOpacity: Double = 0.4
            let glowOpacity: Double = 0.3
            let glowStartRadius: CGFloat = 5
            let glowEndRadius: CGFloat = 30
            let inactiveTextOpacity: Double = 0.3
            let dotOpacity: Double = 0.9
        }
        static let constants = Constants()
    }

    // MARK: - Props
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let eventType: EventDayType
    let isCurrentMonth: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    private let hapticService: HapticFeedbackService

    @State private var dragStart: CGPoint?

    init(
        date: Date,
        isSelected: Bool,
        isToday: Bool,
        eventType: EventDayType,
        isCurrentMonth: Bool,
        action: @escaping () -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self.date = date
        self.isSelected = isSelected
        self.isToday = isToday
        self.eventType = eventType
        self.isCurrentMonth = isCurrentMonth
        self.action = action
        self.hapticService = hapticService
    }

    var body: some View {
        contentView
            .contentShape(Rectangle())
            .disabled(!isCurrentMonth)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged(handleDragChanged)
                    .onEnded(handleDragEnded)
            )
    }

    private var contentView: some View {
        VStack(spacing: Configuration.constants.spacing.value) {
            dayNumberText
            indicator
        }
        .frame(maxWidth: .infinity)
        .frame(height: Configuration.constants.height)
        .background { backgroundView }
        .overlay(borderOverlay)
        // Убираем масштабирование, чтобы сетка не «гуляла» и не налезала
        .scaleEffect(isSelected ? Configuration.constants.selectedScale : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    // MARK: - Subviews

    private var dayNumberText: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .font(AppTypography.body.font)
            .fontWeight(isSelected ? .bold : .medium)
            .foregroundColor(textColor)
            .animation(nil, value: isSelected)
    }

    private var indicator: some View {
        Group {
            switch eventType {
            case .regular, .onlineOnly:
                Circle()
                    .fill(dotColor)
                    .frame(width: Configuration.constants.dotSize, height: Configuration.constants.dotSize)
            case .none:
                AppColor.clear.color(for: colorScheme)
                    .frame(width: Configuration.constants.dotSize, height: Configuration.constants.dotSize)
            }
        }
        .animation(nil, value: isSelected)
    }

    private var backgroundView: some View {
        Group {
            if isSelected { selectedBackground } else { unselectedBackground }
        }
    }

    private var selectedBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .opacity(Configuration.constants.selectedOpacity)
            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
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
        .shadow(color: gradientColors[0].opacity(Configuration.constants.shadowOpacity),
                radius: Configuration.constants.shadowRadius, x: 0, y: Configuration.constants.shadowY)
    }

    private var unselectedBackground: some View {
        RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
            .fill(
                AppColor.background.color(for: colorScheme).opacity(
                    isCurrentMonth ? Configuration.constants.backgroundOpacity : Configuration.constants.inactiveBackgroundOpacity
                )
            )
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
            .strokeBorder(
                isToday && !isSelected
                ? LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                : LinearGradient(colors: [AppColor.clear.color(for: colorScheme)], startPoint: .topLeading, endPoint: .bottomTrailing),
                lineWidth: Configuration.constants.borderWidth
            )
    }

    // MARK: - Colors/Computed

    private var textColor: Color {
        if !isCurrentMonth {
            return AppColor.secondaryText.color(for: colorScheme).opacity(Configuration.constants.inactiveTextOpacity)
        }
        return isSelected ? AppColor.white.color(for: colorScheme) : AppColor.primaryText.color(for: colorScheme)
    }

    private var dotColor: Color {
        if isSelected {
            return AppColor.white.color(for: colorScheme).opacity(Configuration.constants.dotOpacity)
        }
        return gradientColors[0]
    }

    private var gradientColors: [Color] {
        switch eventType {
        case .none, .regular:
            GradientStyle.primary.colors(for: colorScheme)
        case .onlineOnly:
            GradientStyle.online.colors(for: colorScheme)
        }
    }

    // MARK: - Gesture

    private func handleDragChanged(_ value: DragGesture.Value) {
        if dragStart == nil { dragStart = value.startLocation }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        defer { dragStart = nil }
        guard let start = dragStart else { return }
        let distance = hypot(value.location.x - start.x, value.location.y - start.y)
        if distance < Configuration.constants.tapThreshold {
            hapticService.impact(style: .light)
            action()
        }
    }
}
