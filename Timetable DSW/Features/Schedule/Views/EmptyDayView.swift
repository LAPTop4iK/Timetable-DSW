//
//  EmptyDayView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct EmptyDayView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let iconSize: CGFloat = AppDimensions.iconXL.value * 2.5
            let spacing: AppSpacing = .large
            let messageSpacing: AppSpacing = .small
            let circleExtraSize: CGFloat = 40
            let backgroundOpacity: Double = 0.1
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    let date: Date
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let dateService: DateService
    
    // MARK: - Initialization
    
    init(
        date: Date,
        dateService: DateService = DefaultDateService()
    ) {
        self.date = date
        self.dateService = dateService
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Configuration.constants.spacing.value) {
            illustrationView
            messageView
        }
        .frame(maxWidth: .infinity, alignment: .center)   // ← только по ширине
           .multilineTextAlignment(.center)
        .contentShape(Rectangle())
    }
    
    // MARK: - Subviews
    
    private var illustrationView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(Configuration.constants.backgroundOpacity) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(
                    width: Configuration.constants.iconSize + Configuration.constants.circleExtraSize,
                    height: Configuration.constants.iconSize + Configuration.constants.circleExtraSize
                )
            
            AppIcon.calendarBadgeCheckmark.image()
                .font(.system(size: Configuration.constants.iconSize))
                .themedForeground(.success, colorScheme: colorScheme)
        }
    }
    
    private var messageView: some View {
        VStack(spacing: Configuration.constants.messageSpacing.value) {
            Text(dateService.weekdayFull(date))
                .font(AppTypography.title2.font)
                .fontWeight(.bold)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
            
            Text(LocalizedString.scheduleNoClasses.localized)
                .font(AppTypography.headline.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            
            Text(LocalizedString.scheduleEnjoyFreeTime.localized)
                .font(AppTypography.subheadline.font)
                .foregroundAppColor(.tertiaryText, colorScheme: colorScheme)
        }
    }
    
    // MARK: - Computed Properties
    
    private var gradientColors: [Color] {
        GradientStyle.success.colors(for: colorScheme)
    }
}
