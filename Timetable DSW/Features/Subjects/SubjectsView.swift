//
//  SubjectsView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 19/10/2025.
//

import SwiftUI

struct SubjectsView: View {
    // MARK: - Configuration
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let progressScale: CGFloat = 1.2
            let spacing: AppSpacing = .large
        }
        static let constants = Constants()
    }

    // MARK: - Properties
    @StateObject var viewModel: SubjectsViewModel = .init()
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedSubject: Subject?

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.bottomInsetService) private var bottomInsetService

    // MARK: - Body
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle(LocalizedString.subjectsTitle.localized)
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: LocalizedString.subjectsSearch.localized)
                .onAppear {
                    if let data = appViewModel.scheduleData {
                        viewModel.rebuild(from: data)
                    }
                }
                .onChange(of: appViewModel.scheduleData) {
                    if let data = appViewModel.scheduleData {
                        viewModel.rebuild(from: data)
                    }
                }
                #if DEBUG
                .measurePerformance(name: "SubjectsView", category: .viewAppear)
                #endif
        }
        .sheet(item: $selectedSubject) { subject in
            SubjectDetailView(subject: subject)
        }
    }

    // MARK: - Content Views
    @ViewBuilder
    private var contentView: some View {
        if appViewModel.isLoading {
            loadingView
        } else if appViewModel.scheduleData == nil {
            noDataView
        } else if viewModel.filteredSubjects.isEmpty {
            noResultsView
        } else {
            subjectsList
        }
    }

    private var loadingView: some View {
        VStack(spacing: Configuration.constants.spacing.value) {
            ProgressView()
                .scaleEffect(Configuration.constants.progressScale)
            Text(LocalizedString.subjectsLoading.localized)
                .font(AppTypography.subheadline.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }

    private var noDataView: some View {
        ContentUnavailableView(
            LocalizedString.subjectsNoData.localized,
            systemImage: AppIcon.person2Slash.systemName,
            description: Text(LocalizedString.subjectsLoadScheduleFirst.localized)
        )
    }

    private var noResultsView: some View {
        ContentUnavailableView(
            LocalizedString.subjectsNoFound.localized,
            systemImage: AppIcon.magnifyingGlass.systemName,
            description: Text(LocalizedString.groupsAdjustSearch.localized)
        )
    }

    private var subjectsList: some View {
        List(viewModel.filteredSubjects) { subject in
            SubjectRow(subject: subject) {
                selectedSubject = subject
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
}

// MARK: - Subject Row (1-в-1 стиль TeacherRow, меняем только наполнение)

private struct SubjectRow: View {
    struct Constants {
        let avatarSize: CGFloat = AppDimensions.avatarLarge.value
        let spacing: AppSpacing = .medium
        let padding: AppSpacing = .medium
        let initialsSize: CGFloat = 18
        let nameSize: CGFloat = 16
        let subtitleSize: CGFloat = 13
        let countSize: CGFloat = 20
        let classesSize: CGFloat = 11
        let backgroundOpacity: Double = 0.15
        let nameSpacing: AppSpacing = .xxs
        let countSpacing: AppSpacing = .xxs
        let cornerRadius: CGFloat = AppCornerRadius.large.value
    }
    private let constants = Constants()

    // MARK: - Properties
    let subject: Subject
    let action: () -> Void

    // MARK: - Environment
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Dependencies
    private let hapticService: HapticFeedbackService = DefaultHapticFeedbackService()

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
            Text(subject.name)
                .font(AppTypography.custom(size: constants.nameSize, weight: .semibold).font)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)

            // ↓ Вместо типов занятий показываем "сколько осталось"
            Text(bottomLine)
                .font(AppTypography.custom(size: constants.subtitleSize, weight: .regular).font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .lineLimit(1)
        }
    }

    private var gradingType: String? {
           let values = subject.schedule
               .map { ($0.grading ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
               .filter { !$0.isEmpty }
           guard !values.isEmpty else { return nil }
           let freq = Dictionary(grouping: values, by: { $0 }).mapValues(\.count)
           return freq.max(by: { $0.value < $1.value })?.key
       }

       /// Строка под названием предмета: «Осталось … • Тип зачёта»
       private var bottomLine: String {
           if let g = gradingType {
               return "\(LocalizedString.subjectsUpcoming.localized): \(upcomingCount) • \(g)"
           } else {
               return "\(LocalizedString.subjectsUpcoming.localized): \(upcomingCount)"
           }
       }

    private var classesIndicator: some View {
        VStack(spacing: constants.countSpacing.value) {
            Text("\(subject.count)")
                .font(AppTypography.custom(size: constants.countSize, weight: .bold).font)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(LocalizedString.subjectsClasses.localized)
                .font(AppTypography.custom(size: constants.classesSize, weight: .regular).font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }

    // MARK: - Computed
    private var initials: String {
        let parts = subject.name.split(separator: " ")
        if parts.count >= 2 {
            let first = parts[0].prefix(1)
            let last  = parts[1].prefix(1)
            return "\(first)\(last)".uppercased()
        }
        return String(subject.name.prefix(1)).uppercased()
    }

    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }

    // Сколько занятий осталось у предмета (включая текущее, если оно ещё не закончено)
    private var upcomingCount: Int {
        let now = Date()
        return subject.schedule.reduce(into: 0) { acc, ev in
            if let end = ev.endDate {
                if end >= now { acc += 1 }
            } else if let start = ev.startDate {
                if start >= now { acc += 1 }
            }
        }
    }

    // MARK: - Actions
    private func handleTap() {
        hapticService.impact(style: .light)
        action()
    }
}
