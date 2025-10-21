//
//  ScheduleView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct ScheduleView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let headerSpacing: AppSpacing = .small
            let headerCornerRadius: AppCornerRadius = .xl
            let headerShadowRadius: CGFloat = 12
            let headerShadowY: CGFloat = 4
            let headerBlurOpacity: Double = 0.98
            let headerContentPadding: AppSpacing = .medium
            let detentHeightDivider: CGFloat = 1.75
            let maxDetentHeight: CGFloat = 500
            let bottomInset: CGFloat = 110
            let defaultSafeAreaTop: CGFloat = 47
            let darkFillOpacity: Double = 0.15
            let lightFillOpacity: Double = 0.12
            let darkShadowOpacity: Double = 0.3
            let lightShadowOpacity: Double = 0.25
            let springResponse: Double = 0.3
            let springDamping: Double = 0.7
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ScheduleViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var headerHeight: CGFloat = 0
    @State private var headerHeightMax: CGFloat = 0
    @State private var safeAreaTop: CGFloat = Configuration.constants.defaultSafeAreaTop
    @State private var bannerHeight: CGFloat = 0

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.adCoordinator) private var adCoordinator

    // MARK: - Computed Properties
    
    private var headerGradientFill: Color {
        let opacity = colorScheme == .dark ? Configuration.constants.darkFillOpacity : Configuration.constants.lightFillOpacity
        return (colorScheme == .dark ? AppColor.purple : AppColor.pink).color(for: colorScheme).opacity(opacity)
    }
    
    private var headerShadowColor: Color {
        let opacity = colorScheme == .dark ? Configuration.constants.darkShadowOpacity : Configuration.constants.lightShadowOpacity
        return (colorScheme == .dark ? AppColor.purple : AppColor.pink).color(for: colorScheme).opacity(opacity)
    }
    
    private var detentHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return min(Configuration.constants.maxDetentHeight, screenHeight / Configuration.constants.detentHeightDivider)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 0) {
                    floatingHeader
                    Spacer()
                }
                .zIndex(1)

                VStack {
                    Spacer()
                    bannerAd
                }
                .zIndex(2)
            }
            .ignoresSafeArea()
            .sheet(isPresented: $viewModel.navigation.showingDatePicker) {
                datePickerSheet
            }
            .sheet(item: selectedTeacherBinding) { teacher in
                TeacherDetailView(viewModel: TeacherDetailViewModel(teacher: teacher))
            }
            .onAppear {
                viewModel.appViewModel = appViewModel
                if appViewModel.scheduleData == nil {
                    Task { await appViewModel.loadSchedule() }
                }

                safeAreaTop = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.windows.first?.safeAreaInsets.top ?? Configuration.constants.defaultSafeAreaTop
            }
        }
    }
    
    // MARK: - Subviews
    
    private var floatingHeader: some View {
        RoundedShadowContainer(
            corners: [.bottomLeft, .bottomRight],
            cornerRadius: Configuration.constants.headerCornerRadius.value,
            fill: headerGradientFill,
            blurMaterial: .ultraThinMaterial,
            blurOpacity: Configuration.constants.headerBlurOpacity,
            shadow: ShadowStyle(
                color: headerShadowColor,
                radius: Configuration.constants.headerShadowRadius,
                x: 0,
                y: Configuration.constants.headerShadowY
            ),
            contentInsets: .init(
                top: 0,
                leading: Configuration.constants.headerContentPadding.value,
                bottom: Configuration.constants.headerSpacing.value,
                trailing: Configuration.constants.headerContentPadding.value
            ),
            outerPadding: .init(top: 0, leading: 0, bottom: 0, trailing: 0),
            ignoresSafeAreaEdges: .top
        ) {
            VStack(spacing: Configuration.constants.headerSpacing.value) {
                AppColor.clear.color(for: colorScheme)
                    .frame(height: safeAreaTop)
                
                ScheduleHeaderView(
                    selectedDate: viewModel.navigation.selectedDate,
                    isRefreshing: appViewModel.isRefreshing,
                    isOffline: appViewModel.isOffline,
                    lastUpdated: appViewModel.lastUpdated,
                    onCalendarTap: { viewModel.navigation.showingDatePicker = true }
                )
                
                WeekSlider(
                    days: viewModel.navigation.daysInWeek,
                    selectedDate: viewModel.navigation.selectedDate,
                    eventDayType: { appViewModel.eventType(on: $0) },
                    onSelectDate: { viewModel.navigation.selectDate($0) },
                    onNextWeekFromSlider: {
                        withAnimation(.spring(response: Configuration.constants.springResponse, dampingFraction: Configuration.constants.springDamping)) {
                            viewModel.navigation.nextWeekFromSlider()
                        }
                        Task { await viewModel.handleWeekChange(coordinator: adCoordinator) }
                    },
                    onPreviousWeekFromSlider: {
                        withAnimation(.spring(response: Configuration.constants.springResponse, dampingFraction: Configuration.constants.springDamping)) {
                            viewModel.navigation.previousWeekFromSlider()
                        }
                        Task { await viewModel.handleWeekChange(coordinator: adCoordinator) }
                    }
                )
            }
            .overlay(
                GeometryReader { headerGeo in
                    AppColor.clear.color(for: colorScheme)
                        .preference(key: HeaderHeightKey.self, value: headerGeo.size.height + Configuration.constants.headerSpacing.value)
                }
            )
        }
        .onPreferenceChange(HeaderHeightKey.self) { value in
            guard value > 0 else { return }
            headerHeight = value
            let clamped = ceil(value)
            if clamped > headerHeightMax {
                headerHeightMax = clamped
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if appViewModel.isLoading {
            loadingView
        } else if let error = appViewModel.errorMessage, appViewModel.scheduleData == nil {
            ErrorView(message: error) {
                Task { await appViewModel.refresh() }
            }
        } else if let scheduleData = appViewModel.scheduleData {
            let topInset: CGFloat = headerHeightMax > 0 ? headerHeightMax : AppDimensions.headerMinHeight.value

            DayScheduleTabView(
                events: scheduleData.groupSchedule,
                daysInWeek: viewModel.navigation.daysInWeek,
                selectedDate: viewModel.navigation.selectedDate,
                onSelectDate: { viewModel.navigation.selectDate($0) },
                showTeacherName: true,
                topInset: topInset,
                bottomInset: Configuration.constants.bottomInset,
                onTeacherTap: { viewModel.showTeacherDetail(teacherId: $0) },
                onNextWeekFromTabView: {
                    viewModel.navigation.nextWeekFromTabView()
                    Task { await viewModel.handleWeekChange(coordinator: adCoordinator) }
                },
                onPreviousWeekFromTabView: {
                    viewModel.navigation.previousWeekFromTabView()
                    Task { await viewModel.handleWeekChange(coordinator: adCoordinator) }
                }
            )
        }
    }

    private var loadingView: some View {
        VStack(spacing: AppSpacing.large.value) {
            Spacer()
            ProgressView()
            Text(LocalizedString.scheduleLoading.localized)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            Spacer()
        }
    }
    
    private var datePickerSheet: some View {
        DatePickerSheet(
            selectedDate: $viewModel.navigation.selectedDate,
            onDateSelected: { viewModel.navigation.selectDate($0) },
            eventTypeForDate: { appViewModel.eventType(on: $0) }
        )
    }
    
    private var bannerAd: some View {
        VStack(spacing: 0) {
            if adCoordinator?.isAdDisabled() == false {
                AdaptiveBannerView()
                    .background(AppColor.background.color(for: colorScheme))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
            }
        }
    }

    private var selectedTeacherBinding: Binding<Teacher?> {
        Binding(
            get: { viewModel.selectedTeacher },
            set: { _ in viewModel.selectedTeacherId = nil }
        )
    }

    // MARK: - Preference Key
    
    struct HeaderHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}
