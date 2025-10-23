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
    case settingsWidgetsTitle

    // Tabs
    case tabsSchedule
    case tabsTeachers
    case tabsSettings
    case tabsSubjects

    // Error
    case errorTitle
    case errorInvalidURL
    case errorInvalidResponse
    case errorServer

    // Days
    case daysMonday
    case daysTuesday
    case daysWednesday
    case daysThursday
    case daysFriday
    case daysSaturday
    case daysSunday

    // MARK: - NEW: Support / Contact
    case settingsContactTitle
    case settingsSupportSectionTitle
    case settingsSupportFooter

    // MARK: - NEW: Developer Support
    case settingsDeveloperSectionTitle
    case settingsDeveloperAction
    case settingsDeveloperFooter

    // MARK: - NEW: Contact actions
    case contactActionReportProblem
    case contactActionRequestFeature

    // MARK: - NEW: Mail / system
    case mailUnavailableTitle
    /// uses %@ placeholder for email
    case mailUnavailableMessage
    case mailCopyAddress

    // MARK: - NEW: Email subjects
    case contactEmailSubjectBug
    case contactEmailSubjectFeature

    // MARK: - NEW: Email body headers
    case contactEmailBodyBugHeader
    case contactEmailBodyFeatureHeader

    // MARK: - NEW: Email info labels
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

    // MARK: - Settings Premium
    case settingsPremiumActive

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

    case widgetAvailable
    case widgetConfigure
    case widgetHowToAdd
    case widgetNeverUpdated
    case widgetTroubleshooting
    case widgetSettingsTitle
    case widgetTitle
    case widgetEnabled
    case widgetAccess
}

extension LocalizedString {
    var localized: String {
        switch self {
        // General
        case .generalCancel: return String(localized: "general.cancel")
        case .generalDone: return String(localized: "general.done")
        case .generalToday: return String(localized: "general.today")
        case .generalRetry: return String(localized: "general.retry")
        case .generalRefresh: return String(localized: "general.refresh")
        case .generalOnline: return String(localized: "general.online")
        case .generalOffline: return String(localized: "general.offline")
        case .generalCancelled: return String(localized: "general.cancelled")
        case .generalLoading: return String(localized: "general.loading")

        // Greeting
        case .greetingMorning: return String(localized: "greeting.morning")
        case .greetingAfternoon: return String(localized: "greeting.afternoon")
        case .greetingEvening: return String(localized: "greeting.evening")
        case .greetingNight: return String(localized: "greeting.night")

        // Schedule
        case .scheduleTitle: return String(localized: "schedule.title")
        case .scheduleSelectDate: return String(localized: "schedule.selectDate")
        case .scheduleHasClasses: return String(localized: "schedule.hasClasses")
        case .scheduleOnlineOnly: return String(localized: "schedule.onlineOnly")
        case .scheduleNoClasses: return String(localized: "schedule.noClasses")
        case .scheduleEnjoyFreeTime: return String(localized: "schedule.enjoyFreeTime")
        case .scheduleLoading: return String(localized: "schedule.loading")
        case .scheduleLastUpdated: return String(localized: "schedule.lastUpdated")

        // Groups
        case .groupsSelect: return String(localized: "groups.select")
        case .groupsSelected: return String(localized: "groups.selected")
        case .groupsNoSelection: return String(localized: "groups.noSelection")
        case .groupsSearch: return String(localized: "groups.search")
        case .groupsLoading: return String(localized: "groups.loading")
        case .groupsNoAvailable: return String(localized: "groups.noAvailable")
        case .groupsNoFound: return String(localized: "groups.noFound")
        case .groupsPullToRefresh: return String(localized: "groups.pullToRefresh")
        case .groupsAdjustSearch: return String(localized: "groups.adjustSearch")

        // Teachers
        case .teachersTitle: return String(localized: "teachers.title")
        case .teachersSearch: return String(localized: "teachers.search")
        case .teachersLoading: return String(localized: "teachers.loading")
        case .teachersNoFound: return String(localized: "teachers.noFound")
        case .teachersClasses: return String(localized: "teachers.classes")
        case .teachersNoData: return String(localized: "teachers.noData")
        case .teachersLoadScheduleFirst: return String(localized: "teachers.loadScheduleFirst")

        // Subjects
        case .subjectsTitle: return String(localized: "subjects.title")
        case .subjectsSearch: return String(localized: "subjects.search")
        case .subjectsLoading: return String(localized: "subjects.loading")
        case .subjectsNoFound: return String(localized: "subjects.noFound")
        case .subjectsClasses: return String(localized: "subjects.classes")
        case .subjectsNoData: return String(localized: "subjects.noData")
        case .subjectsLoadScheduleFirst: return String(localized: "subjects.loadScheduleFirst")
        case .subjectsStats: return String(localized: "subjects.stats")
        case .subjectsTotal: return String(localized: "subjects.total")
        case .subjectsPast: return String(localized: "subjects.past")
        case .subjectsUpcoming: return String(localized: "subjects.upcoming")
        case .subjectsLectures: return String(localized: "subjects.lectures")
        case .subjectsExercises: return String(localized: "subjects.exercises")
        case .subjectsLaboratories: return String(localized: "subjects.laboratories")
        case .subjectsGradingType: return String(localized: "subjects.gradingType")

        // Settings
        case .settingsTitle: return String(localized: "settings.title")
        case .settingsGroupSettings: return String(localized: "settings.groupSettings")
        case .settingsThemeSectionTitle: return String(localized: "settings.themeSection.title")
        case .settingsThemeSectionHeader: return String(localized: "settings.themeSection.header")
        case .settingsThemeSectionFooter: return String(localized: "settings.themeSection.footer")
        case .settingsCacheStatus: return String(localized: "settings.cacheStatus")
        case .settingsClearCache: return String(localized: "settings.clearCache")
        case .settingsClearCacheMessage: return String(localized: "settings.clearCacheMessage")
        case .settingsVersion: return String(localized: "settings.version")
        case .settingsAbout: return String(localized: "settings.about")
        case .settingsEvents: return String(localized: "settings.events")
        case .settingsLastUpdated: return String(localized: "settings.lastUpdated")
        case .settingsNever: return String(localized: "settings.never")
        case .settingsPleaseSelectGroup: return String(localized: "settings.pleaseSelectGroup")
        case .settingsWidgetsTitle: return String(localized: "settings.widgetsTitle")


        // Tabs
        case .tabsSchedule: return String(localized: "tabs.schedule")
        case .tabsTeachers: return String(localized: "tabs.teachers")
        case .tabsSettings: return String(localized: "tabs.settings")
        case .tabsSubjects: return String(localized: "tabs.subjects")

        // Error
        case .errorTitle: return String(localized: "error.title")
        case .errorInvalidURL: return String(localized: "error.invalidURL")
        case .errorInvalidResponse: return String(localized: "error.invalidResponse")
        case .errorServer: return String(localized: "error.server")

        // Days
        case .daysMonday: return String(localized: "days.monday")
        case .daysTuesday: return String(localized: "days.tuesday")
        case .daysWednesday: return String(localized: "days.wednesday")
        case .daysThursday: return String(localized: "days.thursday")
        case .daysFriday: return String(localized: "days.friday")
        case .daysSaturday: return String(localized: "days.saturday")
        case .daysSunday: return String(localized: "days.sunday")

        // Support / Contact
        case .settingsContactTitle: return String(localized: "settings.contact.title")
        case .settingsSupportSectionTitle: return String(localized: "settings.support.sectionTitle")
        case .settingsSupportFooter: return String(localized: "settings.support.footer")

        // Developer Support
        case .settingsDeveloperSectionTitle: return String(localized: "settings.developer.sectionTitle")
        case .settingsDeveloperAction: return String(localized: "settings.developer.action")
        case .settingsDeveloperFooter: return String(localized: "settings.developer.footer")

        // Contact actions
        case .contactActionReportProblem: return String(localized: "contact.action.reportProblem")
        case .contactActionRequestFeature: return String(localized: "contact.action.requestFeature")

        // Mail / system
        case .mailUnavailableTitle: return String(localized: "mail.unavailable.title")
        case .mailUnavailableMessage: return String(localized: "mail.unavailable.message")
        case .mailCopyAddress: return String(localized: "mail.copyAddress")

        // Email subjects
        case .contactEmailSubjectBug: return String(localized: "contact.email.subject.bug")
        case .contactEmailSubjectFeature: return String(localized: "contact.email.subject.feature")

        // Email body headers
        case .contactEmailBodyBugHeader: return String(localized: "contact.email.body.bugHeader")
        case .contactEmailBodyFeatureHeader: return String(localized: "contact.email.body.featureHeader")

        // Email info labels
        case .contactEmailInfoApp: return String(localized: "contact.email.info.app")
        case .contactEmailInfoiOS: return String(localized: "contact.email.info.ios")
        case .contactEmailInfoDevice: return String(localized: "contact.email.info.device")
        case .contactEmailInfoLocale: return String(localized: "contact.email.info.locale")
        case .contactEmailInfoGroup: return String(localized: "contact.email.info.group")
        case .contactEmailInfoDate: return String(localized: "contact.email.info.date")

        case .contactEmailBodyAdditionalInfo: return String(localized: "contact.email.body.additionalInfo")
        case .contactEmailBodyDetailsTitle: return String(localized: "contact.email.body.detailsTitle")

        // Premium
        case .premiumFeatureTitle: return String(localized: "premium.feature.title")
        case .premiumTapToUnlock: return String(localized: "premium.tapToUnlock")
        case .premiumActive: return String(localized: "premium.active")
        case .premiumThankYou: return String(localized: "premium.thankYou")
        case .premiumEnjoyFeatures: return String(localized: "premium.enjoyFeatures")
        case .premiumTimeRemaining: return String(localized: "premium.timeRemaining")
        case .premiumWatchOrPurchase: return String(localized: "premium.watchOrPurchase")
        case .premiumUnlockTitle: return String(localized: "premium.unlock.title")
        case .premiumGetAccess: return String(localized: "premium.getAccess")
        case .premiumWatchAdButton: return String(localized: "premium.watchAd.button")
        case .premiumPurchaseButton: return String(localized: "premium.purchase.button")
        case .premiumUnlocked: return String(localized: "premium.unlocked")
        case .premiumMaybeLater: return String(localized: "premium.maybeLater")
        case .premiumCalculating: return String(localized: "premium.calculating")
        case .premiumRemaining: return String(localized: "premium.remaining")

        // Settings Premium
        case .settingsPremiumActive: return String(localized: "settings.premium.active")

        // Debug
        case .debugTools: return String(localized: "debug.tools")
        case .debugDone: return String(localized: "debug.done")
        case .debugResetAllFlags: return String(localized: "debug.resetAllFlags")
        case .debugResetConfirm: return String(localized: "debug.resetConfirm")
        case .debugCancel: return String(localized: "debug.cancel")
        case .debugPremiumStatus: return String(localized: "debug.premiumStatus")
        case .debugPremiumControls: return String(localized: "debug.premiumControls")
        case .debugGrantPermanentPremium: return String(localized: "debug.grantPermanentPremium")
        case .debugGrant1HourPremium: return String(localized: "debug.grant1HourPremium")
        case .debugRevokePremium: return String(localized: "debug.revokePremium")
        case .debugFeatureFlags: return String(localized: "debug.featureFlags")
        case .debugFlagsFooter: return String(localized: "debug.flagsFooter")
        case .debugActions: return String(localized: "debug.actions")
        case .debugResetToDefault: return String(localized: "debug.resetToDefault")
        case .debugSyncFromRemote: return String(localized: "debug.syncFromRemote")
        case .debugShowDetails: return String(localized: "debug.showDetails")
        case .debugHideDetails: return String(localized: "debug.hideDetails")

        // Debug Menu (Extended)
        case .debugMenuTitle: return String(localized: "debug.menu.title")
        case .debugActionResult: return String(localized: "debug.actionResult")
        case .debugOK: return String(localized: "debug.ok")
        case .debugConfirm: return String(localized: "debug.confirm")
        case .debugFree: return String(localized: "debug.free")
        case .debugPremiumLabel: return String(localized: "debug.premiumLabel")
        case .debugTrial: return String(localized: "debug.trial")
        case .debugStatus: return String(localized: "debug.status")
        case .debugExpires: return String(localized: "debug.expires")
        case .debugGrantPremium: return String(localized: "debug.grantPremium")
        case .debugGrantTrial1h: return String(localized: "debug.grantTrial1h")
        case .debugRevokePremiumLabel: return String(localized: "debug.revokePremiumLabel")
        case .debugPremiumManagement: return String(localized: "debug.premiumManagement")
        case .debugFeatureFlagsTitle: return String(localized: "debug.featureFlagsTitle")
        case .debugLocalOverrides: return String(localized: "debug.localOverrides")
        case .debugLastSynced: return String(localized: "debug.lastSynced")
        case .debugActionsTitle: return String(localized: "debug.actionsTitle")
        case .debugSyncFromServer: return String(localized: "debug.syncFromServer")
        case .debugClearAllData: return String(localized: "debug.clearAllData")
        case .debugStatistics: return String(localized: "debug.statistics")
        case .debugAdsWatched: return String(localized: "debug.adsWatched")
        case .debugLastAd: return String(localized: "debug.lastAd")
        case .debugPremiumSince: return String(localized: "debug.premiumSince")
        case .debugAbout: return String(localized: "debug.about")
        case .debugEnvironment: return String(localized: "debug.environment")
        case .debugDebug: return String(localized: "debug.debug")
        case .debugRelease: return String(localized: "debug.release")
        case .debugBuild: return String(localized: "debug.build")
        case .debugOnlyInDebugBuilds: return String(localized: "debug.onlyInDebugBuilds")
        case .debugResetToDefaultLabel: return String(localized: "debug.resetToDefaultLabel")
        case .debugResetAllFlagsLabel: return String(localized: "debug.resetAllFlagsLabel")
        case .debugRevokePremiumQuestion: return String(localized: "debug.revokePremiumQuestion")
        case .debugResetAllFlagsQuestion: return String(localized: "debug.resetAllFlagsQuestion")
        case .debugClearAllDataQuestion: return String(localized: "debug.clearAllDataQuestion")
        case .debugConfirmActionQuestion: return String(localized: "debug.confirmActionQuestion")
        case .debugWillRemovePremium: return String(localized: "debug.willRemovePremium")
        case .debugWillResetAllFlags: return String(localized: "debug.willResetAllFlags")
        case .debugWillResetEverything: return String(localized: "debug.willResetEverything")
        case .debugAreYouSure: return String(localized: "debug.areYouSure")
        case .debugPremiumGranted: return String(localized: "debug.premiumGranted")
        case .debugTemporaryPremiumGranted: return String(localized: "debug.temporaryPremiumGranted")
        case .debugPremiumRevoked: return String(localized: "debug.premiumRevoked")
        case .debugAllFlagsReset: return String(localized: "debug.allFlagsReset")
        case .debugAllDataCleared: return String(localized: "debug.allDataCleared")
        case .debugFlagResetTemplate: return String(localized: "debug.flagResetTemplate")
        case .debugSyncFailedTemplate: return String(localized: "debug.syncFailedTemplate")

        // Performance Monitor
        case .perfMonitorTitle: return String(localized: "perfMonitor.title")
        case .perfMonitorClear: return String(localized: "perfMonitor.clear")
        case .perfMonitorExport: return String(localized: "perfMonitor.export")
        case .perfMonitorExportedEvents: return String(localized: "perfMonitor.exportedEvents")
        case .perfMonitorMetrics: return String(localized: "perfMonitor.metrics")
        case .perfMonitorTotalEvents: return String(localized: "perfMonitor.totalEvents")
        case .perfMonitorAverageDuration: return String(localized: "perfMonitor.averageDuration")
        case .perfMonitorSlowestEvent: return String(localized: "perfMonitor.slowestEvent")
        case .perfMonitorFastestEvent: return String(localized: "perfMonitor.fastestEvent")
        case .perfMonitorFilterByCategory: return String(localized: "perfMonitor.filterByCategory")
        case .perfMonitorCategory: return String(localized: "perfMonitor.category")
        case .perfMonitorAll: return String(localized: "perfMonitor.all")
        case .perfMonitorEvents: return String(localized: "perfMonitor.events")
        case .perfMonitorNoEventsRecorded: return String(localized: "perfMonitor.noEventsRecorded")

        // Ads Debug
        case .adsDebugTitle: return String(localized: "adsDebug.title")
        case .adsDebugAdaptiveBanner: return String(localized: "adsDebug.adaptiveBanner")
        case .adsDebugBannerAd: return String(localized: "adsDebug.bannerAd")
        case .adsDebugBannerDescription: return String(localized: "adsDebug.bannerDescription")
        case .adsDebugNativeAd: return String(localized: "adsDebug.nativeAd")
        case .adsDebugNativeDescription: return String(localized: "adsDebug.nativeDescription")
        case .adsDebugLoad: return String(localized: "adsDebug.load")
        case .adsDebugShow: return String(localized: "adsDebug.show")
        case .adsDebugReadyToShow: return String(localized: "adsDebug.readyToShow")
        case .adsDebugInterstitialAd: return String(localized: "adsDebug.interstitialAd")
        case .adsDebugInterstitialDescription: return String(localized: "adsDebug.interstitialDescription")
        case .adsDebugRewardedAd: return String(localized: "adsDebug.rewardedAd")
        case .adsDebugRewardedDescription: return String(localized: "adsDebug.rewardedDescription")
        case .adsDebugRewardedInterstitial: return String(localized: "adsDebug.rewardedInterstitial")
        case .adsDebugRewardedInterstitialDescription: return String(localized: "adsDebug.rewardedInterstitialDescription")
        case .adsDebugPreload: return String(localized: "adsDebug.preload")
        case .adsDebugAppOpenAd: return String(localized: "adsDebug.appOpenAd")
        case .adsDebugAppOpenDescription: return String(localized: "adsDebug.appOpenDescription")
        case .adsDebugDeveloperTools: return String(localized: "adsDebug.developerTools")
        case .adsDebugLaunchAdInspector: return String(localized: "adsDebug.launchAdInspector")
        case .adsDebugAdInspectorDescription: return String(localized: "adsDebug.adInspectorDescription")
        case .adsDebugEventLog: return String(localized: "adsDebug.eventLog")
        case .adsDebugNoEventsYet: return String(localized: "adsDebug.noEventsYet")
        case .adsDebugClearLog: return String(localized: "adsDebug.clearLog")

        // Ad Loading
        case .adLoadingText: return String(localized: "adLoading.text")
        case .adLoadingFailed: return String(localized: "adLoading.failed")
        case .adLoadingRetry: return String(localized: "adLoading.retry")

        // Theme Settings (NEW)
        case .themeSettingsTitle: return String(localized: "themeSettings.title")
        case .themeSettingsAppearanceTitle: return String(localized: "themeSettings.appearance.title")
        case .themeSettingsColorThemeTitle: return String(localized: "themeSettings.colorTheme.title")

        case .appearanceSystem: return String(localized: "appearance.system")
        case .appearanceLight:  return String(localized: "appearance.light")
        case .appearanceDark:   return String(localized: "appearance.dark")
        case .appearanceDescSystem: return String(localized: "appearance.description.system")
        case .appearanceDescLight:  return String(localized: "appearance.description.light")
        case .appearanceDescDark:   return String(localized: "appearance.description.dark")

        case .themeNameDefault:    return String(localized: "theme.name.default")
        case .themeNameOcean:      return String(localized: "theme.name.ocean")
        case .themeNameSunset:     return String(localized: "theme.name.sunset")
        case .themeNameForest:     return String(localized: "theme.name.forest")
        case .themeNameLavender:   return String(localized: "theme.name.lavender")
        case .themeNameCherry:     return String(localized: "theme.name.cherry")
        case .themeNameMidnight:   return String(localized: "theme.name.midnight")

        case .widgetSettingsTitle:   return String(localized: "widget.settings.title")
        case .widgetTitle:     return String(localized: "widget.title")
        case .widgetEnabled:   return String(localized: "widget.enabled")
        case .widgetAccess: return String(localized: "widget.access")
        case .themeNameMonochrome: return String(localized: "theme.name.monochrome")
        case .widgetTroubleshooting: return String(localized: "widget.troubleshooting")
        case .widgetNeverUpdated: return String(localized: "widget.never.updated")
        case .widgetHowToAdd: return String(localized: "widget.how.to.add")
        case .widgetConfigure: return String(localized: "widget.configure")
        case .widgetAvailable: return String(localized: "widget.available")
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
}
