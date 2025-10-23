//
//  DayScheduleTabView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct DayScheduleTabView: View {
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let minimumDistance: CGFloat = 0
            let arrowThreshold: CGFloat = 50
            let weekChangeThreshold: CGFloat = AppDimensions.weekChangeThreshold.value
            let verticalToHorizontalRatio: CGFloat = 1.5
            let minimumHorizontalMovement: CGFloat = 20
            let arrowSize: CGFloat = 64
            let arrowBlurSize: CGFloat = 80
            let arrowPadding: AppSpacing = .xxxl
            let arrowIconSize: CGFloat = 32
            let arrowShadowRadius: CGFloat = 20
            let arrowShadowY: CGFloat = 8
            let arrowShadowOpacity: Double = 0.5
            let arrowGlowOpacity: Double = 0.4
            let arrowGlowStartRadius: CGFloat = 5
            let arrowGlowRadiusMultiplier: CGFloat = 0.6
            let baseScale: CGFloat = 0.7
            let scaleMultiplier: CGFloat = 0.3
            let hideSpringResponse: Double = 0.25
            let hideSpringDamping: Double = 0.8
            let swipeThreshold: CGFloat = 50
            let animationDuration: Double = 0.3
        }
        static let constants = Constants()
    }

    // MARK: - Input
    let events: [ScheduleEvent]
    let daysInWeek: [Date]
    let selectedDate: Date
    let onSelectDate: (Date) -> Void
    let showTeacherName: Bool
    let topInset: CGFloat
    let bottomInset: CGFloat
    let onTeacherTap: ((Int) -> Void)?
    let onNextWeekFromTabView: () -> Void
    let onPreviousWeekFromTabView: () -> Void

    // MARK: - State
    @State private var dragTranslation: CGFloat = 0
    @State private var nextWeekArrowProgress: CGFloat = 0
    @State private var prevWeekArrowProgress: CGFloat = 0
    @State private var hasTriggeredLightHapticNext = false
    @State private var hasTriggeredLightHapticPrev = false
    @State private var contentOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    // MARK: - Env & Deps
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.calendar) private var calendar
    private let hapticService: HapticFeedbackService

    init(
        events: [ScheduleEvent],
        daysInWeek: [Date],
        selectedDate: Date,
        onSelectDate: @escaping (Date) -> Void,
        showTeacherName: Bool,
        topInset: CGFloat,
        bottomInset: CGFloat,
        onTeacherTap: ((Int) -> Void)?,
        onNextWeekFromTabView: @escaping () -> Void,
        onPreviousWeekFromTabView: @escaping () -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self.events = events
        self.daysInWeek = daysInWeek
        self.selectedDate = selectedDate
        self.onSelectDate = onSelectDate
        self.showTeacherName = showTeacherName
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.onTeacherTap = onTeacherTap
        self.onNextWeekFromTabView = onNextWeekFromTabView
        self.onPreviousWeekFromTabView = onPreviousWeekFromTabView
        self.hapticService = hapticService

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEEE"
        formatter.locale = Locale(identifier: "en_US")

        print("📱 [DayScheduleTabView.init] Initializing with \(daysInWeek.count) days")
        print("📱 [DayScheduleTabView.init] Selected date: \(formatter.string(from: selectedDate))")
        print("📱 [DayScheduleTabView.init] Days in week:")
        daysInWeek.enumerated().forEach { index, date in
            print("   [\(index)]: \(formatter.string(from: date))")
        }
    }

    private var selectedDayIndex: Int {
        let index = daysInWeek.firstIndex { calendar.isDate($0, inSameDayAs: selectedDate) } ?? 0

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEEE"
        formatter.locale = Locale(identifier: "en_US")

        print("🎯 [DayScheduleTabView.selectedDayIndex] Computed index: \(index) for selectedDate: \(formatter.string(from: selectedDate))")

        return index
    }

    private var weekIdentifier: String {
        let base = daysInWeek.first ?? selectedDate
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: base)
        return "\(comps.yearForWeekOfYear ?? 0)-\(comps.weekOfYear ?? 0)"
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    // OPTIMIZED: Lazy loading - только видимые дни
                    lazyScrollView(width: geometry.size.width)

                    arrowOverlays
                }
                .onAppear {
                    screenWidth = geometry.size.width
                    updateContentOffset(animated: false)
                }
                .onChange(of: selectedDayIndex) { _ in
                    updateContentOffset(animated: true)
                }
            }
        }
        #if DEBUG
        .measurePerformance(name: "DayScheduleTabView", category: .viewAppear)
        #endif
    }

    // MARK: - Lazy Scroll View (PERFORMANCE OPTIMIZATION)

    private func lazyScrollView(width: CGFloat) -> some View {
        let offset = contentOffset + dragTranslation

        return ZStack {
            // Рендерим только current, previous и next день (max 3 views вместо 7)
            ForEach(visibleIndices(), id: \.self) { index in
                if daysInWeek.indices.contains(index) {
                    DayEventsView(
                        date: daysInWeek[index],
                        events: events,
                        showTeacherName: showTeacherName,
                        onTeacherTap: onTeacherTap,
                        topScrollInset: topInset,
                        bottomScrollInset: bottomInset
                    )
                    .id(daysInWeek[index])
                    .frame(width: width)
                    .offset(x: CGFloat(index) * width + offset)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: Configuration.constants.minimumDistance)
                .onChanged { value in
                    handleDragChanged(translation: value.translation)
                }
                .onEnded { value in
                    handleDragEnded(translation: value.translation, predictedEnd: value.predictedEndTranslation)
                }
        )
        .clipped()
    }

    // PERFORMANCE: Рендерим только видимые индексы
    private func visibleIndices() -> [Int] {
        let current = selectedDayIndex
        var indices: [Int] = [current]

        // Добавляем соседние только если они существуют
        if current > 0 {
            indices.append(current - 1)
        }
        if current < daysInWeek.count - 1 {
            indices.append(current + 1)
        }

        let sorted = indices.sorted()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEEE"
        formatter.locale = Locale(identifier: "en_US")

        print("👁️ [DayScheduleTabView.visibleIndices] Current index: \(current)")
        print("👁️ [DayScheduleTabView.visibleIndices] Visible indices: \(sorted)")
        sorted.forEach { index in
            if daysInWeek.indices.contains(index) {
                print("   [\(index)] -> \(formatter.string(from: daysInWeek[index]))")
            }
        }

        return sorted
    }

    private var arrowOverlays: some View {
        Group {
            if nextWeekArrowProgress > 0 {
                arrowView(isNext: true)
                    .opacity(nextWeekArrowProgress)
                    .scaleEffect(Configuration.constants.baseScale + nextWeekArrowProgress * Configuration.constants.scaleMultiplier)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            }
            if prevWeekArrowProgress > 0 {
                arrowView(isNext: false)
                    .opacity(prevWeekArrowProgress)
                    .scaleEffect(Configuration.constants.baseScale + prevWeekArrowProgress * Configuration.constants.scaleMultiplier)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
            }
        }
        .allowsHitTesting(false)
    }

    private func arrowView(isNext: Bool) -> some View {
        HStack {
            if !isNext {
                arrowContent(icon: .chevronLeft)
                    .padding(.leading, Configuration.constants.arrowPadding.value)
                Spacer()
            } else {
                Spacer()
                arrowContent(icon: .chevronRight)
                    .padding(.trailing, Configuration.constants.arrowPadding.value)
            }
        }
    }

    private func arrowContent(icon: AppIcon) -> some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: Configuration.constants.arrowBlurSize, height: Configuration.constants.arrowBlurSize)
                Circle()
                    .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: Configuration.constants.arrowBlurSize, height: Configuration.constants.arrowBlurSize)
                    .opacity(0.9)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppColor.white.color(for: colorScheme).opacity(Configuration.constants.arrowGlowOpacity),
                                     AppColor.clear.color(for: colorScheme)],
                            center: .topLeading,
                            startRadius: 5,
                            endRadius: Configuration.constants.arrowBlurSize * Configuration.constants.arrowGlowRadiusMultiplier
                        )
                    )
                    .frame(width: Configuration.constants.arrowBlurSize, height: Configuration.constants.arrowBlurSize)
                icon.image()
                    .font(AppTypography.custom(size: Configuration.constants.arrowIconSize, weight: .bold).font)
                    .foregroundAppColor(.white, colorScheme: colorScheme)
            }
            .shadow(color: gradientColors[0].opacity(Configuration.constants.arrowShadowOpacity),
                    radius: Configuration.constants.arrowShadowRadius, x: 0, y: Configuration.constants.arrowShadowY)
            Spacer()
        }
    }

    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }

    // MARK: - Gesture Handlers

    private func isHorizontalSwipe(_ t: CGSize) -> Bool {
        let ax = abs(t.width), ay = abs(t.height)
        guard ax > Configuration.constants.minimumHorizontalMovement else { return false }
        return ay < ax * Configuration.constants.verticalToHorizontalRatio
    }

    private func handleDragChanged(translation: CGSize) {
        guard isHorizontalSwipe(translation) else {
            hideArrowsIfNeeded()
            return
        }

        isDragging = true
        dragTranslation = translation.width

        let index = selectedDayIndex
        let isFirst = index == 0
        let isLast  = index == daysInWeek.count - 1

        // Next week arrow
        if isLast && dragTranslation < 0 {
            let p = min(abs(dragTranslation) / Configuration.constants.weekChangeThreshold, 1.0)
            updateArrowProgress(&nextWeekArrowProgress, to: p)
            if p >= 0.5 && !hasTriggeredLightHapticNext {
                triggerLightHaptic()
                hasTriggeredLightHapticNext = true
            }
        } else {
            updateArrowProgress(&nextWeekArrowProgress, to: 0)
            hasTriggeredLightHapticNext = false
        }

        // Previous week arrow
        if isFirst && dragTranslation > 0 {
            let p = min(dragTranslation / Configuration.constants.weekChangeThreshold, 1.0)
            updateArrowProgress(&prevWeekArrowProgress, to: p)
            if p >= 0.5 && !hasTriggeredLightHapticPrev {
                triggerLightHaptic()
                hasTriggeredLightHapticPrev = true
            }
        } else {
            updateArrowProgress(&prevWeekArrowProgress, to: 0)
            hasTriggeredLightHapticPrev = false
        }
    }

    private func handleDragEnded(translation: CGSize, predictedEnd: CGSize) {
        guard isHorizontalSwipe(translation) else {
            resetDragState()
            return
        }

        let index = selectedDayIndex
        let isFirst = index == 0
        let isLast  = index == daysInWeek.count - 1

        // Week change detection
        if isLast && translation.width < -Configuration.constants.weekChangeThreshold {
            triggerHaptic()
            onNextWeekFromTabView()
            resetDragState()
            return
        } else if isFirst && translation.width > Configuration.constants.weekChangeThreshold {
            triggerHaptic()
            onPreviousWeekFromTabView()
            resetDragState()
            return
        }

        // Day change detection
        let threshold = Configuration.constants.swipeThreshold
        var targetIndex = index

        if translation.width < -threshold && index < daysInWeek.count - 1 {
            targetIndex = index + 1
        } else if translation.width > threshold && index > 0 {
            targetIndex = index - 1
        }

        // Анимированный переход
        isDragging = false

        if targetIndex != index {
            hapticService.impact(style: .light)
            onSelectDate(daysInWeek[targetIndex])
        }

        withAnimation(.spring(response: Configuration.constants.animationDuration, dampingFraction: 0.8)) {
            dragTranslation = 0
        }

        resetArrows()
    }

    // MARK: - Content Offset Management

    private func updateContentOffset(animated: Bool) {
        let targetOffset = -CGFloat(selectedDayIndex) * screenWidth

        if animated {
            withAnimation(.spring(response: Configuration.constants.animationDuration, dampingFraction: 0.8)) {
                contentOffset = targetOffset
            }
        } else {
            contentOffset = targetOffset
        }
    }

    // MARK: - Helper Methods

    private let progressEpsilon: CGFloat = 0.02
    private func updateArrowProgress(_ p: inout CGFloat, to v: CGFloat) {
        let clamped = min(max(v, 0), 1)
        guard abs(p - clamped) > progressEpsilon else { return }
        p = clamped
    }

    private func hideArrowsIfNeeded() {
        guard nextWeekArrowProgress > 0 || prevWeekArrowProgress > 0 else { return }
        withAnimation(.easeOut(duration: 0.15)) {
            nextWeekArrowProgress = 0
            prevWeekArrowProgress = 0
        }
    }

    private func resetArrows() {
        withAnimation(.easeOut(duration: 0.15)) {
            nextWeekArrowProgress = 0
            prevWeekArrowProgress = 0
            hasTriggeredLightHapticNext = false
            hasTriggeredLightHapticPrev = false
        }
    }

    private func resetDragState() {
        isDragging = false
        withAnimation(.spring(response: Configuration.constants.animationDuration, dampingFraction: 0.8)) {
            dragTranslation = 0
        }
        resetArrows()
    }

    private func triggerLightHaptic() { hapticService.impact(style: .light) }
    private func triggerHaptic()      { hapticService.impact(style: .medium) }
}
