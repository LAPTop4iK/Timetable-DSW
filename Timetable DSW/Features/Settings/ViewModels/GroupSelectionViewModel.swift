//
//  GroupSelectionViewModel.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Combine
import Foundation

@MainActor
final class GroupSelectionViewModel: ObservableObject {
    // MARK: - Configuration
    
    struct Configuration {
        struct Constants {
            // Константы если понадобятся
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Published Properties
    
    @Published var searchText = ""
    @Published var isRefreshing = false
    @Published var allGroups: [GroupInfo] = []
    
    // MARK: - Properties
    
    weak var appViewModel: AppViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var filteredGroups: [GroupInfo] {
        guard !searchText.isEmpty else {
            return allGroups
        }
        
        return allGroups.filter { group in
            matchesSearchText(group)
        }
    }
    
    private func matchesSearchText(_ group: GroupInfo) -> Bool {
        group.displayName.localizedCaseInsensitiveContains(searchText) ||
        group.faculty.localizedCaseInsensitiveContains(searchText) ||
        group.program.localizedCaseInsensitiveContains(searchText) ||
        group.id.description.localizedCaseInsensitiveContains(searchText)
    }
    
    var isLoading: Bool {
        appViewModel?.isLoadingGroups ?? false
    }
    
    // MARK: - Public Methods
    
    func setupWithAppViewModel(_ appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        
        appViewModel.$groups
            .assign(to: &$allGroups)
        
        Task {
            await appViewModel.loadGroupsIfNeeded()
        }
    }
    
    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        await appViewModel?.loadGroups()
    }
}