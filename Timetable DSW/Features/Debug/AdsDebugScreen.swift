//
//  AdsDebugScreen.swift
//  Timetable DSW
//
//  Created by Mikita Laptsionak on 20/10/2025.
//

import SwiftUI

struct AdsDebugScreen: View {
    @Environment(\.adCoordinator) private var coordinator
    @State private var logs: [LogEntry] = []
    @State private var isRewardedReady = false
    @State private var isInterstitialReady = false
    @State private var isRewardedInterstitialReady = false

    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let message: String

        var formattedTime: String {
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            return formatter.string(from: timestamp)
        }
    }

    var body: some View {
        List {
            bannerSection
            nativeSection
            interstitialSection
            rewardedSection
            rewardedInterstitialSection
            appOpenSection
            adInspectorSection
            logSection
        }
        .navigationTitle("🧪 Ads Debug")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updateReadyStates()
        }
    }

    // MARK: - Sections

    private var bannerSection: some View {
        Section {
            VStack(spacing: 12) {
                Text("Adaptive Banner")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Баннер с правильными размерами
                AdaptiveBannerView()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(8)
            }
            .padding(.vertical, 8)
        } header: {
            Label("Banner Ad", systemImage: "rectangle.3.group")
        } footer: {
            Text("Adaptive banner автоматически подстраивается под ширину экрана")
                .font(.caption2)
        }
    }

    private var nativeSection: some View {
        Section {
            VStack(spacing: 12) {
                Text("Банер Ad (Inline)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                NativeAdViewSui(style: .card)
//                NativeAdViewSui(style: .basic)
//                NativeAdViewSui(style: .banner)
//                NativeAdViewSui(style: .largeBanner)
            }

            .padding(.vertical, 8)
        } header: {
            Label("Native Ad", systemImage: "square.and.pencil")
        } footer: {
            Text("Native ad встраивается в контент с кастомным дизайном")
                .font(.caption2)
        }
        .withNativeAds()
    }

    private var interstitialSection: some View {
        Section {
            HStack(spacing: 16) {
                Button {
                    Task {
                        await loadAd(type: .interstitial)
                    }
                } label: {
                    Label("Load", systemImage: "arrow.down.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await showAd(type: .interstitial)
                    }
                } label: {
                    Label("Show", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isInterstitialReady)
            }

            if isInterstitialReady {
                Label("Ready to show", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        } header: {
            Label("Interstitial Ad", systemImage: "square.fill")
        } footer: {
            Text("Полноэкранная реклама, показывается между экранами")
                .font(.caption2)
        }
    }

    private var rewardedSection: some View {
        Section {
            HStack(spacing: 16) {
                Button {
                    Task {
                        await loadAd(type: .rewarded)
                    }
                } label: {
                    Label("Load", systemImage: "arrow.down.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await showAd(type: .rewarded)
                    }
                } label: {
                    Label("Show", systemImage: "gift.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isRewardedReady)
            }

            if isRewardedReady {
                Label("Ready to show", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        } header: {
            Label("Rewarded Ad", systemImage: "gift")
        } footer: {
            Text("Пользователь получает награду за просмотр")
                .font(.caption2)
        }
    }

    private var rewardedInterstitialSection: some View {
        Section {
            HStack(spacing: 16) {
                Button {
                    Task {
                        await loadAd(type: .rewardedInterstitial)
                    }
                } label: {
                    Label("Load", systemImage: "arrow.down.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await showAd(type: .rewardedInterstitial)
                    }
                } label: {
                    Label("Show", systemImage: "gift.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isRewardedInterstitialReady)
            }

            if isRewardedInterstitialReady {
                Label("Ready to show", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        } header: {
            Label("Rewarded Interstitial", systemImage: "gift.fill")
        } footer: {
            Text("Комбинация interstitial и rewarded")
                .font(.caption2)
        }
    }

    private var appOpenSection: some View {
        Section {
            HStack(spacing: 16) {
                Button {
                    Task {
                        await loadAd(type: .appOpen)
                    }
                } label: {
                    Label("Preload", systemImage: "arrow.down.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await showAd(type: .appOpen)
                    }
                } label: {
                    Label("Show", systemImage: "arrow.up.forward.app")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        } header: {
            Label("App Open Ad", systemImage: "app.badge")
        } footer: {
            Text("Показывается при возврате в приложение. Cooldown: 1 минута")
                .font(.caption2)
        }
    }

    private var adInspectorSection: some View {
        Section {
            Button {
                Task {
                    await coordinator?.presentAdInspector()
                    addLog("Ad Inspector opened")
                }
            } label: {
                Label("Launch Ad Inspector", systemImage: "magnifyingglass.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        } header: {
            Label("Developer Tools", systemImage: "wrench.and.screwdriver")
        } footer: {
            Text("Ad Inspector работает только с test device IDs")
                .font(.caption2)
        }
    }

    private var logSection: some View {
        Section {
            if logs.isEmpty {
                Text("No events yet")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ForEach(logs.reversed()) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(log.message)
                            .font(.caption)
                        Text(log.formattedTime)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if !logs.isEmpty {
                Button("Clear Log") {
                    logs.removeAll()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
        } header: {
            Label("Event Log", systemImage: "list.bullet.rectangle")
        }
    }

    // MARK: - Actions

    private func loadAd(type: AdType) async {
        guard let coordinator = coordinator else {
            addLog("❌ No coordinator available")
            return
        }

        addLog("⏳ Loading \(type)...")

        do {
            try await coordinator.loadAd(type: type)
            addLog("✅ \(type) loaded successfully")
            updateReadyStates()
        } catch {
            addLog("❌ Failed to load \(type): \(error.localizedDescription)")
        }
    }

    private func showAd(type: AdType) async {
        guard let coordinator = coordinator else {
            addLog("❌ No coordinator available")
            return
        }

        addLog("▶️ Showing \(type)...")

        do {
            try await coordinator.showAd(type: type)
            addLog("✅ \(type) shown successfully")
            updateReadyStates()
        } catch {
            addLog("❌ Failed to show \(type): \(error.localizedDescription)")
        }
    }

    private func updateReadyStates() {
        guard let coordinator = coordinator else { return }

        isInterstitialReady = coordinator.isAdReady(type: .interstitial)
        isRewardedReady = coordinator.isAdReady(type: .rewarded)
        isRewardedInterstitialReady = coordinator.isAdReady(type: .rewardedInterstitial)
    }

    private func addLog(_ message: String) {
        logs.append(LogEntry(timestamp: Date(), message: message))

        // Ограничиваем количество логов
        if logs.count > 50 {
            logs.removeFirst()
        }
    }
}

// MARK: - Preview

struct AdsDebugScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdsDebugScreen()
        }
    }
}
