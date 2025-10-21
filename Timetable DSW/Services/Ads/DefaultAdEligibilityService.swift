//
//  DefaultAdEligibilityService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


final class DefaultAdEligibilityService: AdEligibilityService {
    private let featureFlagService: FeatureFlagService
    private let appStateService: AppStateService
    
    var canShowAds: Bool {
        !appStateService.isPremium && featureFlagService.isEnabled(.showAds)
    }
    
    init(
        featureFlagService: FeatureFlagService,
        appStateService: AppStateService
    ) {
        self.featureFlagService = featureFlagService
        self.appStateService = appStateService
    }
    
    func checkEligibility() throws {
        if appStateService.isPremium {
            throw AdError.premiumUser
        }
        if !featureFlagService.isEnabled(.showAds) {
            throw AdError.adsDisabled
        }
    }
}
