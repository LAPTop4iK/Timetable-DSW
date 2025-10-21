//
//  PremiumFeature.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 21/10/2025.
//


import Foundation

// MARK: - Premium Features

enum PremiumFeature: String, CaseIterable, Codable, Sendable {
    case teachersTab = "teachers_tab"
    case subjectsTab = "subjects_tab"
    case advancedFilters = "advanced_filters"
    case exportSchedule = "export_schedule"
    case customThemes = "custom_themes"

    var displayName: String {
        switch self {
        case .teachersTab: return "Teachers Section"
        case .subjectsTab: return "Subjects Section"
        case .advancedFilters: return "Advanced Filters"
        case .exportSchedule: return "Export Schedule"
        case .customThemes: return "Custom Themes"
        }
    }

    var description: String {
        switch self {
        case .teachersTab:
            return "Browse and view teacher schedules"
        case .subjectsTab:
            return "Browse and view subject details"
        case .advancedFilters:
            return "Advanced filtering options"
        case .exportSchedule:
            return "Export your schedule to calendar"
        case .customThemes:
            return "Customize app appearance"
        }
    }

    var icon: String {
        switch self {
        case .teachersTab: return "person.2.fill"
        case .subjectsTab: return "book.fill"
        case .advancedFilters: return "line.3.horizontal.decrease.circle.fill"
        case .exportSchedule: return "square.and.arrow.up.fill"
        case .customThemes: return "paintbrush.fill"
        }
    }
}

// MARK: - Premium Access

struct PremiumAccess: Sendable {
    let isPremium: Bool
    let status: PremiumStatus
    let expiresAt: Date?

    var timeRemaining: TimeInterval? {
        guard case .temporaryPremium(let expiresAt) = status else {
            return nil
        }
        let remaining = expiresAt.timeIntervalSince(Date())
        return remaining > 0 ? remaining : 0
    }

    var formattedTimeRemaining: String? {
        guard let remaining = timeRemaining else { return nil }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60

        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }

    static func from(appState: AppState) -> PremiumAccess {
        let expiresAt: Date?
        if case .temporaryPremium(let date) = appState.premiumStatus {
            expiresAt = date
        } else {
            expiresAt = nil
        }

        return PremiumAccess(
            isPremium: appState.premiumStatus.isPremium,
            status: appState.premiumStatus,
            expiresAt: expiresAt
        )
    }

    func hasAccess(to feature: PremiumFeature) -> Bool {
        return isPremium
    }
}
