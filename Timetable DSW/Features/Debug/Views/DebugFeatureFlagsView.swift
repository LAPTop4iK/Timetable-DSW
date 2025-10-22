//
//  DebugFeatureFlagsView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import SwiftUI

struct DebugFeatureFlagsView: View {
    // MARK: - Environment

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var featureFlagService: DefaultFeatureFlagService
    @EnvironmentObject var appStateService: DefaultAppStateService

    // MARK: - State

    @State private var searchText = ""
    @State private var showingResetAlert = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                // Premium Controls
                premiumSection

                // Feature Flags
                featureFlagsSection

                // Actions
                actionsSection
            }
            .navigationTitle("🔧 Debug Feature Flags")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search flags...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Reset All Flags?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    featureFlagService.resetAll()
                }
            } message: {
                Text("This will reset all local overrides to default values.")
            }
        }
    }

    // MARK: - Sections

    private var premiumSection: some View {
        Section {
            // Current Premium Status
            HStack {
                Text("Premium Status")
                Spacer()
                Text(premiumStatusText)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }

            // Premium Controls
            Button("Grant Permanent Premium") {
                appStateService.grantPremium()
            }

            Button("Grant 1 Hour Premium") {
                appStateService.grantTemporaryPremium()
            }

            Button("Revoke Premium") {
                appStateService.revokePremium()
            }
            .foregroundColor(.red)

        } header: {
            Text("Premium Controls")
        }
    }

    private var featureFlagsSection: some View {
        Section {
            ForEach(filteredFlags, id: \.rawValue) { flag in
                FeatureFlagRow(
                    flag: flag,
                    isEnabled: featureFlagService.isEnabled(flag),
                    hasOverride: featureFlagService.hasLocalOverride(for: flag),
                    onToggle: { enabled in
                        featureFlagService.setEnabled(flag, enabled: enabled)
                    },
                    onReset: {
                        featureFlagService.reset(flag)
                    }
                )
            }
        } header: {
            Text("Feature Flags (\(filteredFlags.count))")
        } footer: {
            Text("Flags with ⚙️ have local overrides. Tap to toggle, swipe to reset.")
        }
    }

    private var actionsSection: some View {
        Section {
            Button("Reset All Flags") {
                showingResetAlert = true
            }
            .foregroundColor(.red)

            Button("Sync from Remote") {
                Task {
                    try? await featureFlagService.syncFromRemote()
                }
            }
        } header: {
            Text("Actions")
        }
    }

    // MARK: - Computed Properties

    private var filteredFlags: [FeatureFlag] {
        let flags = FeatureFlag.allCases

        if searchText.isEmpty {
            return flags
        }

        return flags.filter { flag in
            flag.displayName.localizedCaseInsensitiveContains(searchText) ||
            flag.description.localizedCaseInsensitiveContains(searchText) ||
            flag.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var premiumStatusText: String {
        switch appStateService.state.premiumStatus {
        case .free:
            return "Free"
        case .premium:
            return "Premium (Permanent)"
        case .temporaryPremium(let expiresAt):
            let remaining = expiresAt.timeIntervalSince(Date())
            if remaining > 0 {
                let hours = Int(remaining) / AppStateConfiguration.secondsInHour
                let minutes = (Int(remaining) % AppStateConfiguration.secondsInHour) / 60
                return "Premium (\(hours)h \(minutes)m)"
            } else {
                return "Expired"
            }
        }
    }
}

// MARK: - Feature Flag Row

private struct FeatureFlagRow: View {
    let flag: FeatureFlag
    let isEnabled: Bool
    let hasOverride: Bool
    let onToggle: (Bool) -> Void
    let onReset: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var showingDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(flag.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        if hasOverride {
                            Image(systemName: "gearshape.fill")
                                .font(.caption2)
                                .foregroundAppColor(.themeAccent, colorScheme: colorScheme)
                        }
                    }

                    Text(flag.rawValue)
                        .font(.caption2)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                        .fontDesign(.monospaced)
                }

                Spacer()

                Toggle("", isOn: Binding(
                    get: { isEnabled },
                    set: { onToggle($0) }
                ))
                .labelsHidden()
            }

            if showingDetails {
                Text(flag.description)
                    .font(.caption)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    .padding(.top, 4)
            }

            HStack {
                Button(action: { showingDetails.toggle() }) {
                    Text(showingDetails ? "Hide Details" : "Show Details")
                        .font(.caption)
                }

                if hasOverride {
                    Spacer()
                    Button(action: onReset) {
                        Text("Reset to Default")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct DebugFeatureFlagsView_Previews: PreviewProvider {
    static var previews: some View {
        DebugFeatureFlagsView()
            .environmentObject(DefaultFeatureFlagService())
            .environmentObject(DefaultAppStateService())
    }
}

