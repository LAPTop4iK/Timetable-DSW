//
//  SuccessToast.swift
//  Timetable DSW
//
//  Beautiful success toast notification
//

import SwiftUI

struct SuccessToast: View {
    let message: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(message)
                .font(AppTypography.body.font)
                .fontWeight(.medium)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background {
            ZStack {
                // Glassmorphism background
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                .green.opacity(0.1),
                                .cyan.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Subtle glow
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .cyan.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .shadow(color: .green.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Toast Manager

@MainActor
class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    @Published var icon = "checkmark.circle.fill"

    func show(message: String, icon: String = "checkmark.circle.fill") {
        self.message = message
        self.icon = icon

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isShowing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                self.isShowing = false
            }
        }
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @StateObject private var manager = ToastManager()

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if manager.isShowing {
                    SuccessToast(message: manager.message, icon: manager.icon)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(999)
                }
            }
            .environmentObject(manager)
    }
}

extension View {
    func toastManager() -> some View {
        modifier(ToastModifier())
    }
}
