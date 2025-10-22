//
//  PremiumStatusPresentation.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


import SwiftUI
import Combine

// MARK: - Presentation Models (Single Responsibility: Data for UI)

struct PremiumStatusPresentation {
    let statusText: String
    let expirationDate: Date?
    let canRevoke: Bool

    init(status: PremiumStatus) {
        switch status {
        case .free:
            self.statusText = "Free"
            self.expirationDate = nil
            self.canRevoke = false

        case .premium:
            self.statusText = "Premium"
            self.expirationDate = nil
            self.canRevoke = true

        case .temporaryPremium(let expiresAt):
            self.statusText = "Trial"
            self.expirationDate = expiresAt
            self.canRevoke = true
        }
    }
}

struct FeatureFlagPresentation: Identifiable {
    let id: FeatureFlag
    let flag: FeatureFlag
    let isEnabled: Bool
    let hasLocalOverride: Bool

    var displayName: String { flag.displayName }
    var description: String { flag.description }
}

struct AppStatistics {
    let totalAdsWatched: Int
    let lastAdWatchedDate: Date?
    let premiumPurchaseDate: Date?

    init(from state: AppState) {
        self.totalAdsWatched = state.totalAdsWatched
        self.lastAdWatchedDate = state.lastAdWatchedDate
        self.premiumPurchaseDate = state.premiumPurchaseDate
    }
}

// MARK: - Debug Actions (Single Responsibility: User Actions)

enum DebugAction {
    case grantPremium
    case grantTemporaryPremium
    case revokePremium
    case toggleFlag(FeatureFlag, Bool)
    case resetFlag(FeatureFlag)
    case resetAllFlags
    case syncFlags
    case clearAllData
}

// MARK: - View State

enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case failure(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

// MARK: - ViewModel

@MainActor
final class DebugMenuViewModel: ObservableObject {

    // MARK: - Dependencies

    private let featureFlagService: FeatureFlagService  // ✅ Protocol!
    private let appStateService: AppStateService        // ✅ Protocol!

    // MARK: - Published State

    @Published private(set) var premiumPresentation: PremiumStatusPresentation
    @Published private(set) var featureFlags: [FeatureFlagPresentation] = []
    @Published private(set) var statistics: AppStatistics
    @Published private(set) var syncState: LoadingState = .idle
    @Published private(set) var lastSyncDate: Date?

    // Alert state
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var confirmationAction: DebugAction?
    @Published var showConfirmation = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        featureFlagService: FeatureFlagService,  // ✅ Protocol!
        appStateService: AppStateService         // ✅ Protocol!
    ) {
        self.featureFlagService = featureFlagService
        self.appStateService = appStateService

        // Initialize presentations
        self.premiumPresentation = PremiumStatusPresentation(
            status: appStateService.premiumStatus
        )
        self.statistics = AppStatistics(from: appStateService.state)

        setupBindings()
        updateFeatureFlags()
    }

    // MARK: - Public Methods

    func handle(_ action: DebugAction) {
        switch action {
        case .grantPremium:
            appStateService.grantPremium()
            showSuccessAlert("Premium granted")

        case .grantTemporaryPremium:
            appStateService.grantTemporaryPremium()
            showSuccessAlert("Temporary premium granted")

        case .revokePremium:
            confirmationAction = action
            showConfirmation = true

        case .toggleFlag(let flag, let enabled):
            featureFlagService.setEnabled(flag, enabled: enabled)

        case .resetFlag(let flag):
            featureFlagService.reset(flag)
            showSuccessAlert("Flag '\(flag.displayName)' reset to default")

        case .resetAllFlags:
            confirmationAction = action
            showConfirmation = true

        case .syncFlags:
            Task { await syncFeatureFlags() }

        case .clearAllData:
            confirmationAction = action
            showConfirmation = true
        }
    }

    func confirmAction() {
        guard let action = confirmationAction else { return }
        confirmationAction = nil

        switch action {
        case .revokePremium:
            appStateService.revokePremium()
            showSuccessAlert("Premium revoked")

        case .resetAllFlags:
            featureFlagService.resetAll()
            showSuccessAlert("All flags reset to defaults")

        case .clearAllData:
            featureFlagService.resetAll()
            appStateService.revokePremium()
            showSuccessAlert("All data cleared")

        default:
            break
        }
    }

    func binding(for flag: FeatureFlag) -> Binding<Bool> {
        Binding(
            get: { [weak self] in
                self?.featureFlagService.isEnabled(flag) ?? flag.defaultValue
            },
            set: { [weak self] newValue in
                self?.handle(.toggleFlag(flag, newValue))
            }
        )
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Observe app state changes via publisher
        appStateService.statePublisher
            .sink { [weak self] state in
                self?.premiumPresentation = PremiumStatusPresentation(status: state.premiumStatus)
                self?.statistics = AppStatistics(from: state)
            }
            .store(in: &cancellables)

        // Observe feature flags changes via publisher
        featureFlagService.flagsPublisher
            .sink { [weak self] _ in
                self?.updateFeatureFlags()
            }
            .store(in: &cancellables)
    }

    private func updateFeatureFlags() {
        featureFlags = FeatureFlag.allCases.map { flag in
            FeatureFlagPresentation(
                id: flag,
                flag: flag,
                isEnabled: featureFlagService.isEnabled(flag),
                hasLocalOverride: featureFlagService.hasLocalOverride(for: flag)
            )
        }
    }

    private func syncFeatureFlags() async {
        syncState = .loading

        do {
            try await featureFlagService.syncFromRemote()
            syncState = .success
            lastSyncDate = Date()

            // Reset to idle after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            syncState = .idle

        } catch {
            syncState = .failure(error.localizedDescription)
            showErrorAlert("Sync failed: \(error.localizedDescription)")

            // Reset to idle after delay
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            syncState = .idle
        }
    }

    private func showSuccessAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }

    private func showErrorAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Confirmation Dialog Helper

extension DebugAction {
    var confirmationTitle: String {
        switch self {
        case .revokePremium:
            return "Revoke Premium?"
        case .resetAllFlags:
            return "Reset All Flags?"
        case .clearAllData:
            return "Clear All Data?"
        default:
            return "Confirm Action?"
        }
    }

    var confirmationMessage: String {
        switch self {
        case .revokePremium:
            return "This will remove premium status."
        case .resetAllFlags:
            return "All feature flags will be reset to their default values."
        case .clearAllData:
            return "This will reset all flags and remove premium status."
        default:
            return "Are you sure?"
        }
    }
}

// MARK: - Debug Menu View

struct DebugMenuScreen: View {

    @StateObject private var viewModel: DebugMenuViewModel
    @Environment(\.dismiss) var dismiss

    init(
        featureFlagService: FeatureFlagService,  // ✅ Protocol!
        appStateService: AppStateService         // ✅ Protocol!
    ) {
        _viewModel = StateObject(
            wrappedValue: DebugMenuViewModel(
                featureFlagService: featureFlagService,
                appStateService: appStateService
            )
        )
    }

    var body: some View {
        NavigationView {
            List {
                premiumSection
                featureFlagsSection
                actionsSection
                statisticsSection
                aboutSection
            }
            .navigationTitle("🐛 Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Action Result", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let message = viewModel.alertMessage {
                    Text(message)
                }
            }
            .confirmationDialog(
                viewModel.confirmationAction?.confirmationTitle ?? "",
                isPresented: $viewModel.showConfirmation,
                titleVisibility: .visible
            ) {
                Button("Confirm", role: .destructive) {
                    viewModel.confirmAction()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(viewModel.confirmationAction?.confirmationMessage ?? "")
            }
        }
    }

    // MARK: - Premium Section

    private var premiumSection: some View {
        Section {
            HStack {
                Label("Status", systemImage: "crown.fill")
                Spacer()
                Text(viewModel.premiumPresentation.statusText)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }

            if let expiration = viewModel.premiumPresentation.expirationDate {
                HStack {
                    Label("Expires", systemImage: "clock.fill")
                    Spacer()
                    Text(expiration, style: .relative)
                        .foregroundColor(.orange)
                }
            }

            Button {
                viewModel.handle(.grantPremium)
            } label: {
                Label("Grant Premium", systemImage: "star.fill")
            }

            Button {
                viewModel.handle(.grantTemporaryPremium)
            } label: {
                Label("Grant Trial (1h)", systemImage: "timer")
            }

            if viewModel.premiumPresentation.canRevoke {
                Button(role: .destructive) {
                    viewModel.handle(.revokePremium)
                } label: {
                    Label("Revoke Premium", systemImage: "xmark.circle.fill")
                }
            }
        } header: {
            Label("Premium Management", systemImage: "crown")
        }
    }

    // MARK: - Feature Flags Section

    private var featureFlagsSection: some View {
        Section {
            ForEach(viewModel.featureFlags) { presentation in
                VStack(alignment: .leading, spacing: 6) {
                    Toggle(isOn: viewModel.binding(for: presentation.flag)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(presentation.displayName)
                                    .font(.body)

                                if presentation.hasLocalOverride {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }

                            Text(presentation.description)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                    if presentation.hasLocalOverride {
                        Button {
                            viewModel.handle(.resetFlag(presentation.flag))
                        } label: {
                            Label("Reset to Default", systemImage: "arrow.counterclockwise")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            Button(role: .destructive) {
                viewModel.handle(.resetAllFlags)
            } label: {
                Label("Reset All Flags", systemImage: "arrow.counterclockwise.circle.fill")
            }
        } header: {
            Label("Feature Flags", systemImage: "flag.fill")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Local overrides take priority over remote configuration")
                if let lastSync = viewModel.lastSyncDate {
                    Text("Last synced: \(lastSync, style: .relative)")
                        .foregroundColor(.secondary)
                }
            }
            .font(.caption2)
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        Section {
            Button {
                viewModel.handle(.syncFlags)
            } label: {
                HStack {
                    Label("Sync from Server", systemImage: "arrow.triangle.2.circlepath")

                    Spacer()

                    if viewModel.syncState.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if case .success = viewModel.syncState {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if case .failure = viewModel.syncState {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .disabled(viewModel.syncState.isLoading)

            Button(role: .destructive) {
                viewModel.handle(.clearAllData)
            } label: {
                Label("Clear All Data", systemImage: "trash.fill")
            }
        } header: {
            Label("Actions", systemImage: "gearshape.fill")
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        Section {
            HStack {
                Label("Ads Watched", systemImage: "play.rectangle.fill")
                Spacer()
                Text("\(viewModel.statistics.totalAdsWatched)")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            if let lastAdDate = viewModel.statistics.lastAdWatchedDate {
                HStack {
                    Label("Last Ad", systemImage: "clock.fill")
                    Spacer()
                    Text(lastAdDate, style: .relative)
                        .foregroundColor(.secondary)
                }
            }

            if let purchaseDate = viewModel.statistics.premiumPurchaseDate {
                HStack {
                    Label("Premium Since", systemImage: "calendar")
                    Spacer()
                    Text(purchaseDate, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Label("Statistics", systemImage: "chart.bar.fill")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Environment")
                Spacer()
                #if DEBUG
                Text("Debug")
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                #else
                Text("Release")
                    .foregroundColor(.green)
                    .fontWeight(.medium)
                #endif
            }

            HStack {
                Text("Build")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        } header: {
            Label("About", systemImage: "info.circle.fill")
        } footer: {
            Text("This menu is only available in debug builds")
                .font(.caption2)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DebugMenuScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Free user
            DebugMenuScreen(
                featureFlagService: MockFeatureFlagService(),
                appStateService: MockAppStateService()
            )
            .previewDisplayName("Free User")

            // Premium user
            DebugMenuScreen(
                featureFlagService: MockFeatureFlagService(),
                appStateService: MockAppStateService(
                    initialState: AppState(
                        premiumStatus: .premium,
                        premiumPurchaseDate: Date(),
                        lastAdWatchedDate: nil,
                        totalAdsWatched: 0
                    )
                )
            )
            .previewDisplayName("Premium User")

            // Trial user with stats
            DebugMenuScreen(
                featureFlagService: MockFeatureFlagService(defaultFlags: [
                    .showAds: true,
                    .showDebugMenu: true
                ]),
                appStateService: MockAppStateService(
                    initialState: AppState(
                        premiumStatus: .temporaryPremium(
                            expiresAt: Date().addingTimeInterval(AppStateConfiguration.temporaryPremiumDuration)
                        ),
                        premiumPurchaseDate: nil,
                        lastAdWatchedDate: Date().addingTimeInterval(-300),
                        totalAdsWatched: 15
                    )
                )
            )
            .previewDisplayName("Trial User with Stats")
        }
    }
}
#endif
