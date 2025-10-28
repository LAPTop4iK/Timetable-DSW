//
//  WidgetAccessSync.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 27/10/2025.
//


import WidgetKit

enum WidgetAccessSync {
    static func sync(
        appStateService: AppStateService,
        adCoordinator: AdCoordinator?
    ) {
        // premiumAccess.isPremium уже учитывает и постоянный .premium,
        // и временный .temporaryPremium(expiresAt:) из AppState.premiumStatus.
        let premiumAccess = PremiumAccess.from(appState: appStateService.state)

        let allowed = (adCoordinator?.isAdDisabled() ?? true) || premiumAccess.isPremium

        let oldValue = AppGroupManager.loadWidgetAccessAllowed()

        guard allowed != oldValue else { return }

        AppGroupManager.saveWidgetAccessAllowed(allowed)

        WidgetCenter.shared.reloadAllTimelines()
    }
}
