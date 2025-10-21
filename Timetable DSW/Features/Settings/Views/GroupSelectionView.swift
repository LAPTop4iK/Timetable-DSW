//
//  GroupSelectionView.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI

struct GroupSelectionView: View {
    // MARK: - Configuration
    
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let spacing: AppSpacing = .large
            let progressScale: CGFloat = 1.2
            let listRowInsets = EdgeInsets(
                top: AppSpacing.xs.value,
                leading: AppSpacing.large.value,
                bottom: AppSpacing.xs.value,
                trailing: AppSpacing.large.value
            )
            let progressScaleRefresh: CGFloat = 0.8
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Properties
    
    @StateObject var viewModel: GroupSelectionViewModel
    let onSelectGroup: (GroupInfo) -> Void
    
    // MARK: - Environment
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Dependencies
    
    private let hapticService: HapticFeedbackService
    
    // MARK: - Initialization
    
    init(
        viewModel: GroupSelectionViewModel,
        onSelectGroup: @escaping (GroupInfo) -> Void,
        hapticService: HapticFeedbackService = DefaultHapticFeedbackService()
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onSelectGroup = onSelectGroup
        self.hapticService = hapticService
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle(LocalizedString.groupsSelect.localized)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $viewModel.searchText, prompt: LocalizedString.groupsSearch.localized)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        cancelButton
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        refreshButton
                    }
                }
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.allGroups.isEmpty {
            loadingView
        } else if viewModel.allGroups.isEmpty {
            emptyStateView
        } else if viewModel.filteredGroups.isEmpty {
            noResultsView
        } else {
            groupsList
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: Configuration.constants.spacing.value) {
            ProgressView()
                .scaleEffect(Configuration.constants.progressScale)
            Text(LocalizedString.groupsLoading.localized)
                .font(AppTypography.subheadline.font)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            LocalizedString.groupsNoAvailable.localized,
            systemImage: AppIcon.listBullet.systemName,
            description: Text(LocalizedString.groupsPullToRefresh.localized)
        )
    }
    
    private var noResultsView: some View {
        ContentUnavailableView(
            LocalizedString.groupsNoFound.localized,
            systemImage: AppIcon.magnifyingGlass.systemName,
            description: Text(LocalizedString.groupsAdjustSearch.localized)
        )
    }
    
    private var groupsList: some View {
        List(viewModel.filteredGroups) { group in
            Button(action: {
                selectGroup(group)
            }) {
                GroupRow(group: group)
            }
            .listRowInsets(Configuration.constants.listRowInsets)
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Toolbar Buttons
    
    private var cancelButton: some View {
        Button(LocalizedString.generalCancel.localized) { dismiss() }
            .themedForeground(.header, colorScheme: colorScheme)
    }
    
    private var refreshButton: some View {
        Button(action: {
            Task { await viewModel.refresh() }
        }) {
            if viewModel.isRefreshing {
                ProgressView()
                    .scaleEffect(Configuration.constants.progressScaleRefresh)
            } else {
                AppIcon.arrowClockwise.image()
                    .themedForeground(.header, colorScheme: colorScheme)
            }
        }
        .disabled(viewModel.isRefreshing)
    }
    
    // MARK: - Actions
    
    private func selectGroup(_ group: GroupInfo) {
        hapticService.impact(style: .light)
        onSelectGroup(group)
        dismiss()
    }
}
