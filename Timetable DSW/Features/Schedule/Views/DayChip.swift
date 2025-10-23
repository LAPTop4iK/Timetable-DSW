//
//  DayChip.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//

import SwiftUI

struct DayChip: View {
    // MARK: - Configuration
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let cornerRadius: AppCornerRadius = .medium
            let dotSize: CGFloat = AppDimensions.dotSmall.value
            let spacing: AppSpacing = .xs

            let compactWeekdaySize: CGFloat = 11
            let compactDaySize: CGFloat = 17
            let regularWeekdaySize: CGFloat = 11
            let regularDaySize: CGFloat = 20

            let selectedScale: Double = 1.05
            let shadowRadius: CGFloat = 4
            let shadowY: CGFloat = 2
            let chipCompactHeight: CGFloat = AppDimensions.chipCompactHeight.value
            let chipBackgroundOpacity: Double = 0.5
            let blurOpacity: Double = 0.3
            let gradientOpacity: Double = 0.9
            let dotOpacity: Double = 0.9
            let glowOpacity: Double = 0.3
            let glowStartRadius: CGFloat = 5
            let glowWidthMultiplier: CGFloat = 0.8
            let outerPaddingTop: CGFloat = AppSpacing.small.value
            let outerPaddingHorizontal: CGFloat = 1
            let outerPaddingBottom: CGFloat = AppSpacing.small.value
            let minimumScaleFactor: CGFloat = 0.8
        }
        
        static let constants = Constants()
    }

    // MARK: - Properties
    
    let date: Date
    let isSelected: Bool
    let eventDayType: EventDayType
    let action: () -> Void
    let size: CGSize

    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Dependencies
    private let hapticService: HapticFeedbackService
    private let dateService: DateService

    // MARK: - Inits
    init(
        date: Date,
        isSelected: Bool,
        eventDayType: EventDayType,
        action: @escaping () -> Void,
        size: CGSize,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService(),
        dateService: DateService = DefaultDateService.shared
    ) {
        self.date = date
        self.isSelected = isSelected
        self.eventDayType = eventDayType
        self.action = action
        self.size = size
        self.hapticService = hapticService
        self.dateService = dateService
    }
    
    // MARK: - Body
    var body: some View {
        return Button(action: handleTap) {
            contentView
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? Configuration.constants.selectedScale : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // MARK: - Subviews
    private var contentView: some View {
        let isCompact = size.height <= Configuration.constants.chipCompactHeight
        let isToday = Calendar.current.isDateInToday(date)

        return RoundedShadowContainer(
            corners: .allCorners,
            cornerRadius: Configuration.constants.cornerRadius.value,
            fill: chipFillColor,
            blurMaterial: isSelected ? .ultraThinMaterial : nil,
            blurOpacity: isSelected ? Configuration.constants.blurOpacity : 0,
            shadow: chipShadow,
            contentInsets: .init(),
            outerPadding: .init(
                top: Configuration.constants.outerPaddingTop,
                leading: Configuration.constants.outerPaddingHorizontal,
                bottom: Configuration.constants.outerPaddingBottom,
                trailing: Configuration.constants.outerPaddingHorizontal
            )
        ) {
            chipContent(isCompact: isCompact)
                .overlay(
                    RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value, style: .continuous)
                        .strokeBorder(
                            LinearGradient(colors: chipGradientColors,
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                        .opacity(isToday ? 1 : 0)
                )
        }
    }

    private func chipContent(isCompact: Bool) -> some View {
        VStack(spacing: Configuration.constants.spacing.value) {
            weekdayText(isCompact: isCompact)
            dayNumberText(isCompact: isCompact)
            indicator // ← точка / капсула / пусто
        }
        .frame(width: size.width, height: size.height)
        .background {
            if isSelected { selectedBackground }
        }
    }

    private func weekdayText(isCompact: Bool) -> some View {
        let fontSize = isCompact ? Configuration.constants.compactWeekdaySize : Configuration.constants.regularWeekdaySize

        return Text(dateService.weekdayShort(date))
            .font(AppTypography.custom(size: fontSize, weight: .medium).font)
            .lineLimit(1)
            .minimumScaleFactor(Configuration.constants.minimumScaleFactor)
            .foregroundAppColor(isSelected ? .white : .secondaryText, colorScheme: colorScheme)
    }

    private func dayNumberText(isCompact: Bool) -> some View {
        let fontSize = isCompact ? Configuration.constants.compactDaySize : Configuration.constants.regularDaySize

        return Text(dateService.dayNumber(date))
            .font(AppTypography.custom(size: fontSize, weight: .bold).font)
            .lineLimit(1)
            .minimumScaleFactor(Configuration.constants.minimumScaleFactor)
            .foregroundAppColor(isSelected ? .white : .primaryText, colorScheme: colorScheme)
    }

    private var indicator: some View {
        Group {
            switch eventDayType {
            case .regular, .onlineOnly:
                Circle()
                    .fill(isSelected
                          ? AppColor.white.color(for: colorScheme).opacity(Configuration.constants.dotOpacity)
                          : chipGradientColors[0])
                    .frame(width: Configuration.constants.dotSize, height: Configuration.constants.dotSize)
            case .none:
                AppColor.clear.color(for: colorScheme)
                    .frame(width: Configuration.constants.dotSize, height: Configuration.constants.dotSize)
            }
        }
        .animation(nil, value: isSelected)
    }

    private var selectedBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                .fill(
                    LinearGradient(
                        colors: chipGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: Configuration.constants.cornerRadius.value)
                .fill(
                    RadialGradient(
                        colors: [
                            AppColor.white.color(for: colorScheme).opacity(Configuration.constants.glowOpacity),
                            AppColor.clear.color(for: colorScheme)
                        ],
                        center: .topLeading,
                        startRadius: Configuration.constants.glowStartRadius,
                        endRadius: size.width * Configuration.constants.glowWidthMultiplier
                    )
                )
        }
    }

    // MARK: - Computed
    private var chipGradientColors: [Color] {
        switch eventDayType {
        case .onlineOnly:
            GradientStyle.online.colors(for: colorScheme)
        case .regular, .none:
            GradientStyle.primary.colors(for: colorScheme)
        }
    }

    private var chipFillColor: Color {
        isSelected
        ? (colorScheme == .dark
           ? AppColor.custom(Color.purple, opacity: 0.2).color(for: colorScheme)
           : AppColor.custom(Color.pink, opacity: 0.15).color(for: colorScheme))
        : AppColor.background.color(for: colorScheme).opacity(Configuration.constants.chipBackgroundOpacity)
    }

    private var chipShadow: ShadowStyle {
        isSelected
        ? ShadowStyle(
            color: shadowColor,
            radius: Configuration.constants.shadowRadius,
            x: 0,
            y: Configuration.constants.shadowY
        )
        : ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
    }

    private var shadowColor: Color {
        let baseColor = chipGradientColors[0]
        let opacity = colorScheme == .dark ? 0.5 : 0.4
        return baseColor.opacity(opacity)
    }

    private var accessibilityText: String {
        let base = "\(dateService.weekdayShort(date)) \(dateService.dayNumber(date))"
        switch eventDayType {
        case .none: return base
        case .regular: return base + ", " + LocalizedString.scheduleHasClasses.localized
        case .onlineOnly: return base + ", " + LocalizedString.scheduleOnlineOnly.localized
        }
    }

    // MARK: - Actions
    private func handleTap() {
        hapticService.impact(style: .light)
        action()
    }
}
