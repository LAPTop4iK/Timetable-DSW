//
//  PremiumStatusButton.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import SwiftUI

struct PremiumStatusButton: View {
    // MARK: - Properties

    let premiumAccess: PremiumAccess
    let onTap: () -> Void

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                icon
                if case .temporaryPremium = premiumAccess.status {
                    timerText
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundView)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Subviews

    @ViewBuilder
    private var icon: some View {
        if premiumAccess.isPremium {
            Image(systemName: "crown.fill")
                .font(.system(size: 16, weight: .semibold))
                .themedForeground(.header, colorScheme: colorScheme)
        } else {
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .themedForeground(.header, colorScheme: colorScheme)
        }
    }

    @ViewBuilder
    private var timerText: some View {
        if let timeRemaining = premiumAccess.formattedTimeRemaining {
            Text(timeRemaining)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }

    private var backgroundView: some View {
        ZStack {
            if premiumAccess.isPremium {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: gradientColors.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: gradientColors.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.secondaryBackground.color(for: colorScheme).opacity(0.3))
            }
        }
    }

    private var gradientColors: [Color] {
        GradientStyle.primary.colors(for: colorScheme)
    }
}
