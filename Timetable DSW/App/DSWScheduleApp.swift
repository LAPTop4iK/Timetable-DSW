//
//  DSWScheduleApp.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


// ===== FILE: Timetable DSW/App/DSWScheduleApp.swift ===== (UPDATED)
import SwiftUI

@main
struct DSWScheduleApp: App {
    // MARK: - Properties

    @StateObject private var appViewModel: AppViewModel
    @StateObject private var appStateService: DefaultAppStateService
    @StateObject private var featureFlagService: DefaultFeatureFlagService

    // AdCoordinator - не ObservableObject, поэтому @State
    @State private var adCoordinator: AdMobCoordinator

    // MARK: - Initialization

    init() {
        // 1️⃣ Создаем базовые зависимости (не ObservableObject)
        let networkManager = NetworkManager()
        let cacheManager = CacheManager()
        let repository = ScheduleRepository(
            networkManager: networkManager,
            cacheManager: cacheManager
        )

        // 2️⃣ Создаем сервисы как ObservableObject
        let featureFlags = DefaultFeatureFlagService(networkManager: networkManager)
        let appState = DefaultAppStateService()
        let viewModel = AppViewModel(repository: repository)

        // 3️⃣ Оборачиваем в StateObject
        _appViewModel = StateObject(wrappedValue: viewModel)
        _appStateService = StateObject(wrappedValue: appState)
        _featureFlagService = StateObject(wrappedValue: featureFlags)

        // 4️⃣ Создаем AdCoordinator используя уже созданные сервисы
        // ✅ Правильно: используем те же экземпляры, что и в StateObject
        let coordinator = AdMobCoordinator.makeForProduction(
            featureFlagService: featureFlags,
            appStateService: appState
        )

        #if DEBUG
        coordinator.setTestDevices(["abe4cf7d005b0f028298ebf7aafd7e17"])
        #endif

        _adCoordinator = State(wrappedValue: coordinator)
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
                .environmentObject(appStateService)
                .environmentObject(featureFlagService)
                .adCoordinator(adCoordinator)
        }
    }
}

// MARK: - Environment Extension (если нужен прямой доступ)

extension EnvironmentValues {
    var featureFlagService: FeatureFlagService {
        get { self[FeatureFlagServiceKey.self] }
        set { self[FeatureFlagServiceKey.self] = newValue }
    }
    
    var appStateService: AppStateService {
        get { self[AppStateServiceKey.self] }
        set { self[AppStateServiceKey.self] = newValue }
    }
}

private struct FeatureFlagServiceKey: EnvironmentKey {
    static let defaultValue: FeatureFlagService = DefaultFeatureFlagService()
}

private struct AppStateServiceKey: EnvironmentKey {
    static let defaultValue: AppStateService = DefaultAppStateService()
}
