import SwiftUI

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
    case settingsCacheStatus
    case settingsClearCache
    case settingsClearCacheMessage
    case settingsVersion
    case settingsAbout
    case settingsEvents
    case settingsLastUpdated
    case settingsNever
    case settingsPleaseSelectGroup

    // Tabs
    case tabsSchedule
    case tabsTeachers
    case tabsSettings
    case tabsSubjects   // NEW

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

        // Subjects (NEW)
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
        case .settingsCacheStatus: return String(localized: "settings.cacheStatus")
        case .settingsClearCache: return String(localized: "settings.clearCache")
        case .settingsClearCacheMessage: return String(localized: "settings.clearCacheMessage")
        case .settingsVersion: return String(localized: "settings.version")
        case .settingsAbout: return String(localized: "settings.about")
        case .settingsEvents: return String(localized: "settings.events")
        case .settingsLastUpdated: return String(localized: "settings.lastUpdated")
        case .settingsNever: return String(localized: "settings.never")
        case .settingsPleaseSelectGroup: return String(localized: "settings.pleaseSelectGroup")

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

            // MARK: NEW: Support / Contact
        case .settingsContactTitle:         return String(localized: "settings.contact.title")
        case .settingsSupportSectionTitle:  return String(localized: "settings.support.sectionTitle")
        case .settingsSupportFooter:        return String(localized: "settings.support.footer")

            // MARK: NEW: Contact actions
        case .contactActionReportProblem:   return String(localized: "contact.action.reportProblem")
        case .contactActionRequestFeature:  return String(localized: "contact.action.requestFeature")

            // MARK: NEW: Mail / system
        case .mailUnavailableTitle:         return String(localized: "mail.unavailable.title")
        case .mailUnavailableMessage:       return String(localized: "mail.unavailable.message")
        case .mailCopyAddress:              return String(localized: "mail.copyAddress")

            // MARK: NEW: Email subjects
        case .contactEmailSubjectBug:       return String(localized: "contact.email.subject.bug")
        case .contactEmailSubjectFeature:   return String(localized: "contact.email.subject.feature")

            // MARK: NEW: Email body headers
        case .contactEmailBodyBugHeader:      return String(localized: "contact.email.body.bugHeader")
        case .contactEmailBodyFeatureHeader:  return String(localized: "contact.email.body.featureHeader")

            // MARK: NEW: Email info labels
        case .contactEmailInfoApp:         return String(localized: "contact.email.info.app")
        case .contactEmailInfoiOS:         return String(localized: "contact.email.info.ios")
        case .contactEmailInfoDevice:      return String(localized: "contact.email.info.device")
        case .contactEmailInfoLocale:      return String(localized: "contact.email.info.locale")
        case .contactEmailInfoGroup:       return String(localized: "contact.email.info.group")
        case .contactEmailInfoDate:        return String(localized: "contact.email.info.date")

        case .contactEmailBodyAdditionalInfo: return String(localized: "contact.email.body.additionalInfo")
        case .contactEmailBodyDetailsTitle:   return String(localized: "contact.email.body.detailsTitle")
        }
    }
}
