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
    @Environment(\.featureFlagService) private var featureFlagService
    @Environment(\.adCoordinator) private var coordinator
    @Environment(\.bottomInsetService) private var bottomInsetService
    @EnvironmentObject var appStateService: DefaultAppStateService

    @State private var showingContactDialog = false
    @State private var showingMailComposer = false
    @State private var showingMailUnavailableAlert = false
    @State private var pendingMailSubject = ""
    @State private var pendingMailBody = ""

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            Form {
                groupSection
                cacheSection
                awardSection
                contactSection
                aboutSection
                debugSection
            }
            .navigationTitle(LocalizedString.settingsTitle.localized)
            .onAppear { viewModel.appViewModel = appViewModel }
            .safeAreaInset(edge: .bottom) {
                AppColor.clear.color(for: colorScheme)
                    .frame(height: bottomInsetService?.bottomInset ?? 78)
            }
        }
        .sheet(isPresented: $viewModel.showingGroupSelection) { groupSelectionSheet }
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
    }

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
        } header: {
            Text(LocalizedString.settingsGroupSettings.localized)
        }
    }

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

    private var awardSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await coordinator?.showAd(type: .rewardedInterstitial)
                        appStateService.grantTemporaryPremium(duration: 3600)
                    } catch {
                        print("Failed to show ad: \(error)")
                    }
                }
            } label: {
                HStack {
                    AppIcon.lockOpen.image()
                        .font(AppTypography.title3.font)
                        .themedForeground(.header, colorScheme: colorScheme)

                    Text(LocalizedString.settingsDeveloperAction.localized)
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
            Text(LocalizedString.settingsDeveloperSectionTitle.localized)
        } footer: {
            Text(LocalizedString.settingsDeveloperFooter.localized)
                .foregroundAppColor(.secondaryText, colorScheme: colorScheme)
        }
        .preloadAds(.rewardedInterstitial, coordinator: coordinator)
    }

    private var contactSection: some View {
        Section {
            Button {
                showingContactDialog = true
            } label: {
                HStack {
                    AppIcon.envelope.image()
                        .font(AppTypography.title3.font)
                        .themedForeground(.header, colorScheme: colorScheme)

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

    private var aboutSection: some View {
        Section {
            infoRow(label: LocalizedString.settingsVersion.localized, value: AppInfo.versionString)
        } header: {
            Text(LocalizedString.settingsAbout.localized)
        }
    }

    @ViewBuilder
    // SettingsView: добавь секцию
    private var debugSection: some View {
        if featureFlagService.isEnabled(.showDebugMenu) == true {
            Section {
                NavigationLink("🐛 Debug Menu") {
                        DebugMenuScreen(
                            featureFlagService: featureFlagService,
                            appStateService: appStateService,
                        )
                    // новый не-модальный контейнер
                }
                NavigationLink("🧪 Ads Debug") {
                    AdsDebugScreen()
                }
            }
        }
    }


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
                Task { try? await coordinator?.showAd(type: .interstitial) }
            }
        )
        .onAppear { selectionVM.setupWithAppViewModel(appViewModel) }
        .preloadAds(.interstitial, coordinator: coordinator)
    }

    private var gradientColors: [Color] {
        GradientStyle.header.colors(for: colorScheme)
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
}
