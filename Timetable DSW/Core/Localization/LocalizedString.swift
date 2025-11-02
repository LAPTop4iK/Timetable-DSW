import Foundation

enum LocalizedString {
    // MARK: - General
    case generalCancel
    case generalDone
    case generalToday
    case generalRetry
    case generalRefresh
    case generalOnline
    case generalOffline
    case generalCancelled
    case generalLoading

    // MARK: - Greeting
    case greetingMorning
    case greetingAfternoon
    case greetingEvening
    case greetingNight

    // MARK: - Schedule
    case scheduleTitle
    case scheduleSelectDate
    case scheduleHasClasses
    case scheduleOnlineOnly
    case scheduleNoClasses
    case scheduleEnjoyFreeTime
    case scheduleLoading
    case scheduleLastUpdated

    // MARK: - Groups
    case groupsSelect
    case groupsSelected
    case groupsNoSelection
    case groupsSearch
    case groupsLoading
    case groupsNoAvailable
    case groupsNoFound
    case groupsPullToRefresh
    case groupsAdjustSearch

    // MARK: - Teachers
    case teachersTitle
    case teachersSearch
    case teachersLoading
    case teachersNoFound
    case teachersClasses
    case teachersNoData
    case teachersLoadScheduleFirst
    case teachersFilterCurrent
    case teachersFilterAll

    // MARK: - Subjects (NEW)
    case subjectsTitle
    case subjectsSearch
    case subjectsLoading
    case subjectsNoFound
    case subjectsClasses
    case subjectsNoData
    case subjectsLoadScheduleFirst
    case subjectsStats
    case subjectsTotal
    case subjectsPast
    case subjectsUpcoming
    case subjectsLectures
    case subjectsExercises
    case subjectsLaboratories
    case subjectsGradingType
    case subjectsShowPast
    case subjectsHidePast
    case subjectsHiddenCount

    // MARK: - Settings
    case settingsTitle
    case settingsGroupSettings
    case settingsThemeSectionTitle
    case settingsThemeSectionHeader
    case settingsThemeSectionFooter
    case settingsCacheStatus
    case settingsClearCache
    case settingsClearCacheMessage
    case settingsVersion
    case settingsAbout
    case settingsEvents
    case settingsLastUpdated
    case settingsNever
    case settingsPleaseSelectGroup

    // MARK: - Tabs
    case tabsSchedule
    case tabsTeachers
    case tabsSettings
    case tabsSubjects

    // MARK: - Error
    case errorTitle
    case errorInvalidURL
    case errorInvalidResponse
    case errorServer

    // MARK: - Days
    case daysMonday
    case daysTuesday
    case daysWednesday
    case daysThursday
    case daysFriday
    case daysSaturday
    case daysSunday

    // MARK: - Support / Contact (NEW)
    case settingsContactTitle
    case settingsSupportSectionTitle
    case settingsSupportFooter

    // MARK: - Developer Support (NEW)
    case settingsDeveloperSectionTitle
    case settingsDeveloperAction
    case settingsDeveloperFooter

    // MARK: - Contact actions (NEW)
    case contactActionReportProblem
    case contactActionRequestFeature

    // MARK: - Mail / system (NEW)
    case mailUnavailableTitle
    /// uses %@ placeholder for email
    case mailUnavailableMessage
    case mailCopyAddress

    // MARK: - Email subjects (NEW)
    case contactEmailSubjectBug
    case contactEmailSubjectFeature

    // MARK: - Email body headers (NEW)
    case contactEmailBodyBugHeader
    case contactEmailBodyFeatureHeader

    // MARK: - Email info labels (NEW)
    case contactEmailInfoApp
    case contactEmailInfoiOS
    case contactEmailInfoDevice
    case contactEmailInfoLocale
    case contactEmailInfoGroup
    case contactEmailInfoDate

    case contactEmailBodyAdditionalInfo
    case contactEmailBodyDetailsTitle

    // MARK: - Premium
    case premiumFeatureTitle
    case premiumTapToUnlock
    case premiumActive
    case premiumThankYou
    case premiumEnjoyFeatures
    case premiumTimeRemaining
    case premiumWatchOrPurchase
    case premiumUnlockTitle
    case premiumGetAccess
    case premiumWatchAdButton
    case premiumPurchaseButton
    case premiumUnlocked
    case premiumMaybeLater
    case premiumCalculating
    case premiumRemaining
    case premiumOnlyTitle
    case premiumWidgetDescription

    // MARK: - Settings Premium
    case settingsPremiumActive

    // MARK: - In-App Purchases
    case iapTipTitle
    case iapTipDescription
    case iapPremiumTitle
    case iapPremiumDescription
    case iapRestorePurchases
    case iapPurchaseSuccess
    case iapPurchaseFailed
    case iapRestoreSuccess
    case iapRestoreFailed
    case iapPurchasing
    case iapRestoring

    // MARK: - Debug
    case debugTools
    case debugDone
    case debugResetAllFlags
    case debugResetConfirm
    case debugCancel
    case debugPremiumStatus
    case debugPremiumControls
    case debugGrantPermanentPremium
    case debugGrant1HourPremium
    case debugRevokePremium
    case debugFeatureFlags
    case debugFlagsFooter
    case debugActions
    case debugResetToDefault
    case debugSyncFromRemote
    case debugShowDetails
    case debugHideDetails

    // MARK: - Debug Menu (Extended)
    case debugMenuTitle
    case debugActionResult
    case debugOK
    case debugConfirm
    case debugFree
    case debugPremiumLabel
    case debugTrial
    case debugStatus
    case debugExpires
    case debugGrantPremium
    case debugGrantTrial1h
    case debugRevokePremiumLabel
    case debugPremiumManagement
    case debugFeatureFlagsTitle
    case debugLocalOverrides
    case debugLastSynced
    case debugActionsTitle
    case debugSyncFromServer
    case debugClearAllData
    case debugStatistics
    case debugAdsWatched
    case debugLastAd
    case debugPremiumSince
    case debugAbout
    case debugEnvironment
    case debugDebug
    case debugRelease
    case debugBuild
    case debugOnlyInDebugBuilds
    case debugResetToDefaultLabel
    case debugResetAllFlagsLabel
    case debugRevokePremiumQuestion
    case debugResetAllFlagsQuestion
    case debugClearAllDataQuestion
    case debugConfirmActionQuestion
    case debugWillRemovePremium
    case debugWillResetAllFlags
    case debugWillResetEverything
    case debugAreYouSure
    case debugPremiumGranted
    case debugTemporaryPremiumGranted
    case debugPremiumRevoked
    case debugAllFlagsReset
    case debugAllDataCleared
    case debugFlagResetTemplate
    case debugSyncFailedTemplate

    // MARK: - Performance Monitor
    case perfMonitorTitle
    case perfMonitorClear
    case perfMonitorExport
    case perfMonitorExportedEvents
    case perfMonitorMetrics
    case perfMonitorTotalEvents
    case perfMonitorAverageDuration
    case perfMonitorSlowestEvent
    case perfMonitorFastestEvent
    case perfMonitorFilterByCategory
    case perfMonitorCategory
    case perfMonitorAll
    case perfMonitorEvents
    case perfMonitorNoEventsRecorded

    // MARK: - Ads Debug
    case adsDebugTitle
    case adsDebugAdaptiveBanner
    case adsDebugBannerAd
    case adsDebugBannerDescription
    case adsDebugNativeAd
    case adsDebugNativeDescription
    case adsDebugLoad
    case adsDebugShow
    case adsDebugReadyToShow
    case adsDebugInterstitialAd
    case adsDebugInterstitialDescription
    case adsDebugRewardedAd
    case adsDebugRewardedDescription
    case adsDebugRewardedInterstitial
    case adsDebugRewardedInterstitialDescription
    case adsDebugPreload
    case adsDebugAppOpenAd
    case adsDebugAppOpenDescription
    case adsDebugDeveloperTools
    case adsDebugLaunchAdInspector
    case adsDebugAdInspectorDescription
    case adsDebugEventLog
    case adsDebugNoEventsYet
    case adsDebugClearLog

    // MARK: - Ad Loading
    case adLoadingText
    case adLoadingFailed
    case adLoadingRetry

    // MARK: - Theme Settings (NEW)
    case themeSettingsTitle
    case themeSettingsAppearanceTitle
    case themeSettingsColorThemeTitle

    case appearanceSystem
    case appearanceLight
    case appearanceDark
    case appearanceDescSystem
    case appearanceDescLight
    case appearanceDescDark

    case themeNameDefault
    case themeNameOcean
    case themeNameSunset
    case themeNameForest
    case themeNameLavender
    case themeNameCherry
    case themeNameMidnight
    case themeNameMonochrome

    // MARK: - Widgets (titles/sections)
    case widgetAvailable
    case widgetConfigure
    case widgetHowToAdd
    case widgetNeverUpdated
    case widgetTroubleshooting
    case widgetTitle
    case widgetEnabled
    case widgetAccess

    // MARK: - Widgets (detailed keys)
    case widgetStatusTitle
    case widgetEnabledTitle
    case widgetAccessDescription
    case widgetInstructionStep1
    case widgetInstructionStep2
    case widgetInstructionStep3
    case widgetInstructionStep4
    case widgetTypeSmallTitle
    case widgetTypeSmallDescription
    case widgetTypeMediumTitle
    case widgetTypeMediumDescription
    case widgetTypeLargeTitle
    case widgetTypeLargeDescription
    case widgetTypeLiveTitle
    case widgetTypeLiveDescription
    case relativeAgo
    case widgetTroubleNoDataTitle
    case widgetTroubleNoDataSolution
    case widgetTroubleNotUpdatingTitle
    case widgetTroubleNotUpdatingSolution
    case widgetTroubleWrongThemeTitle
    case widgetTroubleWrongThemeSolution
    case widgetSettingsSubtitle
    case settingsRefresh
    case widgetFooterReloadHint
    case widgetHomeTitle
    case widgetHomeSubtitle

    case featureTeachersTab
    case featureTeachersTabDescription
    case featureSubjectsTab
    case featureSubjectsTabDescription
    case featureThemeSettings
    case featureThemeSettingsDescription
    case featureWidgetSettings

    // Widget names/descriptions
        case widgetNameTimetable
        case widgetDescriptionTimetable

        // Control Center: open schedule
        case controlOpenScheduleDisplayName
        case controlOpenScheduleDescription
        case controlOpenScheduleLabel

        // Control Center: toggle
        case controlToggleDisplayName
        case controlToggleDescription
        case controlToggleLabel

        // Status
        case statusActive
        case statusNoClasses

        // AppIntents
        case intentOpenTimetableTitle
        case intentOpenTimetableDescription
        case intentTodayScheduleTitle
        case intentTodayScheduleDescription
        case intentNextClassTitle
        case intentNextClassDescription
        case intentRefreshScheduleTitle
        case intentRefreshScheduleParameterEnabled
        case intentConfigurationTitle

        // Live Activity
        case liveEnds
        case livePercentCompleteSuffix

        // Common UI
        case commonNow
        case commonNext
        case commonUntil
        case commonNoClasses
        case commonNoClassesToday
        case commonEnjoyFreeDay
        case commonToday
        case commonThisWeek
        case commonWeek
        case commonClasses
        case commonMoreSuffix

        // Widget config (widget configuration intent)
        case configTitle
        case configDescription
        case configViewTypeTitle
        case configViewTypeToday
        case configViewTypeWeek
        case configShowOnlineStatusTitle
}

extension LocalizedString {
    var key: String {
        switch self {
        // General
        case .generalCancel: return "general.cancel"
        case .generalDone: return "general.done"
        case .generalToday: return "general.today"
        case .generalRetry: return "general.retry"
        case .generalRefresh: return "general.refresh"
        case .generalOnline: return "general.online"
        case .generalOffline: return "general.offline"
        case .generalCancelled: return "general.cancelled"
        case .generalLoading: return "general.loading"

        // Greeting
        case .greetingMorning: return "greeting.morning"
        case .greetingAfternoon: return "greeting.afternoon"
        case .greetingEvening: return "greeting.evening"
        case .greetingNight: return "greeting.night"

        // Schedule
        case .scheduleTitle: return "schedule.title"
        case .scheduleSelectDate: return "schedule.selectDate"
        case .scheduleHasClasses: return "schedule.hasClasses"
        case .scheduleOnlineOnly: return "schedule.onlineOnly"
        case .scheduleNoClasses: return "schedule.noClasses"
        case .scheduleEnjoyFreeTime: return "schedule.enjoyFreeTime"
        case .scheduleLoading: return "schedule.loading"
        case .scheduleLastUpdated: return "schedule.lastUpdated"

        // Groups
        case .groupsSelect: return "groups.select"
        case .groupsSelected: return "groups.selected"
        case .groupsNoSelection: return "groups.noSelection"
        case .groupsSearch: return "groups.search"
        case .groupsLoading: return "groups.loading"
        case .groupsNoAvailable: return "groups.noAvailable"
        case .groupsNoFound: return "groups.noFound"
        case .groupsPullToRefresh: return "groups.pullToRefresh"
        case .groupsAdjustSearch: return "groups.adjustSearch"

        // Teachers
        case .teachersTitle: return "teachers.title"
        case .teachersSearch: return "teachers.search"
        case .teachersLoading: return "teachers.loading"
        case .teachersNoFound: return "teachers.noFound"
        case .teachersClasses: return "teachers.classes"
        case .teachersNoData: return "teachers.noData"
        case .teachersLoadScheduleFirst: return "teachers.loadScheduleFirst"
        case .teachersFilterCurrent: return "teachers.filter.current"
        case .teachersFilterAll: return "teachers.filter.all"

        // Subjects
        case .subjectsTitle: return "subjects.title"
        case .subjectsSearch: return "subjects.search"
        case .subjectsLoading: return "subjects.loading"
        case .subjectsNoFound: return "subjects.noFound"
        case .subjectsClasses: return "subjects.classes"
        case .subjectsNoData: return "subjects.noData"
        case .subjectsLoadScheduleFirst: return "subjects.loadScheduleFirst"
        case .subjectsStats: return "subjects.stats"
        case .subjectsTotal: return "subjects.total"
        case .subjectsPast: return "subjects.past"
        case .subjectsUpcoming: return "subjects.upcoming"
        case .subjectsLectures: return "subjects.lectures"
        case .subjectsExercises: return "subjects.exercises"
        case .subjectsLaboratories: return "subjects.laboratories"
        case .subjectsGradingType: return "subjects.gradingType"
        case .subjectsShowPast: return "subjects.showPast"
        case .subjectsHidePast: return "subjects.hidePast"
        case .subjectsHiddenCount: return "subjects.hiddenCount"

        // Settings
        case .settingsTitle: return "settings.title"
        case .settingsGroupSettings: return "settings.groupSettings"
        case .settingsThemeSectionTitle: return "settings.themeSection.title"
        case .settingsThemeSectionHeader: return "settings.themeSection.header"
        case .settingsThemeSectionFooter: return "settings.themeSection.footer"
        case .settingsCacheStatus: return "settings.cacheStatus"
        case .settingsClearCache: return "settings.clearCache"
        case .settingsClearCacheMessage: return "settings.clearCacheMessage"
        case .settingsVersion: return "settings.version"
        case .settingsAbout: return "settings.about"
        case .settingsEvents: return "settings.events"
        case .settingsLastUpdated: return "settings.lastUpdated"
        case .settingsNever: return "settings.never"
        case .settingsPleaseSelectGroup: return "settings.pleaseSelectGroup"

        // Tabs
        case .tabsSchedule: return "tabs.schedule"
        case .tabsTeachers: return "tabs.teachers"
        case .tabsSettings: return "tabs.settings"
        case .tabsSubjects: return "tabs.subjects"

        // Error
        case .errorTitle: return "error.title"
        case .errorInvalidURL: return "error.invalidURL"
        case .errorInvalidResponse: return "error.invalidResponse"
        case .errorServer: return "error.server"

        // Days
        case .daysMonday: return "days.monday"
        case .daysTuesday: return "days.tuesday"
        case .daysWednesday: return "days.wednesday"
        case .daysThursday: return "days.thursday"
        case .daysFriday: return "days.friday"
        case .daysSaturday: return "days.saturday"
        case .daysSunday: return "days.sunday"

        // Support / Contact
        case .settingsContactTitle: return "settings.contact.title"
        case .settingsSupportSectionTitle: return "settings.support.sectionTitle"
        case .settingsSupportFooter: return "settings.support.footer"

        // Developer Support
        case .settingsDeveloperSectionTitle: return "settings.developer.sectionTitle"
        case .settingsDeveloperAction: return "settings.developer.action"
        case .settingsDeveloperFooter: return "settings.developer.footer"

        // Contact actions
        case .contactActionReportProblem: return "contact.action.reportProblem"
        case .contactActionRequestFeature: return "contact.action.requestFeature"

        // Mail / system
        case .mailUnavailableTitle: return "mail.unavailable.title"
        case .mailUnavailableMessage: return "mail.unavailable.message"
        case .mailCopyAddress: return "mail.copyAddress"

        // Email subjects
        case .contactEmailSubjectBug: return "contact.email.subject.bug"
        case .contactEmailSubjectFeature: return "contact.email.subject.feature"

        // Email body headers
        case .contactEmailBodyBugHeader: return "contact.email.body.bugHeader"
        case .contactEmailBodyFeatureHeader: return "contact.email.body.featureHeader"

        // Email info labels
        case .contactEmailInfoApp: return "contact.email.info.app"
        case .contactEmailInfoiOS: return "contact.email.info.ios"
        case .contactEmailInfoDevice: return "contact.email.info.device"
        case .contactEmailInfoLocale: return "contact.email.info.locale"
        case .contactEmailInfoGroup: return "contact.email.info.group"
        case .contactEmailInfoDate: return "contact.email.info.date"

        case .contactEmailBodyAdditionalInfo: return "contact.email.body.additionalInfo"
        case .contactEmailBodyDetailsTitle: return "contact.email.body.detailsTitle"

        // Premium
        case .premiumFeatureTitle: return "premium.feature.title"
        case .premiumTapToUnlock: return "premium.tapToUnlock"
        case .premiumActive: return "premium.active"
        case .premiumThankYou: return "premium.thankYou"
        case .premiumEnjoyFeatures: return "premium.enjoyFeatures"
        case .premiumTimeRemaining: return "premium.timeRemaining"
        case .premiumWatchOrPurchase: return "premium.watchOrPurchase"
        case .premiumUnlockTitle: return "premium.unlock.title"
        case .premiumGetAccess: return "premium.getAccess"
        case .premiumWatchAdButton: return "premium.watchAd.button"
        case .premiumPurchaseButton: return "premium.purchase.button"
        case .premiumUnlocked: return "premium.unlocked"
        case .premiumMaybeLater: return "premium.maybeLater"
        case .premiumCalculating: return "premium.calculating"
        case .premiumRemaining: return "premium.remaining"
        case .premiumOnlyTitle: return "premium.only.title"
        case .premiumWidgetDescription: return "premium.widget.description"

        // Settings Premium
        case .settingsPremiumActive: return "settings.premium.active"

        // In-App Purchases
        case .iapTipTitle: return "iap.tip.title"
        case .iapTipDescription: return "iap.tip.description"
        case .iapPremiumTitle: return "iap.premium.title"
        case .iapPremiumDescription: return "iap.premium.description"
        case .iapRestorePurchases: return "iap.restorePurchases"
        case .iapPurchaseSuccess: return "iap.purchaseSuccess"
        case .iapPurchaseFailed: return "iap.purchaseFailed"
        case .iapRestoreSuccess: return "iap.restoreSuccess"
        case .iapRestoreFailed: return "iap.restoreFailed"
        case .iapPurchasing: return "iap.purchasing"
        case .iapRestoring: return "iap.restoring"

        // Debug
        case .debugTools: return "debug.tools"
        case .debugDone: return "debug.done"
        case .debugResetAllFlags: return "debug.resetAllFlags"
        case .debugResetConfirm: return "debug.resetConfirm"
        case .debugCancel: return "debug.cancel"
        case .debugPremiumStatus: return "debug.premiumStatus"
        case .debugPremiumControls: return "debug.premiumControls"
        case .debugGrantPermanentPremium: return "debug.grantPermanentPremium"
        case .debugGrant1HourPremium: return "debug.grant1HourPremium"
        case .debugRevokePremium: return "debug.revokePremium"
        case .debugFeatureFlags: return "debug.featureFlags"
        case .debugFlagsFooter: return "debug.flagsFooter"
        case .debugActions: return "debug.actions"
        case .debugResetToDefault: return "debug.resetToDefault"
        case .debugSyncFromRemote: return "debug.syncFromRemote"
        case .debugShowDetails: return "debug.showDetails"
        case .debugHideDetails: return "debug.hideDetails"

        // Debug Menu (Extended)
        case .debugMenuTitle: return "debug.menu.title"
        case .debugActionResult: return "debug.actionResult"
        case .debugOK: return "debug.ok"
        case .debugConfirm: return "debug.confirm"
        case .debugFree: return "debug.free"
        case .debugPremiumLabel: return "debug.premiumLabel"
        case .debugTrial: return "debug.trial"
        case .debugStatus: return "debug.status"
        case .debugExpires: return "debug.expires"
        case .debugGrantPremium: return "debug.grantPremium"
        case .debugGrantTrial1h: return "debug.grantTrial1h"
        case .debugRevokePremiumLabel: return "debug.revokePremiumLabel"
        case .debugPremiumManagement: return "debug.premiumManagement"
        case .debugFeatureFlagsTitle: return "debug.featureFlagsTitle"
        case .debugLocalOverrides: return "debug.localOverrides"
        case .debugLastSynced: return "debug.lastSynced"
        case .debugActionsTitle: return "debug.actionsTitle"
        case .debugSyncFromServer: return "debug.syncFromServer"
        case .debugClearAllData: return "debug.clearAllData"
        case .debugStatistics: return "debug.statistics"
        case .debugAdsWatched: return "debug.adsWatched"
        case .debugLastAd: return "debug.lastAd"
        case .debugPremiumSince: return "debug.premiumSince"
        case .debugAbout: return "debug.about"
        case .debugEnvironment: return "debug.environment"
        case .debugDebug: return "debug.debug"
        case .debugRelease: return "debug.release"
        case .debugBuild: return "debug.build"
        case .debugOnlyInDebugBuilds: return "debug.onlyInDebugBuilds"
        case .debugResetToDefaultLabel: return "debug.resetToDefaultLabel"
        case .debugResetAllFlagsLabel: return "debug.resetAllFlagsLabel"
        case .debugRevokePremiumQuestion: return "debug.revokePremiumQuestion"
        case .debugResetAllFlagsQuestion: return "debug.resetAllFlagsQuestion"
        case .debugClearAllDataQuestion: return "debug.clearAllDataQuestion"
        case .debugConfirmActionQuestion: return "debug.confirmActionQuestion"
        case .debugWillRemovePremium: return "debug.willRemovePremium"
        case .debugWillResetAllFlags: return "debug.willResetAllFlags"
        case .debugWillResetEverything: return "debug.willResetEverything"
        case .debugAreYouSure: return "debug.areYouSure"
        case .debugPremiumGranted: return "debug.premiumGranted"
        case .debugTemporaryPremiumGranted: return "debug.temporaryPremiumGranted"
        case .debugPremiumRevoked: return "debug.premiumRevoked"
        case .debugAllFlagsReset: return "debug.allFlagsReset"
        case .debugAllDataCleared: return "debug.allDataCleared"
        case .debugFlagResetTemplate: return "debug.flagResetTemplate"
        case .debugSyncFailedTemplate: return "debug.syncFailedTemplate"

        // Performance Monitor
        case .perfMonitorTitle: return "perfMonitor.title"
        case .perfMonitorClear: return "perfMonitor.clear"
        case .perfMonitorExport: return "perfMonitor.export"
        case .perfMonitorExportedEvents: return "perfMonitor.exportedEvents"
        case .perfMonitorMetrics: return "perfMonitor.metrics"
        case .perfMonitorTotalEvents: return "perfMonitor.totalEvents"
        case .perfMonitorAverageDuration: return "perfMonitor.averageDuration"
        case .perfMonitorSlowestEvent: return "perfMonitor.slowestEvent"
        case .perfMonitorFastestEvent: return "perfMonitor.fastestEvent"
        case .perfMonitorFilterByCategory: return "perfMonitor.filterByCategory"
        case .perfMonitorCategory: return "perfMonitor.category"
        case .perfMonitorAll: return "perfMonitor.all"
        case .perfMonitorEvents: return "perfMonitor.events"
        case .perfMonitorNoEventsRecorded: return "perfMonitor.noEventsRecorded"

        // Ads Debug
        case .adsDebugTitle: return "adsDebug.title"
        case .adsDebugAdaptiveBanner: return "adsDebug.adaptiveBanner"
        case .adsDebugBannerAd: return "adsDebug.bannerAd"
        case .adsDebugBannerDescription: return "adsDebug.bannerDescription"
        case .adsDebugNativeAd: return "adsDebug.nativeAd"
        case .adsDebugNativeDescription: return "adsDebug.nativeDescription"
        case .adsDebugLoad: return "adsDebug.load"
        case .adsDebugShow: return "adsDebug.show"
        case .adsDebugReadyToShow: return "adsDebug.readyToShow"
        case .adsDebugInterstitialAd: return "adsDebug.interstitialAd"
        case .adsDebugInterstitialDescription: return "adsDebug.interstitialDescription"
        case .adsDebugRewardedAd: return "adsDebug.rewardedAd"
        case .adsDebugRewardedDescription: return "adsDebug.rewardedDescription"
        case .adsDebugRewardedInterstitial: return "adsDebug.rewardedInterstitial"
        case .adsDebugRewardedInterstitialDescription: return "adsDebug.rewardedInterstitialDescription"
        case .adsDebugPreload: return "adsDebug.preload"
        case .adsDebugAppOpenAd: return "adsDebug.appOpenAd"
        case .adsDebugAppOpenDescription: return "adsDebug.appOpenDescription"
        case .adsDebugDeveloperTools: return "adsDebug.developerTools"
        case .adsDebugLaunchAdInspector: return "adsDebug.launchAdInspector"
        case .adsDebugAdInspectorDescription: return "adsDebug.adInspectorDescription"
        case .adsDebugEventLog: return "adsDebug.eventLog"
        case .adsDebugNoEventsYet: return "adsDebug.noEventsYet"
        case .adsDebugClearLog: return "adsDebug.clearLog"

        // Ad Loading
        case .adLoadingText: return "adLoading.text"
        case .adLoadingFailed: return "adLoading.failed"
        case .adLoadingRetry: return "adLoading.retry"

        // Theme Settings (NEW)
        case .themeSettingsTitle: return "themeSettings.title"
        case .themeSettingsAppearanceTitle: return "themeSettings.appearance.title"
        case .themeSettingsColorThemeTitle: return "themeSettings.colorTheme.title"

        case .appearanceSystem: return "appearance.system"
        case .appearanceLight:  return "appearance.light"
        case .appearanceDark:   return "appearance.dark"
        case .appearanceDescSystem: return "appearance.description.system"
        case .appearanceDescLight:  return "appearance.description.light"
        case .appearanceDescDark:   return "appearance.description.dark"

        case .themeNameDefault:    return "theme.name.default"
        case .themeNameOcean:      return "theme.name.ocean"
        case .themeNameSunset:     return "theme.name.sunset"
        case .themeNameForest:     return "theme.name.forest"
        case .themeNameLavender:   return "theme.name.lavender"
        case .themeNameCherry:     return "theme.name.cherry"
        case .themeNameMidnight:   return "theme.name.midnight"
        case .themeNameMonochrome: return "theme.name.monochrome"

        case .widgetTitle:   return "widget.title"
        case .widgetHomeTitle:   return "widget.home.title"
        case .widgetHomeSubtitle:   return "widget.home.subtitle"
        case .widgetEnabled:         return "widget.enabled"
        case .widgetAccess:          return "widget.access"
        case .widgetStatusTitle:     return "widget.status.title"
        case .widgetEnabledTitle:    return "widget.enabled.title"
        case .widgetAccessDescription: return "widget.access.description"
        case .widgetInstructionStep1: return "widget.instruction.step1"
        case .widgetInstructionStep2: return "widget.instruction.step2"
        case .widgetInstructionStep3: return "widget.instruction.step3"
        case .widgetInstructionStep4: return "widget.instruction.step4"
        case .widgetTypeSmallTitle: return "widget.type.small.title"
        case .widgetTypeSmallDescription: return "widget.type.small.description"
        case .widgetTypeMediumTitle: return "widget.type.medium.title"
        case .widgetTypeMediumDescription: return "widget.type.medium.description"
        case .widgetTypeLargeTitle: return "widget.type.large.title"
        case .widgetTypeLargeDescription: return "widget.type.large.description"
        case .widgetTypeLiveTitle: return "widget.type.live.title"
        case .widgetTypeLiveDescription: return "widget.type.live.description"
        case .relativeAgo: return "relative.ago"
        case .widgetTroubleNoDataTitle: return "widget.troubleshoot.noData.title"
        case .widgetTroubleNoDataSolution: return "widget.troubleshoot.noData.solution"
        case .widgetTroubleNotUpdatingTitle: return "widget.troubleshoot.notUpdating.title"
        case .widgetTroubleNotUpdatingSolution: return "widget.troubleshoot.notUpdating.solution"
        case .widgetTroubleWrongThemeTitle: return "widget.troubleshoot.wrongTheme.title"
        case .widgetTroubleWrongThemeSolution: return "widget.troubleshoot.wrongTheme.solution"
        case .widgetTroubleshooting: return "widget.troubleshooting"
        case .widgetNeverUpdated: return "widget.never.updated"
        case .widgetHowToAdd: return "widget.how.to.add"
        case .widgetConfigure: return "widget.configure"
        case .widgetAvailable: return "widget.available"
        case .widgetSettingsSubtitle: return "widget.settings.subtitle"
        case .settingsRefresh: return "settings.refresh"
        case .widgetFooterReloadHint: return "widget.footer.reloadHint"
        case .featureTeachersTab: return "feature.teachersTab"
        case .featureSubjectsTab: return "feature.subjectsTab"
        case .featureThemeSettings: return "feature.themeSettings"
        case .featureTeachersTabDescription: return "feature.teachersTab.description"
        case .featureSubjectsTabDescription: return "feature.subjectsTab.description"
        case .featureThemeSettingsDescription: return "feature.themeSettings.description"
        case .featureWidgetSettings: return "feature.widgetSettings"
        case .widgetNameTimetable: return "widget.name.timetable"
        case .widgetDescriptionTimetable: return "widget.description.timetable"

        case .controlOpenScheduleDisplayName: return "widget.control.openSchedule.displayName"
        case .controlOpenScheduleDescription: return "widget.control.openSchedule.description"
        case .controlOpenScheduleLabel: return "widget.control.openSchedule.label"

        case .controlToggleDisplayName: return "widget.control.toggle.displayName"
        case .controlToggleDescription: return "widget.control.toggle.description"
        case .controlToggleLabel: return "widget.control.toggle.label"

        case .statusActive: return "widget.status.active"
        case .statusNoClasses: return "widget.status.noClasses"

        case .intentOpenTimetableTitle: return "widget.intent.openTimetable.title"
        case .intentOpenTimetableDescription: return "widget.intent.openTimetable.description"
        case .intentTodayScheduleTitle: return "widget.intent.todaySchedule.title"
        case .intentTodayScheduleDescription: return "widget.intent.todaySchedule.description"
        case .intentNextClassTitle: return "widget.intent.nextClass.title"
        case .intentNextClassDescription: return "widget.intent.nextClass.description"
        case .intentRefreshScheduleTitle: return "widget.intent.refreshSchedule.title"
        case .intentRefreshScheduleParameterEnabled: return "widget.intent.refreshSchedule.parameter.enabled"
        case .intentConfigurationTitle: return "widget.intent.configuration.title"

        case .liveEnds: return "widget.live.ends"
        case .livePercentCompleteSuffix: return "widget.live.percentCompleteSuffix"

        case .commonNow: return "widget.common.now"
        case .commonNext: return "widget.common.next"
        case .commonUntil: return "widget.common.until"
        case .commonNoClasses: return "widget.common.noClasses"
        case .commonNoClassesToday: return "widget.common.noClassesToday"
        case .commonEnjoyFreeDay: return "widget.common.enjoyFreeDay"
        case .commonToday: return "widget.common.today"
        case .commonThisWeek: return "widget.common.thisWeek"
        case .commonWeek: return "widget.common.week"
        case .commonClasses: return "widget.common.classes"
        case .commonMoreSuffix: return "widget.common.moreSuffix"

        case .configTitle: return "widget.config.title"
        case .configDescription: return "widget.config.description"
        case .configViewTypeTitle: return "widget.config.viewType.title"
        case .configViewTypeToday: return "widget.config.viewType.today"
        case .configViewTypeWeek: return "widget.config.viewType.week"
        case .configShowOnlineStatusTitle: return "widget.config.showOnlineStatus.title"
        }
    }

    // Helper for theme names by id
    static func themeName(for id: String) -> String {
        switch id {
        case "default":    return LocalizedString.themeNameDefault.localized
        case "ocean":      return LocalizedString.themeNameOcean.localized
        case "sunset":     return LocalizedString.themeNameSunset.localized
        case "forest":     return LocalizedString.themeNameForest.localized
        case "lavender":   return LocalizedString.themeNameLavender.localized
        case "cherry":     return LocalizedString.themeNameCherry.localized
        case "midnight":   return LocalizedString.themeNameMidnight.localized
        case "monochrome": return LocalizedString.themeNameMonochrome.localized
        default:           return LocalizedString.themeNameDefault.localized
        }
    }

    var localized: String {
            NSLocalizedString(self.key, bundle: .main, comment: "")
        }

    var resource: LocalizedStringResource {
            LocalizedStringResource(String.LocalizationValue(self.key), table: nil, bundle: .main)
        }
}
