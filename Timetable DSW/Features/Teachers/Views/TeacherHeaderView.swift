//
//  TeacherHeaderView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct TeacherHeaderView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let spacing: AppSpacing = .medium
            let nameSpacing: AppSpacing = .xxs
            let horizontalPadding: AppSpacing = .large
            let verticalPadding: AppSpacing = .small
            let emailSpacing: AppSpacing = .xs
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties

    let teacher: Teacher
    let selectedDate: Date
    let onCalendarTap: () -> Void

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let hapticService: HapticFeedbackService
    
    // MARK: - Initialization
    
    init(
        teacher: Teacher,
        selectedDate: Date,
        onCalendarTap: @escaping () -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self.teacher = teacher
        self.selectedDate = selectedDate
        self.onCalendarTap = onCalendarTap
        self.hapticService = hapticService
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .center, spacing: Configuration.constants.spacing.value) {
            leftSection
            Spacer()
            calendarButton
        }
        .padding(.horizontal, Configuration.constants.horizontalPadding.value)
        .padding(.vertical, Configuration.constants.verticalPadding.value)
    }
    
    // MARK: - Subviews
    
    private var leftSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.nameSpacing.value) {
            Text(teacher.displayName)
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .lineLimit(1)

            HStack(spacing: Configuration.constants.emailSpacing.value) {
                Text(formattedSelectedDate)
                    .font(AppTypography.subheadline.font)
                    .fontWeight(.medium)
                    .themedForeground(.header, colorScheme: colorScheme)

                if let email = teacher.email {
                    Text("•")
                        .font(AppTypography.caption.font)
                        .themedForeground(.header, colorScheme: colorScheme)

                    emailButton(email: email)
                }
            }
        }
    }

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "dd.MM.yyyy, EEE"
        return formatter.string(from: selectedDate)
    }
    
    private func emailButton(email: String) -> some View {
        Button(action: {
            copyEmail(email)
        }) {
            HStack(spacing: Configuration.constants.emailSpacing.value) {
                Text(email)
                    .font(AppTypography.caption.font)
                    .lineLimit(1)
                AppIcon.docOnDoc.image()
                    .font(AppTypography.caption2.font)
            }
            .themedForeground(.header, colorScheme: colorScheme)
        }
    }
    
    private var calendarButton: some View {
        Button(action: onCalendarTap) {
            AppIcon.calendar.image()
                .font(AppTypography.title3.font)
                .themedForeground(.header, colorScheme: colorScheme)
        }
    }
    
    // MARK: - Actions
    
    private func copyEmail(_ email: String) {
        UIPasteboard.general.string = email
        hapticService.impact(style: .light)
    }
}