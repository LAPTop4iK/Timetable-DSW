//
//  ThemeSettingsContainer.swift
//  Timetable DSW
//
//  Created by Claude on 23/10/2025.
//

import SwiftUI

struct ThemeSettingsContainer: View {
    @EnvironmentObject var appStateService: DefaultAppStateService
    @Environment(\.adCoordinator) private var coordinator

    var body: some View {
        let premiumAccess = PremiumAccess.from(appState: appStateService.state)

        if premiumAccess.hasAccess(to: .themeSettings) {
            // User has premium - show theme settings
            ThemeSettingsView()
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
            .navigationTitle(LocalizedString.themeSettingsTitle.localized)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
