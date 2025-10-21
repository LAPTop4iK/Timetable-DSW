//
//  GroupRow.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct GroupRow: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let iconSize: CGFloat = AppDimensions.buttonHeight.value
            let spacing: AppSpacing = .medium
            let padding: AppSpacing = .medium
            let iconCornerRadius: AppCornerRadius = .medium
            let iconImageSize: CGFloat = AppDimensions.iconMedium.value
            let nameSize: CGFloat = 16
            let programSize: CGFloat = 13
            let facultySize: CGFloat = 12
            let chevronSize: CGFloat = 14
            let backgroundOpacity: Double = 0.15
            let nameSpacing: AppSpacing = .xxs
            let chevronOpacity: Double = 0.5
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    let group: GroupInfo
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Configuration.constants.spacing.value) {
            iconView
            textContent
            Spacer()
            chevronIcon
        }
        .padding(Configuration.constants.padding.value)
    }
    
    // MARK: - Subviews
    
    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Configuration.constants.iconCornerRadius.value)
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(Configuration.constants.backgroundOpacity) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: Configuration.constants.iconSize, height: Configuration.constants.iconSize)
            
            AppIcon.person3Fill.image()
                .font(.system(size: Configuration.constants.iconImageSize))
                .themedForeground(.secondary, colorScheme: colorScheme)
        }
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.nameSpacing.value) {
            Text(group.displayName)
                .font(AppTypography.custom(size: Configuration.constants.nameSize, weight: .semibold).font)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
            
            Text(group.program)
                .font(AppTypography.custom(size: Configuration.constants.programSize, weight: .regular).font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .lineLimit(1)
            
            Text(group.faculty)
                .font(AppTypography.custom(size: Configuration.constants.facultySize, weight: .regular).font)
                .foregroundAppColor(.tertiaryText, colorScheme: colorScheme)
                .lineLimit(1)
        }
    }
    
    private var chevronIcon: some View {
        AppIcon.chevronRight.image()
            .font(AppTypography.custom(size: Configuration.constants.chevronSize, weight: .semibold).font)
            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            .opacity(Configuration.constants.chevronOpacity)
    }
    
    // MARK: - Computed Properties
    
    private var gradientColors: [Color] {
        GradientStyle.secondary.colors(for: colorScheme)
    }
}
