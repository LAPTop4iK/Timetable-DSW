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
        }
        static let constants = Constants()
    }

    // MARK: - Input
    let events: [ScheduleEvent]
    let daysInWeek: [Date]
    let selectedDate: Date                     // read-only
    let onSelectDate: (Date) -> Void           // единая точка записи
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
    @State private var applyingSelection = false // анти-реэнтрант

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
    }

    private var selectedDayIndex: Int {
        daysInWeek.firstIndex { calendar.isDate($0, inSameDayAs: selectedDate) } ?? 0
    }

    private var weekIdentifier: String {
        let base = daysInWeek.first ?? selectedDate
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: base)
        return "\(comps.yearForWeekOfYear ?? 0)-\(comps.weekOfYear ?? 0)"
    }

    var body: some View {
        ZStack {
            tabView
            arrowOverlays
        }
        #if DEBUG
        .measurePerformance(name: "DayScheduleTabView", category: .viewAppear)
        #endif
    }

    private var tabView: some View {
        TabView(selection: createSelectionBinding()) {
            ForEach(Array(daysInWeek.enumerated()), id: \.element) { index, date in
                // Убрали ненужный GeometryReader — снижает стоимость layout
                DayEventsView(
                    date: date,
                    events: events,
                    showTeacherName: showTeacherName,
                    onTeacherTap: onTeacherTap,
                    topScrollInset: topInset,
                    bottomScrollInset: bottomInset
                )
                .tag(index)
                .gesture(
                    SimultaneousDragGesture(
                        onChanged: { value in
                            handleDragChanged(translation: value.translation, index: index)
                        },
                        onEnded: { value in
                            handleDragEnded(translation: value.translation, index: index)
                        }
                    )
                )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .transaction { $0.animation = nil } // без implicit-анимаций при программной синхронизации
        .id(weekIdentifier)
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
                            startRadius: Configuration.constants.arrowGlowStartRadius,
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

    // MARK: - Selection binding with reentrancy guard
    private func createSelectionBinding() -> Binding<Int> {
        Binding(
            get: { selectedDayIndex },
            set: { newIndex in
                #if DEBUG
                let startTime = CFAbsoluteTimeGetCurrent()
                #endif

                guard !applyingSelection else { return }
                guard daysInWeek.indices.contains(newIndex) else { return }

                let newDate = daysInWeek[newIndex]
                guard !calendar.isDate(selectedDate, inSameDayAs: newDate) else { return }

                applyingSelection = true
                DispatchQueue.main.async { applyingSelection = false }

                var txn = Transaction(); txn.disablesAnimations = true
                withTransaction(txn) {
                    onSelectDate(newDate)
                }

                #if DEBUG
                let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
                print("[TabView] ⏱ Tab selection took: \(String(format: "%.2f", elapsed))ms")
                #endif
            }
        )
    }

    // MARK: - Gesture / arrows
    private func isHorizontalSwipe(_ t: CGSize) -> Bool {
        let ax = abs(t.width), ay = abs(t.height)
        guard ax > Configuration.constants.minimumHorizontalMovement else { return false }
        return ay < ax * Configuration.constants.verticalToHorizontalRatio
    }

    private func handleDragChanged(translation: CGSize, index: Int) {
        #if DEBUG
        let startTime = CFAbsoluteTimeGetCurrent()
        #endif

        guard isHorizontalSwipe(translation) else {
            hideArrowsIfNeeded()
            return
        }

        dragTranslation = translation.width

        let isFirst = index == 0
        let isLast  = index == daysInWeek.count - 1

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

        #if DEBUG
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("[TabView] ⏱ handleDragChanged took: \(String(format: "%.2f", elapsed))ms")
        #endif
    }

    private func handleDragEnded(translation: CGSize, index: Int) {
        #if DEBUG
        let startTime = CFAbsoluteTimeGetCurrent()
        print("[TabView] 🏁 Drag ended - Index: \(index), Translation: \(String(format: "%.1f", translation.width))px, Threshold: \(Configuration.constants.weekChangeThreshold)px")
        #endif

        guard isHorizontalSwipe(translation) else {
            resetDragState()
            return
        }

        let isFirst = index == 0
        let isLast  = index == daysInWeek.count - 1

        if isLast && translation.width < -Configuration.constants.weekChangeThreshold {
            triggerHaptic()
            onNextWeekFromTabView()
        } else if isFirst && translation.width > Configuration.constants.weekChangeThreshold {
            triggerHaptic()
            onPreviousWeekFromTabView()
        }

        resetDragState()

        #if DEBUG
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("[TabView] ⏱ handleDragEnded took: \(String(format: "%.2f", elapsed))ms")
        #endif
    }

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

    private func resetDragState() {
        withAnimation(.easeOut(duration: 0.15)) {
            dragTranslation = 0
            nextWeekArrowProgress = 0
            prevWeekArrowProgress = 0
            hasTriggeredLightHapticNext = false
            hasTriggeredLightHapticPrev = false
        }
    }

    private func triggerLightHaptic() { hapticService.impact(style: .light) }
    private func triggerHaptic()      { hapticService.impact(style: .medium) }
}
