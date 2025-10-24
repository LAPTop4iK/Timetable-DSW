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
            let premiumAccess = PremiumAccess.from(appState: appStateService.state)
            Group {
                if (coordinator?.isAdDisabled() ?? false) {
                    // Внутри есть свой ScrollView — не дублируем
                    WidgetSettingsView()
                } else {
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
            // Полностью убираем фон системного навбара
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden(true)

            // Наш кастомный заголовок сверху
            .safeAreaInset(edge: .top) {
                GradientTitleBar(
                    title: LocalizedString.settingsWidgetsTitle.localized,
                    onDone: { dismiss() }
                )
            }

            #if DEBUG
            .measurePerformance(name: "WidgetSettingsContainer", category: .viewAppear)
            #endif
        }
        .presentationDragIndicator(.hidden)
    }
}
