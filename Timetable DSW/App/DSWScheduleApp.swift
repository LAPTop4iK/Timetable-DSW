//
//  DSWScheduleApp.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 18/10/2025.
//


import SwiftUI
import AppTrackingTransparency 

@main
struct DSWScheduleApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // MARK: - Properties

    @StateObject private var appViewModel: AppViewModel
    @StateObject private var appStateService: DefaultAppStateService
    @StateObject private var featureFlagService: DefaultFeatureFlagService
    @StateObject private var parametersService: FeatureFlagParametersService
    @StateObject private var bottomInsetService: DefaultBottomInsetService
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var toastManager = ToastManager()
    @StateObject private var successFeedback = SuccessFeedbackSystem()
    @StateObject private var storeKitManager: StoreKitManager

    // AdCoordinator - не ObservableObject, поэтому @State
    @State private var adCoordinator: AdMobCoordinator

    // ⬇️ Добавлено: следим за жизненным циклом сцены и флаг от повторных вызовов
    @Environment(\.scenePhase) private var scenePhase
    @State private var didAskATTThisSession = false

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
        let parameters = FeatureFlagParametersService()
        let featureFlags = DefaultFeatureFlagService(networkManager: networkManager)
        let appState = DefaultAppStateService(parametersService: parameters)
        let viewModel = AppViewModel(repository: repository)

        // 3️⃣ BottomInsetService
        let bottomInset = DefaultBottomInsetService(
            appStateService: appState,
            featureFlagService: featureFlags,
            parametersService: parameters
        )

        // 4️⃣ Оборачиваем в StateObject
        _appViewModel = StateObject(wrappedValue: viewModel)
        _appStateService = StateObject(wrappedValue: appState)
        _featureFlagService = StateObject(wrappedValue: featureFlags)
        _parametersService = StateObject(wrappedValue: parameters)
        _bottomInsetService = StateObject(wrappedValue: bottomInset)

        // StoreKit Manager
        let storeKit = StoreKitManager(appStateService: appState)
        _storeKitManager = StateObject(wrappedValue: storeKit)

        // 5️⃣ Создаем AdCoordinator используя уже созданные сервисы
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
                .environmentObject(parametersService)
                .environmentObject(bottomInsetService)
                .environmentObject(themeManager)
                .environmentObject(toastManager)
                .environmentObject(successFeedback)
                .environment(\.featureFlagParameters, parametersService)
                .environment(\.bottomInsetService, bottomInsetService)
                .environment(\.themeManager, themeManager)
                .environment(\.storeKitManager, storeKitManager)
                .adCoordinator(adCoordinator)
                .toastManager()
                .onChange(of: scenePhase) { _, phase in
                    WidgetAccessSync.sync(
                        appStateService: appStateService,
                        adCoordinator: adCoordinator
                    )
                    guard phase == .active else { return }
                    guard !didAskATTThisSession else {
                        Task { @MainActor in
                            let status = ATTrackingManager.trackingAuthorizationStatus
                            adCoordinator.start(afterATT: status)
                        }
                        return
                    }
                    didAskATTThisSession = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Task { @MainActor in
                            let status = await ATTPermissionManager.requestIfNeeded()
                            adCoordinator.start(afterATT: status)
                        }
                    }
                }
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
