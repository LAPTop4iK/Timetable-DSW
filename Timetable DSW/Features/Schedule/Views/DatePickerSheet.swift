//
//  DatePickerSheet.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI
import UIKit

struct DatePickerSheet: View {
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let spacing: AppSpacing = .small
            let dayHeight: CGFloat = AppDimensions.buttonHeight.value
            let dayEmptyHeight: CGFloat = AppDimensions.buttonHeight.value
            let headerHeight: CGFloat = 28
            let monthNavPadding: AppSpacing = .large
            let gridPadding: AppSpacing = .large
            let weekdayToGridSpacing: AppSpacing = .medium
            let dotSize: CGFloat = AppDimensions.dotMedium.value
            let circleSize: CGFloat = AppDimensions.dotLarge.value
            let legendSpacing: CGFloat = 24
            let legendItemSpacing: AppSpacing = .xs
            let legendPadding: AppSpacing = .small
            let circleStrokeWidth: CGFloat = AppDimensions.lineSmall.value
            let gridTopPadding: AppSpacing = .xs
            let springResponse: Double = 0.3
            let springDamping: Double = 0.7

            // Для бейджа "только онлайн"
            let onlineBadgeHeight: CGFloat = 10
            let onlineBadgeMinWidth: CGFloat = 20
            let onlineBadgeHorizontalPadding: CGFloat = 6
        }
        static let constants = Constants()
    }

    // MARK: - Input
    @Binding var selectedDate: Date
    var onDateSelected: ((Date) -> Void)?
    let eventTypeForDate: (Date) -> EventDayType

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - State
    @State private var currentMonth: Date = Date()
    @State private var measuredHeight: CGFloat = 520
    @State private var preferredDetent: CGFloat = 520

    // MARK: - Deps
    private let calendar: Calendar
    private let hapticService: HapticFeedbackService
    private let dateService: DateService

    // MARK: - Layout
    private let columns = Array(repeating: GridItem(.flexible(minimum: 0, maximum: .infinity)), count: 7)

    init(
        selectedDate: Binding<Date>,
        onDateSelected: ((Date) -> Void)? = nil,
        eventTypeForDate: @escaping (Date) -> EventDayType,
        calendar: Calendar = .current,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService(),
        dateService: DateService = DefaultDateService.shared
    ) {
        self._selectedDate = selectedDate
        self.onDateSelected = onDateSelected
        self.eventTypeForDate = eventTypeForDate
        self.calendar = calendar
        self.hapticService = hapticService
        self.dateService = dateService
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                monthNavigationHeader
                    .padding(.bottom, Configuration.constants.spacing.value)

                weekdayHeaders
                    .padding(.bottom, Configuration.constants.weekdayToGridSpacing.value)

                calendarGrid

                legend
                    .padding(.top, Configuration.constants.spacing.value)
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { updateDetent(with: geo.size.height) }
                        .onChange(of: geo.size.height) { updateDetent(with: $0) }
                }
            )
            .navigationTitle(LocalizedString.scheduleSelectDate.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { todayButton }
                ToolbarItem(placement: .confirmationAction) { doneButton }
            }
        }
        // Важно: выставляем detent здесь, чтобы он динамически подстраивался.
//        .presentationDetents([.height(preferredDetent), .large])
        .presentationDetents([.medium])
//        .presentationDragIndicator(.visible)
    }

    // MARK: - Header
    private var monthNavigationHeader: some View {
        HStack(spacing: AppSpacing.xl.value) {
            Button(action: previousMonth) {
                AppIcon.chevronLeftCircleFill.image()
                    .font(AppTypography.title2.font)
                    .themedForeground(.header, colorScheme: colorScheme)
            }
            Spacer()
            Text(monthYearString(currentMonth))
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
            Spacer()
            Button(action: nextMonth) {
                AppIcon.chevronRightCircleFill.image()
                    .font(AppTypography.title2.font)
                    .themedForeground(.header, colorScheme: colorScheme)
            }
        }
        .padding(.horizontal, Configuration.constants.monthNavPadding.value)
    }

    private var weekdayHeaders: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(AppTypography.caption.font)
                    .fontWeight(.semibold)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    .frame(height: Configuration.constants.headerHeight)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Configuration.constants.gridPadding.value)
    }

    // MARK: - Grid
    private var calendarGrid: some View {
        // Скролл остаётся как fallback, но при нормальном размере не потребуется
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: Configuration.constants.spacing.value) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, maybeDate in
                    if let date = maybeDate {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            eventType: eventTypeForDate(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            selectDate(date)
                        }
                    } else {
                        AppColor.clear.color(for: colorScheme)
                            .frame(height: Configuration.constants.dayEmptyHeight)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, Configuration.constants.gridPadding.value)
            .padding(.top, Configuration.constants.gridTopPadding.value)
        }
    }

    // MARK: - Legend
    private var legend: some View {
        HStack(spacing: Configuration.constants.legendSpacing) {
            legendItem(text: LocalizedString.scheduleHasClasses.localized, kind: .regular)    // точка
            legendItem(text: LocalizedString.scheduleOnlineOnly.localized, kind: .onlineOnly) // зелёный бейдж
            legendItem(text: LocalizedString.generalToday.localized, kind: .today)            // обводка
        }
        .padding(.horizontal, Configuration.constants.gridPadding.value)
        .padding(.bottom, Configuration.constants.legendPadding.value)
    }

    private enum LegendKind { case regular, onlineOnly, today }

    private func legendItem(text: String, kind: LegendKind) -> some View {
        HStack(spacing: Configuration.constants.legendItemSpacing.value) {
            switch kind {
            case .regular:
                Circle()
                    .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: Configuration.constants.dotSize, height: Configuration.constants.dotSize)

            case .onlineOnly:
                Circle()
                    .fill(LinearGradient(colors: onlineGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: Configuration.constants.dotSize, height: Configuration.constants.dotSize)
            case .today:
                Circle()
                    .strokeBorder(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                                  lineWidth: Configuration.constants.circleStrokeWidth)
                    .frame(width: Configuration.constants.circleSize, height: Configuration.constants.circleSize)
            }

            Text(text)
                .font(AppTypography.caption.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }

    // MARK: - Toolbar
    private var todayButton: some View {
        Button(action: { selectDate(Date()) }) {
            Text(LocalizedString.generalToday.localized).fontWeight(.medium)
        }
        .themedForeground(.header, colorScheme: colorScheme)
    }

    private var doneButton: some View {
        Button(LocalizedString.generalDone.localized) { dismiss() }
            .fontWeight(.medium)
            .themedForeground(.header, colorScheme: colorScheme)
    }

    // MARK: - Helpers
    private var gradientColors: [Color] {
        GradientStyle.header.colors(for: colorScheme)
    }

    private var onlineGradient: [Color] {
        GradientStyle.online.colors(for: colorScheme)
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = .current
        let symbols = formatter.shortWeekdaySymbols ?? []
        var result = symbols
        if calendar.firstWeekday == 2 { result = Array(symbols[1...]) + [symbols[0]] }
        return result.map { String($0.prefix(3)).uppercased() }
    }

    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }

        let days = CalendarHelper.generateDates(
            in: calendar,
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )

        var offset = calendar.component(.weekday, from: monthInterval.start) - calendar.firstWeekday
        if offset < 0 { offset += 7 }

        var result: [Date?] = Array(repeating: nil, count: offset)
        result.append(contentsOf: days.map { $0 as Date? })
        return result
    }

    private func monthYearString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy LLLL"
        formatter.locale = .current
        return formatter.string(from: date)
    }

    private func previousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        withAnimation(.spring(response: Configuration.constants.springResponse, dampingFraction: Configuration.constants.springDamping)) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        withAnimation(.spring(response: Configuration.constants.springResponse, dampingFraction: Configuration.constants.springDamping)) {
            currentMonth = newMonth
        }
    }

    private func selectDate(_ date: Date) {
        hapticService.impact(style: .light)
        onDateSelected?(date)
        if !calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
            withAnimation(.spring(response: Configuration.constants.springResponse, dampingFraction: Configuration.constants.springDamping)) {
                currentMonth = date
            }
        }
    }

    // MARK: - Dynamic detent
    private func updateDetent(with contentHeight: CGFloat) {
        measuredHeight = contentHeight

        // Нормируем: оставим небольшой отступ и ограничим долей экрана
        let screenH = UIScreen.main.bounds.height
        let maxAllowed = screenH * 0.88  // чтобы не упираться в низ/верх
        let minAllowed: CGFloat = 360

        let clamped = min(max(contentHeight + 8, minAllowed), maxAllowed)
        if abs(clamped - preferredDetent) > 0.5 {
            preferredDetent = clamped
        }
    }
}
