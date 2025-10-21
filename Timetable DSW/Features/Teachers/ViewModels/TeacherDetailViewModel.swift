//
//  TeacherDetailViewModel.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Combine
import Foundation

@MainActor
final class TeacherDetailViewModel: ObservableObject {
    // MARK: - Configuration
    
    struct Configuration {
        struct Constants {
            // Константы если понадобятся
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Published Properties
    
    @Published var navigation = WeekNavigationController()
    
    // MARK: - Properties
    
    let teacher: Teacher
    let eventsProvider: EventsProviderProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(teacher: Teacher) {
        self.teacher = teacher
        self.eventsProvider = TeacherEventsProvider(teacher: teacher)
        
        setupNavigationObserver()
    }
    
    private func setupNavigationObserver() {
        navigation.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}