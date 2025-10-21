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
    
    // MARK: - Computed Properties
    
    var filteredTeachers: [Teacher] {
        guard !searchText.isEmpty else {
            return allTeachers
        }
        
        return allTeachers.filter { teacher in
            matchesSearchText(teacher)
        }
    }
    
    private func matchesSearchText(_ teacher: Teacher) -> Bool {
        teacher.displayName.localizedCaseInsensitiveContains(searchText) ||
        (teacher.email?.localizedCaseInsensitiveContains(searchText) ?? false)
    }
    
    // MARK: - Public Methods
    
    func updateTeachers(_ teachers: [Teacher]) {
        allTeachers = teachers.sorted { $0.displayName < $1.displayName }
    }
}