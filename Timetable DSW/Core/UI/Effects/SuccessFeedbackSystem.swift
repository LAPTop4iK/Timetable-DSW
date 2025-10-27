//
//  SuccessFeedbackSystem.swift
//  Timetable DSW
//
//  Unified system for success feedback
//

import SwiftUI

@MainActor
class SuccessFeedbackSystem: ObservableObject {
    @Published var showBorderEffect = false

    private let hapticService: HapticFeedbackService

    init(hapticService: HapticFeedbackService = DefaultHapticFeedbackService()) {
        self.hapticService = hapticService
    }

    func celebrate(
        message: String,
        icon: String = "checkmark.circle.fill",
        toastManager: ToastManager
    ) {
        // 1. Haptic feedback
        hapticService.success()

        // 2. Show border effect
        showBorderEffect = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 3. Show toast
            toastManager.show(message: message, icon: icon)
        }

        // Reset border effect after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showBorderEffect = false
        }
    }
}

// MARK: - Environment Key

private struct SuccessFeedbackSystemKey: EnvironmentKey {
    static let defaultValue: SuccessFeedbackSystem? = nil
}

extension EnvironmentValues {
    var successFeedback: SuccessFeedbackSystem? {
        get { self[SuccessFeedbackSystemKey.self] }
        set { self[SuccessFeedbackSystemKey.self] = newValue }
    }
}

extension View {
    func successFeedbackSystem(_ system: SuccessFeedbackSystem) -> some View {
        environment(\.successFeedback, system)
    }
}
