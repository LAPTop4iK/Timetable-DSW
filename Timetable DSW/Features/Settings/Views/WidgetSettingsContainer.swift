//
//  WidgetSettingsContainer.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

struct WidgetSettingsContainer: View {
    @EnvironmentObject var appStateService: DefaultAppStateService
    @Environment(\.adCoordinator) private var coordinator

    var body: some View {
        let premiumAccess = PremiumAccess.from(appState: appStateService.state)

        if premiumAccess.hasAccess(to: .widgetSettings) {
            // User has premium - show widget settings
            WidgetSettingsView()
        } else {
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
            .navigationTitle("Widget Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
