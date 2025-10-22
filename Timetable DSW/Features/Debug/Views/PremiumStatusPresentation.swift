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
            self.statusText = LocalizedString.debugFree.localized
            self.expirationDate = nil
            self.canRevoke = false

        case .premium:
            self.statusText = LocalizedString.debugPremiumLabel.localized
            self.expirationDate = nil
            self.canRevoke = true

        case .temporaryPremium(let expiresAt):
            self.statusText = LocalizedString.debugTrial.localized
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
            showSuccessAlert(LocalizedString.debugPremiumGranted.localized)

        case .grantTemporaryPremium:
            appStateService.grantTemporaryPremium()
            showSuccessAlert(LocalizedString.debugTemporaryPremiumGranted.localized)

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
            showSuccessAlert(LocalizedString.debugPremiumRevoked.localized)

        case .resetAllFlags:
            featureFlagService.resetAll()
            showSuccessAlert(LocalizedString.debugAllFlagsReset.localized)

        case .clearAllData:
            featureFlagService.resetAll()
            appStateService.revokePremium()
            showSuccessAlert(LocalizedString.debugAllDataCleared.localized)

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
            return LocalizedString.debugRevokePremiumQuestion.localized
        case .resetAllFlags:
            return LocalizedString.debugResetAllFlagsQuestion.localized
        case .clearAllData:
            return LocalizedString.debugClearAllDataQuestion.localized
        default:
            return LocalizedString.debugConfirmActionQuestion.localized
        }
    }

    var confirmationMessage: String {
        switch self {
        case .revokePremium:
            return LocalizedString.debugWillRemovePremium.localized
        case .resetAllFlags:
            return LocalizedString.debugWillResetAllFlags.localized
        case .clearAllData:
            return LocalizedString.debugWillResetEverything.localized
        default:
            return LocalizedString.debugAreYouSure.localized
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
            .navigationTitle(LocalizedString.debugMenuTitle.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedString.debugDone.localized) { dismiss() }
                }
            }
            .alert(LocalizedString.debugActionResult.localized, isPresented: $viewModel.showAlert) {
                Button(LocalizedString.debugOK.localized, role: .cancel) { }
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
                Button(LocalizedString.debugConfirm.localized, role: .destructive) {
                    viewModel.confirmAction()
                }
                Button(LocalizedString.debugCancel.localized, role: .cancel) { }
            } message: {
                Text(viewModel.confirmationAction?.confirmationMessage ?? "")
            }
        }
    }

    // MARK: - Premium Section

    private var premiumSection: some View {
        Section {
            HStack {
                Label(LocalizedString.debugStatus.localized, systemImage: "crown.fill")
                Spacer()
                Text(viewModel.premiumPresentation.statusText)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }

            if let expiration = viewModel.premiumPresentation.expirationDate {
                HStack {
                    Label(LocalizedString.debugExpires.localized, systemImage: "clock.fill")
                    Spacer()
                    Text(expiration, style: .relative)
                        .foregroundColor(.orange)
                }
            }

            Button {
                viewModel.handle(.grantPremium)
            } label: {
                Label(LocalizedString.debugGrantPremium.localized, systemImage: "star.fill")
            }

            Button {
                viewModel.handle(.grantTemporaryPremium)
            } label: {
                Label(LocalizedString.debugGrantTrial1h.localized, systemImage: "timer")
            }

            if viewModel.premiumPresentation.canRevoke {
                Button(role: .destructive) {
                    viewModel.handle(.revokePremium)
                } label: {
                    Label(LocalizedString.debugRevokePremiumLabel.localized, systemImage: "xmark.circle.fill")
                }
            }
        } header: {
            Label(LocalizedString.debugPremiumManagement.localized, systemImage: "crown")
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
                            Label(LocalizedString.debugResetToDefaultLabel.localized, systemImage: "arrow.counterclockwise")
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
                Label(LocalizedString.debugResetAllFlagsLabel.localized, systemImage: "arrow.counterclockwise.circle.fill")
            }
        } header: {
            Label(LocalizedString.debugFeatureFlagsTitle.localized, systemImage: "flag.fill")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedString.debugLocalOverrides.localized)
                if let lastSync = viewModel.lastSyncDate {
                    Text("\(LocalizedString.debugLastSynced.localized): \(lastSync, style: .relative)")
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
                    Label(LocalizedString.debugSyncFromServer.localized, systemImage: "arrow.triangle.2.circlepath")

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
                Label(LocalizedString.debugClearAllData.localized, systemImage: "trash.fill")
            }
        } header: {
            Label(LocalizedString.debugActionsTitle.localized, systemImage: "gearshape.fill")
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        Section {
            HStack {
                Label(LocalizedString.debugAdsWatched.localized, systemImage: "play.rectangle.fill")
                Spacer()
                Text("\(viewModel.statistics.totalAdsWatched)")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            if let lastAdDate = viewModel.statistics.lastAdWatchedDate {
                HStack {
                    Label(LocalizedString.debugLastAd.localized, systemImage: "clock.fill")
                    Spacer()
                    Text(lastAdDate, style: .relative)
                        .foregroundColor(.secondary)
                }
            }

            if let purchaseDate = viewModel.statistics.premiumPurchaseDate {
                HStack {
                    Label(LocalizedString.debugPremiumSince.localized, systemImage: "calendar")
                    Spacer()
                    Text(purchaseDate, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Label(LocalizedString.debugStatistics.localized, systemImage: "chart.bar.fill")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            HStack {
                Text(LocalizedString.debugEnvironment.localized)
                Spacer()
                #if DEBUG
                Text(LocalizedString.debugDebug.localized)
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                #else
                Text(LocalizedString.debugRelease.localized)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
                #endif
            }

            HStack {
                Text(LocalizedString.debugBuild.localized)
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        } header: {
            Label(LocalizedString.debugAbout.localized, systemImage: "info.circle.fill")
        } footer: {
            Text(LocalizedString.debugOnlyInDebugBuilds.localized)
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
