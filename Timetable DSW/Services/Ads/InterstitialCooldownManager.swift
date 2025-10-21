//
//  InterstitialCooldownManager.swift
//  Timetable DSW
//
//  Created for optimized ad placement with cooldown mechanism
//

import Foundation

@MainActor
final class InterstitialCooldownManager {
    // MARK: - Configuration

    struct Configuration {
        let cooldownInterval: TimeInterval
        let actionsBeforeShow: Int

        static let weekSwitch = Configuration(
            cooldownInterval: 300, // 5 minutes
            actionsBeforeShow: 3   // Show after every 3 week switches
        )
    }

    // MARK: - Properties

    private let configuration: Configuration
    private var lastShowTime: Date?
    private var actionCounter: Int = 0

    // MARK: - Initialization

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: - Public Methods

    func shouldShowAd() -> Bool {
        let timePassed = checkTimeCooldown()
        let actionsPassed = checkActionCounter()

        return timePassed && actionsPassed
    }

    func recordAction() {
        actionCounter += 1
    }

    func recordAdShown() {
        lastShowTime = Date()
        actionCounter = 0
    }

    func reset() {
        lastShowTime = nil
        actionCounter = 0
    }

    // MARK: - Private Methods

    private func checkTimeCooldown() -> Bool {
        guard let lastShow = lastShowTime else {
            return true
        }

        let elapsed = Date().timeIntervalSince(lastShow)
        return elapsed >= configuration.cooldownInterval
    }

    private func checkActionCounter() -> Bool {
        return actionCounter >= configuration.actionsBeforeShow
    }
}
