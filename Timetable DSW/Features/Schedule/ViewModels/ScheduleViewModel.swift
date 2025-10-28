//
//  ScheduleViewModel.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import Combine
import Foundation

@MainActor
final class ScheduleViewModel: ObservableObject {
    // MARK: - Configuration
    
    struct Configuration {
        struct Constants {
            // Константы если понадобятся
        }
        
        static let constants = Constants()
    }
    
    // MARK: - Published Properties
    
    @Published var navigation = WeekNavigationController()
    @Published var selectedTeacherId: Int?
    
    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    weak var appViewModel: AppViewModel?
    weak var parametersService: FeatureFlagParametersService?
    lazy var interstitialCooldown: InterstitialCooldownManager = {
        InterstitialCooldownManager(configuration: .weekSwitch(parametersService: parametersService))
    }()

    // MARK: - Computed Properties
    
    var selectedTeacher: Teacher? {
        guard let teacherId = selectedTeacherId,
              let scheduleData = appViewModel?.scheduleData else {
            return nil
        }
        return scheduleData.teachers.first { $0.id == teacherId }
    }
    
    // MARK: - Initialization
    
    init() {
        setupNavigationObserver()
    }
    
    private func setupNavigationObserver() {
        navigation.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Teacher Selection

    func showTeacherDetail(teacherId: Int) {
        selectedTeacherId = teacherId
    }

    // MARK: - Week Navigation with Ads

    func handleWeekChange(coordinator: AdCoordinator?) async {
        interstitialCooldown.recordAction()

        guard interstitialCooldown.shouldShowAd() else { return }

        do {
            try await coordinator?.loadAd(type: .interstitial)
            try await coordinator?.showAd(type: .interstitial)
            interstitialCooldown.recordAdShown()
        } catch {
            print("[ScheduleViewModel] Failed to show interstitial: \(error)")
        }
    }
}