//
//  SuccessFeedbackSystem.swift
//  Timetable DSW
//
//  Unified system for success feedback
//

import SwiftUI
import Combine

@MainActor
class SuccessFeedbackSystem: ObservableObject {
    @Published var showBorderEffect = false

    private let hapticService: HapticFeedbackService
    private var borderEffectTask: Task<Void, Never>?

    init(hapticService: HapticFeedbackService = DefaultHapticFeedbackService()) {
        self.hapticService = hapticService
    }

    func celebrate(
        message: String,
        icon: String = "checkmark.circle.fill",
        toastManager: ToastManager
    ) {
        // Cancel previous border effect task if still running
        borderEffectTask?.cancel()

        // 1. Haptic feedback
        hapticService.impact(style: .medium)

        // 2. Show border effect
        showBorderEffect = true

        // 3. Show toast after short delay
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            toastManager.show(message: message, icon: icon)
        }

        // Reset border effect after animation
        borderEffectTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s
            if !Task.isCancelled {
                self.showBorderEffect = false
            }
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
