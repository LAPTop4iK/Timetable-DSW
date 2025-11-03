//
//  SettingsView.swift
//  Timetable DSW
//

import SwiftUI
import Combine
import Foundation

struct SettingsView: View {
    struct Configuration: ComponentConfiguration {
        struct Constants {
            let spacing: AppSpacing = .medium
            let iconSize: CGFloat = AppDimensions.avatarSmall.value
            let iconCornerRadius: AppCornerRadius = .small
            let iconImageSize: CGFloat = 14
            let backgroundOpacity: Double = 0.15
            let captionSpacing: AppSpacing = .xxs

            let supportEmail: String = "dev.mikita.laptsionak@gmail.com"
        }
        static let constants = Constants()
    }

    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var featureFlagService: DefaultFeatureFlagService
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.adCoordinator) private var coordinator
    @Environment(\.bottomInsetService) private var bottomInsetService
    @EnvironmentObject var appStateService: DefaultAppStateService
    @Environment(\.storeKitManager) private var storeKitManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var successFeedback: SuccessFeedbackSystem

    @State private var showingContactDialog = false
    @State private var showingMailComposer = false
    @State private var showingMailUnavailableAlert = false
    @State private var pendingMailSubject = ""
    @State private var pendingMailBody = ""
    @State private var timeRemaining = ""
    @State private var timer: Timer?

    // Модальные состояния
    @State private var showThemeSheet = false
    @State private var showWidgetSheet = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            Form {
                groupSection
                themeRow
                widgetRow
                cacheSection
                awardSection
                contactSection
                aboutSection
                debugSection
            }
            .navigationTitle(LocalizedString.settingsTitle.localized)
            .accessibilityIdentifier("settings_root_view")
            .onAppear { viewModel.appViewModel = appViewModel }
            .safeAreaInset(edge: .bottom) {
                AppColor.clear.color(for: colorScheme)
                    .frame(height: bottomInsetService?.bottomInset ?? 78)
            }
            #if DEBUG
            .measurePerformance(name: "SettingsView", category: .viewAppear)
            #endif
        }
        .sheet(isPresented: $viewModel.showingGroupSelection) { groupSelectionSheet }
        // Модалка: Тема
        .sheet(isPresented: $showThemeSheet) {
            ThemeSettingsContainer()
        }
        // Модалка: Виджеты
        .sheet(isPresented: $showWidgetSheet) {
            WidgetSettingsContainer()
        }
        .sheet(isPresented: $showingMailComposer) {
            MailComposerView(
                recipients: [Configuration.constants.supportEmail],
                subject: pendingMailSubject,
                body: pendingMailBody
            ) { _ in showingMailComposer = false }
        }
        .alert(LocalizedString.mailUnavailableTitle.localized, isPresented: $showingMailUnavailableAlert) {
            Button(LocalizedString.mailCopyAddress.localized) {
                UIPasteboard.general.string = Configuration.constants.supportEmail
            }
            Button(LocalizedString.generalCancel.localized, role: .cancel) {}
        } message: {
            Text(String(format: LocalizedString.mailUnavailableMessage.localized,
                        Configuration.constants.supportEmail))
        }
        .confirmationDialog(
            LocalizedString.settingsContactTitle.localized,
            isPresented: $showingContactDialog,
            titleVisibility: .visible
        ) {
            Button(LocalizedString.contactActionReportProblem.localized) { openMail(kind: .bug) }
            Button(LocalizedString.contactActionRequestFeature.localized) { openMail(kind: .feature) }
            Button(LocalizedString.generalCancel.localized, role: .cancel) {}
        }
        .alert(LocalizedString.settingsClearCache.localized, isPresented: $viewModel.showingClearCacheAlert) {
            Button(LocalizedString.generalCancel.localized, role: .cancel) {}
            Button(LocalizedString.settingsClearCache.localized, role: .destructive) {
                Task { await viewModel.clearCache() }
            }
        } message: {
            Text(LocalizedString.settingsClearCacheMessage.localized)
        }
        .siriStyleBorder(isActive: successFeedback.showBorderEffect)
        .onAppear {
            updateTimeRemaining()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Тема (модально)
    private var themeRow: some View {
        Section {
            Button {
                showThemeSheet = true
            } label: {
                HStack(spacing: Configuration.constants.spacing.value) {
                    iconView(icon: .paintpaletteFill, colors: gradientColors)
                    VStack(alignment: .leading, spacing: Configuration.constants.captionSpacing.value) {
                        Text(LocalizedString.settingsThemeSectionTitle.localized)
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                        Text(currentThemeName)
                            .font(AppTypography.body.font)
                            .foregroundAppColor(.primaryText, colorScheme: colorScheme)
                    }
                    Spacer()
                    AppIcon.chevronRight.image()
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("settings_theme_button")
        } header: {
            Text(LocalizedString.settingsThemeSectionHeader.localized)
        } footer: {
            Text(LocalizedString.settingsThemeSectionFooter.localized)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }

    private var currentThemeName: String {
        let theme = themeManager.currentTheme(for: colorScheme)
        return "\(theme.name) • \(themeManager.appearanceMode.displayName)"
    }

    // MARK: - Виджеты (модально)
    private var widgetRow: some View {
        Section {
            Button {
                showWidgetSheet = true
            } label: {
                HStack(spacing: Configuration.constants.spacing.value) {
                    iconView(icon: .squareGrid2x2Fill, colors: gradientColors)
                    VStack(alignment: .leading, spacing: Configuration.constants.captionSpacing.value) {
                        Text(LocalizedString.widgetHomeTitle.localized)
                            .font(AppTypography.body.font)
                            .foregroundAppColor(.primaryText, colorScheme: colorScheme)
                    }
                    Spacer()
                    AppIcon.chevronRight.image()
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } header: {
            Text(LocalizedString.widgetTitle.localized)
        } footer: {
            Text(LocalizedString.widgetHomeSubtitle.localized)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }

    // MARK: - Группы
    private var groupSection: some View {
        Section {
            Button(action: { viewModel.showingGroupSelection = true }) {
                HStack(spacing: Configuration.constants.spacing.value) {
                    iconView(icon: .person3Fill, colors: gradientColors)
                    VStack(alignment: .leading, spacing: Configuration.constants.captionSpacing.value) {
                        Text(LocalizedString.groupsSelected.localized)
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                        Text(appViewModel.selectedGroupName ?? LocalizedString.groupsNoSelection.localized)
                            .font(AppTypography.body.font)
                            .foregroundAppColor(appViewModel.selectedGroupName != nil ? .primaryText : .secondaryText, colorScheme: colorScheme)
                    }
                    Spacer()
                    AppIcon.chevronRight.image()
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                }
            }
            .accessibilityIdentifier("settings_group_selection_button")
        } header: {
            Text(LocalizedString.settingsGroupSettings.localized)
        }
    }

    // MARK: - Кэш
    private var cacheSection: some View {
        Section {
            if let data = appViewModel.scheduleData {
                infoRow(label: LocalizedString.settingsEvents.localized, value: "\(data.groupSchedule.count)")
                infoRow(label: LocalizedString.teachersTitle.localized, value: "\(data.teachers.count)")
            }
            Button(role: .destructive) {
                viewModel.showingClearCacheAlert = true
            } label: {
                HStack {
                    AppIcon.trash.image().foregroundAppColor(.error, colorScheme: colorScheme)
                    Text(LocalizedString.settingsClearCache.localized)
                }
            }
        } header: {
            Text(LocalizedString.settingsCacheStatus.localized)
        }
    }

    // MARK: - Награда/реклама
    private var awardSection: some View {
        let premiumAccess = PremiumAccess.from(appState: appStateService.state)
        let isPremium = premiumAccess.isPremium
        let hasAds = !(coordinator?.isAdDisabled() ?? true)

        return Section {
            // Always show: Tip button (Hotdog for developer)
            tipButton(isPremium: isPremium)

            // If ads are enabled and not premium - show premium purchase button
            if hasAds && !isPremium {
                premiumPurchaseButton
            }

            // If ads are enabled and not premium - show ad button
            if hasAds && !isPremium {
                watchAdButton(premiumAccess: premiumAccess)
            }

            // If ads are enabled and not premium - show restore purchases button
            if hasAds && !isPremium {
                restorePurchasesButton
            }

            // Show premium status if already premium
            if isPremium {
                premiumStatusRow(premiumAccess: premiumAccess)
            }
        } header: {
            Text(LocalizedString.settingsDeveloperSectionTitle.localized)
        } footer: {
            if hasAds {
                Text(String(format: LocalizedString.settingsDeveloperFooter.localized,
                            DurationFormatter.localizedShortDuration(from: appStateService.tempAwareDuration)))
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }
        }
        .preloadAds(.rewardedInterstitial, coordinator: coordinator)
    }

    // MARK: - Award Section Components

    private func tipButton(isPremium: Bool) -> some View {
        Button {
            guard let manager = storeKitManager else { return }
            Task {
                let result = await manager.purchase(.tip)
                switch result {
                case .success:
                    successFeedback.celebrate(
                        message: LocalizedString.iapPurchaseSuccess.localized,
                        icon: "gift.fill",
                        toastManager: toastManager
                    )
                case .cancelled:
                    break
                case .pending:
                    break
                case .failed(let error):
                    print("Tip purchase failed: \(error)")
                }
            }
        } label: {
            HStack {
                AppIcon.giftFill.image()
                    .font(AppTypography.title3.font)
                    .themedForeground(.primary, colorScheme: colorScheme)

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.iapTipTitle.localized)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    if let productInfo = storeKitManager?.getProductInfo(for: .tip) {
                        Text(productInfo.displayPrice)
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    }
                }

                Spacer()

                AppIcon.chevronRight.image()
                    .font(AppTypography.caption.font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    private func watchAdButton(premiumAccess: PremiumAccess) -> some View {
        Button {
            Task {
                do {
                    try await coordinator?.showAd(type: .rewardedInterstitial)
                    appStateService.grantTemporaryPremium()

                    successFeedback.celebrate(
                        message: LocalizedString.premiumUnlocked.localized,
                        icon: "crown.fill",
                        toastManager: toastManager
                    )
                    updateTimeRemaining()
                } catch {
                    print("Failed to show ad: \(error)")
                }
            }
        } label: {
            HStack {
                AppIcon.lockOpen.image()
                    .font(AppTypography.title3.font)
                    .themedForeground(.primary, colorScheme: colorScheme)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: LocalizedString.settingsDeveloperAction.localized,
                                DurationFormatter.localizedShortDuration(from: appStateService.tempAwareDuration)))
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    if case .temporaryPremium = premiumAccess.status {
                        Text(timeRemaining.isEmpty ? "Calculating..." : timeRemaining)
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    }
                }

                Spacer()

                AppIcon.chevronRight.image()
                    .font(AppTypography.caption.font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    private var premiumPurchaseButton: some View {
        Button {
            guard let manager = storeKitManager else { return }
            Task {
                let result = await manager.purchase(.premium)
                switch result {
                case .success:
                    successFeedback.celebrate(
                        message: LocalizedString.premiumUnlocked.localized,
                        icon: "crown.fill",
                        toastManager: toastManager
                    )
                case .cancelled:
                    break
                case .pending:
                    break
                case .failed(let error):
                    print("Premium purchase failed: \(error)")
                }
            }
        } label: {
            HStack {
                rowIcon(.crownFill)

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedString.iapPremiumTitle.localized)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    if let productInfo = storeKitManager?.getProductInfo(for: .premium) {
                        Text(productInfo.displayPrice)
                            .font(AppTypography.caption.font)
                            .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                    }
                }

                Spacer()

                AppIcon.chevronRight.image()
                    .font(AppTypography.caption.font)
                    .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    private var restorePurchasesButton: some View {
        Button {
            guard let manager = storeKitManager else { return }
            Task {
                do {
                    try await manager.restorePurchases()
                    appStateService.grantPremium()
                    successFeedback.celebrate(
                        message: LocalizedString.premiumUnlocked.localized,
                        icon: "crown.fill",
                        toastManager: toastManager
                    )
                } catch {
                    print("Failed to restore purchases: \(error)")
                }
            }
        } label: {
            HStack {
                rowIcon(.arrowClockwise)

                Text(LocalizedString.iapRestorePurchases.localized)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    private func premiumStatusRow(premiumAccess: PremiumAccess) -> some View {
        HStack {
            rowIcon(.crownFill)

            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedString.settingsPremiumActive.localized)
                    .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                if case .temporaryPremium = premiumAccess.status {
                    Text(timeRemaining)
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    // MARK: - Контакты
    private var contactSection: some View {
        Section {
            Button {
                showingContactDialog = true
            } label: {
                HStack {
                    AppIcon.envelope.image()
                        .font(AppTypography.title3.font)
                        .themedForeground(.primary, colorScheme: colorScheme)

                    Text(LocalizedString.settingsContactTitle.localized)
                        .foregroundAppColor(.primaryText, colorScheme: colorScheme)

                    Spacer()

                    AppIcon.chevronRight.image()
                        .font(AppTypography.caption.font)
                        .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        } header: {
            Text(LocalizedString.settingsSupportSectionTitle.localized)
        } footer: {
            Text(LocalizedString.settingsSupportFooter.localized)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
    }

    // MARK: - О приложении
    private var aboutSection: some View {
        Section {
            infoRow(label: LocalizedString.settingsVersion.localized, value: AppInfo.versionString)
        } header: {
            Text(LocalizedString.settingsAbout.localized)
        }
    }

    // MARK: - Debug
    @ViewBuilder
    private var debugSection: some View {
        #if DEBUG
        let isDebug = true
        #else
        let isDebug = false
        #endif

        if isDebug || featureFlagService.isEnabled(.showDebugMenu) {
            Section {
                NavigationLink("🐛 Debug Menu") {
                    DebugMenuScreen(
                        featureFlagService: featureFlagService,
                        appStateService: appStateService
                    )
                }

                NavigationLink("⚡️ Performance Monitor") {
                    PerformanceMonitorView()
                }

                NavigationLink("🧪 Ads Debug") {
                    AdsDebugScreen()
                }
            } header: {
                Text(LocalizedString.debugTools.localized)
            }
        }
    }

    // MARK: - Вспомогательные

    private func iconView(icon: AppIcon, colors: [Color]) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Configuration.constants.iconCornerRadius.value)
                .fill(
                    LinearGradient(
                        colors: colors.map { $0.opacity(Configuration.constants.backgroundOpacity) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: Configuration.constants.iconSize, height: Configuration.constants.iconSize)
            icon.image()
                .font(.system(size: Configuration.constants.iconImageSize))
                .foregroundStyle(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .accessibilityHidden(true)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
        .accessibilityElement(children: .combine)
    }

    private var groupSelectionSheet: some View {
        let selectionVM = GroupSelectionViewModel()
        return GroupSelectionView(
            viewModel: selectionVM,
            onSelectGroup: { group in
                viewModel.selectGroup(group)
                Task {
                    try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
                    try? await coordinator?.showAd(type: .interstitial)
                }
            }
        )
        .onAppear { selectionVM.setupWithAppViewModel(appViewModel) }
        .preloadAds(.interstitial, coordinator: coordinator)
    }

    private var gradientColors: [Color] {
        let theme = themeManager.currentTheme(for: colorScheme)
        return GradientStyle.primary.colors(for: colorScheme, theme: theme)
    }

    private var contactComposer: ContactComposer {
        ContactComposer(
            appInfoProvider: { (AppInfo.version, AppInfo.build) },
            deviceInfoProvider: { (DeviceInfo.iOSVersion, DeviceInfo.deviceIdentifier) },
            localeProvider: { Locale.current.identifier },
            selectedGroupProvider: { "\(appViewModel.groupId.description): " + (appViewModel.selectedGroupName ?? "")}
        )
    }

    private func openMail(kind: ContactComposer.Kind) {
        pendingMailSubject = contactComposer.subject(for: kind)
        pendingMailBody = contactComposer.body(for: kind)
        if MailComposerView.canSendMail { showingMailComposer = true } else { showingMailUnavailableAlert = true }
    }

    // MARK: - Premium Timer

    private func updateTimeRemaining() {
        let premiumAccess = PremiumAccess.from(appState: appStateService.state)

        guard case .temporaryPremium(let endDate) = premiumAccess.status else {
            timeRemaining = ""
            return
        }

        let now = Date()
        guard endDate > now else {
            timeRemaining = ""
            return
        }

        let interval = endDate.timeIntervalSince(now)
        let hours = Int(interval) / AppStateConfiguration.secondsInHour
        let minutes = (Int(interval) % AppStateConfiguration.secondsInHour) / 60
        let seconds = Int(interval) % 60

        if hours > 0 {
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeRemaining = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeRemaining()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func rowIcon(_ icon: AppIcon) -> some View {
        icon.image()
            .font(AppTypography.title3.font)
            .themedForeground(.primary, colorScheme: colorScheme)
            .frame(width: 24, height: 24, alignment: .center)
    }
}
