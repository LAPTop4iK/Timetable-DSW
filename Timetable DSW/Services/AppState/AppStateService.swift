//
//  AppStateService.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//


// ===== FILE: Timetable DSW/Services/AppState/AppStateService.swift =====
import Foundation
import Combine

// MARK: - Core Models (Sendable для Swift Concurrency)

enum PremiumStatus: Codable, Sendable, Equatable {
    case free
    case premium
    case temporaryPremium(expiresAt: Date)

    var isPremium: Bool {
        switch self {
        case .free:
            return false
        case .premium:
            return true
        case .temporaryPremium(let expiresAt):
            return Date() < expiresAt
        }
    }
}

struct AppState: Codable, Sendable, Equatable {
    var premiumStatus: PremiumStatus
    var premiumPurchaseDate: Date?
    var lastAdWatchedDate: Date?
    var totalAdsWatched: Int

    static let `default` = AppState(
        premiumStatus: .free,
        premiumPurchaseDate: nil,
        lastAdWatchedDate: nil,
        totalAdsWatched: 0
    )
}

// MARK: - Protocol (@MainActor для SwiftUI)

// MARK: - Configuration

struct AppStateConfiguration {
    static let temporaryPremiumDuration: TimeInterval = 3600 // 1 hour
    static let secondsInHour: Int = 3600 // For time formatting
    static let stateStorageKey = "app_state"
}

// MARK: - Storage Layer (Single Responsibility: Persistence)

actor AppStateStorage {
    private let userDefaults: UserDefaults
    private let storageKey: String

    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = AppStateConfiguration.stateStorageKey
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    func loadState() -> AppState {
        guard let data = userDefaults.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(AppState.self, from: data) else {
            return .default
        }
        return state
    }

    func saveState(_ state: AppState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}

// MARK: - Premium Expiration Monitor (Single Responsibility: Time-based checks)

@MainActor
final class PremiumExpirationMonitor {
    private var timer: Timer?
    private let onExpiration: () -> Void

    init(onExpiration: @escaping () -> Void) {
        self.onExpiration = onExpiration
    }

    func scheduleCheck(for expirationDate: Date) {
        cancelScheduledCheck()

        let timeInterval = expirationDate.timeIntervalSince(Date())
        guard timeInterval > 0 else {
            onExpiration()
            return
        }

        timer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: false
        ) { [weak self] _ in
            self?.onExpiration()
        }
    }

    func cancelScheduledCheck() {
        timer?.invalidate()
        timer = nil
    }

    // deinit не может быть @MainActor, поэтому делаем cleanup синхронно
    nonisolated deinit {
        // Timer.invalidate() может быть вызвано из любого потока
        // Для безопасности проверяем, что timer существует
        Task { @MainActor [timer] in
            timer?.invalidate()
        }
    }
}

// MARK: - Premium Status Validator (Single Responsibility: Validation logic)

struct PremiumStatusValidator {
    func validateAndUpdate(_ state: AppState) -> AppState {
        var updatedState = state

        guard case .temporaryPremium(let expiresAt) = state.premiumStatus else {
            return state
        }

        if Date() >= expiresAt {
            updatedState.premiumStatus = .free
        }

        return updatedState
    }

    func isExpired(_ status: PremiumStatus) -> Bool {
        guard case .temporaryPremium(let expiresAt) = status else {
            return false
        }
        return Date() >= expiresAt
    }
}

// MARK: - Main Service (@MainActor для SwiftUI)

@MainActor
final class DefaultAppStateService: ObservableObject, AppStateService {

    // MARK: - Dependencies

    private let storage: AppStateStorage
    private let validator = PremiumStatusValidator()

    // MARK: - Published State

    @Published private(set) var state: AppState {
        didSet {
            Task {
                await storage.saveState(state)
            }
            updateExpirationMonitor()
        }
    }

    // MARK: - Computed Properties

    var statePublisher: AnyPublisher<AppState, Never> {
        $state.eraseToAnyPublisher()
    }

    var premiumStatus: PremiumStatus {
        state.premiumStatus
    }

    var isPremium: Bool {
        state.premiumStatus.isPremium
    }

    private lazy var expirationMonitor: PremiumExpirationMonitor = {
            PremiumExpirationMonitor { [weak self] in
                self?.handlePremiumExpiration()
            }
        }()

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.storage = AppStateStorage(userDefaults: userDefaults)

        // Временная инициализация для создания monitor
        self.state = .default

        // Загружаем реальное состояние
        Task {
            await loadInitialState()
        }
    }

    // MARK: - Public Methods

    func grantPremium() {
        state.premiumStatus = .premium
        state.premiumPurchaseDate = Date()
    }

    func grantTemporaryPremium(
        duration: TimeInterval = AppStateConfiguration.temporaryPremiumDuration
    ) {
        let expiresAt = Date().addingTimeInterval(duration)
        state.premiumStatus = .temporaryPremium(expiresAt: expiresAt)
    }

    func revokePremium() {
        state.premiumStatus = .free
        state.premiumPurchaseDate = nil
    }

    func recordAdWatched() {
        state.lastAdWatchedDate = Date()
        state.totalAdsWatched += 1
    }

    // MARK: - Private Methods

    private func loadInitialState() async {
        let loadedState = await storage.loadState()
        state = validator.validateAndUpdate(loadedState)
    }

    private func handlePremiumExpiration() {
        guard validator.isExpired(state.premiumStatus) else { return }
        state.premiumStatus = .free
    }

    private func updateExpirationMonitor() {
        guard case .temporaryPremium(let expiresAt) = state.premiumStatus else {
            expirationMonitor.cancelScheduledCheck()
            return
        }

        expirationMonitor.scheduleCheck(for: expiresAt)
    }
}
