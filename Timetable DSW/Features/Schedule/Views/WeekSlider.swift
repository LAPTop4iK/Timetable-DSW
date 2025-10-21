//
//  WeekSlider.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct WeekSlider: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let horizontalPadding: AppSpacing = .large
            let baseSpacing: AppSpacing = .medium
            let minSpacing: AppSpacing = .xs
            let preferredMinChipWidth: CGFloat = 44
            let absoluteMinChipWidth: CGFloat = 36
            let preferredMaxChipWidth: CGFloat = 64
            let chipAspect: CGFloat = 1.35
            let maxChipHeight: CGFloat = AppDimensions.chipMaxHeight.value
            let minChipHeight: CGFloat = AppDimensions.chipMinHeight.value
            let minimumSwipeDistance: CGFloat = AppDimensions.minimumSwipeDistance.value
            let weekChangeThreshold: CGFloat = AppDimensions.weekChangeThreshold.value
            let verticalToHorizontalRatio: CGFloat = 1.5
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    let days: [Date]
    let selectedDate: Date
    let eventDayType: (Date) -> EventDayType
    let onSelectDate: (Date) -> Void
    let onNextWeekFromSlider: () -> Void
    let onPreviousWeekFromSlider: () -> Void
    
    // MARK: - State
    
    @State private var hasTriggeredNextWeekHaptic = false
    @State private var hasTriggeredPreviousWeekHaptic = false
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let hapticService: HapticFeedbackService
    
    // MARK: - Initialization
    
    init(
        days: [Date],
        selectedDate: Date,
        eventDayType: @escaping (Date) -> EventDayType,
        onSelectDate: @escaping (Date) -> Void,
        onNextWeekFromSlider: @escaping () -> Void,
        onPreviousWeekFromSlider: @escaping () -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self.days = days
        self.selectedDate = selectedDate
        self.eventDayType = eventDayType
        self.onSelectDate = onSelectDate
        self.onNextWeekFromSlider = onNextWeekFromSlider
        self.onPreviousWeekFromSlider = onPreviousWeekFromSlider
        self.hapticService = hapticService
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { proxy in
            let containerWidth = proxy.size.width
            let availableWidth = max(0, containerWidth - Configuration.constants.horizontalPadding.value * 2)

            let (chipW, spacing) = adaptiveMetrics(availableWidth: availableWidth, count: days.count)
            let chipH = clampHeight(chipW * Configuration.constants.chipAspect)
            let sliderHeight = chipH

            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach(days, id: \.self) { date in
                        DayChip(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            eventDayType: eventDayType(date),
                            action: { onSelectDate(date) },
                            size: CGSize(width: chipW, height: chipH),
                            hapticService: hapticService
                        )
                    }
                }
                .frame(width: availableWidth, alignment: .center)
                .padding(.horizontal, Configuration.constants.horizontalPadding.value)
            }
            .frame(height: sliderHeight)
            .background(AppColor.clear.color(for: colorScheme))
        }
        .frame(height: idealSliderHeight)
        .contentShape(Rectangle())
        .gesture(
            SimultaneousDragGesture(
                onChanged: { value in
                    handleSwipeProgress(translation: value.translation)
                },
                onEnded: { value in
                    handleSwipeEnd(translation: value.translation)
                }
            )
        )
    }

    // MARK: - Computed Properties
    
    private var idealSliderHeight: CGFloat {
        clampHeight(Configuration.constants.preferredMaxChipWidth * Configuration.constants.chipAspect)
    }
    
    // MARK: - Helper Methods
    
    private func clampHeight(_ raw: CGFloat) -> CGFloat {
        min(max(raw, Configuration.constants.minChipHeight), Configuration.constants.maxChipHeight)
    }
    
    private func adaptiveMetrics(availableWidth: CGFloat, count: Int) -> (chipWidth: CGFloat, spacing: CGFloat) {
        guard count > 0 else {
            return (Configuration.constants.preferredMinChipWidth, Configuration.constants.baseSpacing.value)
        }
        
        if let fit = solve(width: availableWidth, chips: count, spacing: Configuration.constants.baseSpacing.value) {
            return fit
        }
        
        if let fit = solve(width: availableWidth, chips: count, spacing: Configuration.constants.minSpacing.value) {
            return fit
        }
        
        return solve(
            width: availableWidth,
            chips: count,
            spacing: Configuration.constants.minSpacing.value,
            allowBelowPreferredMin: true
        )!
    }
    
    private func solve(
        width availableWidth: CGFloat,
        chips: Int,
        spacing: CGFloat,
        allowBelowPreferredMin: Bool = false
    ) -> (chipWidth: CGFloat, spacing: CGFloat)? {
        let free = max(0, availableWidth - spacing * CGFloat(max(0, chips - 1)))
        let idealW = free / CGFloat(chips)
        
        let minW = allowBelowPreferredMin ? Configuration.constants.absoluteMinChipWidth : Configuration.constants.preferredMinChipWidth
        let clampedW = min(max(idealW, minW), Configuration.constants.preferredMaxChipWidth)
        
        let total = clampedW * CGFloat(chips) + spacing * CGFloat(max(0, chips - 1))
        if total <= availableWidth + 0.5 {
            return (clampedW, spacing)
        }
        return allowBelowPreferredMin ? (clampedW, spacing) : nil
    }
    
    private func isHorizontalSwipe(_ translation: CGSize) -> Bool {
        let absHorizontal = abs(translation.width)
        let absVertical = abs(translation.height)
        
        guard absHorizontal > Configuration.constants.minimumSwipeDistance else {
            return false
        }
        
        return absVertical < absHorizontal * Configuration.constants.verticalToHorizontalRatio
    }
    
    // MARK: - Gesture Handlers
    
    private func handleSwipeProgress(translation: CGSize) {
        guard isHorizontalSwipe(translation) else { return }
        
        if translation.width < -Configuration.constants.weekChangeThreshold && !hasTriggeredNextWeekHaptic {
            triggerHaptic()
            hasTriggeredNextWeekHaptic = true
        }
        
        if translation.width > Configuration.constants.weekChangeThreshold && !hasTriggeredPreviousWeekHaptic {
            triggerHaptic()
            hasTriggeredPreviousWeekHaptic = true
        }
        
        if abs(translation.width) < Configuration.constants.weekChangeThreshold {
            resetHapticFlags()
        }
    }
    
    private func handleSwipeEnd(translation: CGSize) {
        guard isHorizontalSwipe(translation) else { return }

        if translation.width < -Configuration.constants.weekChangeThreshold {
            onNextWeekFromSlider()
        } else if translation.width > Configuration.constants.weekChangeThreshold {
            onPreviousWeekFromSlider()
        }
        
        resetHapticFlags()
    }
    
    private func triggerHaptic() {
        hapticService.impact(style: .medium)
    }
    
    private func resetHapticFlags() {
        hasTriggeredNextWeekHaptic = false
        hasTriggeredPreviousWeekHaptic = false
    }
}
