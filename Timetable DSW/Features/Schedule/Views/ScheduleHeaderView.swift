//
//  ScheduleHeaderView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct ScheduleHeaderView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let spacing: AppSpacing = .medium
            let statusSpacing: AppSpacing = .medium
            let dateSpacing: AppSpacing = .xs
            let horizontalPadding: AppSpacing = .large
            let verticalPadding: AppSpacing = .small
            let progressScale: CGFloat = 0.7
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    let selectedDate: Date
    let isRefreshing: Bool
    let isOffline: Bool
    let lastUpdated: Date?
    let onCalendarTap: () -> Void
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let dateService: DateService
    
    // MARK: - Initialization
    
    init(
        selectedDate: Date,
        isRefreshing: Bool,
        isOffline: Bool,
        lastUpdated: Date?,
        onCalendarTap: @escaping () -> Void,
        dateService: DateService = DefaultDateService()
    ) {
        self.selectedDate = selectedDate
        self.isRefreshing = isRefreshing
        self.isOffline = isOffline
        self.lastUpdated = lastUpdated
        self.onCalendarTap = onCalendarTap
        self.dateService = dateService
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: Configuration.constants.spacing.value) {
            leftSection
            Spacer()
            rightSection
        }
        .padding(.horizontal, Configuration.constants.horizontalPadding.value)
        .padding(.vertical, Configuration.constants.verticalPadding.value)
    }
    
    // MARK: - Subviews
    
    private var leftSection: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(dateService.greeting(for: Date()))
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
            
            HStack(spacing: Configuration.constants.dateSpacing.value) {
                Text(dateService.formatDate(selectedDate))
                    .font(AppTypography.caption.font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                
                if let lastUpdated = lastUpdated {
                    Text("• \(lastUpdated, style: .relative)")
                        .font(AppTypography.caption2.font)
                        .foregroundAppColor(.tertiaryText, colorScheme: colorScheme)
                }
            }
        }
    }
    
    private var rightSection: some View {
        HStack(spacing: Configuration.constants.statusSpacing.value) {
            if isRefreshing {
                ProgressView()
                    .scaleEffect(Configuration.constants.progressScale)
            }
            
            if isOffline {
                AppIcon.wifiSlash.image()
                    .font(AppTypography.caption.font)
                    .foregroundAppColor(.warning, colorScheme: colorScheme)
            }
            
            Button(action: onCalendarTap) {
                AppIcon.calendar.image()
                    .font(AppTypography.title3.font)
                    .themedForeground(.header, colorScheme: colorScheme)
            }
        }
    }
}
