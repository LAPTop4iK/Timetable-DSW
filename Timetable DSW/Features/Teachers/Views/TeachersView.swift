//
//  TeachersView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct TeachersView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let progressScale: CGFloat = 1.2
            let spacing: AppSpacing = .large
        }

        static let constants = Constants()
    }

    // MARK: - Properties

    @StateObject var viewModel: TeachersViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedTeacher: Teacher?

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.bottomInsetService) private var bottomInsetService
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.hasFilterOptions {
                    filterSegmentControl
                        .padding(.horizontal, AppSpacing.large.value)
                        .padding(.bottom, AppSpacing.medium.value)
                }
                contentView
            }
            .navigationTitle(LocalizedString.teachersTitle.localized)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedString.teachersSearch.localized)
            .onAppear {
                if let scheduleData = appViewModel.scheduleData {
                    viewModel.updateTeachers(scheduleData.teachers, currentPeriod: scheduleData.currentPeriodTeachers)
                }
            }
            .onChange(of: appViewModel.scheduleData) {
                if let newData = appViewModel.scheduleData {
                    viewModel.updateTeachers(newData.teachers, currentPeriod: newData.currentPeriodTeachers)
                }
            }
            #if DEBUG
            .measurePerformance(name: "TeachersView", category: .viewAppear)
            #endif
        }
        .sheet(item: $selectedTeacher) { teacher in
            TeacherDetailView(viewModel: TeacherDetailViewModel(teacher: teacher))
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        if appViewModel.isLoadingTeachers {
            loadingView
        } else if appViewModel.scheduleData == nil {
            noDataView
        } else if viewModel.filteredTeachers.isEmpty {
            noResultsView
        } else {
            teachersList
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: Configuration.constants.spacing.value) {
            ProgressView()
                .scaleEffect(Configuration.constants.progressScale)
            Text(LocalizedString.teachersLoading.localized)
                .font(AppTypography.subheadline.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }
    
    private var noDataView: some View {
        ContentUnavailableView(
            LocalizedString.teachersNoData.localized,
            systemImage: AppIcon.person2Slash.systemName,
            description: Text(LocalizedString.teachersLoadScheduleFirst.localized)
        )
    }
    
    private var noResultsView: some View {
        ContentUnavailableView(
            LocalizedString.teachersNoFound.localized,
            systemImage: AppIcon.magnifyingGlass.systemName,
            description: Text(LocalizedString.groupsAdjustSearch.localized)
        )
    }
    
    private var teachersList: some View {
        List(viewModel.filteredTeachers) { teacher in
            TeacherRow(teacher: teacher) {
                selectedTeacher = teacher
            }
            .listRowInsets(EdgeInsets(
                top: AppSpacing.xs.value,
                leading: AppSpacing.large.value,
                bottom: AppSpacing.xs.value,
                trailing: AppSpacing.large.value
            ))
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .bottom) {
            AppColor.clear.color(for: colorScheme)
                .frame(height: bottomInsetService?.bottomInset ?? 78)
        }
    }

    private var filterSegmentControl: some View {
        Picker("Filter", selection: $viewModel.selectedFilter) {
            Text(LocalizedString.teachersFilterCurrent.localized)
                .tag(TeachersViewModel.TeacherFilter.current)
            Text(LocalizedString.teachersFilterAll.localized)
                .tag(TeachersViewModel.TeacherFilter.all)
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Teacher Row

private struct TeacherRow: View {
    // MARK: - Configuration
    
    struct Constants {
        let avatarSize: CGFloat = AppDimensions.avatarLarge.value
        let spacing: AppSpacing = .medium
        let padding: AppSpacing = .medium
        let initialsSize: CGFloat = 18
        let nameSize: CGFloat = 16
        let emailSize: CGFloat = 13
        let countSize: CGFloat = 20
        let classesSize: CGFloat = 11
        let backgroundOpacity: Double = 0.15
        let nameSpacing: AppSpacing = .xxs
        let countSpacing: AppSpacing = .xxs
    }
    
    private let constants = Constants()
    
    // MARK: - Properties
    
    let teacher: Teacher
    let action: () -> Void
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let hapticService: HapticFeedbackService
    
    // MARK: - Initialization
    
    init(
        teacher: Teacher,
        action: @escaping () -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self.teacher = teacher
        self.action = action
        self.hapticService = hapticService
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: constants.spacing.value) {
                avatarView
                textContent
                Spacer()
                classesIndicator
            }
            .padding(constants.padding.value)
        }
    }
    
    // MARK: - Subviews
    
    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(constants.backgroundOpacity) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: constants.avatarSize, height: constants.avatarSize)
            
            Text(initials)
                .font(AppTypography.custom(size: constants.initialsSize, weight: .semibold).font)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: constants.nameSpacing.value) {
            Text(teacher.displayName)
                .font(AppTypography.custom(size: constants.nameSize, weight: .semibold).font)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
            
            if let email = teacher.email {
                Text(email)
                    .font(AppTypography.custom(size: constants.emailSize, weight: .regular).font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    .lineLimit(1)
            }
        }
    }
    
    private var classesIndicator: some View {
        VStack(spacing: constants.countSpacing.value) {
            Text("\(teacher.schedule.count)")
                .font(AppTypography.custom(size: constants.countSize, weight: .bold).font)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(LocalizedString.teachersClasses.localized)
                .font(AppTypography.custom(size: constants.classesSize, weight: .regular).font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }
    
    // MARK: - Computed Properties
    
    private var initials: String {
        let components = teacher.displayName.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        }
        return String(teacher.displayName.prefix(1)).uppercased()
    }
    
    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }
    
    // MARK: - Actions
    
    private func handleTap() {
        hapticService.impact(style: .light)
        action()
    }
}
