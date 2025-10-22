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
                    Button(LocalizedString.debugDone.localized) { dismiss() }
                }
            }
            .alert("Reset All Flags?", isPresented: $showingResetAlert) {
                Button(LocalizedString.debugCancel.localized, role: .cancel) {}
                Button(LocalizedString.generalDone.localized, role: .destructive) {
                    featureFlagService.resetAll()
                }
            } message: {
                Text(LocalizedString.debugResetConfirm.localized)
            }
        }
    }

    // MARK: - Sections

    private var premiumSection: some View {
        Section {
            // Current Premium Status
            HStack {
                Text(LocalizedString.debugPremiumStatus.localized)
                Spacer()
                Text(premiumStatusText)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }

            // Premium Controls
            Button(LocalizedString.debugGrantPermanentPremium.localized) {
                appStateService.grantPremium()
            }

            Button(LocalizedString.debugGrant1HourPremium.localized) {
                appStateService.grantTemporaryPremium()
            }

            Button(LocalizedString.debugRevokePremium.localized) {
                appStateService.revokePremium()
            }
            .foregroundColor(.red)

        } header: {
            Text(LocalizedString.debugPremiumControls.localized)
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
            Text(LocalizedString.debugFlagsFooter.localized)
        }
    }

    private var actionsSection: some View {
        Section {
            Button(LocalizedString.debugResetAllFlags.localized) {
                showingResetAlert = true
            }
            .foregroundColor(.red)

            Button(LocalizedString.debugSyncFromRemote.localized) {
                Task {
                    try? await featureFlagService.syncFromRemote()
                }
            }
        } header: {
            Text(LocalizedString.debugActions.localized)
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
                    Text(showingDetails ? LocalizedString.debugHideDetails.localized : LocalizedString.debugShowDetails.localized)
                        .font(.caption)
                }

                if hasOverride {
                    Spacer()
                    Button(action: onReset) {
                        Text(LocalizedString.debugResetToDefault.localized)
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

