import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Configuration

    struct Configuration {
        struct Constants {
            // Убрали константу neverText
        }

        static let constants = Constants()
    }

    // MARK: - Published Properties

    @Published var showingClearCacheAlert = false
    @Published var showingGroupSelection = false

    // MARK: - Properties

    weak var appViewModel: AppViewModel?

    // MARK: - Computed Properties

    var lastUpdatedText: String {
        guard let date = appViewModel?.lastUpdated else {
            return LocalizedString.settingsNever.localized // ← ИСПРАВЛЕНО
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Public Methods

    func selectGroup(_ group: GroupInfo) {
        appViewModel?.groupId = group.groupId
        showingGroupSelection = false

        Task {
            await appViewModel?.clearCache()
            await appViewModel?.loadSchedule()
        }
    }

    func clearCache() async {
        await appViewModel?.clearCache()
    }
}
