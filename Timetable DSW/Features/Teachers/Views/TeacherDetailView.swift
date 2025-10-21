//
//  TeacherDetailView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct TeacherDetailView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let headerSpacing: AppSpacing = .small
            let headerCornerRadius: AppCornerRadius = .xl
            let headerShadowRadius: CGFloat = 12
            let headerShadowY: CGFloat = 4
            let headerBlurOpacity: Double = 0.98
            let headerContentPadding: AppSpacing = .medium
            let bottomInset: CGFloat = 20
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
    
    @StateObject var viewModel: TeacherDetailViewModel
    @State private var headerHeight: CGFloat = 0
    @State private var headerHeightMax: CGFloat = 0
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Computed Properties
    
    private var safeAreaTop: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? Configuration.constants.defaultSafeAreaTop
    }
    
    private var headerGradientFill: Color {
        let opacity = colorScheme == .dark ? Configuration.constants.darkFillOpacity : Configuration.constants.lightFillOpacity
        return (colorScheme == .dark ? AppColor.purple : AppColor.pink).color(for: colorScheme).opacity(opacity)
    }
    
    private var headerShadowColor: Color {
        let opacity = colorScheme == .dark ? Configuration.constants.darkShadowOpacity : Configuration.constants.lightShadowOpacity
        return (colorScheme == .dark ? AppColor.purple : AppColor.pink).color(for: colorScheme).opacity(opacity)
    }
    
    // MARK: - Body
    
    var body: some View {
//        let _ = db()
        NavigationView {
            ZStack(alignment: .top) {
                contentView
                floatingHeader
                    .zIndex(1)
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneButton
                }
            }
            .sheet(isPresented: $viewModel.navigation.showingDatePicker) {
                datePickerSheet
            }
        }
    }
    
    // MARK: - Subviews
    
    private var contentView: some View {
        let topInset: CGFloat = headerHeightMax > 0 ? headerHeightMax : AppDimensions.headerMinHeight.value

        return DayScheduleTabView(
            events: viewModel.teacher.schedule,
            daysInWeek: viewModel.navigation.daysInWeek,
            selectedDate: viewModel.navigation.selectedDate,
            onSelectDate: { viewModel.navigation.selectDate($0) },
            showTeacherName: false,
            topInset: topInset,
            bottomInset: Configuration.constants.bottomInset,
            onTeacherTap: nil,
            onNextWeekFromTabView: { viewModel.navigation.nextWeekFromTabView() },
            onPreviousWeekFromTabView: { viewModel.navigation.previousWeekFromTabView() }
        )
        .ignoresSafeArea(edges: .bottom)
    }

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
                
                TeacherHeaderView(
                    teacher: viewModel.teacher,
                    selectedDate: viewModel.navigation.selectedDate,
                    onCalendarTap: { viewModel.navigation.showingDatePicker = true }
                )
                
                WeekSlider(
                    days: viewModel.navigation.daysInWeek,
                    selectedDate: viewModel.navigation.selectedDate,
                    eventDayType: { viewModel.eventsProvider.eventType(on: $0) },
                    onSelectDate: { viewModel.navigation.selectDate($0) },
                    onNextWeekFromSlider: {
                        withAnimation(.spring(response: Configuration.constants.springResponse, dampingFraction: Configuration.constants.springDamping)) {
                            viewModel.navigation.nextWeekFromSlider()
                        }
                    },
                    onPreviousWeekFromSlider: {
                        withAnimation(.spring(response: Configuration.constants.springResponse, dampingFraction: Configuration.constants.springDamping)) {
                            viewModel.navigation.previousWeekFromSlider()
                        }
                    }
                )
            }
            .overlay(
                GeometryReader { headerGeo in
                    AppColor.clear.color(for: colorScheme)
                        .preference(
                            key: HeaderHeightKey.self,
                            value: headerGeo.size.height + Configuration.constants.headerSpacing.value
                        )
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
    
    private var doneButton: some View {
        Button(LocalizedString.generalDone.localized) { dismiss() }
            .themedForeground(.header, colorScheme: colorScheme)
    }
    
    private var datePickerSheet: some View {
        DatePickerSheet(
            selectedDate: $viewModel.navigation.selectedDate,
            onDateSelected: { viewModel.navigation.selectDate($0) },
            eventTypeForDate: { viewModel.eventsProvider.eventType(on: $0) },
        )
        .presentationDetents([.medium])
    }
    
    // MARK: - Preference Key
    
    struct HeaderHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}
