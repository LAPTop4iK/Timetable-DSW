//
//  WidgetSettingsContainer.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

struct WidgetSettingsContainer: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appStateService: DefaultAppStateService
    @Environment(\.adCoordinator) private var coordinator

    var body: some View {
        NavigationStack {
            ScrollView {
                if (coordinator?.isAdDisabled() ?? true) {
                    // User has premium - show widget settings
                    WidgetSettingsView()
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
            .scrollIndicators(.never)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top) {
                GradientTitleBar(
                    title: LocalizedString.settingsWidgetsTitle.localized, // локализуй
                    onDone: { dismiss() }
                )
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 12)
            }
            #if DEBUG
            .measurePerformance(name: "WidgetSettingsContainer", category: .viewAppear)
            #endif
        }
        .presentationDragIndicator(.hidden)
    }
}
