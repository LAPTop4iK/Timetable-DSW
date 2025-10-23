//
//  WidgetSettingsView.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI
import WidgetKit

struct WidgetSettingsView: View {
    // MARK: - Configuration

    struct Configuration: ComponentConfiguration {
        struct Constants {
            let sectionSpacing: AppSpacing = .xl
            let itemSpacing: AppSpacing = .medium
            let cardPadding: AppSpacing = .medium
            let cardCornerRadius: AppCornerRadius = .large
            let instructionSpacing: AppSpacing = .small
        }
        static let constants = Constants()
    }

    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.bottomInsetService) private var bottomInsetService

    // MARK: - State

    @State private var lastUpdated: Date? = AppGroupManager.loadLastUpdated()

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: Configuration.constants.sectionSpacing.value) {
                statusSection
                instructionsSection
                widgetTypesSection
                troubleshootingSection
            }
            .padding()
        }
        .background(AppColor.background.color(for: colorScheme))
        .navigationTitle("Widget Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    refreshWidgets()
                } label: {
                    AppIcon.arrowClockwise.image()
                        .font(.system(size: 16, weight: .semibold))
                        .themedForeground(.header, colorScheme: colorScheme)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            AppColor.clear.color(for: colorScheme)
                .frame(height: bottomInsetService?.bottomInset ?? 78)
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text("Status")
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)

            statusCard
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Widgets Enabled")
                        .font(AppTypography.body.font)
                        .fontWeight(.semibold)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    if let lastUpdated = lastUpdated {
                        Text("Last updated: \(lastUpdated, style: .relative) ago")
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    } else {
                        Text("Never updated")
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    }
                }
            }

            Text("Your widgets have access to your schedule data")
                .font(AppTypography.caption.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
        .padding(Configuration.constants.cardPadding.value)
        .background {
            RoundedRectangle(cornerRadius: Configuration.constants.cardCornerRadius.value)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: Configuration.constants.cardCornerRadius.value)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
        }
    }

    // MARK: - Instructions Section

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text("How to Add Widget")
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)

            VStack(alignment: .leading, spacing: Configuration.constants.instructionSpacing.value) {
                instructionRow(step: 1, text: "Long press on your home screen")
                instructionRow(step: 2, text: "Tap the \"+\" button in the top-left")
                instructionRow(step: 3, text: "Search for \"Timetable\"")
                instructionRow(step: 4, text: "Choose widget size and add")
            }
        }
    }

    private func instructionRow(step: Int, text: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColor.themePrimary.color(for: colorScheme),
                                AppColor.themeSecondary.color(for: colorScheme)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)

                Text("\(step)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(text)
                .font(AppTypography.body.font)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)
        }
    }

    // MARK: - Widget Types Section

    private var widgetTypesSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text("Available Widgets")
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)

            widgetTypeCard(
                title: "Small Widget",
                icon: "square.fill",
                description: "Shows current or next class"
            )

            widgetTypeCard(
                title: "Medium Widget",
                icon: "rectangle.fill",
                description: "Today's schedule (up to 3 classes)"
            )

            widgetTypeCard(
                title: "Large Widget",
                icon: "rectangle.portrait.fill",
                description: "Weekly schedule overview"
            )

            widgetTypeCard(
                title: "Live Activity",
                icon: "circle.hexagongrid.circle.fill",
                description: "Real-time class tracking (Dynamic Island)"
            )
        }
    }

    private func widgetTypeCard(title: String, icon: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColor.themePrimary.color(for: colorScheme),
                            AppColor.themeSecondary.color(for: colorScheme)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.body.font)
                    .fontWeight(.semibold)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                Text(description)
                    .font(AppTypography.caption.font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }
        }
        .padding(Configuration.constants.cardPadding.value)
        .background {
            RoundedRectangle(cornerRadius: Configuration.constants.cardCornerRadius.value)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: Configuration.constants.cardCornerRadius.value)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
        }
    }

    // MARK: - Troubleshooting Section

    private var troubleshootingSection: some View {
        VStack(alignment: .leading, spacing: Configuration.constants.itemSpacing.value) {
            Text("Troubleshooting")
                .font(AppTypography.title3.font)
                .fontWeight(.semibold)
                .foregroundAppColor(.primaryText, colorScheme: colorScheme)

            VStack(alignment: .leading, spacing: 12) {
                troubleshootingItem(
                    problem: "Widget shows \"No Data\"",
                    solution: "Open the app at least once to load your schedule"
                )

                troubleshootingItem(
                    problem: "Widget not updating",
                    solution: "Tap the refresh button above to manually update"
                )

                troubleshootingItem(
                    problem: "Wrong theme colors",
                    solution: "Change theme in app, widgets will update automatically"
                )
            }
        }
    }

    private func troubleshootingItem(problem: String, solution: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)

                Text(problem)
                    .font(AppTypography.caption.font)
                    .fontWeight(.semibold)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)
            }

            Text(solution)
                .font(AppTypography.caption2.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                .padding(.leading, 22)
        }
    }

    // MARK: - Actions

    private func refreshWidgets() {
        // Reload all widgets
        WidgetCenter.shared.reloadAllTimelines()

        // Update last updated timestamp
        lastUpdated = Date()
        AppGroupManager.saveLastUpdated(Date())
    }
}
