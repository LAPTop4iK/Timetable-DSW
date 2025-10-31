//
//  TeachersViewModel.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Combine
import Foundation

@MainActor
final class TeachersViewModel: ObservableObject {
    // MARK: - Types

    enum TeacherFilter: Int, CaseIterable {
        case current
        case all
    }

    // MARK: - Configuration

    struct Configuration {
        struct Constants {
            // Константы если понадобятся
        }

        static let constants = Constants()
    }

    // MARK: - Published Properties

    @Published var searchText = ""
    @Published var allTeachers: [Teacher] = []
    @Published var currentPeriodTeachers: [Teacher]?
    @Published var selectedFilter: TeacherFilter = .current
    
    // MARK: - Computed Properties

    var hasFilterOptions: Bool {
        currentPeriodTeachers != nil
    }

    var filteredTeachers: [Teacher] {
        let baseTeachers: [Teacher]
        if selectedFilter == .current, let currentTeachers = currentPeriodTeachers {
            baseTeachers = currentTeachers
        } else {
            baseTeachers = allTeachers
        }

        guard !searchText.isEmpty else {
            return baseTeachers
        }

        return baseTeachers.filter { teacher in
            matchesSearchText(teacher)
        }
    }
    
    private func matchesSearchText(_ teacher: Teacher) -> Bool {
        teacher.displayName.localizedCaseInsensitiveContains(searchText) ||
        (teacher.email?.localizedCaseInsensitiveContains(searchText) ?? false)
    }
    
    // MARK: - Public Methods

    func updateTeachers(_ teachers: [Teacher], currentPeriod: [Teacher]? = nil) {
        allTeachers = teachers.sorted { $0.displayName < $1.displayName }
        currentPeriodTeachers = currentPeriod?.sorted { $0.displayName < $1.displayName }

        // Reset filter to current if current period teachers are available, otherwise set to all
        if currentPeriodTeachers != nil {
            selectedFilter = .current
        } else {
            selectedFilter = .all
        }
    }
}