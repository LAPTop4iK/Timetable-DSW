//
//  ThemeSettingsContainer.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

struct ThemeSettingsContainer: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appStateService: DefaultAppStateService
    @Environment(\.adCoordinator) private var coordinator
    
    var body: some View {
        NavigationStack {
            if (coordinator?.isAdDisabled() ?? true) {
                ThemeSettingsView()
                    .padding(.horizontal, AppSpacing.large.value)
                    .padding(.bottom, AppSpacing.large.value)
            } else {
                let premiumAccess = PremiumAccess.from(appState: appStateService.state)
                // User doesn't have premium - show paywall with back button
                PremiumStatusScreen(
                    premiumAccess: premiumAccess,
                    onWatchAd: {
                        Task {
                            do {
                                try await coordinator?.loadAd(type: .rewarded)
                                try await coordinator?.showAd(type: .rewarded)
                                appStateService.grantTemporaryPremium()
                            } catch {
                                print("[Premium] Failed to show rewarded ad: \(error)")
                            }
                        }
                    },
                    onPurchase: {
#if DEBUG
                        appStateService.grantPremium()
#endif
                    }
                )
            }
        }
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                GradientTitleBar(
                    title: LocalizedString.settingsThemeSectionTitle.localized,
                    onDone: { dismiss() }
                )
            }

            #if DEBUG
            .measurePerformance(name: "ThemeSettingsContainer", category: .viewAppear)
            #endif
        }
        // Без detents — как у SubjectDetailView (занимает всю высоту)
    }
