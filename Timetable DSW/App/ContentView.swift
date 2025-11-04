//
//  ContentView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI
import Combine
import WidgetKit

struct ContentView: View {
    // MARK: - Configuration
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let springResponse: Double = 0.4
            let springDamping: Double = 0.8
        }
        static let constants = Constants()
    }

    // MARK: - Properties
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var appStateService: DefaultAppStateService
    @Environment(\.showToast) private var showToast
    @Environment(\.adCoordinator) private var adCoordinator

    // ✅ successFeedback passed from parent (DSWScheduleApp)
    let successFeedback: SuccessFeedbackSystem

    @State private var selectedTab = 0

    // MARK: - Dependencies
    private let tabs: [TabBarItem] = [
        TabBarItem(icon: .calendar,    title: .tabsSchedule, tag: 0),
        TabBarItem(icon: .listBullet,  title: .tabsSubjects, tag: 1),
        TabBarItem(icon: .people,      title: .tabsTeachers, tag: 2),
        TabBarItem(icon: .gear,        title: .tabsSettings, tag: 3)
    ]

    // MARK: - Computed Properties

    private var premiumAccess: PremiumAccess {
        PremiumAccess.from(appState: appStateService.state)
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            FloatingTabBar(tabs: tabs, selectedTab: $selectedTab)
        }
        .task {
            await appViewModel.loadGroupsIfNeeded()
        }
    }

    // MARK: - Subviews
    private var contentView: some View {
        Group {
            switch selectedTab {
            case 0:
                ScheduleView()
                    .transition(tabTransition)
            case 1:
                SubjectsView()
                    .premiumContent(
                        feature: .subjectsTab,
                        premiumAccess: premiumAccess,
                        coordinator: adCoordinator,
                        onWatchAd: handleWatchAd,
                        onPurchase: handlePurchase
                    )
                    .transition(tabTransition)
            case 2:
                TeachersView(viewModel: TeachersViewModel())
                    .premiumContent(
                        feature: .teachersTab,
                        premiumAccess: premiumAccess,
                        coordinator: adCoordinator,
                        onWatchAd: handleWatchAd,
                        onPurchase: handlePurchase
                    )
                    .transition(tabTransition)
            case 3:
                SettingsView()
                    .transition(tabTransition)
            default:
                EmptyView()
            }
        }
        .animation(
            .spring(response: Configuration.constants.springResponse,
                    dampingFraction: Configuration.constants.springDamping),
            value: selectedTab
        )
    }

    // MARK: - Actions

    private func handleWatchAd() {
        Task {
            do {
                try await adCoordinator?.loadAd(type: .rewarded)
                try await adCoordinator?.showAd(type: .rewarded)

                // Grant temporary premium (duration from AppStateConfiguration)
                appStateService.grantTemporaryPremium()

                // Sync widget access
                WidgetAccessSync.sync(
                    appStateService: appStateService,
                    adCoordinator: adCoordinator
                )

                // Show success feedback
                await MainActor.run {
                    successFeedback.celebrate(
                        message: LocalizedString.premiumUnlocked.localized,
                        icon: "crown.fill",
                        showToast: showToast
                    )
                }
            } catch {
                print("[Premium] Failed to show rewarded ad: \(error)")
            }
        }
    }

    private func handlePurchase() {
        // TODO: Implement purchase flow
        // For now, grant permanent premium for testing
        #if DEBUG
        appStateService.grantPremium()

        // Sync widget access
        WidgetAccessSync.sync(
            appStateService: appStateService,
            adCoordinator: adCoordinator
        )

        successFeedback.celebrate(
            message: LocalizedString.premiumUnlocked.localized,
            icon: "crown.fill",
            showToast: showToast
        )
        #endif
    }

    // MARK: - Computed Properties
    private var tabTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
