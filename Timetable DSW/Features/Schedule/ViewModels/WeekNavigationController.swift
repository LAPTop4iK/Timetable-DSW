import Foundation
import Combine
import SwiftUI

@MainActor
final class WeekNavigationController: ObservableObject {
    // MARK: - Configuration
    struct Configuration {
        struct Constants {}
        static let constants = Constants()
    }

    // MARK: - Published
    @Published var selectedDate: Date
    @Published var weekStart: Date
    @Published var showingDatePicker = false

    // MARK: - Deps
    private let dateService: DateService
    private let calendar: Calendar

    // MARK: - Computed
    var daysInWeek: [Date] {
        dateService.daysInWeek(startingFrom: weekStart)
    }

    // MARK: - Init
    init(
        initialDate: Date = Date(),
        dateService: DateService = DefaultDateService(),
        calendar: Calendar = .current
    ) {
        self.dateService = dateService
        self.calendar = calendar
        let normalized = calendar.startOfDay(for: initialDate)
        self.selectedDate = normalized
        self.weekStart = dateService.startOfWeek(for: normalized)
    }

    // MARK: - Date Selection
    private var selectionApplyCount = 0

    func selectDate(_ date: Date) {
        let normalized = calendar.startOfDay(for: date)
        // печать — по желанию:
        // print("selectDate applied: \(normalized)")
        guard !calendar.isDate(selectedDate, inSameDayAs: normalized) else { return }

        var txn = Transaction(); txn.disablesAnimations = true          // 👈 без анимаций
        withTransaction(txn) { selectedDate = normalized }
        updateWeekStartIfNeeded(for: normalized)
    }

    private func updateWeekStartIfNeeded(for date: Date) {
        let newWeekStart = dateService.startOfWeek(for: date)
        guard !calendar.isDate(weekStart, equalTo: newWeekStart, toGranularity: .weekOfYear) else { return }
        weekStart = newWeekStart
    }

    // MARK: - Week Navigation (Slider / TabView)
    func nextWeekFromSlider()    { moveWeek(by: 1, selectFirst: true) }
    func previousWeekFromSlider(){ moveWeek(by: -1, selectFirst: true) }
    func nextWeekFromTabView()   { moveWeek(by: 1, selectFirst: true) }
    func previousWeekFromTabView(){ moveWeek(by: -1, selectFirst: false) }

    // MARK: - Private
    private func moveWeek(by value: Int, selectFirst: Bool) {
        guard let newWeekStart = calendar.date(byAdding: .weekOfYear, value: value, to: weekStart) else { return }
        weekStart = newWeekStart

        if selectFirst {
            selectDate(newWeekStart)
        } else {
            let last = calendar.date(byAdding: .day, value: 6, to: newWeekStart) ?? newWeekStart
            selectDate(last)
        }
    }
}
